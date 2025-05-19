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

INSERT INTO socios.socio (
  dni, cuil, nombre, apellido, email, telefono,
  fechaNacimiento, fechaDeVigenciaContraseña, contactoDeEmergencia,
  usuario, contraseña, estadoMembresia, saldoAFavor
) VALUES
(10123456, 20101234561, 'Juan', 'Pérez', 'juan.perez@gmail.com', '1134567890', '1985-04-12', '2025-01-01', '1122334455', 'jperez', 'clave123', 'Activo', 0.00),
(10234567, 20102345672, 'María', 'Gómez', 'maria.gomez@yahoo.com', '1145678901', '1990-08-23', '2025-01-01', '1133445566', 'mgomez', 'clave123', 'Activo', 100.00),
(10345678, 20103456783, 'Carlos', 'Rodríguez', 'carlos.r@gmail.com', '1156789012', '1978-02-14', '2025-01-01', '1144556677', 'crodriguez', 'clave123', 'Activo', 200.00),
(10456789, 20104567894, 'Ana', 'Martínez', 'ana.martinez@hotmail.com', '1167890123', '1995-12-01', '2025-01-01', '1155667788', 'amartinez', 'clave123', 'Activo', 300.00),
(10567890, 20105678905, 'Luis', 'Fernández', 'luisf@live.com', '1178901234', '1982-11-19', '2025-01-01', '1166778899', 'lfernandez', 'clave123', 'Activo', 400.00),
(10678901, 20106789016, 'Laura', 'López', 'laura.lopez@gmail.com', '1189012345', '1998-06-30', '2025-01-01', '1177889900', 'llopez', 'clave123', 'Activo', 500.00),
(10789012, 20107890127, 'Jorge', 'García', 'jorge.garcia@gmail.com', '1190123456', '1987-09-07', '2025-01-01', '1188990011', 'jgarcia', 'clave123', 'Activo', 600.00),
(10890123, 20108901238, 'Valeria', 'Díaz', 'valeria.diaz@gmail.com', '1101234567', '1991-03-18', '2025-01-01', '1199001122', 'vdiaz', 'clave123', 'Activo', 700.00),
(10901234, 20109012349, 'Ricardo', 'Sánchez', 'ricardo.s@hotmail.com', '1112345678', '1983-07-11', '2025-01-01', '1110011223', 'rsanchez', 'clave123', 'Activo', 800.00),
(11012345, 20110123450, 'Sofía', 'Torres', 'sofia.torres@gmail.com', '1123456789', '1996-10-29', '2025-01-01', '1121122334', 'storres', 'clave123', 'Activo', 900.00),
(11123456, 20111234561, 'Diego', 'Ramírez', 'diego.ramirez@gmail.com', '1134567890', '1989-05-06', '2025-01-01', '1132233445', 'dramirez', 'clave123', 'Activo', 0.00),
(11234567, 20112345672, 'Julieta', 'Moreno', 'julieta.moreno@yahoo.com', '1145678901', '1994-01-27', '2025-01-01', '1143344556', 'jmoreno', 'clave123', 'Activo', 100.00),
(11345678, 20113456783, 'Martín', 'Silva', 'martin.silva@gmail.com', '1156789012', '1980-06-02', '2025-01-01', '1154455667', 'msilva', 'clave123', 'Activo', 200.00),
(11456789, 20114567894, 'Camila', 'Ortiz', 'camila.ortiz@gmail.com', '1167890123', '1992-11-11', '2025-01-01', '1165566778', 'cortiz', 'clave123', 'Activo', 300.00),
(11567890, 20115678905, 'Pedro', 'Molina', 'pedro.molina@live.com', '1178901234', '1986-03-16', '2025-01-01', '1176677889', 'pmolina', 'clave123', 'Activo', 400.00),
(11678901, 20116789016, 'Lucía', 'Rojas', 'lucia.rojas@gmail.com', '1189012345', '1999-09-09', '2025-01-01', '1187788990', 'lrojas', 'clave123', 'Activo', 500.00),
(11789012, 20117890127, 'Fernando', 'Castro', 'fernando.castro@gmail.com', '1190123456', '1977-04-04', '2025-01-01', '1198899001', 'fcastro', 'clave123', 'Activo', 600.00),
(11890123, 20118901238, 'Elena', 'Acosta', 'elena.acosta@gmail.com', '1101234567', '1993-12-21', '2025-01-01', '1109900112', 'eacosta', 'clave123', 'Activo', 700.00),
(11901234, 20119012349, 'Gabriel', 'Cruz', 'gabriel.cruz@hotmail.com', '1112345678', '1981-08-08', '2025-01-01', '1111011223', 'gcruz', 'clave123', 'Activo', 800.00),
(12012345, 20120123450, 'Florencia', 'Herrera', 'florencia.herrera@gmail.com', '1123456789', '1997-02-05', '2025-01-01', '1122122334', 'fherrera', 'clave123', 'Activo', 900.00);

SELECT TOP 10 * FROM socios.socio

CREATE OR ALTER PROCEDURE socios.insertarSocio
    @dni BIGINT,
    @cuil BIGINT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @email VARCHAR(100) = NULL,
    @telefono VARCHAR(11) = NULL,
    @fechaNacimiento DATE = NULL,
    @fechaDeVigenciaContrasenia DATE = NULL,
    @contactoDeEmergencia VARCHAR(11) = NULL,
    @usuario VARCHAR(50) = NULL,
    @contrasenia VARCHAR(10) = NULL,
    @estadoMembresia VARCHAR(8),
    @saldoAFavor DECIMAL(10,2) = 0.00
AS
BEGIN

    INSERT INTO socios.socio
        (dni, cuil, nombre, apellido, email, telefono,
         fechaNacimiento, fechaDeVigenciaContrasenia, contactoDeEmergencia,
         usuario, contrasenia, estadoMembresia, saldoAFavor)
    VALUES
        (@dni, @cuil, @nombre, @apellido, @email, @telefono,
         @fechaNacimiento, @fechaDeVigenciaContrasenia, @contactoDeEmergencia,
         @usuario, @contrasenia, @estadoMembresia, @saldoAFavor);

END
GO

CREATE PROCEDURE socios.modificarSocio
    @dni BIGINT,

AS
BEGIN

	 UPDATE socios.socio
	 SET 
	 WHERE id = @id 

END
GO

EXEC socios.insertarSocio 10123455, 20101234562, 'Juan', 'Pérez', 'juan.perez@gmail.com', '1134567890', '1985-04-12', '2025-01-01', '1122334455', 'juperez', 'clave123', 'Activo', 0.00

CREATE OR ALTER PROCEDURE socios.modificarSocio
    @idSocio                    INT,
    @dni                        BIGINT      = NULL,
    @cuil                       BIGINT      = NULL,
    @nombre                     VARCHAR(100)= NULL,
    @apellido                   VARCHAR(100)= NULL,
    @email                      VARCHAR(100)= NULL,
    @telefono                   VARCHAR(11) = NULL,
    @fechaNacimiento            DATE        = NULL,
    @fechaDeVigenciaContrasenia DATE      = NULL,
    @contactoDeEmergencia       VARCHAR(11) = NULL,
    @usuario                    VARCHAR(50) = NULL,
    @contrasenia                VARCHAR(10) = NULL,
    @estadoMembresia            VARCHAR(8)  = NULL,
    @saldoAFavor                DECIMAL(10,2)= NULL,
    @direccion                  VARCHAR(100)= NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE socios.socio
    SET
        dni                       = COALESCE(@dni, dni),
        cuil                      = COALESCE(@cuil, cuil),
        nombre                    = COALESCE(@nombre, nombre),
        apellido                  = COALESCE(@apellido, apellido),
        email                     = COALESCE(@email, email),
        telefono                  = COALESCE(@telefono, telefono),
        fechaNacimiento           = COALESCE(@fechaNacimiento, fechaNacimiento),
        fechaDeVigenciaContrasenia= COALESCE(@fechaDeVigenciaContrasenia, fechaDeVigenciaContrasenia),
        contactoDeEmergencia      = COALESCE(@contactoDeEmergencia, contactoDeEmergencia),
        usuario                   = COALESCE(@usuario, usuario),
        contrasenia               = COALESCE(@contrasenia, contrasenia),
        estadoMembresia           = COALESCE(@estadoMembresia, estadoMembresia),
        saldoAFavor               = COALESCE(@saldoAFavor, saldoAFavor),
        direccion                 = COALESCE(@direccion, direccion)
    WHERE idSocio = @idSocio;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No existe un socio con idSocio = %d.', 16, 1, @idSocio);
    END
END;
GO

EXEC socios.usp_ModificarSocio
    @idSocio        = 2,
    @nombre         = 'María',
    @apellido       = 'Pérez',
    @saldoAFavor    = 150.75;

CREATE OR ALTER PROCEDURE socios.eliminarSocio
    @idSocio INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM socios.socio
    WHERE idSocio = @idSocio and estadoMembresia = 'Inactivo';
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No se encontró ningún socio con id = %d o el socio encontrado esta actualmente activo', 16, 1, @idSocio);
    END
END
GO

EXEC socios.sp_Eliminar_Socio @idSocio = 1