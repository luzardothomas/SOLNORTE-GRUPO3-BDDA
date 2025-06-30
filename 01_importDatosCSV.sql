-- Usar la base de datos
USE Com2900G03;
GO

-- Datos de Prueba (NO SON LOS REALES QUE VAN A IR ***)

-- Insertar datos en socios.socio ***
INSERT INTO socios.socio (idSocio, categoriaSocio, dni, cuil, nombre, apellido, email, telefono, fechaNacimiento, fechaDeVigenciaContrasenia, fechaIngresoSocio, contactoDeEmergencia, usuario, contrasenia, estadoMembresia, fechaVencimientoMembresia, direccion) VALUES
(4148, 1, '12345678', '20123456789', 'Juan', 'Perez', 'juan.p@email.com', '1122334455', '1990-01-15', '2025-12-31', '2020-05-01', '1166778899', 'juanp', 'pass123', 'Activo', '2025-07-31', 'Calle Falsa 123'),
(4144, 1, '87654321', '27876543210', 'Maria', 'Gomez', 'maria.g@email.com', '1133445566', '1988-03-20', '2025-12-31', '2021-02-10', '1177889900', 'mariag', 'pass123', 'Activo', '2025-07-31', 'Av. Siempre Viva 742'),
(4149, 2, '11223344', '20112233445', 'Carlos', 'Lopez', 'carlos.l@email.com', '1144556677', '1995-07-05', '2025-12-31', '2022-01-15', '1188990011', 'carlosl', 'pass123', 'Activo', '2025-07-31', 'Ruta 66 Km 10'),
(4129, 2, '22334455', '27223344556', 'Ana', 'Rodriguez', 'ana.r@email.com', '1155667788', '1992-11-10', '2025-12-31', '2021-09-20', '1199001122', 'anar', 'pass123', 'Activo', '2025-07-31', 'Callejon Diagon 4'),
(4132, 1, '33445566', '20334455667', 'Pedro', 'Martinez', 'pedro.m@email.com', '1166778899', '1985-04-25', '2025-12-31', '2020-11-05', '1100112233', 'pedrom', 'pass123', 'Activo', '2025-07-31', 'Plaza Mayor 5'),
(4133, 3, '44556677', '27445566778', 'Laura', 'Diaz', 'laura.d@email.com', '1177889900', '1998-09-30', '2025-12-31', '2023-03-12', '1111223344', 'laurad', 'pass123', 'Activo', '2025-07-31', 'Avenida Siempre 1'); -- �CORREGIDO! Agregado 'pass123' para contrasenia
GO

-- Insertar datos en actividades.deporteActivo ***
INSERT INTO actividades.deporteActivo (idSocio, idDeporte, estadoActividadDeporte, estadoMembresia) VALUES
(4148, (SELECT idDeporte FROM actividades.deporteDisponible WHERE descripcion = 'Futsal'), 'Activo', 'Activo'),
(4144, (SELECT idDeporte FROM actividades.deporteDisponible WHERE descripcion = 'Futsal'), 'Activo', 'Activo'),
(4149, (SELECT idDeporte FROM actividades.deporteDisponible WHERE descripcion = 'Futsal'), 'Activo', 'Activo'),
(4129, (SELECT idDeporte FROM actividades.deporteDisponible WHERE descripcion = 'Futsal'), 'Activo', 'Activo'),
(4132, (SELECT idDeporte FROM actividades.deporteDisponible WHERE descripcion = 'Futsal'), 'Activo', 'Activo'),
(4133, (SELECT idDeporte FROM actividades.deporteDisponible WHERE descripcion = 'Futsal'), 'Activo', 'Activo');
GO

-- ************************************************************************************************
-- Procedimiento: socios.importarGrupoFamiliar
-- Descripción: Este procedimiento se encarga de importar y sincronizar los datos de los miembros individuales del grupo familiar desde un archivo CSV.
-- Parámetros:
--   @FilePath NVARCHAR(255): Ruta completa del archivo CSV de datos del grupo familiar.
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE socios.importarGrupoFamiliar -- REVISAR BIEN EL PORQUE NO ANDA (PARECE SER UN ERROR DE BLOQUEOS O PERMISOS PERO NO LO ENCUENTRO)
    @FilePath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DefaultTextValue NVARCHAR(50) = 'A completar'; -- Valor por defecto para campos de texto vacíos
    DECLARE @DefaultDateValue DATE = '1900-01-01';          -- Valor por defecto para fechas inválidas
    DECLARE @consultaSqlDinamica NVARCHAR(MAX);
    IF OBJECT_ID('tempdb..#StagingGrupoFamiliar') IS NOT NULL
        DROP TABLE #StagingGrupoFamiliar;
    -- Creamos la tabla temporal. Las columnas aquí deben coincidir con las columnas y el orden de tu archivo CSV.
    -- Las columnas con espacios en el nombre del CSV se manejan con [].
    CREATE TABLE #StagingGrupoFamiliar (
        [Nro de Socio] NVARCHAR(50),
        [Nro de socio RP] NVARCHAR(50),
        [Nombre] NVARCHAR(50),
        [ apellido] NVARCHAR(50),
        [ DNI] NVARCHAR(10),
        [ email personal] NVARCHAR(50),
        [ fecha de nacimiento] NVARCHAR(20),
        [ teléfono de contacto] NVARCHAR(14),
        [ teléfono de contacto emergencia] NVARCHAR(14),
        [Nombre de la obra social o prepaga] NVARCHAR(50),
        [nro. de socio obra social/prepaga ] NVARCHAR(50),
        [teléfono de contacto de emergencia ] NVARCHAR(14)
    );
    BEGIN TRY
        -- Construimos la sentencia BULK INSERT de forma dinámica.
        SET @consultaSqlDinamica = N'BULK INSERT #StagingGrupoFamiliar
                                     FROM ''' + @FilePath + N'''
                                     WITH
                                     (
                                         FIRSTROW = 2,
                                         FIELDTERMINATOR = '';'',
                                         ROWTERMINATOR = ''0x0d0a'',
										 TABLOCK
                                     );'; 
        EXEC sp_executesql @consultaSqlDinamica;
        -- MERGE nos permite insertar nuevas filas o actualizar existentes en un solo paso.
        MERGE socios.grupoFamiliar AS Target
        USING (
            -- Subconsulta para preparar los datos de origen, realizando transformaciones
            SELECT
                -- idGrupoFamiliar: Transformar 'SN-XXXX' a INT. Este será el PK.
                CAST(REPLACE(st.[Nro de Socio], 'SN-', '') AS INT) AS idMiembroFamiliar,
                -- idSocioResponsable: Transformar 'SN-XXXX' a INT.
                CAST(REPLACE(st.[Nro de socio RP], 'SN-', '') AS INT) AS idSocioResponsable,
                -- Limpiar espacios en nombre y apellido
                RTRIM(LTRIM(st.Nombre)) AS Nombre,
                RTRIM(LTRIM(st.[ apellido])) AS Apellido,
                RTRIM(LTRIM(st.[ DNI])) AS DNI,
                -- Manejar campos de texto vacíos (NULLIF convierte '' a NULL, ISNULL reemplaza NULL con @DefaultTextValue)
                ISNULL(NULLIF(RTRIM(LTRIM(st.[ email personal])), ''), @DefaultTextValue) AS EmailPersonal,
                -- Convertir fecha de nacimiento (DD/MM/YYYY) usando TRY_CONVERT y valor por defecto
                ISNULL(TRY_CONVERT(DATE, st.[ fecha de nacimiento], 103), @DefaultDateValue) AS FechaNacimiento,
                ISNULL(NULLIF(RTRIM(LTRIM(st.[ teléfono de contacto])), ''), @DefaultTextValue) AS TelefonoContacto,
                ISNULL(NULLIF(RTRIM(LTRIM(st.[ teléfono de contacto emergencia])), ''), @DefaultTextValue) AS TelefonoContactoEmergencia,
                ISNULL(NULLIF(RTRIM(LTRIM(st.[Nombre de la obra social o prepaga])), ''), @DefaultTextValue) AS NombreObraSocial,
                ISNULL(NULLIF(RTRIM(LTRIM(st.[nro. de socio obra social/prepaga ])), ''), @DefaultTextValue) AS NroSocioObraSocial,
                ISNULL(NULLIF(RTRIM(LTRIM(st.[teléfono de contacto de emergencia ])), ''), @DefaultTextValue) AS TelefonoObraSocialEmergencia
            FROM
                #StagingGrupoFamiliar st -- Los datos que recién cargamos del CSV
        ) AS Source (idGrupoFamiliar, idSocioResponsable, nombre, apellido, dni, emailPersonal,
                     fechaNacimiento, telefonoContacto, telefonoContactoEmergencia,
                     nombreObraSocial, nroSocioObraSocial, telefonoObraSocialEmergencia)
        -- La condición ON para MERGE se basa en la clave primaria de la tabla destino
        ON Target.idGrupoFamiliar = Source.idGrupoFamiliar
        WHEN MATCHED THEN
            UPDATE SET
                Target.idSocioResponsable = Source.idSocioResponsable,
                Target.nombre = Source.nombre,
                Target.apellido = Source.apellido,
                Target.dni = Source.dni,
                Target.emailPersonal = Source.emailPersonal,
                Target.fechaNacimiento = Source.fechaNacimiento,
                Target.telefonoContacto = Source.telefonoContacto,
                Target.telefonoContactoEmergencia = Source.telefonoContactoEmergencia,
                Target.nombreObraSocial = Source.nombreObraSocial,
                Target.nroSocioObraSocial = Source.nroSocioObraSocial,
                Target.telefonoObraSocialEmergencia = Source.telefonoObraSocialEmergencia
        WHEN NOT MATCHED THEN
            INSERT (idGrupoFamiliar, idSocioResponsable, nombre, apellido, dni, emailPersonal,
                    fechaNacimiento, telefonoContacto, telefonoContactoEmergencia,
                    nombreObraSocial, nroSocioObraSocial, telefonoObraSocialEmergencia)
            VALUES (Source.idGrupoFamiliar, Source.idSocioResponsable, Source.nombre, Source.apellido, Source.dni, Source.emailPersonal,
                    Source.fechaNacimiento, Source.telefonoContacto, Source.telefonoContactoEmergencia,
                    Source.nombreObraSocial, Source.nroSocioObraSocial, Source.telefonoObraSocialEmergencia);
        PRINT 'Datos de miembros del grupo familiar importados/actualizados con exito!';
    END TRY
    BEGIN CATCH
        -- Manejo de Errores
        DECLARE @MensajeError NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @SeveridadError INT = ERROR_SEVERITY();
        DECLARE @EstadoError INT = ERROR_STATE();
        RAISERROR(@MensajeError, @SeveridadError, @EstadoError);
    END CATCH;
    IF OBJECT_ID('tempdb..#StagingGrupoFamiliar') IS NOT NULL
        DROP TABLE #StagingGrupoFamiliar;
END;
GO

-- CARGAR DATOS DEL CSV
EXEC socios.importarGrupoFamiliar
	@FilePath = 'D:\Lautaro_Santillan\UNLaM\Bases de Datos Aplicada\SolNorte-Grupo3-BDDA\SOLNORTE-GRUPO3-BDDA\dataImport\grupoFamiliar.csv';
GO

-- VER DATOS CARGADOS
SELECT * FROM socios.grupoFamiliar;
GO

-- ************************************************************************************************
-- Procedimiento: socios.importarCategoriasSocio
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
EXEC socios.importarCategoriasSocio @FilePath = 'D:\Lautaro_Santillan\UNLaM\Bases de Datos Aplicada\SolNorte-Grupo3-BDDA\SOLNORTE-GRUPO3-BDDA\dataImport\tarifasCategoriaSocio.csv';
GO

-- VER DATOS CARGADOS
SELECT * FROM socios.categoriaMembresiaSocio;
GO

-- ************************************************************************************************
-- Procedimiento: actividades.importarDeportesDisponibles
-- Descripción: Este procedimiento se encarga de importar y sincronizar los deportes disponibles desde un archivo CSV.         
-- Parámetros:
--   @FilePath NVARCHAR(255): Ruta completa del archivo CSV que contiene los datos.
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE actividades.importarDeportesDisponibles
    @FilePath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    -- Declaramos una variable para construir la consulta de BULK INSERT dinámicamente
    DECLARE @consultaSqlDinamica NVARCHAR(MAX);
    IF OBJECT_ID('tempdb..#StagingDeportesDisponibles') IS NOT NULL
        DROP TABLE #StagingDeportesDisponibles;
    -- Creamos la tabla temporal. Las columnas aquí deben coincidir
    CREATE TABLE #StagingDeportesDisponibles (
        ActividadCsv NVARCHAR(50),          -- Corresponde a 'Actividad' del CSV
        ValorPorMesCsv DECIMAL(10, 2),      -- Corresponde a 'Valor por mes' del CSV
        VigenteHastaCsv NVARCHAR(20)        -- Corresponde a 'Vigente hasta' del CSV (NVARCHAR(20) para mayor seguridad)
    );
    -- Manejo de errores: Si algo sale mal, capturamos el error
    BEGIN TRY
        SET @consultaSqlDinamica = N'BULK INSERT #StagingDeportesDisponibles
                                     FROM ''' + @FilePath + N'''
                                     WITH
                                     (
                                         FIRSTROW = 2,             -- Empezamos a leer desde la segunda fila (ignoramos el encabezado)
                                         FIELDTERMINATOR = '';'',  -- *** IMPORTANTE: Usa punto y coma (;) como delimitador ***
                                         ROWTERMINATOR = ''0x0a'', -- El final de cada fila se identifica con un salto de línea (LF).                             
                                         TABLOCK                   -- Ayuda a optimizar la carga masiva bloqueando la tabla temporal
                                     );';
     
        -- Ejecutamos la consulta BULK INSERT que acabamos de construir
        EXEC sp_executesql @consultaSqlDinamica;
        -- MERGE nos permite insertar nuevos deportes o actualizar existentes en un solo paso.
        MERGE actividades.deporteDisponible AS TablaDestino -- Nuestra tabla final donde queremos los datos
        USING (
            -- Preparamos los datos de ORIGEN para la sincronización.
            SELECT
                st.ActividadCsv AS DescripcionDeporte,
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
        -- Mensaje de éxito al usuario
        PRINT 'Proceso de importacion de deportes disponibles completado con exito!';
    END TRY
    BEGIN CATCH
        DECLARE @MensajeError NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @SeveridadError INT = ERROR_SEVERITY();
        DECLARE @EstadoError INT = ERROR_STATE();
        -- Lanzamos el error capturado 
        RAISERROR(@MensajeError, @SeveridadError, @EstadoError);
    END CATCH;
    IF OBJECT_ID('tempdb..#StagingDeportesDisponibles') IS NOT NULL
        DROP TABLE #StagingDeportesDisponibles;
END;
GO

-- CARGAR DATOS DEL CSV
EXEC actividades.importarDeportesDisponibles @FilePath = 'D:\Lautaro_Santillan\UNLaM\Bases de Datos Aplicada\SolNorte-Grupo3-BDDA\SOLNORTE-GRUPO3-BDDA\dataImport\tarifasActividades.csv';
GO

-- VER DATOS CARGADOS
SELECT * FROM actividades.deporteDisponible;
GO

-- ************************************************************************************************
-- Procedimiento: actividades.importarDeportesPileta
-- Descripción: Este procedimiento se encarga de importar y sincronizar las tarifas y horarios
--              de la actividad de pileta desde un archivo CSV con una estructura compleja.
--              Transforma los datos de múltiples filas del CSV en una única fila en la tabla 'actividades.actividadPileta'.
-- Parámetros:
--   @FilePath NVARCHAR(255): Ruta completa del archivo CSV que contiene las tarifas de pileta.
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE actividades.importarDeportesPileta
    @FilePath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    -- Definición de valores por defecto
    DECLARE @DefaultTariffValue DECIMAL(10, 2) = 0.01;
    DECLARE @DefaultApertura TIME = '10:00:00';
    DECLARE @DefaultCierre TIME = '20:00:00';

    DECLARE @DynamicSql NVARCHAR(MAX);
    DECLARE @MaxRowNum INT;
    IF OBJECT_ID('tempdb..#StagingPiletaActividad') IS NOT NULL
        DROP TABLE #StagingPiletaActividad;
    
    CREATE TABLE #StagingPiletaActividad (
        RowNum INT IDENTITY(1,1) PRIMARY KEY, -- Añadimos RowNum para ordenar sin CTEs
        TipoValorCsv NVARCHAR(50),
        TipoPersonaCsv NVARCHAR(50),
        TarifaSocioCsv NVARCHAR(50),
        TarifaInvitadoCsv NVARCHAR(50),
        VigenciaHastaCsv NVARCHAR(20)
    );
    IF OBJECT_ID('tempdb..#ProcessedPiletaActividad') IS NOT NULL
        DROP TABLE #ProcessedPiletaActividad;

    CREATE TABLE #ProcessedPiletaActividad (
        idActividad INT PRIMARY KEY,
        tarifaSocioPorDiaAdulto DECIMAL(10,2),
        tarifaSocioPorTemporadaAdulto DECIMAL(10,2),
        tarifaSocioPorMesAdulto DECIMAL(10,2),
        tarifaSocioPorDiaMenor DECIMAL(10,2),
        tarifaSocioPorTemporadaMenor DECIMAL(10,2),
        tarifaSocioPorMesMenor DECIMAL(10,2),
        tarifaInvitadoPorDiaAdulto DECIMAL(10,2),
        tarifaInvitadoPorTemporadaAdulto DECIMAL(10,2),
        tarifaInvitadoPorMesAdulto DECIMAL(10,2),
        tarifaInvitadoPorDiaMenor DECIMAL(10,2),
        tarifaInvitadoPorTemporadaMenor DECIMAL(10,2),
        tarifaInvitadoPorMesMenor DECIMAL(10,2),
        horaAperturaActividad TIME,
        horaCierreActividad TIME,
        vigenciaHasta DATE
    );

    BEGIN TRY
        SET @DynamicSql = N'BULK INSERT #StagingPiletaActividad
                             FROM ''' + @FilePath + N'''
                             WITH
                             (
                                 FIRSTROW = 2,
                                 FIELDTERMINATOR = '';'',
                                 ROWTERMINATOR = ''0x0d0a'', -- CRLF para Windows
                                 TABLOCK                  
                             );';
        
        EXEC sp_executesql @DynamicSql;
        INSERT INTO #ProcessedPiletaActividad (
            idActividad,
            tarifaSocioPorDiaAdulto, tarifaSocioPorTemporadaAdulto, tarifaSocioPorMesAdulto,
            tarifaSocioPorDiaMenor, tarifaSocioPorTemporadaMenor, tarifaSocioPorMesMenor,
            tarifaInvitadoPorDiaAdulto, tarifaInvitadoPorTemporadaAdulto, tarifaInvitadoPorMesAdulto,
            tarifaInvitadoPorDiaMenor, tarifaInvitadoPorTemporadaMenor, tarifaInvitadoPorMesMenor,
            horaAperturaActividad, horaCierreActividad, vigenciaHasta
        )
        SELECT
            1 AS idActividad, -- Siempre será 1 para este registro
            -- Tarifas Socio por Día
            ISNULL(MAX(CASE WHEN PropagatedData.EffectiveTipoValor = 'Valor del dia' AND PropagatedData.TipoPersonaCsv = 'Adultos' 
                             THEN (CASE WHEN ISNUMERIC(PropagatedData.TarifaSocioFormatted) = 1 THEN CAST(PropagatedData.TarifaSocioFormatted AS DECIMAL(10,2)) ELSE @DefaultTariffValue END) END), @DefaultTariffValue),
            ISNULL(MAX(CASE WHEN PropagatedData.EffectiveTipoValor = 'Valor de temporada' AND PropagatedData.TipoPersonaCsv = 'Adultos' 
                             THEN (CASE WHEN ISNUMERIC(PropagatedData.TarifaSocioFormatted) = 1 THEN CAST(PropagatedData.TarifaSocioFormatted AS DECIMAL(10,2)) ELSE @DefaultTariffValue END) END), @DefaultTariffValue),
            ISNULL(MAX(CASE WHEN PropagatedData.EffectiveTipoValor = 'Valor del Mes' AND PropagatedData.TipoPersonaCsv = 'Adultos' 
                             THEN (CASE WHEN ISNUMERIC(PropagatedData.TarifaSocioFormatted) = 1 THEN CAST(PropagatedData.TarifaSocioFormatted AS DECIMAL(10,2)) ELSE @DefaultTariffValue END) END), @DefaultTariffValue),
            ISNULL(MAX(CASE WHEN PropagatedData.EffectiveTipoValor = 'Valor del dia' AND PropagatedData.TipoPersonaCsv = 'Menores de 12 años' 
                             THEN (CASE WHEN ISNUMERIC(PropagatedData.TarifaSocioFormatted) = 1 THEN CAST(PropagatedData.TarifaSocioFormatted AS DECIMAL(10,2)) ELSE @DefaultTariffValue END) END), @DefaultTariffValue),
            ISNULL(MAX(CASE WHEN PropagatedData.EffectiveTipoValor = 'Valor de temporada' AND PropagatedData.TipoPersonaCsv = 'Menores de 12 años' 
                             THEN (CASE WHEN ISNUMERIC(PropagatedData.TarifaSocioFormatted) = 1 THEN CAST(PropagatedData.TarifaSocioFormatted AS DECIMAL(10,2)) ELSE @DefaultTariffValue END) END), @DefaultTariffValue),
            ISNULL(MAX(CASE WHEN PropagatedData.EffectiveTipoValor = 'Valor del Mes' AND PropagatedData.TipoPersonaCsv = 'Menores de 12 años' 
                             THEN (CASE WHEN ISNUMERIC(PropagatedData.TarifaSocioFormatted) = 1 THEN CAST(PropagatedData.TarifaSocioFormatted AS DECIMAL(10,2)) ELSE @DefaultTariffValue END) END), @DefaultTariffValue),

            -- Tarifas Invitado por Día
            ISNULL(MAX(CASE WHEN PropagatedData.EffectiveTipoValor = 'Valor del dia' AND PropagatedData.TipoPersonaCsv = 'Adultos' 
                             THEN (CASE WHEN ISNUMERIC(PropagatedData.TarifaInvitadoFormatted) = 1 THEN CAST(PropagatedData.TarifaInvitadoFormatted AS DECIMAL(10,2)) ELSE @DefaultTariffValue END) END), @DefaultTariffValue),
            ISNULL(MAX(CASE WHEN PropagatedData.EffectiveTipoValor = 'Valor de temporada' AND PropagatedData.TipoPersonaCsv = 'Adultos' 
                             THEN (CASE WHEN ISNUMERIC(PropagatedData.TarifaInvitadoFormatted) = 1 THEN CAST(PropagatedData.TarifaInvitadoFormatted AS DECIMAL(10,2)) ELSE @DefaultTariffValue END) END), @DefaultTariffValue),
            ISNULL(MAX(CASE WHEN PropagatedData.EffectiveTipoValor = 'Valor del Mes' AND PropagatedData.TipoPersonaCsv = 'Adultos' 
                             THEN (CASE WHEN ISNUMERIC(PropagatedData.TarifaInvitadoFormatted) = 1 THEN CAST(PropagatedData.TarifaInvitadoFormatted AS DECIMAL(10,2)) ELSE @DefaultTariffValue END) END), @DefaultTariffValue),
            ISNULL(MAX(CASE WHEN PropagatedData.EffectiveTipoValor = 'Valor del dia' AND PropagatedData.TipoPersonaCsv = 'Menores de 12 años' 
                             THEN (CASE WHEN ISNUMERIC(PropagatedData.TarifaInvitadoFormatted) = 1 THEN CAST(PropagatedData.TarifaInvitadoFormatted AS DECIMAL(10,2)) ELSE @DefaultTariffValue END) END), @DefaultTariffValue),
            ISNULL(MAX(CASE WHEN PropagatedData.EffectiveTipoValor = 'Valor de temporada' AND PropagatedData.TipoPersonaCsv = 'Menores de 12 años' 
                             THEN (CASE WHEN ISNUMERIC(PropagatedData.TarifaInvitadoFormatted) = 1 THEN CAST(PropagatedData.TarifaInvitadoFormatted AS DECIMAL(10,2)) ELSE @DefaultTariffValue END) END), @DefaultTariffValue),
            ISNULL(MAX(CASE WHEN PropagatedData.EffectiveTipoValor = 'Valor del Mes' AND PropagatedData.TipoPersonaCsv = 'Menores de 12 años' 
                             THEN (CASE WHEN ISNUMERIC(PropagatedData.TarifaInvitadoFormatted) = 1 THEN CAST(PropagatedData.TarifaInvitadoFormatted AS DECIMAL(10,2)) ELSE @DefaultTariffValue END) END), @DefaultTariffValue),
            -- Horarios fijos por defecto
            @DefaultApertura,
            @DefaultCierre,
            -- Vigencia (se toma la primera fecha encontrada que sea válida)
            MAX(ISNULL(CASE WHEN ISDATE(PropagatedData.VigenciaHastaCsv) = 1 THEN CONVERT(DATE, PropagatedData.VigenciaHastaCsv, 103) ELSE NULL END, '2025-02-28'))
        FROM (
            SELECT
                sa.RowNum,
                -- Simulación de LAG: encontrar el TipoValorCsv del registro anterior no nulo
                ISNULL(sa.TipoValorCsv, (
                    SELECT TOP 1 s_prev.TipoValorCsv
                    FROM #StagingPiletaActividad s_prev
                    WHERE s_prev.RowNum < sa.RowNum AND s_prev.TipoValorCsv IS NOT NULL
                    ORDER BY s_prev.RowNum DESC
                )) AS EffectiveTipoValor,
                sa.TipoPersonaCsv,
                REPLACE(sa.TarifaSocioCsv, ',', '.') AS TarifaSocioFormatted,
                REPLACE(sa.TarifaInvitadoCsv, ',', '.') AS TarifaInvitadoFormatted,
                sa.VigenciaHastaCsv
            FROM #StagingPiletaActividad sa
        ) AS PropagatedData
        GROUP BY (); -- Agrupar por nada para obtener una sola fila de resultados
        IF EXISTS (SELECT 1 FROM actividades.actividadPileta WHERE idActividad = 1)
        BEGIN
            -- Si el registro existe, actualizarlo
            UPDATE Target
            SET
                Target.tarifaSocioPorDiaAdulto = Source.tarifaSocioPorDiaAdulto,
                Target.tarifaSocioPorTemporadaAdulto = Source.tarifaSocioPorTemporadaAdulto,
                Target.tarifaSocioPorMesAdulto = Source.tarifaSocioPorMesAdulto,
                Target.tarifaSocioPorDiaMenor = Source.tarifaSocioPorDiaMenor,
                Target.tarifaSocioPorTemporadaMenor = Source.tarifaSocioPorTemporadaMenor,
                Target.tarifaSocioPorMesMenor = Source.tarifaSocioPorMesMenor,
                Target.tarifaInvitadoPorDiaAdulto = Source.tarifaInvitadoPorDiaAdulto,
                Target.tarifaInvitadoPorTemporadaAdulto = Source.tarifaInvitadoPorTemporadaAdulto,
                Target.tarifaInvitadoPorMesAdulto = Source.tarifaInvitadoPorMesAdulto,
                Target.tarifaInvitadoPorDiaMenor = Source.tarifaInvitadoPorDiaMenor,
                Target.tarifaInvitadoPorTemporadaMenor = Source.tarifaInvitadoPorTemporadaMenor,
                Target.tarifaInvitadoPorMesMenor = Source.tarifaInvitadoPorMesMenor,
                Target.horaAperturaActividad = Source.horaAperturaActividad,
                Target.horaCierreActividad = Source.horaCierreActividad,
                Target.vigenciaHasta = Source.vigenciaHasta
            FROM actividades.actividadPileta AS Target
            INNER JOIN #ProcessedPiletaActividad AS Source ON Target.idActividad = Source.idActividad;
        END
        ELSE
        BEGIN
            -- Si el registro no existe, insertarlo
            SET IDENTITY_INSERT actividades.actividadPileta ON; -- Habilitar para insertar el ID 
            INSERT INTO actividades.actividadPileta (
                idActividad, tarifaSocioPorDiaAdulto, tarifaSocioPorTemporadaAdulto, tarifaSocioPorMesAdulto,
                tarifaSocioPorDiaMenor, tarifaSocioPorTemporadaMenor, tarifaSocioPorMesMenor,
                tarifaInvitadoPorDiaAdulto, tarifaInvitadoPorTemporadaAdulto, tarifaInvitadoPorMesAdulto,
                tarifaInvitadoPorDiaMenor, tarifaInvitadoPorTemporadaMenor, tarifaInvitadoPorMesMenor,
                horaAperturaActividad, horaCierreActividad, vigenciaHasta
            )
            SELECT
                idActividad, tarifaSocioPorDiaAdulto, tarifaSocioPorTemporadaAdulto, tarifaSocioPorMesAdulto,
                tarifaSocioPorDiaMenor, tarifaSocioPorTemporadaMenor, tarifaSocioPorMesMenor,
                tarifaInvitadoPorDiaAdulto, tarifaInvitadoPorTemporadaAdulto, tarifaInvitadoPorMesAdulto,
                tarifaInvitadoPorDiaMenor, tarifaInvitadoPorTemporadaMenor, tarifaInvitadoPorMesMenor,
                horaAperturaActividad, horaCierreActividad, vigenciaHasta
            FROM #ProcessedPiletaActividad;
            SET IDENTITY_INSERT actividades.actividadPileta OFF; -- Deshabilitar
        END;
        PRINT 'Tarifas y horarios de actividad de pileta importados/actualizados con éxito!';
    END TRY
    BEGIN CATCH
        -- Asegurar que IDENTITY_INSERT se desactive en caso de error
        IF (SELECT OBJECTPROPERTY(OBJECT_ID('actividades.actividadPileta'), 'TableHasIdentity')) = 1
           AND (SELECT COLUMNPROPERTY(OBJECT_ID('actividades.actividadPileta'), 'idActividad', 'IsIdentity')) = 1
           AND EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('actividades.actividadPileta') AND is_identity = 1 AND is_computed = 0 AND OBJECTPROPERTY(object_id, 'TableHasIdentity') = 1)
        BEGIN
            SET IDENTITY_INSERT actividades.actividadPileta OFF;
        END;
        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
    IF OBJECT_ID('tempdb..#StagingPiletaActividad') IS NOT NULL
        DROP TABLE #StagingPiletaActividad;
    IF OBJECT_ID('tempdb..#ProcessedPiletaActividad') IS NOT NULL
        DROP TABLE #ProcessedPiletaActividad;
END;
GO

-- CARGAR DATOS DEL CSV
EXEC actividades.importarDeportesPileta
    @FilePath = 'D:\Lautaro_Santillan\UNLaM\Bases de Datos Aplicada\SolNorte-Grupo3-BDDA\SOLNORTE-GRUPO3-BDDA\dataImport\tarifasActividadesPileta.csv';
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
SELECT * FROM
    actividades.actividadPileta;
GO

-- ************************************************************************************************
-- Procedimiento: actividades.importarPresentismoActividadSocio
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
    -- (Para este caso identificamos 9 columnas: 5 de datos reales + 4 columnas vacias adicionales)
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
    -- Manejo de errores: Si algo sale mal, capturamos el error
    BEGIN TRY
        -- Construimos la sentencia BULK INSERT de forma dinamica. Esto es necesario porque la ruta del archivo CSV es una variable.
        SET @consultaSqlDinamica = N'BULK INSERT #TablaDeCargaTemporal
                                     FROM ''' + @FilePath + N'''
                                     WITH
                                     (
                                         FIRSTROW = 2,            -- Empezamos a leer desde la segunda fila (por el encabezado)
                                         FIELDTERMINATOR = '';'', -- Los campos estan separados por ;
                                         ROWTERMINATOR = ''0x0a'',-- El final de cada fila se identifica con un salto de linea
                                         TABLOCK                  -- Ayuda a optimizar la carga masiva bloqueando la tabla temporal
                                     );';
        -- Ejecutamos la consulta BULK INSERT que acabamos de construir
        EXEC sp_executesql @consultaSqlDinamica;
        -- MERGE nos permite insertar nuevas filas o actualizar existentes en un solo paso.
        MERGE actividades.presentismoActividadSocio AS TablaDestino
        USING (
            -- Preparamos los datos de ORIGEN para la sincronizacion y realizamos INNER JOIN para validar los datos
            SELECT
                CAST(REPLACE(st.NumeroDeSocioCsv, 'SN-', '') AS INT) AS idSocioFinal, -- Transformamos el numero de socio (ej. 'SN-4148' a 4148)
                da.idDeporteActivo,
                CONVERT(DATE, st.FechaAsistenciaCsv, 103) AS FechaDeAsistenciaFinal,
                st.EstadoAsistenciaCsv AS EstadoPresentismoFinal,
                st.ProfesorCsv AS ProfesorAsociado
            FROM
                #TablaDeCargaTemporal st
            INNER JOIN
                actividades.deporteDisponible dd ON st.ActividadCsv = dd.descripcion -- Solo procesamos filas si la 'Actividad' del CSV existe en nuestra tabla 'deporteDisponible'
            INNER JOIN
                actividades.deporteActivo da ON CAST(REPLACE(st.NumeroDeSocioCsv, 'SN-', '') AS INT) = da.idSocio
                                            AND dd.idDeporte = da.idDeporte -- Solo procesamos filas si el socio ya esta asociado a ese deporte en nuestra tabla 'deporteActivo'
        ) AS TablaOrigen (idSocio, idDeporteActivo, fechaActividad, estadoPresentismo, profesorDeporte)
        -- Definimos las condiciones para saber si una fila ya existe en la tabla destino.
        ON TablaDestino.idSocio = TablaOrigen.idSocio
           AND TablaDestino.idDeporteActivo = TablaOrigen.idDeporteActivo
           AND TablaDestino.fechaActividad = TablaOrigen.fechaActividad
        -- Si la fila ya existe en la tabla destino (coincide con las 3 condiciones de arriba)
        WHEN MATCHED THEN
            UPDATE SET
                TablaDestino.estadoPresentismo = TablaOrigen.estadoPresentismo, -- Actualizamos el estado
                TablaDestino.profesorDeporte = TablaOrigen.profesorDeporte      -- Profesor
        -- Si la fila NO existe en la tabla destino (no coincide con las 3 condiciones)
        WHEN NOT MATCHED THEN
            INSERT (idSocio, idDeporteActivo, fechaActividad, estadoPresentismo, profesorDeporte)
            VALUES (TablaOrigen.idSocio, TablaOrigen.idDeporteActivo, TablaOrigen.fechaActividad, TablaOrigen.estadoPresentismo, TablaOrigen.profesorDeporte);
        -- Mensaje de exito al usuario
        PRINT 'Proceso de importacion de presentismo completado con exito!';
    END TRY
    BEGIN CATCH
        DECLARE @MensajeError NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @SeveridadError INT = ERROR_SEVERITY();
        DECLARE @EstadoError INT = ERROR_STATE();
        -- Lanzamos el error capturado
        RAISERROR(@MensajeError, @SeveridadError, @EstadoError);
    END CATCH;
    -- Eliminamos la tabla temporal para liberar recursos
    IF OBJECT_ID('tempdb..#TablaDeCargaTemporal') IS NOT NULL
        DROP TABLE #TablaDeCargaTemporal;
END;
GO

-- CARGAR DATOS DEL CSV
EXEC actividades.importarPresentismoActividadSocio @FilePath = 'D:\Lautaro_Santillan\UNLaM\Bases de Datos Aplicada\SolNorte-Grupo3-BDDA\SOLNORTE-GRUPO3-BDDA\dataImport\presentismo_actividades.csv';
GO

-- VER DATOS CARGADOS
SELECT * FROM actividades.presentismoActividadSocio;
GO