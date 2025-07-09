----------------------------------------------------------------------------------------------------
-- Fecha de entrega: 01-07-2025
-- Numero de grupo: 3
-- Materia: Bases de Datos Aplicada
-- Alumnos:
--   - Codina, Santiago Ivan - 44.391.352
--   - Santillan, Lautaro Ezequiel - 45.175.053
----------------------------------------------------------------------------------------------------

-- Usar la base de datos
USE Com2900G03;
GO

-- ************************************************************************************
-- ACLARACION: CUANDO SE PRUEBEN LOS IMPORTS MODIFICAR EL @FilePath AL CORRESPONDIENTE
-- ************************************************************************************

ALTER LOGIN sa WITH PASSWORD = 'OchoDel12!';
GO

SELECT name
     , is_disabled
     , type_desc
  FROM sys.sql_logins
 WHERE name = 'sa';

 ALTER LOGIN sa WITH PASSWORD = 'M1x3dMode!2025';
GO

ALTER LOGIN sa ENABLE;
GO

DECLARE @loginMode INT;
EXEC xp_instance_regread  
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'LoginMode',
    @loginMode OUTPUT;

SELECT @loginMode AS LoginMode;

/*USE master;
GO
ALTER SERVER ROLE bulkadmin ADD MEMBER [LA-BESTIA\santi];
GO
ALTER SERVER ROLE bulkadmin ADD MEMBER [MicrosoftAccount\santiagocodina@live.com.ar];
GO

ALTER DATABASE [Com2900G03] SET TRUSTWORTHY ON;
GO
USE Com2900G03;
CREATE CERTIFICATE Cert_BulkImport
  ENCRYPTION BY PASSWORD = 'StrongPass#1'
  WITH SUBJECT = 'Cert para BULK INSERT';
GO

ADD SIGNATURE TO OBJECT::socios.importarGrupoFamiliar
  BY CERTIFICATE Cert_BulkImport
  WITH PASSWORD = 'StrongPass#1';
GO

CREATE USER CertUser FROM CERTIFICATE Cert_BulkImport;
GRANT ADMINISTER BULK OPERATIONS TO CertUser;
GO

SELECT 
  CASE WHEN SUSER_SNAME() = 'sa' THEN 1 ELSE 0 END AS EsLoginSA;
  -- Lista todos los logins con sysadmin*/

/* SELECT servicename,
       service_account
  FROM sys.dm_server_services
 WHERE servicename LIKE 'SQL Server (%';  -- Filtra solo instancias

SELECT *
FROM OPENROWSET(
   BULK N'C:\Importar\dataImport\grupoFamiliar.csv',
   FORMAT = 'CSV',
   FIRSTROW = 2
) AS Data;

-- 1) En Com2900G03, “respaldar” el certificado a un fichero .cer
USE Com2900G03;
GO
BACKUP CERTIFICATE Cert_BulkImport
  TO FILE = 'C:\Temp\Cert_BulkImport.cer';
GO

-- 2) En master, crear un certificado a partir de ese fichero
USE master;
GO
CREATE CERTIFICATE Cert_BulkImport_Master
  FROM FILE = 'C:\Temp\Cert_BulkImport.cer';
GO

-- 3) Crear el login asociado al certificado en master
CREATE LOGIN CertLogin
  FROM CERTIFICATE Cert_BulkImport_Master;
GO

-- 4) Concederle el permiso de BULK INSERT
GRANT ADMINISTER BULK OPERATIONS TO CertLogin;
GO

SELECT servicename, service_account
  FROM sys.dm_server_services
  WHERE servicename LIKE 'SQL Server (%';

SELECT 
  rp.name AS RoleName, 
  mp.name AS MemberName 
FROM sys.server_role_members m
JOIN sys.server_principals rp ON m.role_principal_id = rp.principal_id
JOIN sys.server_principals mp ON m.member_principal_id = mp.principal_id
WHERE rp.name = 'bulkadmin';*/

/* SELECT SUSER_SNAME()      AS LoginActual,  
       ORIGINAL_LOGIN()   AS LoginOriginal,  
       SYSTEM_USER        AS UsuarioSQL;

	   ALTER SERVER ROLE bulkadmin ADD MEMBER [LA-BESTIA\santi];
GO*/

-- ************************************************************************************************
-- Procedimiento: socios.importarCategoriasSocio (1° ejecutar - FUNCIONA)
-- Descripción: Este procedimiento se encarga de importar y sincronizar las categorías de membresía de socios desde un archivo CSV.
-- Parámetros:
--   @FilePath NVARCHAR(255): Ruta completa del archivo CSV que contiene los datos de las categorías de socio.
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE socios.importarCategoriasSocio
    @FilePath NVARCHAR(255) -- Parámetro para la ruta del archivo CSV
AS
BEGIN
    SET NOCOUNT ON;
    -- Declaramos una variable para construir la consulta de BULK INSERT dinámicamente
    DECLARE @consultaSqlDinamica NVARCHAR(MAX);
    IF OBJECT_ID('tempdb..#StagingCategoriasSocio') IS NOT NULL
        DROP TABLE #StagingCategoriasSocio;
    -- Creamos la tabla temporal. Las columnas aquí deben coincidir
    CREATE TABLE #StagingCategoriasSocio (
        CategoriaSocioCsv NVARCHAR(15),      -- Corresponde a 'Categoria socio' del CSV
        ValorCuotaCsv DECIMAL(10, 2),       -- Corresponde a 'Valor cuota' del CSV
        VigenteHastaCsv NVARCHAR(20)        -- Corresponde a 'Vigente hasta' del CSV (NVARCHAR(20) para mayor seguridad)
    );
    -- Manejo de errores: Si algo sale mal, capturamos el error
    BEGIN TRY
        -- Construimos la sentencia BULK INSERT de forma dinámica.
        SET @consultaSqlDinamica = N'BULK INSERT #StagingCategoriasSocio
                                     FROM ''' + @FilePath + N'''
                                     WITH
                                     (
                                         FIRSTROW = 2,           -- Empezamos a leer desde la segunda fila (ignoramos el encabezado)
                                         FIELDTERMINATOR = '';'',  -- *** IMPORTANTE: Usa punto y coma (;) como delimitador ***
                                         ROWTERMINATOR = ''0x0a'', -- El final de cada fila se identifica con un salto de línea (LF).
                                                                  -- Si tu CSV fuera de Windows, podría ser ''0x0d0a'' (CRLF).
                                         TABLOCK                  -- Ayuda a optimizar la carga masiva bloqueando la tabla temporal
                                     );';
        
        -- Ejecutamos la consulta BULK INSERT que acabamos de construir
        EXEC sp_executesql @consultaSqlDinamica;
        -- MERGE nos permite insertar nuevas filas o actualizar existentes en un solo paso.
        MERGE socios.categoriaMembresiaSocio AS TablaDestino -- Nuestra tabla final donde queremos los datos
        USING (
            -- Realizamos las transformaciones necesarias desde los datos del CSV.
            SELECT
                st.CategoriaSocioCsv AS TipoCategoria,
                st.ValorCuotaCsv AS CostoMembresia,
                ISNULL(TRY_CONVERT(DATE, st.VigenteHastaCsv, 103), '2025-05-31') AS VigenciaHasta,
                -- Si el CSV no la provee, usaremos ese valor por defecto.
                1 AS EstadoCategoria -- Asumimos que las categorías importadas están activas
            FROM
                #StagingCategoriasSocio st
        ) AS TablaOrigen (tipo, costoMembresia, vigenciaHasta, estadoCategoriaSocio)
        -- Definimos las condiciones para saber si una fila ya existe en la tabla destino.
        -- En este caso, la clave de negocio para una categoría es su 'tipo'.
        ON (TablaDestino.tipo = TablaOrigen.tipo)
        -- Si la fila ya existe en la tabla destino (coincide por el 'tipo' de categoría)
        WHEN MATCHED THEN
            UPDATE SET
                TablaDestino.costoMembresia = TablaOrigen.costoMembresia,
                TablaDestino.vigenciaHasta = TablaOrigen.vigenciaHasta,
                TablaDestino.estadoCategoriaSocio = TablaOrigen.estadoCategoriaSocio
        -- Si la fila NO existe en la tabla destino (es una nueva categoría)
        WHEN NOT MATCHED THEN
            INSERT (tipo, costoMembresia, vigenciaHasta, estadoCategoriaSocio)
            VALUES (TablaOrigen.tipo, TablaOrigen.costoMembresia, TablaOrigen.vigenciaHasta, TablaOrigen.estadoCategoriaSocio);
        -- Mensaje de éxito al usuario
        PRINT '¡Proceso de importación de categorías de socio completado con éxito!';
    END TRY
    BEGIN CATCH
        DECLARE @MensajeError NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @SeveridadError INT = ERROR_SEVERITY();
        DECLARE @EstadoError INT = ERROR_STATE();
        -- Lanzamos el error capturado
        RAISERROR(@MensajeError, @SeveridadError, @EstadoError);
    END CATCH;
    -- Al finalizar, eliminamos la tabla temporal para liberar recursos
    IF OBJECT_ID('tempdb..#StagingCategoriasSocio') IS NOT NULL
        DROP TABLE #StagingCategoriasSocio;
END;
GO

-- CARGAR DATOS DEL CSV
EXEC socios.importarCategoriasSocio 
	@FilePath = 'C:\Importar\dataImport\tarifasCategoriaSocio.csv';
GO

-- VER DATOS CARGADOS
SELECT * FROM socios.categoriaMembresiaSocio;
GO

-- ************************************************************************************************
-- Procedimiento: actividades.importarDeportesDisponibles (2° ejecutar - FUNCIONA)
-- Descripción: Este procedimiento se encarga de importar y sincronizar los deportes disponibles desde un archivo CSV.         
-- Parámetros:
--   @FilePath NVARCHAR(255): Ruta completa del archivo CSV que contiene los datos.
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE actividades.importarDeportesDisponibles
    @FilePath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @consultaSqlDinamica NVARCHAR(MAX);
    IF OBJECT_ID('tempdb..#StagingDeportesDisponibles') IS NOT NULL
        DROP TABLE #StagingDeportesDisponibles;
    CREATE TABLE #StagingDeportesDisponibles (
        ActividadCsv NVARCHAR(50),           -- Corresponde a 'Actividad' del CSV
        ValorPorMesCsv DECIMAL(10, 2),       -- Corresponde a 'Valor por mes' del CSV
        VigenteHastaCsv NVARCHAR(20)         -- Corresponde a 'Vigente hasta' del CSV (NVARCHAR(20) para mayor seguridad)
    );

    BEGIN TRY
        SET @consultaSqlDinamica = N'BULK INSERT #StagingDeportesDisponibles
                                     FROM ''' + @FilePath + N'''
                                     WITH
                                     (
                                         FIRSTROW = 2,           -- Empezamos a leer desde la segunda fila (ignoramos el encabezado)
                                         FIELDTERMINATOR = '';'', -- *** IMPORTANTE: Usa punto y coma (;) como delimitador ***
                                         ROWTERMINATOR = ''0x0a'', -- El final de cada fila se identifica con un salto de línea (LF).
                                         TABLOCK                  -- Ayuda a optimizar la carga masiva bloqueando la tabla temporal
                                     );';
        EXEC sp_executesql @consultaSqlDinamica;
        PRINT 'BULK INSERT de deportes completado. Filas cargadas en #StagingDeportesDisponibles: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
        -- MERGE nos permite insertar nuevos deportes o actualizar existentes en un solo paso.
        MERGE actividades.deporteDisponible AS TablaDestino -- Nuestra tabla final donde queremos los datos
        USING (
            SELECT
                -- Corregimos 'Ajederez' a 'Ajedrez' aquí
                REPLACE(st.ActividadCsv, 'Ajederez', 'Ajedrez') AS DescripcionDeporte,
                st.ValorPorMesCsv AS CostoMensual,
                -- Usamos TRY_CONVERT para manejar posibles errores de formato de fecha.
                ISNULL(TRY_CONVERT(DATE, st.VigenteHastaCsv, 103), '2025-05-31') AS VigenciaHastaDeporte
            FROM
                #StagingDeportesDisponibles st -- Los datos que recién cargamos del CSV
        ) AS TablaOrigen (descripcion, costoPorMes, vigenciaHasta)
        -- Definimos las condiciones para saber si un deporte ya existe en la tabla destino.
        -- En este caso, la clave de negocio para un deporte es su 'descripcion'.
        ON (TablaDestino.descripcion = TablaOrigen.descripcion)
        -- Si la fila ya existe en la tabla destino (coincide por la 'descripcion' del deporte)
        WHEN MATCHED THEN
            UPDATE SET
                TablaDestino.costoPorMes = TablaOrigen.costoPorMes,
                TablaDestino.vigenciaHasta = TablaOrigen.vigenciaHasta
        -- Si la fila NO existe en la tabla destino (es un nuevo deporte)
        WHEN NOT MATCHED THEN
            INSERT (descripcion, costoPorMes, vigenciaHasta)
            VALUES (TablaOrigen.descripcion, TablaOrigen.costoPorMes, TablaOrigen.vigenciaHasta);
        PRINT 'Proceso de importacion de deportes disponibles completado con exito!';
    END TRY
    BEGIN CATCH
        DECLARE @MensajeError NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @SeveridadError INT = ERROR_SEVERITY();
        DECLARE @EstadoError INT = ERROR_STATE();
        RAISERROR(@MensajeError, @SeveridadError, @EstadoError);
    END CATCH;
    IF OBJECT_ID('tempdb..#StagingDeportesDisponibles') IS NOT NULL
        DROP TABLE #StagingDeportesDisponibles;
END;
GO

-- CARGAR DATOS DEL CSV
EXEC actividades.importarDeportesDisponibles 
	@FilePath = 'C:\Importar\dataImport\tarifasActividades.csv';
GO

-- VER DATOS CARGADOS
SELECT * FROM actividades.deporteDisponible;
GO

-- ************************************************************************************************
-- Procedimiento: actividades.importarDeportesPileta (3° ejecutar - YA FUNCIONA)
-- Descripción: Este procedimiento se encarga de importar y sincronizar las tarifas y horarios
--              de la actividad de pileta desde un archivo CSV con una estructura compleja.
--              Transforma los datos de múltiples filas del CSV en una única fila en la tabla 'actividades.actividadPileta'.
-- Parámetros:
--   @FilePath NVARCHAR(255): Ruta completa del archivo CSV que contiene las tarifas de pileta.
-- ************************************************************************************************

EXEC xp_cmdshell 'type C:\Importar\dataImport\tarifasActividadesPileta.csv';

IF OBJECT_ID('tempdb..#StagingPiletaActividad') IS NOT NULL
  DROP TABLE #StagingPiletaActividad;

-- 1) Tabla staging *sin* identity
CREATE TABLE #StagingPiletaActividad (
    DescripcionCsv      NVARCHAR(100),
    ValorCsv            NVARCHAR(50),
    VigenciaHastaCsv    NVARCHAR(20)
);

-- 2) Bulk insert usando exactly tu delimitador ';'
BULK INSERT #StagingPiletaActividad
  FROM 'C:\Importar\dataImport\tarifasActividadesPileta.csv'
  WITH
  (
    FIRSTROW        = 2,
    DATAFILETYPE    = 'char',       -- lee como ANSI/UTF8 sin BOM problemas
    FIELDTERMINATOR = ';',
    ROWTERMINATOR   = '0x0a',       -- solo LF
    TABLOCK
  );

-- 3) Verifica que las filas llegaron bien
SELECT
  ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS RowNum,
  DescripcionCsv, ValorCsv, VigenciaHastaCsv
FROM #StagingPiletaActividad;

CREATE OR ALTER PROCEDURE actividades.importarDeportesPileta
    @FilePath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @DefaultTariffValue   DECIMAL(10,2) = 0.01,
        @DefaultApertura      TIME          = '10:00:00',
        @DefaultCierre        TIME          = '20:00:00',
        @DefaultVigenciaHasta DATE          = '2025-02-28',
        @sql                  NVARCHAR(MAX);

    ---------------------------
    -- 1) STAGING
    ---------------------------
    IF OBJECT_ID('tempdb..#StagingPiletaActividad') IS NOT NULL
        DROP TABLE #StagingPiletaActividad;

    CREATE TABLE #StagingPiletaActividad (
        DescripcionCsv      NVARCHAR(100),
        ValorCsv            NVARCHAR(50),
        VigenciaHastaCsv    NVARCHAR(20)
    );

    ---------------------------
    -- 2) BULK INSERT
    ---------------------------
    SET @sql = N'
      BULK INSERT #StagingPiletaActividad
      FROM ''' + @FilePath + N'''
      WITH
      (
        DATAFILETYPE    = ''char'',
        CODEPAGE        = ''65001'',
        FIRSTROW        = 2,
        FIELDTERMINATOR = '';'',
        ROWTERMINATOR   = ''0x0d0a'',
        TABLOCK,
        MAXERRORS       = 1
      );';
    EXEC sp_executesql @sql;

    /*PRINT 'Filas cargadas en staging: ' 
          + CAST((SELECT COUNT(*) FROM #StagingPiletaActividad) AS VARCHAR(10));*/

    ---------------------------
    -- 3) PROCESSED
    ---------------------------
    IF OBJECT_ID('tempdb..#ProcessedPiletaActividad') IS NOT NULL
        DROP TABLE #ProcessedPiletaActividad;

    CREATE TABLE #ProcessedPiletaActividad (
        idActividad                    INT          PRIMARY KEY,
        tarifaSocioPorDiaAdulto        DECIMAL(10,2),
        tarifaSocioPorTemporadaAdulto  DECIMAL(10,2),
        tarifaSocioPorMesAdulto        DECIMAL(10,2),
        tarifaSocioPorDiaMenor         DECIMAL(10,2),
        tarifaSocioPorTemporadaMenor   DECIMAL(10,2),
        tarifaSocioPorMesMenor         DECIMAL(10,2),
        tarifaInvitadoPorDiaAdulto     DECIMAL(10,2),
        tarifaInvitadoPorTemporadaAdulto DECIMAL(10,2),
        tarifaInvitadoPorMesAdulto     DECIMAL(10,2),
        tarifaInvitadoPorDiaMenor      DECIMAL(10,2),
        tarifaInvitadoPorTemporadaMenor DECIMAL(10,2),
        tarifaInvitadoPorMesMenor      DECIMAL(10,2),
        horaAperturaActividad          TIME,
        horaCierreActividad            TIME,
        vigenciaHasta                  DATE
    );

    ---------------------------
    -- 4) PIVOT / AGREGACIÓN
    ---------------------------
    INSERT INTO #ProcessedPiletaActividad
    SELECT
      1 AS idActividad,
      ISNULL(MAX(CASE 
        WHEN DescripcionCsv LIKE 'Valor del dia Socios Adultos%' 
        THEN TRY_CAST(REPLACE(ValorCsv,',','.') AS DECIMAL(10,2)) 
      END), @DefaultTariffValue),
      ISNULL(MAX(CASE 
        WHEN DescripcionCsv LIKE 'Valor de temporada Socios Adultos%' 
        THEN TRY_CAST(REPLACE(ValorCsv,',','.') AS DECIMAL(10,2)) 
      END), @DefaultTariffValue),
      ISNULL(MAX(CASE 
        WHEN DescripcionCsv LIKE 'Valor del mes Socios Adultos%' 
        THEN TRY_CAST(REPLACE(ValorCsv,',','.') AS DECIMAL(10,2)) 
      END), @DefaultTariffValue),
      ISNULL(MAX(CASE 
        WHEN DescripcionCsv LIKE 'Valor del dia Socios Menores de 12 años%' 
        THEN TRY_CAST(REPLACE(ValorCsv,',','.') AS DECIMAL(10,2)) 
      END), @DefaultTariffValue),
      ISNULL(MAX(CASE 
        WHEN DescripcionCsv LIKE 'Valor de temporada Socios Menores de 12 años%' 
        THEN TRY_CAST(REPLACE(ValorCsv,',','.') AS DECIMAL(10,2)) 
      END), @DefaultTariffValue),
      ISNULL(MAX(CASE 
        WHEN DescripcionCsv LIKE 'Valor del mes Socios Menores de 12 años%' 
        THEN TRY_CAST(REPLACE(ValorCsv,',','.') AS DECIMAL(10,2)) 
      END), @DefaultTariffValue),
      ISNULL(MAX(CASE 
        WHEN DescripcionCsv LIKE 'Valor del dia Invitados Adultos%' 
        THEN TRY_CAST(REPLACE(ValorCsv,',','.') AS DECIMAL(10,2)) 
      END), @DefaultTariffValue),
      ISNULL(MAX(CASE 
        WHEN DescripcionCsv LIKE 'Valor de temporada Invitados Adultos%' 
        THEN TRY_CAST(REPLACE(ValorCsv,',','.') AS DECIMAL(10,2)) 
      END), @DefaultTariffValue),
      ISNULL(MAX(CASE 
        WHEN DescripcionCsv LIKE 'Valor del mes Invitados Adultos%' 
        THEN TRY_CAST(REPLACE(ValorCsv,',','.') AS DECIMAL(10,2)) 
      END), @DefaultTariffValue),
      ISNULL(MAX(CASE 
        WHEN DescripcionCsv LIKE 'Valor del dia Invitados Menores de 12 años%' 
        THEN TRY_CAST(REPLACE(ValorCsv,',','.') AS DECIMAL(10,2)) 
      END), @DefaultTariffValue),
      ISNULL(MAX(CASE 
        WHEN DescripcionCsv LIKE 'Valor de temporada Invitados Menores de 12 años%' 
        THEN TRY_CAST(REPLACE(ValorCsv,',','.') AS DECIMAL(10,2)) 
      END), @DefaultTariffValue),
      ISNULL(MAX(CASE 
        WHEN DescripcionCsv LIKE 'Valor del mes Invitados Menores de 12 años%' 
        THEN TRY_CAST(REPLACE(ValorCsv,',','.') AS DECIMAL(10,2)) 
      END), @DefaultTariffValue),
      @DefaultApertura,
      @DefaultCierre,
      ISNULL(
        MAX(TRY_CONVERT(DATE, VigenciaHastaCsv, 103)),
        @DefaultVigenciaHasta
      )
    FROM #StagingPiletaActividad;

    ---------------------------
    -- 5) SINCRONIZAR CON ACTIVIDADPILETA
    ---------------------------
    IF EXISTS (SELECT 1 FROM actividades.actividadPileta WHERE idActividad = 1)
    BEGIN
      UPDATE t
      SET
        t.tarifaSocioPorDiaAdulto        = p.tarifaSocioPorDiaAdulto,
        t.tarifaSocioPorTemporadaAdulto  = p.tarifaSocioPorTemporadaAdulto,
        t.tarifaSocioPorMesAdulto        = p.tarifaSocioPorMesAdulto,
        t.tarifaSocioPorDiaMenor         = p.tarifaSocioPorDiaMenor,
        t.tarifaSocioPorTemporadaMenor   = p.tarifaSocioPorTemporadaMenor,
        t.tarifaSocioPorMesMenor         = p.tarifaSocioPorMesMenor,
        t.tarifaInvitadoPorDiaAdulto     = p.tarifaInvitadoPorDiaAdulto,
        t.tarifaInvitadoPorTemporadaAdulto = p.tarifaInvitadoPorTemporadaAdulto,
        t.tarifaInvitadoPorMesAdulto     = p.tarifaInvitadoPorMesAdulto,
        t.tarifaInvitadoPorDiaMenor      = p.tarifaInvitadoPorDiaMenor,
        t.tarifaInvitadoPorTemporadaMenor = p.tarifaInvitadoPorTemporadaMenor,
        t.tarifaInvitadoPorMesMenor      = p.tarifaInvitadoPorMesMenor,
        t.horaAperturaActividad          = p.horaAperturaActividad,
        t.horaCierreActividad            = p.horaCierreActividad,
        t.vigenciaHasta                  = p.vigenciaHasta
      FROM actividades.actividadPileta AS t
      JOIN #ProcessedPiletaActividad AS p ON t.idActividad = p.idActividad;
    END
    ELSE
    BEGIN
      SET IDENTITY_INSERT actividades.actividadPileta ON;
      INSERT INTO actividades.actividadPileta
      SELECT * FROM #ProcessedPiletaActividad;
      SET IDENTITY_INSERT actividades.actividadPileta OFF;
    END;

    ---------------------------
    -- 6) LIMPIEZA
    ---------------------------
    DROP TABLE #StagingPiletaActividad;
    DROP TABLE #ProcessedPiletaActividad;

    PRINT 'Importación de tarifas de pileta completada correctamente.';
END;
GO

-- CARGAR DATOS DEL CSV
EXEC actividades.importarDeportesPileta
    @FilePath = 'C:\Importar\dataImport\tarifasActividadesPileta.csv';
GO

SELECT -- FORMAT(valor, 'C', 'es-AR') para mostrar los valores como moneda local de Argentina
    idActividad,
    CASE WHEN tarifaSocioPorDiaAdulto = 0.01 THEN 'PREGUNTAR EN VENTANILLA' ELSE FORMAT(tarifaSocioPorDiaAdulto, 'C', 'es-AR') END AS TarifaSocioDiaAdulto,
    CASE WHEN tarifaSocioPorTemporadaAdulto = 0.01 THEN 'PREGUNTAR EN VENTANILLA' ELSE FORMAT(tarifaSocioPorTemporadaAdulto, 'C', 'es-AR') END AS TarifaSocioTemporadaAdulto,
    CASE WHEN tarifaSocioPorMesAdulto = 0.01 THEN 'PREGUNTAR EN VENTANILLA' ELSE FORMAT(tarifaSocioPorMesAdulto, 'C', 'es-AR') END AS TarifaSocioMesAdulto,
    CASE WHEN tarifaSocioPorDiaMenor = 0.01 THEN 'PREGUNTAR EN VENTANILLA' ELSE FORMAT(tarifaSocioPorDiaMenor, 'C', 'es-AR') END AS TarifaSocioDiaMenor,
    CASE WHEN tarifaSocioPorTemporadaMenor = 0.01 THEN 'PREGUNTAR EN VENTANILLA' ELSE FORMAT(tarifaSocioPorTemporadaMenor, 'C', 'es-AR') END AS TarifaSocioTemporadaMenor,
    CASE WHEN tarifaSocioPorMesMenor = 0.01 THEN 'PREGUNTAR EN VENTANILLA' ELSE FORMAT(tarifaSocioPorMesMenor, 'C', 'es-AR') END AS TarifaSocioMesMenor,
    CASE WHEN tarifaInvitadoPorDiaAdulto = 0.01 THEN 'PREGUNTAR EN VENTANILLA' ELSE FORMAT(tarifaInvitadoPorDiaAdulto, 'C', 'es-AR') END AS TarifaInvitadoDiaAdulto,
    CASE WHEN tarifaInvitadoPorTemporadaAdulto = 0.01 THEN 'PREGUNTAR EN VENTANILLA' ELSE FORMAT(tarifaInvitadoPorTemporadaAdulto, 'C', 'es-AR') END AS TarifaInvitadoTemporadaAdulto,
    CASE WHEN tarifaInvitadoPorMesAdulto = 0.01 THEN 'PREGUNTAR EN VENTANILLA' ELSE FORMAT(tarifaInvitadoPorMesAdulto, 'C', 'es-AR') END AS TarifaInvitadoMesAdulto,
    CASE WHEN tarifaInvitadoPorDiaMenor = 0.01 THEN 'PREGUNTAR EN VENTANILLA' ELSE FORMAT(tarifaInvitadoPorDiaMenor, 'C', 'es-AR') END AS TarifaInvitadoDiaMenor,
    CASE WHEN tarifaInvitadoPorTemporadaMenor = 0.01 THEN 'PREGUNTAR EN VENTANILLA' ELSE FORMAT(tarifaInvitadoPorTemporadaMenor, 'C', 'es-AR') END AS TarifaInvitadoTemporadaMenor,
    CASE WHEN tarifaInvitadoPorMesMenor = 0.01 THEN 'PREGUNTAR EN VENTANILLA' ELSE FORMAT(tarifaInvitadoPorMesMenor, 'C', 'es-AR') END AS TarifaInvitadoMesMenor,
    horaAperturaActividad,
    horaCierreActividad,
    vigenciaHasta
--SELECT * 
FROM actividades.actividadPileta;
GO

-- ************************************************************************************************
-- Procedimiento: socios.importarGrupoFamiliar (4° ejecutar - YA FUNCIONA)
-- Descripción: Este procedimiento se encarga de importar y sincronizar los datos de los miembros individuales del grupo familiar desde un archivo CSV.
-- Parámetros:
--   @FilePath NVARCHAR(255): Ruta completa del archivo CSV de datos del grupo familiar.
-- ************************************************************************************************

EXEC sp_configure 'show advanced options', 1; RECONFIGURE;  
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;  

-- ¿Puede verlo el motor?
EXEC xp_cmdshell 'dir "D:\Lautaro_Santillan\UNLaM\Bases de Datos Aplicada\SolNorte-Grupo3-BDDA\SOLNORTE-GRUPO3-BDDA\dataImport\grupoFamiliar.csv"';

CREATE OR ALTER PROCEDURE socios.importarGrupoFamiliar
  @FilePath NVARCHAR(255)
AS
BEGIN
  SET NOCOUNT ON;

  IF OBJECT_ID('tempdb..#StagingGrupoFamiliar') IS NOT NULL
    DROP TABLE #StagingGrupoFamiliar;

  -- 1) Creamos la tabla temporal
  CREATE TABLE #StagingGrupoFamiliar (
      [Nro de Socio]                        NVARCHAR(50),
      [Nro de socio RP]                     NVARCHAR(50),
      [Nombre]                              NVARCHAR(50),
      [ apellido]                           NVARCHAR(50),
      [ DNI]                                NVARCHAR(10),
      [ email personal]                     NVARCHAR(50),
      [ fecha de nacimiento]                NVARCHAR(20),
      [ teléfono de contacto]               NVARCHAR(50),
      [ teléfono de contacto emergencia]    NVARCHAR(50),
      [Nombre de la obra social o prepaga]  NVARCHAR(50),
      [nro. de socio obra social/prepaga ]  NVARCHAR(50),
      [teléfono de contacto de emergencia ] NVARCHAR(50)
  );

  BEGIN TRY
    -- 2) Construimos y ejecutamos la sentencia BULK INSERT en dinámico
    DECLARE @sql NVARCHAR(MAX) =  
      N'BULK INSERT #StagingGrupoFamiliar
        FROM ''' + REPLACE(@FilePath,'''','''''') + N'''
        WITH
        (
          FIRSTROW        = 2,
          FIELDTERMINATOR = '';'',
          ROWTERMINATOR   = ''0x0a'',
          CODEPAGE        = ''65001'',
          MAXERRORS       = 1000
        );';

    EXEC sp_executesql @sql;

    -- 3) Ahora hacemos el MERGE contra socios.grupoFamiliar
    MERGE socios.grupoFamiliar AS Target
    USING (
      SELECT
        CAST(REPLACE([Nro de Socio], 'SN-', '') AS INT)            AS idGrupoFamiliar,
        CAST(REPLACE([Nro de socio RP], 'SN-', '') AS INT)         AS idSocioResponsable,
        RTRIM(LTRIM([Nombre]))                                     AS nombre,
        RTRIM(LTRIM([ apellido]))                                  AS apellido,
        RTRIM(LTRIM([ DNI]))                                       AS dni,
        [ email personal]                                          AS emailPersonal,
        TRY_CONVERT(DATE, [ fecha de nacimiento], 103)             AS fechaNacimiento,
        [ teléfono de contacto]                                    AS telefonoContacto,
        [ teléfono de contacto emergencia]                         AS telefonoContactoEmergencia,
        [Nombre de la obra social o prepaga]                       AS nombreObraSocial,
        [nro. de socio obra social/prepaga ]                       AS nroSocioObraSocial,
        [teléfono de contacto de emergencia ]                      AS telefonoObraSocialEmergencia
      FROM #StagingGrupoFamiliar
    ) AS Source
    ON Target.idGrupoFamiliar = Source.idGrupoFamiliar
    WHEN MATCHED THEN
      UPDATE SET
        Target.idSocioResponsable         = Source.idSocioResponsable,
        Target.nombre                     = Source.nombre,
        Target.apellido                   = Source.apellido,
        Target.dni                        = Source.dni,
        Target.emailPersonal              = Source.emailPersonal,
        Target.fechaNacimiento            = Source.fechaNacimiento,
        Target.telefonoContacto           = Source.telefonoContacto,
        Target.telefonoContactoEmergencia = Source.telefonoContactoEmergencia,
        Target.nombreObraSocial           = Source.nombreObraSocial,
        Target.nroSocioObraSocial         = Source.nroSocioObraSocial,
        Target.telefonoObraSocialEmergencia = Source.telefonoObraSocialEmergencia
    WHEN NOT MATCHED THEN
      INSERT (
        idGrupoFamiliar, idSocioResponsable, nombre, apellido, dni,
        emailPersonal, fechaNacimiento, telefonoContacto,
        telefonoContactoEmergencia,
        nombreObraSocial, nroSocioObraSocial, telefonoObraSocialEmergencia
      )
      VALUES (
        Source.idGrupoFamiliar, Source.idSocioResponsable,
        Source.nombre, Source.apellido, Source.dni,
        Source.emailPersonal, Source.fechaNacimiento,
        Source.telefonoContacto,
        Source.telefonoContactoEmergencia,
        Source.nombreObraSocial,
        Source.nroSocioObraSocial,
        Source.telefonoObraSocialEmergencia
      );

    PRINT 'Datos de miembros del grupo familiar importados/actualizados con éxito!';
  END TRY
  BEGIN CATCH
    DECLARE 
      @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE(),
      @ErrorSev INT             = ERROR_SEVERITY(),
      @ErrorState INT           = ERROR_STATE();
    RAISERROR(@ErrorMsg, @ErrorSev, @ErrorState);
  END CATCH;

  DROP TABLE IF EXISTS #StagingGrupoFamiliar;
END;
GO

-- CARGAR DATOS DEL CSV
EXEC socios.importarGrupoFamiliar
  @FilePath = N'C:\Importar\dataImport\grupoFamiliar.csv';
GO

-- VER DATOS CARGADOS
SELECT * FROM socios.grupoFamiliar;
GO

-- ========================================================================
-- Procedimiento: pagos.importarPagosCuotas (5° ejecutar - FUNCIONA)
-- Descripción: Importa datos de pagos de cuotas desde "pagoCuotas.csv" a la tabla 'pagos.cobroFactura'.
-- Parámetros:
--   @FilePath NVARCHAR(255): Ruta completa del archivo CSV,
-- ========================================================================
CREATE OR ALTER PROCEDURE pagos.importarPagosCuotas
    @FilePath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DynamicSql NVARCHAR(MAX);

    -- Limpiar tablas temporales si existen de una ejecución anterior
    IF OBJECT_ID('tempdb..#StagingPagosCuotas') IS NOT NULL
        DROP TABLE #StagingPagosCuotas;
    IF OBJECT_ID('tempdb..#ProcessedCobros') IS NOT NULL
        DROP TABLE #ProcessedCobros;

    CREATE TABLE #StagingPagosCuotas (
        IdDePagoCsv NVARCHAR(50),
        FechaCsv NVARCHAR(50),
        ResponsableDePagoCsv NVARCHAR(50), -- SN-XXXX
        ValorCsv NVARCHAR(50),
        MedioDePagoCsv NVARCHAR(50)
    );

    BEGIN TRY
        SET @DynamicSql = N'BULK INSERT #StagingPagosCuotas
                             FROM ''' + @FilePath + N'''
                             WITH
                             (
                                 FIRSTROW = 2, -- Omitir encabezados
                                 FIELDTERMINATOR = '';'', -- Separador de columnas
                                 ROWTERMINATOR = ''0x0d0a'', -- CRLF para Windows
                                 TABLOCK                     
                             );';
        
        EXEC sp_executesql @DynamicSql;
        PRINT '--- Depuración: Después de BULK INSERT ---';
        SELECT COUNT(*) AS 'Count_StagingPagosCuotas' FROM #StagingPagosCuotas;
        --SELECT TOP 10 * FROM #StagingPagosCuotas;
		--SELECT * FROM #StagingPagosCuotas;
        PRINT '-----------------------------------------';

        CREATE TABLE #ProcessedCobros (
            idCobro BIGINT PRIMARY KEY,
            idSocio INT,
            categoriaSocio INT,
            fechaEmisionCobro DATE,
            nombreSocio VARCHAR(50),
            apellidoSocio VARCHAR(50),
            cuilDeudor VARCHAR(13),
            domicilio VARCHAR(50),
            modalidadCobro VARCHAR(25),
            numeroCuota INT,
            totalAbonado DECIMAL(10, 2)
        );

        INSERT INTO #ProcessedCobros (
            idCobro, idSocio, categoriaSocio, fechaEmisionCobro, 
            nombreSocio, apellidoSocio, cuilDeudor, domicilio, 
            modalidadCobro, numeroCuota, totalAbonado
        )
        SELECT
            CASE WHEN ISNUMERIC(sp.IdDePagoCsv) = 1 THEN CAST(sp.IdDePagoCsv AS BIGINT) ELSE NULL END AS idCobro,
            CAST(SUBSTRING(sp.ResponsableDePagoCsv, CHARINDEX('-', sp.ResponsableDePagoCsv) + 1, LEN(sp.ResponsableDePagoCsv)) AS INT) AS idSocio,
            s.categoriaSocio,
            -- ********************************************
            ISNULL(TRY_CONVERT(DATE, sp.FechaCsv, 103), '2025-01-01') AS fechaEmisionCobro,
            -- ********************************************
            s.nombre AS nombreSocio,
            s.apellido AS apellidoSocio,
            s.dni AS cuilDeudor,
            s.direccion AS domicilio,
            TRIM(sp.MedioDePagoCsv) AS modalidadCobro,
            1 AS numeroCuota,
            CASE WHEN ISNUMERIC(sp.ValorCsv) = 1 THEN CAST(sp.ValorCsv AS DECIMAL(10,2)) ELSE 0.00 END AS totalAbonado
        FROM
            #StagingPagosCuotas sp
        INNER JOIN
            socios.socio s ON CAST(SUBSTRING(sp.ResponsableDePagoCsv, CHARINDEX('-', sp.ResponsableDePagoCsv) + 1, LEN(sp.ResponsableDePagoCsv)) AS INT) = s.idSocio
        WHERE
            ISNUMERIC(sp.IdDePagoCsv) = 1
            AND ISNUMERIC(SUBSTRING(sp.ResponsableDePagoCsv, CHARINDEX('-', sp.ResponsableDePagoCsv) + 1, LEN(sp.ResponsableDePagoCsv))) = 1
            AND ISNUMERIC(sp.ValorCsv) = 1;

        PRINT '--- Depuración: Después de la inserción en #ProcessedCobros ---';
        SELECT COUNT(*) AS 'Count_ProcessedCobros' FROM #ProcessedCobros;
        SELECT TOP 10 * FROM #ProcessedCobros;

        PRINT '--- Fechas en FechaCsv (Staging) que NO pudieron convertirse a DATE (DD/MM/YYYY) ---';
        SELECT DISTINCT FechaCsv
        FROM #StagingPagosCuotas
        WHERE TRY_CONVERT(DATE, FechaCsv, 103) IS NULL;
        PRINT '-----------------------------------------------------------------------------------';

        PRINT '--- IDs de Socio del CSV (Staging) que NO tienen match en la tabla socios.socio ---';
        SELECT DISTINCT
            CAST(SUBSTRING(sp.ResponsableDePagoCsv, CHARINDEX('-', sp.ResponsableDePagoCsv) + 1, LEN(sp.ResponsableDePagoCsv)) AS INT) AS idSocio_SinMatch_en_Socios
        FROM #StagingPagosCuotas sp
        LEFT JOIN socios.socio s ON CAST(SUBSTRING(sp.ResponsableDePagoCsv, CHARINDEX('-', sp.ResponsableDePagoCsv) + 1, LEN(sp.ResponsableDePagoCsv)) AS INT) = s.idSocio
        WHERE s.idSocio IS NULL;
        PRINT '-------------------------------------------------------------';

        MERGE pagos.cobroFactura AS Target
        USING #ProcessedCobros AS Source
        ON (Target.idCobro = Source.idCobro)
        WHEN MATCHED THEN
            UPDATE SET
                Target.idSocio = Source.idSocio,
                Target.categoriaSocio = Source.categoriaSocio,
                Target.fechaEmisionCobro = Source.fechaEmisionCobro,
                Target.nombreSocio = Source.nombreSocio,
                Target.apellidoSocio = Source.apellidoSocio,
                Target.cuilDeudor = Source.cuilDeudor,
                Target.domicilio = Source.domicilio,
                Target.modalidadCobro = Source.modalidadCobro,
                Target.numeroCuota = Source.numeroCuota,
                Target.totalAbonado = Source.totalAbonado
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                idCobro, idSocio, categoriaSocio, fechaEmisionCobro, 
                nombreSocio, apellidoSocio, cuilDeudor, domicilio, 
                modalidadCobro, numeroCuota, totalAbonado, idFacturaCobrada
            )
            VALUES (
                Source.idCobro, Source.idSocio, Source.categoriaSocio, Source.fechaEmisionCobro,
                Source.nombreSocio, Source.apellidoSocio, Source.cuilDeudor, Source.domicilio,
                Source.modalidadCobro, Source.numeroCuota, Source.totalAbonado, NULL
            );

        PRINT '¡Datos de pagos de cuotas importados/actualizados con exito!';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
    IF OBJECT_ID('tempdb..#StagingPagosCuotas') IS NOT NULL
        DROP TABLE #StagingPagosCuotas;
    IF OBJECT_ID('tempdb..#ProcessedCobros') IS NOT NULL
        DROP TABLE #ProcessedCobros;
END;
GO

-- CARGAR DATOS DEL CSV
EXEC pagos.importarPagosCuotas
	@FilePath = 'C:\Importar\dataImport\pagoCuotas.csv';
GO

-- VER DATOS CARGADOS
SELECT * FROM pagos.cobroFactura;
GO

-- ************************************************************************************************
-- Procedimiento: actividades.importarPresentismoActividadSocio (6° ejecutar - FUNCIONA)
-- Descripcion: Este procedimiento se encarga de importar los registros de presentismo de las actividades de los socios desde un archivo CSV.
-- Parametros:
--   @FilePath NVARCHAR(255): Ruta completa del archivo CSV a importar.
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE actividades.importarPresentismoActividadSocio
    @FilePath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @consultaSqlDinamica NVARCHAR(MAX);
    IF OBJECT_ID('tempdb..#TablaDeCargaTemporal') IS NOT NULL
        DROP TABLE #TablaDeCargaTemporal;
    -- Es crucial que el numero de columnas aqui coincida con el numero de columnas del CSV, incluyendo las vacias.
    CREATE TABLE #TablaDeCargaTemporal (
        NumeroDeSocioCsv NVARCHAR(50),
        ActividadCsv NVARCHAR(50),
        FechaAsistenciaCsv NVARCHAR(10),
        EstadoAsistenciaCsv CHAR(1),
        ProfesorCsv NVARCHAR(50),
        ColumnaVacia1 NVARCHAR(50),
        ColumnaVacia2 NVARCHAR(50),
        ColumnaVacia3 NVARCHAR(50),
        ColumnaVacia4 NVARCHAR(50)
    );
    BEGIN TRY
        SET @consultaSqlDinamica = N'BULK INSERT #TablaDeCargaTemporal
                                     FROM ''' + @FilePath + N'''
                                     WITH
                                     (
                                         FIRSTROW = 2,
                                         FIELDTERMINATOR = '';'',
                                         ROWTERMINATOR = ''0x0a'',
                                         TABLOCK
                                     );';
        EXEC sp_executesql @consultaSqlDinamica;
        PRINT 'BULK INSERT completado. Filas cargadas en #TablaDeCargaTemporal: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
        -- Depuración: Mostrar algunas filas de la tabla temporal
        PRINT 'Top 10 filas de #TablaDeCargaTemporal:';
        SELECT TOP 10 * FROM #TablaDeCargaTemporal;

        -- MERGE para insertar/actualizar datos en actividades.presentismoActividadSocio
        MERGE actividades.presentismoActividadSocio AS TablaDestino
        USING (
            SELECT
                CAST(REPLACE(st.NumeroDeSocioCsv, 'SN-', '') AS INT) AS idSocioFinal,
                da.idDeporteActivo,
                -- Usar TRY_CONVERT para manejar fechas inválidas y asignar una por defecto si falla
                ISNULL(TRY_CONVERT(DATE, st.FechaAsistenciaCsv, 103), '2025-01-01') AS FechaDeAsistenciaFinal,
                st.EstadoAsistenciaCsv AS EstadoPresentismoFinal,
                st.ProfesorCsv AS ProfesorAsociado
            FROM
                #TablaDeCargaTemporal st
            INNER JOIN
                actividades.deporteDisponible dd ON st.ActividadCsv = dd.descripcion
            INNER JOIN
                actividades.deporteActivo da ON CAST(REPLACE(st.NumeroDeSocioCsv, 'SN-', '') AS INT) = da.idSocio
                                            AND dd.idDeporte = da.idDeporte
        ) AS TablaOrigen (idSocio, idDeporteActivo, fechaActividad, estadoPresentismo, profesorDeporte)
        ON TablaDestino.idSocio = TablaOrigen.idSocio
           AND TablaDestino.idDeporteActivo = TablaOrigen.idDeporteActivo
           AND TablaDestino.fechaActividad = TablaOrigen.fechaActividad
        WHEN MATCHED THEN
            UPDATE SET
                TablaDestino.estadoPresentismo = TablaOrigen.estadoPresentismo,
                TablaDestino.profesorDeporte = TablaOrigen.profesorDeporte
        WHEN NOT MATCHED THEN
            INSERT (idSocio, idDeporteActivo, fechaActividad, estadoPresentismo, profesorDeporte)
            VALUES (TablaOrigen.idSocio, TablaOrigen.idDeporteActivo, TablaOrigen.fechaActividad, TablaOrigen.estadoPresentismo, TablaOrigen.profesorDeporte);

        PRINT 'Proceso de importacion de presentismo completado con exito!';
        --PRINT 'Filas afectadas por MERGE: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
    END TRY
    BEGIN CATCH
        DECLARE @MensajeError NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @SeveridadError INT = ERROR_SEVERITY();
        DECLARE @EstadoError INT = ERROR_STATE();
        RAISERROR(@MensajeError, @SeveridadError, @EstadoError);
    END CATCH;
    IF OBJECT_ID('tempdb..#TablaDeCargaTemporal') IS NOT NULL
        DROP TABLE #TablaDeCargaTemporal;
END;
GO

-- CARGAR DATOS DEL CSV
EXEC actividades.importarPresentismoActividadSocio
    @FilePath = 'C:\Importar\dataImport\presentismo_actividades.csv';
GO

-- VER DATOS CARGADOS
SELECT * FROM actividades.presentismoActividadSocio;
GO