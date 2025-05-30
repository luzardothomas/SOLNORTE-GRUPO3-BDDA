USE SolNorte_Grupo3
GO

-- Eliminar todas las tablas

--DROP TABLE itinerarios.itinerario
--DROP TABLE actividades.actividadRecreativa
--DROP TABLE actividades.deporteActivo
--DROP TABLE actividades.deporteDisponible
--DROP TABLE descuentos.descuentoVigente
--DROP TABLE descuentos.descuentoDisponible
--DROP TABLE socios.tutorACargo
--DROP TABLE socios.categoriaSocio
--DROP TABLE coberturas.prepagaEnUso
--DROP TABLE coberturas.coberturaDisponible
--DROP TABLE pagos.reembolso
--DROP TABLE pagos.facturaCobro
--DROP TABLE pagos.medioEnUso
--DROP TABLE pagos.medioDePago
--DROP TABLE socios.rolVigente
--DROP TABLE socios.rolDisponible
--DROP TABLE socios.socio

-- :::::::::::::::::::::::::::::::::::::::::::: SOCIOS ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA SOCIO ###### 

-- INSERTAR

EXEC socios.insertarSocio 10123456, 20101234561, 'Juan', 'P�rez', 'juan.perez@gmail.com', '1134567890', '1985-04-12', '2028-01-01', '1122334455', 'jperez', 'clave123', 'Activo', 0.00
EXEC socios.insertarSocio 10234567, 20102345672, 'Mar�a', 'G�mez', 'maria.gomez@yahoo.com', '1145678901', '1990-08-23', '2028-01-01', '1133445566', 'mgomez', 'clave123', 'Activo', 100.00
EXEC socios.insertarSocio 10345678, 20103456783, 'Carlos', 'Rodr�guez', 'carlos.r@gmail.com', '1156789012', '1978-02-14', '2028-01-01', '1144556677', 'crodriguez', 'clave123', 'Activo', 200.00
EXEC socios.insertarSocio 10456789, 20104567894, 'Ana', 'Mart�nez', 'ana.martinez@hotmail.com', '1167890123', '1995-12-01', '2028-01-01', '1155667788', 'amartinez', 'clave123', 'Activo', 300.00
EXEC socios.insertarSocio 10567890, 20105678905, 'Luis', 'Fern�ndez', 'luisf@live.com', '1178901234', '1982-11-19', '2028-01-01', '1166778899', 'lfernandez', 'clave123', 'Activo', 400.00
EXEC socios.insertarSocio 10678901, 20106789016, 'Laura', 'L�pez', 'laura.lopez@gmail.com', '1189012345', '1998-06-30', '2028-01-01', '1177889900', 'llopez', 'clave123', 'Activo', 500.00
EXEC socios.insertarSocio 10789012, 20107890127, 'Jorge', 'Garc�a', 'jorge.garcia@gmail.com', '1190123456', '1987-09-07', '2028-01-01', '1188990011', 'jgarcia', 'clave123', 'Activo', 600.00
EXEC socios.insertarSocio 10890123, 20108901238, 'Valeria', 'D�az', 'valeria.diaz@gmail.com', '1101234567', '1991-03-18', '2028-01-01', '1199001122', 'vdiaz', 'clave123', 'Activo', 700.00
EXEC socios.insertarSocio 10901234, 20109012349, 'Ricardo', 'S�nchez', 'ricardo.s@hotmail.com', '1112345678', '1983-07-11', '2028-01-01', '1110011223', 'rsanchez', 'clave123', 'Activo', 800.00
EXEC socios.insertarSocio 11012345, 20110123450, 'Sof�a', 'Torres', 'sofia.torres@gmail.com', '1123456789', '1996-10-29', '2028-01-01', '1121122334', 'storres', 'clave123', 'Activo', 900.00
EXEC socios.insertarSocio 11123456, 20111234561, 'Diego', 'Ram�rez', 'diego.ramirez@gmail.com', '1134567890', '1989-05-06', '2028-01-01', '1132233445', 'dramirez', 'clave123', 'Activo', 0.00
EXEC socios.insertarSocio 11234567, 20112345672, 'Julieta', 'Moreno', 'julieta.moreno@yahoo.com', '1145678901', '1994-01-27', '2028-01-01', '1143344556', 'jmoreno', 'clave123', 'Activo', 100.00
EXEC socios.insertarSocio 11345678, 20113456783, 'Mart�n', 'Silva', 'martin.silva@gmail.com', '1156789012', '1980-06-02', '2028-01-01', '1154455667', 'msilva', 'clave123', 'Activo', 200.00
EXEC socios.insertarSocio 11456789, 20114567894, 'Camila', 'Ortiz', 'camila.ortiz@gmail.com', '1167890123', '1992-11-11', '2028-01-01', '1165566778', 'cortiz', 'clave123', 'Activo', 300.00
EXEC socios.insertarSocio 11567890, 20115678905, 'Pedro', 'Molina', 'pedro.molina@live.com', '1178901234', '1986-03-16', '2028-01-01', '1176677889', 'pmolina', 'clave123', 'Activo', 400.00
EXEC socios.insertarSocio 11678901, 20116789016, 'Luc�a', 'Rojas', 'lucia.rojas@gmail.com', '1189012345', '1999-09-09', '2028-01-01', '1187788990', 'lrojas', 'clave123', 'Activo', 500.00
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

-- ###### TABLA CATEGORIASSOCIO ######

-- INSERTAR

EXEC socios.insertarCategoriaSocio Cadete, 5000
SELECT * FROM socios.categoriaSocio

-- MODIFICAR

EXEC socios.modificarCategoriaSocio 1, Joven, 5500
SELECT * FROM socios.categoriaSocio

-- ELIMINAR
EXEC socios.eliminarCategoriaSocio 2
SELECT * FROM socios.categoriaSocio


-- ###### TABLA ROLDISPONIBLE ######

-- INSERTAR

EXEC socios.insertarRolDisponible 1, Administrador
SELECT * FROM socios.rolDisponible

-- MODIFICAR

EXEC socios.modificarRolDisponible 1, 'Mate sin Azucar'
SELECT * FROM socios.rolDisponible

-- ELIMINAR

EXEC socios.eliminarRolDisponible 1
SELECT * FROM socios.rolDisponible

-- ###### TABLA ROLVIGENTE

-- INSERTAR ROL VIGENTE

EXEC socios.insertarRolVigente
    @idRol = 2,
    @idSocio = 101;

-- MODIFICAR ROL VIGENTE

EXEC socios.modificarRolVigente
    @idRol = 2,
    @idSocio = 101,
    @nuevoIdRol = 3,
    @nuevoIdSocio = 101;

-- ELIMINAR ROL VIGENTE

EXEC socios.eliminarRolVigente
    @idRol = 3,
    @idSocio = 101;

-- :::::::::::::::::::::::::::::::::::::::::::: PAGOS ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA FACTURACOBRO

EXEC pagos.insertarFacturaCobro
    @idSocio = 101,
    @fechaEmision = '2025-05-20',
    @fechaPrimerVencimiento = '2025-06-01',
    @fechaSegundoVencimiento = '2025-06-10',
    @cuitDeudor = 20304050607,
    @idMedioDePago = 2,
    @tipoMedioDePago = 'Transferencia',
    @direccion = 'Calle Falsa 123',
    @tipoCobro = 'Mensual',
    @numeroCuota = 1,
    @servicioPagado = 'Servicio A',
    @importeBruto = 5000.00,
    @importeTotal = 5500.00;

EXEC pagos.modificarFacturaCobro
    @idFactura = 10,
    @importeTotal = 5600.00,
    @direccion = 'Nueva Direcci�n 456';

EXEC pagos.eliminarFacturaCobro
    @idFactura = 10;

-- ###### TABLA REEMBOLSO

-- INSERTAR REEMBOLSO

EXEC pagos.insertarReembolso
    @idFacturaOriginal = 10,
    @montoReembolsado = 1000.00,
    @cuitDestinatario = 30111222333,
    @medioDePago = 'Cheque';

-- MODIFICAR REEMBOLSO

EXEC pagos.modificarReembolso
    @idFacturaReembolso = 5,
    @idFacturaOriginal = 10,
    @montoReembolsado = 1200.00,
    @medioDePago = 'Transferencia';

-- ELIMINAR REEMBOLSO

EXEC pagos.eliminarReembolso
    @idFacturaReembolso = 5,
    @idFacturaOriginal = 10;

-- ###### TABLA MEDIODEPAGO ######

-- INSERTAR

EXEC pagos.insertarMedioDePago 1,'Debito','Mastercard Debito'
SELECT * FROM pagos.medioDePago

-- MODIFICAR

EXEC pagos.modificarMedioDePago -1, 'Credito', 'Mastercard Cr�dito'
SELECT * FROM pagos.medioDePago

-- ELIMINAR

EXEC pagos.eliminarMedioDePago 1, 'Debito'
SELECT * FROM pagos.medioDePago

-- :::::::::::::::::::::::::::::::::::::::::::: ACTIVIDADES ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA DEPORTEDISPONIBLE ######

-- INSERTAR

EXEC actividades.insertarDeporteDisponible 'F�tbol', 'F�tbol 5', 1500.00;
EXEC actividades.insertarDeporteDisponible 'Basquet', 'Cancha profesional', 1500.00;
EXEC actividades.insertarDeporteDisponible 'Tenis', 'Cancha ladrillo', 1500.00;

SELECT TOP 3 *
FROM actividades.DeporteDisponible

-- MODIFICAR

EXEC actividades.modificarDeporteDisponible @idDeporte = 1, @tipo = 'Kickboxing',@descripcion = 'Cuadrilatero',@costoPorMes = 1250.25;

SELECT TOP 3 *
FROM actividades.DeporteDisponible

-- ELIMINAR

EXEC actividades.eliminarDeporteDisponible @idDeporte = 1

-- ###### TABLA ACTIVIDAD RECREATIVA ######

-- INSERTAR
-- Casos Validos
EXEC actividades.insertarActividadRecreativa 'F�tbol', '18:00', '20:00', 50.00, 75.00;
EXEC actividades.insertarActividadRecreativa 'Bochas', '08:30', '10:00', 15.00, 20.00;
EXEC actividades.insertarActividadRecreativa 'Ajedrez', '09:00', '11:00', 20.00, 35.00;

SELECT *
FROM actividades.actividadRecreativa 
-- Casos Invalidos
EXEC actividades.insertarActividadRecreativa '', '18:00', '20:00', 50.00, 75.00; -- Descripci�n vac�a
EXEC actividades.insertarActividadRecreativa 'F�tbol', '', '20:00', 50.00, 75.00; -- Hora de inicio vac�a
EXEC actividades.insertarActividadRecreativa 'F�tbol', '18:00', '', 50.00, 75.00; -- Hora de fin vac�a
EXEC actividades.insertarActividadRecreativa 'F�tbol', '18:00', '20:00', 0, 75.00;    -- Tarifa socio inv�lida
EXEC actividades.insertarActividadRecreativa 'F�tbol', '18:00', '20:00', 50.00, 0;    -- Tarifa invitado inv�lida
EXEC actividades.insertarActividadRecreativa 'F�tbol', '18:00', '20:00', -10, 75.00;  -- Tarifa socio negativa
EXEC actividades.insertarActividadRecreativa 'F�tbol', '18:00', '20:00', 50.00, -10;  -- Tarifa invitado negativa

-- MODIFICAR

-- Caso Valido
DECLARE @idActividadModificar INT;
SELECT @idActividadModificar = 2;
EXEC actividades.modificarActividadRecreativa @idActividadModificar, 'F�tbol Recreativo', '13:00', '15:00', 35.00, 55.00;
-- Casos Invalidos
EXEC actividades.modificarActividadRecreativa 9999, 'Tenis', '10:00', '12:00', 60.00, 90.00; -- ID inexistente
EXEC actividades.modificarActividadRecreativa 1, '', '10:00', '12:00', 60.00, 90.00;    -- Descripci�n vac�a
EXEC actividades.modificarActividadRecreativa 1, 'Tenis', '', '12:00', 60.00, 90.00;    -- Hora inicio vac�a
EXEC actividades.modificarActividadRecreativa 1, 'Tenis', '10:00', '', 60.00, 90.00;    -- Hora fin vac�a
EXEC actividades.modificarActividadRecreativa 1, 'Tenis', '10:00', '12:00', 0, 90.00;       -- Tarifa socio inv�lida
EXEC actividades.modificarActividadRecreativa 1, 'Tenis', '10:00', '12:00', 60.00, 0;       -- Tarifa invitado inv�lida

-- ELIMINAR
-- Caso Valido
DECLARE @ultimaActividad INT;
SELECT @ultimaActividad = MAX(idActividad) FROM actividades.actividadRecreativa
EXEC actividades.eliminarActividadRecreativa @ultimaActividad;
-- Caso Invalido
EXEC actividades.eliminarActividadRecreativa 9999; -- ID inexistente

-- ###### TABLA DEPORTEACTIVO ######

-- INSERTAR

EXEC actividades.insertarDeporteActivo @idSocio = 1, @idDeporte = 1
SELECT * FROM actividades.deporteActivo

-- MODIFICAR

EXEC actividades.modificarDeporteActivo @idDeporteActivo = 1, @idSocio = 1, @estadoMembresia = 'Activo';
SELECT * FROM actividades.deporteActivo

-- ELIMINAR

EXEC actividades.eliminarDeporteActivo @idDeporteActivo = 1
SELECT * FROM actividades.deporteActivo

-- :::::::::::::::::::::::::::::::::::::::::::: ITINERARIOS ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA ITINERARIO ######

-- INSERTAR

EXEC itinerarios.insertarItinerario @dia = 'Lunes', @idDeporte = 1, @horaInicio = '08:00', @horaFin = '10:00';

SELECT *
FROM itinerarios.itinerario

-- MODIFICAR

EXEC itinerarios.modificarItinerario @idItinerario = 1, @horaFin = '11:30';

SELECT *
FROM itinerarios.itinerario

-- ELIMINAR

EXEC itinerarios.eliminarItinerario @idItinerario = 1;

SELECT *
FROM itinerarios.itinerario