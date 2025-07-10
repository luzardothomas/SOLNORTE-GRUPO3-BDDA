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

-- ==================================================================================================================================
-- Reporte 1: Morosos Recurrentes (FUNCIONA)
-- Descripcion: Reporte de los socios morosos, que hayan incumplido en más de dos oportunidades dado un rango de fechas a ingresar. 
-- El reporte debe contener los siguientes datos:
--												Nombre del reporte: Morosos Recurrentes
--												Período: rango de fechas
--												Nro de socio
--												Nombre y apellido.
--												Mes incumplido
--												Ordenados de Mayor a menor por ranking de morosidad
-- El mismo debe ser desarrollado utilizando Windows Function.
-- ==================================================================================================================================
CREATE OR ALTER PROCEDURE reporte_morososRecurrentes
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    WITH MorososCTE AS (
        SELECT
            s.idSocio AS 'Nro de Socio',
            s.nombre AS 'Nombre',
            s.apellido AS 'Apellido',
            DATENAME(month, ems.fechaVencimientoMembresia) AS 'Mes Incumplido',
            YEAR(ems.fechaVencimientoMembresia) AS 'Año Incumplido',
            COUNT(*) OVER (PARTITION BY s.idSocio) AS 'Ranking Morosidad'
        FROM
            socios.socio s
        INNER JOIN
            socios.estadoMembresiaSocio ems ON s.idSocio = ems.idSocio
        WHERE
            ems.estadoMorosidadMembresia IN ('Moroso-1er Vencimiento', 'Moroso-2do Vencimiento', 'Inactivo')
            AND ems.fechaVencimientoMembresia BETWEEN @FechaInicio AND @FechaFin
    )
    SELECT 
        [Nro de Socio],
        [Nombre],
        [Apellido],
        [Mes Incumplido],
        [Año Incumplido],
        [Ranking Morosidad]
    FROM MorososCTE
    WHERE [Ranking Morosidad] > 2 -- Filtra solo a los socios con más de 2 incumplimientos
    ORDER BY [Ranking Morosidad] DESC, [Nro de Socio], [Año Incumplido], [Mes Incumplido];
END;
GO

-- EJECUCION DEL REPORTE
EXEC reporte_morososRecurrentes @FechaInicio = '2024-01-01', @FechaFin = '2024-12-31';
GO

EXEC reporte_morososRecurrentes @FechaInicio = '2025-01-01', @FechaFin = '2025-12-31';
GO

-- ============================================================================
-- Reporte 2: Acumulado Mensual de Ingresos por Actividad Deportiva (FUNCIONA)
-- Descripcion: Reporte acumulado mensual de ingresos por actividad deportiva 
--				al momento en que se saca el reporte tomando como inicio enero.
-- ============================================================================
CREATE OR ALTER PROCEDURE reporte_ingresosPorActividadMensual
    @AnioActual INT = NULL -- Opcional: Para especificar el año, por defecto GETDATE()
AS
BEGIN
    SET NOCOUNT ON;
    SET @AnioActual = ISNULL(@AnioActual, YEAR(GETDATE())); -- Si no se especifica el año, se usa el año actual

    SELECT
        FORMAT(cf.fechaEmision, 'yyyy-MM') AS 'Año-Mes',
        DATENAME(month, cf.fechaEmision) AS 'Mes',
        ISNULL(dd.descripcion, 'Otros/Desconocido') AS 'Actividad Deportiva',
        SUM(cuerpo.importeItem) AS 'Ingreso Mensual Acumulado'
    FROM
        pagos.facturaActiva cf
    INNER JOIN
        pagos.cuerpoFactura cuerpo ON cf.idFactura = cuerpo.idFactura
    LEFT JOIN
        actividades.deporteDisponible dd ON cuerpo.descripcionItem = dd.descripcion
    WHERE
        YEAR(cf.fechaEmision) = @AnioActual
        AND MONTH(cf.fechaEmision) >= 1 -- Desde enero
        AND cf.estadoFactura = 'Pagada'
    GROUP BY
        FORMAT(cf.fechaEmision, 'yyyy-MM'),
        DATENAME(month, cf.fechaEmision),
        ISNULL(dd.descripcion, 'Otros/Desconocido')
    ORDER BY
        FORMAT(cf.fechaEmision, 'yyyy-MM'),
        'Actividad Deportiva';
END;
GO

-- EJECUCION DEL REPORTE
EXEC reporte_ingresosPorActividadMensual @AnioActual = 2024; -- Para el año 2024
GO

EXEC reporte_ingresosPorActividadMensual; -- Para el año actual
GO

-- ===========================================================================================================
-- Reporte 3: Socios con Actividad Alternada (Inasistencias) (FUNCIONA)
-- Descripcion: Reporte de la cantidad de socios que han realizado alguna actividad de forma alternada
--				(inasistencias) por categoría de socios y actividad, ordenado según cantidad de inasistencias
--				ordenadas de mayor a menor.
-- ===========================================================================================================
CREATE OR ALTER PROCEDURE reporte_sociosConInasistencias
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        s.idSocio AS 'Nro Socio',
        s.nombre AS 'Nombre Socio',
        s.apellido AS 'Apellido Socio',
        cms.tipo AS 'Categoría Socio',
        dd.descripcion AS 'Actividad',
        SUM(CASE WHEN pas.estadoPresentismo IN ('A', 'J') THEN 1 ELSE 0 END) AS 'Cantidad Inasistencias',
        SUM(CASE WHEN pas.estadoPresentismo = 'P' THEN 1 ELSE 0 END) AS 'Cantidad Asistencias'
    FROM
        actividades.presentismoActividadSocio pas
    INNER JOIN
        socios.socio s ON pas.idSocio = s.idSocio
    INNER JOIN
        socios.categoriaMembresiaSocio cms ON s.categoriaSocio = cms.idCategoria
    INNER JOIN
        actividades.deporteActivo da ON pas.idDeporteActivo = da.idDeporteActivo
    INNER JOIN
        actividades.deporteDisponible dd ON da.idDeporte = dd.idDeporte
    GROUP BY
        s.idSocio,
        s.nombre,
        s.apellido,
        cms.tipo,
        dd.descripcion
    HAVING
        SUM(CASE WHEN pas.estadoPresentismo IN ('A', 'J') THEN 1 ELSE 0 END) > 0 -- Socios con al menos 1 inasistencia
        AND SUM(CASE WHEN pas.estadoPresentismo = 'P' THEN 1 ELSE 0 END) > 0     -- Y al menos 1 asistencia (para "alternada")
    ORDER BY
        'Cantidad Inasistencias' DESC;
END;
GO

-- EJECUCION DEL REPORTE
EXEC reporte_sociosConInasistencias;

-- ======================================================================================================================
-- Reporte 4: Socios con Cero Asistencias a Actividad (FUNCIONA)
-- Descripcion: Reporte que contenga a los socios que no han asistido a alguna clase 
--				de la actividad que realizan. El reporte debe contener: Nombre, Apellido, edad, categoría y la actividad
-- ======================================================================================================================
CREATE OR ALTER PROCEDURE reporte_sociosSinAsistencia
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        s.nombre AS 'Nombre',
        s.apellido AS 'Apellido',
        DATEDIFF(year, s.fechaNacimiento, GETDATE()) AS 'Edad',
        cms.tipo AS 'Categoría Socio',
        dd.descripcion AS 'Actividad'
    FROM
        socios.socio s
    INNER JOIN
        socios.categoriaMembresiaSocio cms ON s.categoriaSocio = cms.idCategoria
    INNER JOIN
        actividades.deporteActivo da ON s.idSocio = da.idSocio
    INNER JOIN
        actividades.deporteDisponible dd ON da.idDeporte = dd.idDeporte
    LEFT JOIN
        actividades.presentismoActividadSocio pas ON da.idDeporteActivo = pas.idDeporteActivo
                                               AND s.idSocio = pas.idSocio
    WHERE
        pas.idSocio IS NULL
    GROUP BY
        s.idSocio,
        s.nombre,
        s.apellido,
        s.fechaNacimiento,
        cms.tipo,
        dd.descripcion
    ORDER BY
        s.nombre, s.apellido, dd.descripcion;
END;
GO

-- EJECUCION DEL REPORTE
EXEC reporte_sociosSinAsistencia;