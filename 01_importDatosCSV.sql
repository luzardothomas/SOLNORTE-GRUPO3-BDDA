-- Usar la base de datos
USE Com2900G03;
GO

-- Datos de Prueba (NO SON LOS REALES QUE VAN A IR ***)

-- Insertar datos en socios.categoriaMembresiaSocio ***
INSERT INTO socios.categoriaSocio (tipo, costoMembresia, estadoCategoriaSocio) VALUES
('Menor', 50.00, 1),
('Cadete', 80.00, 1),
('Mayor', 120.00, 1);
GO

-- Insertar datos en actividades.deporteDisponible ***
INSERT INTO actividades.deporteDisponible (descripcion, tipo, costoPorMes) VALUES
('Futsal', 'Equipo', 30.00),
('Natacion', 'Individual', 40.00),
('Spinning', 'Clase', 25.00),
('Yoga', 'Clase', 35.00);
GO

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
-- Procedimiento: actividades.importarPresentismoActividadSocio
-- Descripcion: Este procedimiento se encarga de importar los registros de presentismo de las actividades de los socios desde un archivo CSV.
-- Parametros:
--   @@FilePath NVARCHAR(255): Ruta completa del archivo CSV a importar.
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE actividades.importarPresentismoActividadSocio
    @FilePath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @consultaSqlDinamica NVARCHAR(MAX);
    -- Si ya existe una tabla temporal con este nombre de una ejecucion anterior, la eliminamos
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
                CONVERT(DATE, st.FechaAsistenciaCsv, 103) AS FechaDeAsistenciaFinal, -- Convertimos la fecha del CSV al formato DATE de SQL Server
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

EXEC actividades.importarPresentismoActividadSocio @FilePath = 'D:\Lautaro_Santillan\UNLaM\Bases de Datos Aplicada\SolNorte-Grupo3-BDDA\SOLNORTE-GRUPO3-BDDA\dataImport\presentismo_actividades.csv';
GO

-- VER DATOS CARGADOS
SELECT * FROM actividades.presentismoActividadSocio;
GO