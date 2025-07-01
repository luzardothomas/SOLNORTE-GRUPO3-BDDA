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

-- =============================================
-- Reporte 1: Morosos Recurrentes
-- =============================================
CREATE OR ALTER PROCEDURE reporte_morososRecurrentes
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;
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
        AND ems.fechaVencimientoMembresia >= @FechaInicio
        AND ems.fechaVencimientoMembresia <= @FechaFin
    QUALIFY -- Utilizando QUALIFY para filtrar por la Window Function
        COUNT(*) OVER (PARTITION BY s.idSocio) > 2
    ORDER BY
        'Ranking Morosidad' DESC; -- Ordenado de Mayor a menor por ranking de morosidad
END;
GO

-- Ejemplo de Ejecución:
EXEC reporte_morososRecurrentes @FechaInicio = '2024-01-01', @FechaFin = '2024-12-31';

-- =============================================
-- Reporte 2: Acumulado Mensual de Ingresos por Actividad Deportiva
-- =============================================
CREATE OR ALTER PROCEDURE reporte_ingresosPorActividadMensual
    @AnioActual INT = NULL -- Opcional: Para especificar el año, por defecto GETDATE()
AS
BEGIN
    SET NOCOUNT ON;
    SET @AnioActual = ISNULL(@AnioActual, YEAR(GETDATE())); -- Si no se especifica el año, usar el año actual
    SELECT
        FORMAT(cf.fechaEmision, 'yyyy-MM') AS 'Año-Mes',
        DATENAME(month, cf.fechaEmision) AS 'Mes',
        -- Asumo que descripcionItem de cuerpoFactura puede ser mapeado a una actividad
        ISNULL(df.descripcion, 'Otros/Desconocido') AS 'Actividad Deportiva',
        SUM(cuerpo.importeItem) AS 'Ingreso Mensual Acumulado'
    FROM
        pagos.facturaEmitida cf
    INNER JOIN
        pagos.cuerpoFactura cuerpo ON cf.idFactura = cuerpo.idFactura
    LEFT JOIN -- LEFT JOIN en caso de que no todo item sea de un deporte disponible
        actividades.deporteDisponible df ON cuerpo.descripcionItem = df.descripcion
    WHERE
        YEAR(cf.fechaEmision) = @AnioActual
        AND MONTH(cf.fechaEmision) >= 1 -- Desde enero
        AND cf.estadoFactura = 'Pagada'
    GROUP BY
        FORMAT(cf.fechaEmision, 'yyyy-MM'),
        DATENAME(month, cf.fechaEmision),
        ISNULL(df.descripcion, 'Otros/Desconocido')
    ORDER BY
        FORMAT(cf.fechaEmision, 'yyyy-MM'),
        'Actividad Deportiva';
END;
GO

-- Ejemplo de Ejecución:
EXEC reporte_ingresosPorActividadMensual @AnioActual = 2024; -- Para el año 2024
EXEC reporte_ingresosPorActividadMensual; -- Para el año actual

-- =============================================
-- Reporte 3: Socios con Actividad Alternada (Inasistencias)
-- =============================================
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
        SUM(CASE WHEN pas.estadoPresentismo IN ('A', 'J') THEN 1 ELSE 0 END) > 0 -- Solo socios con al menos 1 inasistencia
        AND SUM(CASE WHEN pas.estadoPresentismo = 'P' THEN 1 ELSE 0 END) > 0     -- Y al menos 1 asistencia (para "alternada")
    ORDER BY
        'Cantidad Inasistencias' DESC; -- Ordenado de mayor a menor por cantidad de inasistencias
END;
GO

-- Ejemplo de Ejecución:
EXEC reporte_sociosConInasistencias;

-- =============================================
-- Reporte 4: Socios con Cero Asistencias a Actividad
-- =============================================
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
        actividades.presentismoActividadSocio pas ON da.idDeporteActivo = pas.idDeporteActivo AND s.idSocio = pas.idSocio
    GROUP BY
        s.idSocio,
        s.nombre,
        s.apellido,
        s.fechaNacimiento,
        cms.tipo,
        dd.descripcion
    HAVING
        COUNT(CASE WHEN pas.estadoPresentismo = 'P' THEN 1 ELSE NULL END) = 0 -- No tiene asistencias registradas
        AND COUNT(pas.idSocio) > 0; -- Pero sí tiene registros de presentismo (solo 'A' o 'J' o no tiene)
        -- La condición COUNT(pas.idSocio) > 0 asegura que ha habido un intento de registrar presentismo,
END;
GO

-- Ejemplo de Ejecución:
EXEC reporte_sociosSinAsistencia;