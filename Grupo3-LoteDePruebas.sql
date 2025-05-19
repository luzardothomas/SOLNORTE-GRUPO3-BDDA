USE SolNorte_Grupo3
GO

-- Eliminar todas las tablas

DROP TABLE itinerarios.itinerario
DROP TABLE actividades.actividadRecreativa
DROP TABLE actividades.deporteActivo
DROP TABLE actividades.deporteDisponible
DROP TABLE descuentos.descuento
DROP TABLE socios.tutorACargo
DROP TABLE socios.categoriaSocio
DROP TABLE coberturas.prepagaEnUso
DROP TABLE coberturas.coberturaDisponible
DROP TABLE pagos.reembolso
DROP TABLE pagos.facturaCobro
DROP TABLE pagos.medioEnUso
DROP TABLE pagos.medioDePago
DROP TABLE socios.rolVigente
DROP TABLE socios.rolDisponible
DROP TABLE socios.socio

-- :::::::::::::::::::::::::::::::::::::::::::: SOCIOS ::::::::::::::::::::::::::::::::::::::::::::

-- INSERTAR

EXEC socios.insertarSocio 10123456, 20101234561, 'Juan', 'Pérez', 'juan.perez@gmail.com', '1134567890', '1985-04-12', '2028-01-01', '1122334455', 'jperez', 'clave123', 'Activo', 0.00
EXEC socios.insertarSocio 10234567, 20102345672, 'María', 'Gómez', 'maria.gomez@yahoo.com', '1145678901', '1990-08-23', '2028-01-01', '1133445566', 'mgomez', 'clave123', 'Activo', 100.00
EXEC socios.insertarSocio 10345678, 20103456783, 'Carlos', 'Rodríguez', 'carlos.r@gmail.com', '1156789012', '1978-02-14', '2028-01-01', '1144556677', 'crodriguez', 'clave123', 'Activo', 200.00
EXEC socios.insertarSocio 10456789, 20104567894, 'Ana', 'Martínez', 'ana.martinez@hotmail.com', '1167890123', '1995-12-01', '2028-01-01', '1155667788', 'amartinez', 'clave123', 'Activo', 300.00
EXEC socios.insertarSocio 10567890, 20105678905, 'Luis', 'Fernández', 'luisf@live.com', '1178901234', '1982-11-19', '2028-01-01', '1166778899', 'lfernandez', 'clave123', 'Activo', 400.00
EXEC socios.insertarSocio 10678901, 20106789016, 'Laura', 'López', 'laura.lopez@gmail.com', '1189012345', '1998-06-30', '2028-01-01', '1177889900', 'llopez', 'clave123', 'Activo', 500.00
EXEC socios.insertarSocio 10789012, 20107890127, 'Jorge', 'García', 'jorge.garcia@gmail.com', '1190123456', '1987-09-07', '2028-01-01', '1188990011', 'jgarcia', 'clave123', 'Activo', 600.00
EXEC socios.insertarSocio 10890123, 20108901238, 'Valeria', 'Díaz', 'valeria.diaz@gmail.com', '1101234567', '1991-03-18', '2028-01-01', '1199001122', 'vdiaz', 'clave123', 'Activo', 700.00
EXEC socios.insertarSocio 10901234, 20109012349, 'Ricardo', 'Sánchez', 'ricardo.s@hotmail.com', '1112345678', '1983-07-11', '2028-01-01', '1110011223', 'rsanchez', 'clave123', 'Activo', 800.00
EXEC socios.insertarSocio 11012345, 20110123450, 'Sofía', 'Torres', 'sofia.torres@gmail.com', '1123456789', '1996-10-29', '2028-01-01', '1121122334', 'storres', 'clave123', 'Activo', 900.00
EXEC socios.insertarSocio 11123456, 20111234561, 'Diego', 'Ramírez', 'diego.ramirez@gmail.com', '1134567890', '1989-05-06', '2028-01-01', '1132233445', 'dramirez', 'clave123', 'Activo', 0.00
EXEC socios.insertarSocio 11234567, 20112345672, 'Julieta', 'Moreno', 'julieta.moreno@yahoo.com', '1145678901', '1994-01-27', '2028-01-01', '1143344556', 'jmoreno', 'clave123', 'Activo', 100.00
EXEC socios.insertarSocio 11345678, 20113456783, 'Martín', 'Silva', 'martin.silva@gmail.com', '1156789012', '1980-06-02', '2028-01-01', '1154455667', 'msilva', 'clave123', 'Activo', 200.00
EXEC socios.insertarSocio 11456789, 20114567894, 'Camila', 'Ortiz', 'camila.ortiz@gmail.com', '1167890123', '1992-11-11', '2028-01-01', '1165566778', 'cortiz', 'clave123', 'Activo', 300.00
EXEC socios.insertarSocio 11567890, 20115678905, 'Pedro', 'Molina', 'pedro.molina@live.com', '1178901234', '1986-03-16', '2028-01-01', '1176677889', 'pmolina', 'clave123', 'Activo', 400.00
EXEC socios.insertarSocio 11678901, 20116789016, 'Lucía', 'Rojas', 'lucia.rojas@gmail.com', '1189012345', '1999-09-09', '2028-01-01', '1187788990', 'lrojas', 'clave123', 'Activo', 500.00
EXEC socios.insertarSocio 11789012, 20117890127, 'Fernando', 'Castro', 'fernando.castro@gmail.com', '1190123456', '1977-04-04', '2028-01-01', '1198899001', 'fcastro', 'clave123', 'Activo', 600.00
EXEC socios.insertarSocio 11890123, 20118901238, 'Elena', 'Acosta', 'elena.acosta@gmail.com', '1101234567', '1993-12-21', '2028-01-01', '1109900112', 'eacosta', 'clave123', 'Activo', 700.00
EXEC socios.insertarSocio 11901234, 20119012349, 'Gabriel', 'Cruz', 'gabriel.cruz@hotmail.com', '1112345678', '1981-08-08', '2028-01-01', '1111011223', 'gcruz', 'clave123', 'Activo', 800.00
EXEC socios.insertarSocio 12012345, 20120123450, 'Florencia', 'Herrera', 'florencia.herrera@gmail.com', '1123456789', '1997-02-05', '2028-01-01', '1122122334', 'fherrera', 'clave123', 'Activo', 900.00


SELECT TOP 20 *
FROM socios.socio s 

-- MODIFICAR

EXEC socios.modificarSocio @idSocio = 1,@nombre = 'Maria',@apellido = 'Gutierrez',@saldoAFavor = 150.75;
EXEC socios.modificarSocio @idSocio = 2,@apellido = 'Hilton',@saldoAFavor = 800.75;
EXEC socios.modificarSocio @idSocio = 3,@saldoAFavor = 1250.50; 

SELECT TOP 3 *
FROM socios.socio s 

-- ELIMINAR

EXEC socios.eliminarSocio @idSocio = 1
EXEC socios.eliminarSocio @idSocio = 2
EXEC socios.eliminarSocio @idSocio = 3
EXEC socios.eliminarSocio @idSocio = 4
EXEC socios.eliminarSocio @idSocio = 5

SELECT TOP 5 *
FROM socios.socio