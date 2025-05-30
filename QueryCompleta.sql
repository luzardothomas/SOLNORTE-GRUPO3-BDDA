----------------------------------------------------------------------------------------------------
-- Fecha de entrega: 19-05-2025
-- N�mero de grupo: 3
-- Materia: Bases de Datos Aplicada
-- Alumnos:
--   - Codina, Santiago Ivan - 44.391.352
--   - Meynet, Mauro Fernando - 43.252.948
--   - Santillan, Lautaro Ezequiel - 45.175.053
--   - Luzardo, Thomas Gaston - 42.597.231
----------------------------------------------------------------------------------------------------

-- Crear la base de datos SolNorte_Grupo3
CREATE DATABASE SolNorte_Grupo3;
GO

-- Usar la base de datos SolNorte_Grupo3
USE SolNorte_Grupo3;
GO

-- Creaci�n de esquemas para las diferentes gestiones
CREATE SCHEMA socios;
GO

CREATE SCHEMA actividades;
GO

CREATE SCHEMA pagos;
GO

CREATE SCHEMA descuentos;
GO

CREATE SCHEMA itinerarios;
GO

CREATE SCHEMA coberturas;
GO

-- Creaci�n de tablas

-- 1. socios.socio
CREATE TABLE socios.socio (
    idSocio INT PRIMARY KEY IDENTITY(1,1),
    dni BIGINT NOT NULL CHECK (dni > 0),
    cuil BIGINT NOT NULL CHECK (cuil > 0),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(14),
    fechaNacimiento DATE,
    fechaDeVigenciaContrasenia DATE,
    contactoDeEmergencia VARCHAR(14),
    usuario VARCHAR(50) UNIQUE,
    contrasenia VARCHAR(10),
    estadoMembresia VARCHAR(8) NOT NULL CHECK (estadoMembresia IN ('Activo', 'Moroso', 'Inactivo')),
    saldoAFavor DECIMAL(10, 2) CHECK (saldoAFavor >= 0),
    direccion VARCHAR(100)
);
GO

-- 2. actividades.actividadRecreativa
CREATE TABLE actividades.actividadRecreativa (
    idActividad INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(50) NOT NULL,
    horaInicio VARCHAR(50) NOT NULL,
    horaFin VARCHAR(50) NOT NULL,
    tarifaSocio DECIMAL(10, 2) CHECK (tarifaSocio > 0) NOT NULL,
    tarifaInvitado DECIMAL(10, 2) CHECK (tarifaInvitado > 0) NOT NULL
);
GO

-- 3. actividades.deporteDisponible
CREATE TABLE actividades.deporteDisponible (
    idDeporte INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    costoPorMes DECIMAL(10, 2) CHECK (costoPorMes > 0) NOT NULL
);
GO

-- 4. pagos.medioDePago
CREATE TABLE pagos.medioDePago (
    idMedioDePago INT NOT NULL,
    tipoMedioDePago VARCHAR(50) NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    CONSTRAINT PKMediosDePago PRIMARY KEY (idMedioDePago, tipoMedioDePago)
);
GO

-- 5. coberturas.coberturaDisponible
CREATE TABLE coberturas.coberturaDisponible (
    idCoberturaDisponible INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(50) NOT NULL
);
GO

-- 6. socios.categoriaSocio
CREATE TABLE socios.categoriaSocio (
    idCategoria INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(50) NOT NULL,
    costoMembresia DECIMAL(10, 2) NOT NULL CHECK (costoMembresia > 0)
);
GO

-- 7. descuentos.descuentoDisponible
CREATE TABLE descuentos.descuentoDisponible (
    idDescuento INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(100) NOT NULL,
    porcentajeDescontado DECIMAL(5, 2) CHECK (porcentajeDescontado > 0)
);
GO

-- 8. socios.tutorACargo
CREATE TABLE socios.tutorACargo (
    dniTutor BIGINT CHECK (dniTutor > 0) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(11),
    parentescoConMenor VARCHAR(10)
);
GO

-- 9. socios.rolDisponible
CREATE TABLE socios.rolDisponible (
    idRol INT NOT NULL CHECK (idRol > 0) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);
GO

-- 10. actividades.deporteActivo
CREATE TABLE actividades.deporteActivo (
    idDeporteActivo INT PRIMARY KEY IDENTITY(1,1),
    idSocio INT NOT NULL,
    idDeporte INT NOT NULL,
    estadoMembresia VARCHAR(8) NOT NULL CHECK (estadoMembresia IN ('Activo', 'Moroso', 'Inactivo')),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idDeporte) REFERENCES actividades.deporteDisponible(idDeporte)
);
GO

-- 11. itinerarios.itinerario
CREATE TABLE itinerarios.itinerario (
    idItinerario INT PRIMARY KEY IDENTITY(1,1),
    dia VARCHAR(9) NOT NULL,
    idDeporte INT NOT NULL,
    horaInicio VARCHAR(50) NOT NULL,
    horaFin VARCHAR(50) NOT NULL,
    FOREIGN KEY (idDeporte) REFERENCES actividades.deporteDisponible(idDeporte)
);
GO

-- 12. pagos.medioEnUso
CREATE TABLE pagos.medioEnUso (
    idSocio INT NOT NULL,
    idMedioDePago INT NOT NULL,
    tipoMedioDePago VARCHAR(50) NOT NULL,
    numeroTarjeta BIGINT CHECK (numeroTarjeta > 0),
    CONSTRAINT PKMedioEnUso PRIMARY KEY (idSocio, idMedioDePago, tipoMedioDePago),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idMedioDePago, tipoMedioDePago) REFERENCES pagos.medioDePago(idMedioDePago, tipoMedioDePago)
);
GO

-- 13. coberturas.prepagaEnUso
CREATE TABLE coberturas.prepagaEnUso (
    idPrepaga INT PRIMARY KEY IDENTITY(1,1),
    idNumeroSocio INT NOT NULL,  
    idCobertura INT NOT NULL,
    FOREIGN KEY (idNumeroSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idCobertura) REFERENCES coberturas.coberturaDisponible(idCoberturaDisponible)
);
GO

-- 14. descuentos.descuentoVigente
CREATE TABLE descuentos.descuentoVigente (
    idDescuento INT,
    idSocio INT,
    FOREIGN KEY (idDescuento) REFERENCES descuentos.descuentoDisponible(idDescuento), 
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    CONSTRAINT PKDescuentoVigente PRIMARY KEY (idDescuento, idSocio)
);
GO

-- 15. socios.rolVigente
CREATE TABLE socios.rolVigente (
    idRol INT NOT NULL CHECK (idRol > 0),
    idSocio INT NOT NULL CHECK (idSocio > 0),
    CONSTRAINT PKRolVigente PRIMARY KEY (idRol, idSocio),
    FOREIGN KEY (idRol) REFERENCES socios.rolDisponible(idRol),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 16. pagos.facturaCobro
CREATE TABLE pagos.facturaCobro (
    idFactura INT PRIMARY KEY IDENTITY(1,1),
	idSocio INT,
    fechaEmision DATE DEFAULT GETDATE(),
    fechaPrimerVencimiento DATE NOT NULL,
    fechaSegundoVencimiento DATE NOT NULL,
    cuitDeudor INT NOT NULL,
    idMedioDePago INT NOT NULL,
    tipoMedioDePago VARCHAR(50) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    tipoCobro VARCHAR(25) NOT NULL,
    numeroCuota INT NOT NULL CHECK (numeroCuota > 0),
    servicioPagado VARCHAR(50) NOT NULL,
    importeBruto DECIMAL(10, 2) NOT NULL CHECK (importeBruto > 0),
    importeTotal DECIMAL(10, 2) NOT NULL CHECK (importeTotal > 0),
    CONSTRAINT FKFacturaCobro FOREIGN KEY (idSocio,idMedioDePago, tipoMedioDePago) REFERENCES pagos.medioEnUso(idSocio,idMedioDePago, tipoMedioDePago)
);
GO

-- 17. pagos.reembolso
CREATE TABLE pagos.reembolso (
    idFacturaReembolso INT NOT NULL IDENTITY(1,1),
    idFacturaOriginal INT NOT NULL,
    montoReembolsado DECIMAL(10, 2) NOT NULL CHECK (montoReembolsado > 0),
    cuitDestinatario BIGINT NOT NULL CHECK (cuitDestinatario > 0),
    medioDePago VARCHAR(50) NOT NULL,
    CONSTRAINT PKReembolso PRIMARY KEY (idFacturaReembolso, idFacturaOriginal),
    CONSTRAINT FKReembolso FOREIGN KEY (idFacturaOriginal) REFERENCES pagos.facturaCobro(idFactura)
);
GO

USE SolNorte_Grupo3
GO

-- :::::::::::::::::::::::::::::::::::::::::::: SOCIOS ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA SOCIO ######

-- INSERTAR SOCIO

CREATE OR ALTER PROCEDURE socios.insertarSocio
    @dni BIGINT,
    @cuil BIGINT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @email VARCHAR(100) = NULL,
    @telefono VARCHAR(14) = NULL,
    @fechaNacimiento DATE = NULL,
    @fechaDeVigenciaContrasenia DATE = NULL,
    @contactoDeEmergencia VARCHAR(14) = NULL,
    @usuario VARCHAR(50) = NULL,
    @contrasenia VARCHAR(10) = NULL,
    @estadoMembresia VARCHAR(8),
    @saldoAFavor DECIMAL(10,2) = NULL,
	@direccion VARCHAR(100) = NULL
AS
BEGIN

	IF NOT (@dni >= 4000000 AND @dni <= 99999999)
	BEGIN
		RAISERROR('Error: DNI fuera de rango (4.000.000 - 99.999.999)', 16, 1);
		RETURN;
	END

	IF NOT (@cuil >= 2040000001 AND @cuil <= 27999999999)
	BEGIN
		RAISERROR('Error: CUIL fuera de rango (2.040.000.001 - 27.999.999.999)', 16, 1);
		RETURN;
	END

	IF NOT (LEN(@nombre) >= 3)
	BEGIN
		RAISERROR('Error: Nombre debe tener al menos 3 caracteres', 16, 1);
		RETURN;
	END

	IF NOT (LEN(@apellido) >= 3)
	BEGIN
		RAISERROR('Error: Apellido debe tener al menos 3 caracteres', 16, 1);
		RETURN;
	END

	IF NOT (@email LIKE '_%@_%._%' OR @email IS NULL)
	BEGIN
		RAISERROR('Error: Email no v�lido o es NULL', 16, 1);
		RETURN;
	END

	IF NOT ((LEN(@telefono) >= 10 AND LEN(@telefono) <= 14) OR  @telefono IS NULL)
	BEGIN
		RAISERROR('Error: Tel�fono debe tener al menos 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF NOT ((@fechaNacimiento >= '1920-01-01' AND @fechaNacimiento <= GETDATE()) OR @fechaNacimiento IS NULL)
	BEGIN
		RAISERROR('Error: Fecha de nacimiento fuera de rango o es NULL', 16, 1);
		RETURN;
	END

	IF NOT (@fechaDeVigenciaContrasenia > GETDATE() OR @fechaDeVigenciaContrasenia IS NULL)
	BEGIN
		RAISERROR('Error: Fecha de vigencia de contrase�a inv�lida o es NULL', 16, 1);
		RETURN;
	END

	IF NOT ((LEN(@contactoDeEmergencia) >= 10 AND LEN(@contactoDeEmergencia) <= 14) OR @contactoDeEmergencia IS NULL)
	BEGIN
		RAISERROR('Error: Contacto de emergencia debe tener al menos 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF NOT (LEN(@usuario) >= 3 OR @usuario IS NULL)
	BEGIN
		RAISERROR('Error: Usuario debe tener al menos 3 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF NOT ((LEN(@contrasenia) >= 5 AND LEN(@contrasenia) <= 10) OR @contrasenia IS NULL)
	BEGIN
		RAISERROR('Error: Contrase�a debe tener entre 5 y 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF NOT (@estadoMembresia IN ('Activo', 'Moroso', 'Inactivo'))
	BEGIN
		RAISERROR('Error: Estado de membres�a inv�lido', 16, 1);
		RETURN;
	END

	IF NOT (@saldoAFavor >= 0 OR @saldoAFavor IS NULL)
	BEGIN
		RAISERROR('Error: Saldo a favor debe ser mayor o igual a cero o NULL', 16, 1);
		RETURN;
	END

	IF NOT ((LEN(@direccion) >= 3 AND LEN(@direccion) <= 100) OR @direccion IS NULL)
	BEGIN
		RAISERROR('Error: Direcci�n debe tener entre 3 y 100 caracteres o ser NULL', 16, 1);
		RETURN;
	END

    INSERT INTO socios.socio
        (dni, cuil, nombre, apellido, email, telefono,
         fechaNacimiento, fechaDeVigenciaContrasenia, contactoDeEmergencia,
         usuario, contrasenia, estadoMembresia, saldoAFavor, direccion)
    VALUES
        (@dni, @cuil, @nombre, @apellido, @email, @telefono,
         @fechaNacimiento, @fechaDeVigenciaContrasenia, @contactoDeEmergencia,
         @usuario, @contrasenia, @estadoMembresia, @saldoAFavor, @direccion);

END
GO

-- MODIFICAR SOCIO

CREATE OR ALTER PROCEDURE socios.modificarSocio
    @idSocio                    INT,
    @dni                        BIGINT        = NULL,
    @cuil                       BIGINT        = NULL,
    @nombre                     VARCHAR(100)  = NULL,
    @apellido                   VARCHAR(100)  = NULL,
    @email                      VARCHAR(100)  = NULL,
    @telefono                   VARCHAR(14)   = NULL,
    @fechaNacimiento            DATE          = NULL,
    @fechaDeVigenciaContrasenia DATE          = NULL,
    @contactoDeEmergencia       VARCHAR(14)   = NULL,
    @usuario                    VARCHAR(50)   = NULL,
    @contrasenia                VARCHAR(10)   = NULL,
    @estadoMembresia            VARCHAR(8)    = NULL,
    @saldoAFavor                DECIMAL(10,2) = NULL,
    @direccion                  VARCHAR(100)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

	IF @dni IS NOT NULL AND NOT (@dni >= 4000000 AND @dni <= 99999999)
	BEGIN
		RAISERROR('Error: DNI fuera de rango (4.000.000 - 99.999.999)', 16, 1);
		RETURN;
	END

	IF @cuil IS NOT NULL AND NOT (@cuil >= 2040000001 AND @cuil <= 27999999999)
	BEGIN
		RAISERROR('Error: CUIL fuera de rango (2.040.000.001 - 27.999.999.999)', 16, 1);
		RETURN;
	END

	IF @nombre IS NOT NULL AND NOT (LEN(@nombre) >= 3)
	BEGIN
		RAISERROR('Error: Nombre debe tener al menos 3 caracteres', 16, 1);
		RETURN;
	END

	IF @apellido IS NOT NULL AND NOT (LEN(@apellido) >= 3)
	BEGIN
		RAISERROR('Error: Apellido debe tener al menos 3 caracteres', 16, 1);
		RETURN;
	END

	IF @email IS NOT NULL AND NOT (@email LIKE '_%@_%._%')
	BEGIN
		RAISERROR('Error: Email no v�lido o es NULL', 16, 1);
		RETURN;
	END

	IF @telefono IS NOT NULL AND NOT ((LEN(@telefono) >= 10 AND LEN(@telefono) <= 14))
	BEGIN
		RAISERROR('Error: Tel�fono debe tener al menos 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF @fechaNacimiento IS NOT NULL AND NOT ((@fechaNacimiento >= '1920-01-01' AND @fechaNacimiento <= GETDATE()))
	BEGIN
		RAISERROR('Error: Fecha de nacimiento fuera de rango o es NULL', 16, 1);
		RETURN;
	END

	IF @fechaDeVigenciaContrasenia IS NOT NULL AND NOT (@fechaDeVigenciaContrasenia > GETDATE() OR @fechaDeVigenciaContrasenia IS NULL)
	BEGIN
		RAISERROR('Error: Fecha de vigencia de contrase�a inv�lida o es NULL', 16, 1);
		RETURN;
	END

	IF @contactoDeEmergencia IS NOT NULL AND NOT ((LEN(@contactoDeEmergencia) >= 10 AND LEN(@contactoDeEmergencia) <= 14))
	BEGIN
		RAISERROR('Error: Contacto de emergencia debe tener al menos 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF @usuario IS NOT NULL AND NOT (LEN(@usuario) >= 3)
	BEGIN
		RAISERROR('Error: Usuario debe tener al menos 3 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF @contrasenia IS NOT NULL AND NOT ((LEN(@contrasenia) >= 5 AND LEN(@contrasenia) <= 10))
	BEGIN
		RAISERROR('Error: Contrase�a debe tener entre 5 y 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF @estadoMembresia IS NOT NULL AND NOT (@estadoMembresia IN ('Activo', 'Moroso', 'Inactivo'))
	BEGIN
		RAISERROR('Error: Estado de membres�a inv�lido', 16, 1);
		RETURN;
	END

	IF @saldoAFavor IS NOT NULL AND NOT (@saldoAFavor >= 0)
	BEGIN
		RAISERROR('Error: Saldo a favor debe ser mayor o igual a cero o NULL', 16, 1);
		RETURN;
	END

	IF @direccion IS NOT NULL AND NOT ((LEN(@direccion) >= 3 AND LEN(@direccion) <= 100))
	BEGIN
		RAISERROR('Error: Direcci�n debe tener entre 3 y 100 caracteres o ser NULL', 16, 1);
		RETURN;
	END

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

-- ELIMINAR SOCIO

CREATE OR ALTER PROCEDURE socios.eliminarSocio
    @idSocio INT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @estadoMembresia VARCHAR(8) = (SELECT s.estadoMembresia FROM socios.socio s WHERE idSocio = @idSocio);

	IF @estadoMembresia IN('Moroso','Activo')
	BEGIN
		UPDATE socios.socio
		SET estadoMembresia = 'Inactivo'
		WHERE idSocio = @idSocio
	END
	ELSE
	BEGIN
		DELETE FROM socios.socio
		WHERE idSocio = @idSocio;
    
		IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR('No se encontr� ning�n socio con id = %d', 16, 1, @idSocio);
		END
	END

END
GO


-- ###### TABLA CATEGORIASSOCIO ######

-- INSERTAR CATEGORIAS DE SOCIO

CREATE OR ALTER PROCEDURE socios.insertarCategoriaSocio
    @tipo           VARCHAR(50),
    @costoMembresia DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    IF (@costoMembresia>0)
	BEGIN
    INSERT INTO socios.categoriaSocio (tipo, costoMembresia)
    VALUES (@tipo, @costoMembresia) ;
	END
END
GO

-- MODIFICAR CATEGORIAS DE SOCIO

CREATE OR ALTER PROCEDURE socios.modificarCategoriaSocio
    @idCategoria    INT,
    @tipo           VARCHAR(50)     = NULL,
    @costoMembresia DECIMAL(10,2)   = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE socios.categoriaSocio
    SET
        tipo           = COALESCE(@tipo, tipo),
        costoMembresia = COALESCE(@costoMembresia, costoMembresia)
    WHERE idCategoria = @idCategoria AND (@costoMembresia>0)

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontr� categor�a con id=%d.',16,1,@idCategoria);
END
GO

-- ELIMINAR CATEGORIAS DE SOCIO

CREATE OR ALTER PROCEDURE socios.eliminarCategoriaSocio
    @idCategoria INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM socios.categoriaSocio
    WHERE categoriaSocio.idCategoria = @idCategoria

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontr� categor�a activa con id=%d.',16,1,@idCategoria);
END
GO


-- ###### TABLA ROLDISPONIBLE ######

-- INSERTAR ROL DISPONIBLE

CREATE OR ALTER PROCEDURE socios.insertarRolDisponible
    @idRol       INT,
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	IF(@idRol > 0)
	BEGIN
    INSERT INTO socios.rolDisponible (idRol, descripcion)
    VALUES (@idRol, @descripcion);
	END
END
GO

-- MODIFICAR ROL DISPONIBLE

CREATE OR ALTER PROCEDURE socios.modificarRolDisponible
    @idRol       INT,
    @descripcion VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE socios.rolDisponible
    SET
        descripcion = COALESCE(@descripcion, descripcion)  -- mantendr� su valor inicial si es NULL
    WHERE idRol = @idRol

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontr� rol con id=%d.', 16, 1, @idRol);
END
GO

-- ELIMINAR ROL DISPONIBLE

CREATE OR ALTER PROCEDURE socios.eliminarRolDisponible
    @idRol INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM socios.rolDisponible
    WHERE idRol = @idRol

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontr� rol activo con id=%d.', 16, 1, @idRol);
END
GO

-- ###### TABLA MEDIODEPAGO ######

-- INSERTAR MEDIO DE PAGO

CREATE OR ALTER PROCEDURE pagos.insertarMedioDePago
    @idMedioDePago     INT,
    @tipoMedioDePago   VARCHAR(50),
    @descripcion       VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	IF(@idMedioDePago>0)
	BEGIN
    INSERT INTO pagos.medioDePago (idMedioDePago, tipoMedioDePago, descripcion)
    VALUES (@idMedioDePago, @tipoMedioDePago, @descripcion);
	END
END
GO

-- MODIFICAR MEDIO DE PAGO

CREATE OR ALTER PROCEDURE pagos.modificarMedioDePago
    @idMedioDePago     INT,
    @tipoMedioDePago   VARCHAR(50),
    @descripcion       VARCHAR(50) = NULL
AS
BEGIN

    UPDATE pagos.medioDePago
    SET
        descripcion = COALESCE(@descripcion, descripcion)
    WHERE idMedioDePago   = @idMedioDePag AND (@idMedioDePago>0)

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontr� medio de pago con id=%d.', 16, 1, @idMedioDePago, @tipoMedioDePago);
END
GO

-- ELIMINAR MEDIO DE PAGO

CREATE OR ALTER PROCEDURE pagos.eliminarMedioDePago
    @idMedioDePago     INT,
    @tipoMedioDePago   VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM pagos.medioDePago
    WHERE idMedioDePago   = @idMedioDePago
      AND tipoMedioDePago = @tipoMedioDePago

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontr� medio de pago activo con id=%d y tipo="%s".', 16, 1, @idMedioDePago, @tipoMedioDePago);
END
GO

-- :::::::::::::::::::::::::::::::::::::::::::: ACTIVIDADES ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA DEPORTEDISPONIBLE ######

-- INSERTAR DEPORTE DISPONIBLE

CREATE OR ALTER PROCEDURE actividades.insertarDeporteDisponible
    @tipo VARCHAR(50),
    @descripcion VARCHAR(50),
    @costoPorMes DECIMAL(10, 2)
AS
BEGIN

	IF NOT (LEN(@tipo) >= 4)
	BEGIN
		RAISERROR('Error: El deporte tiene que tener por lo menos 4 letras', 16, 1);
		RETURN;
	END

	IF NOT (LEN(@descripcion) >= 4)
	BEGIN
		RAISERROR('Error: El deporte tiene que tener por lo menos 4 letras', 16, 1);
		RETURN;
	END

	IF NOT (@costoPorMes > 0)
	BEGIN
		RAISERROR('Error: El costo tiene que ser mayor a cero', 16, 1);
		RETURN;
	END

    INSERT INTO actividades.deporteDisponible
        (tipo,descripcion,costoPorMes)
    VALUES
        (@tipo,@descripcion,@costoPorMes)

END
GO

-- MODIFICAR DEPORTE DISPONIBLE

CREATE OR ALTER PROCEDURE actividades.modificarDeporteDisponible
    @idDeporte INT,
    @tipo VARCHAR(50) = NULL,
    @descripcion VARCHAR(50) = NULL,
    @costoPorMes DECIMAL(10, 2) = NULL

AS
BEGIN
    SET NOCOUNT ON;

	IF @tipo IS NOT NULL AND NOT (LEN(@tipo) >= 4)
	BEGIN
		RAISERROR('Error: Tipo tiene que tener mas de 4 letras', 16, 1);
		RETURN;
	END

	IF @descripcion IS NOT NULL AND NOT(LEN(@descripcion) >= 4)
	BEGIN
		RAISERROR('Error: El deporte tiene que tener por lo menos 4 letras', 16, 1);
		RETURN;
	END

	IF @costoPorMes IS NOT NULL AND NOT (@costoPorMes > 0)
	BEGIN
		RAISERROR('Error: El costo tiene que ser mayor a cero', 16, 1);
		RETURN;
	END

    UPDATE actividades.deporteDisponible
    SET
		tipo                      = COALESCE(@tipo, tipo),
		descripcion               = COALESCE(@descripcion, descripcion),
		costoPorMes               = COALESCE(@costoPorMes, costoPorMes)
    WHERE idDeporte = @idDeporte;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No existe un deporte con idDeporte = %d.', 16, 1, @idDeporte);
    END
END;
GO

-- ELIMINAR DEPORTE DISPONIBLE

CREATE OR ALTER PROCEDURE actividades.eliminarDeporteDisponible
    @idDeporte INT
AS
BEGIN
    SET NOCOUNT ON;

	DELETE FROM actividades.deporteDisponible
	WHERE idDeporte = @idDeporte;
    
	IF @@ROWCOUNT = 0
	BEGIN
		RAISERROR('No se encontr� ning�n deporte con id = %d', 16, 1, @idDeporte);
	END
	
END
GO

-- ###### TABLA ACTIVIDAD RECREATIVA ######

--Insertar Actividad Recreativa
CREATE PROCEDURE actividades.insertarActividadRecreativa (
    @descripcion VARCHAR(50),
    @horaInicio VARCHAR(50),
    @horaFin VARCHAR(50),
    @tarifaSocio DECIMAL(10, 2),
    @tarifaInvitado DECIMAL(10, 2)
)
AS
BEGIN
    IF @descripcion IS NULL OR @descripcion = ''
    BEGIN
        RAISERROR('La descripci�n de la actividad no puede estar vac�a.', 16, 1);
        RETURN;
    END
    IF @horaInicio IS NULL OR @horaInicio = ''
    BEGIN
        RAISERROR('La hora de inicio de la actividad no puede estar vac�a.', 16, 1);
        RETURN;
    END
    IF @horaFin IS NULL OR @horaFin = ''
    BEGIN
        RAISERROR('La hora de fin de la actividad no puede estar vac�a.', 16, 1);
        RETURN;
    END
    IF @tarifaSocio IS NULL OR @tarifaSocio <= 0
    BEGIN
        RAISERROR('La tarifa para socios debe ser mayor que cero.', 16, 1);
        RETURN;
    END
    IF @tarifaInvitado IS NULL OR @tarifaInvitado <= 0
    BEGIN
        RAISERROR('La tarifa para invitados debe ser mayor que cero.', 16, 1);
        RETURN;
    END

    -- Inserci�n de la actividad
    INSERT INTO actividades.actividadRecreativa (descripcion, horaInicio, horaFin, tarifaSocio, tarifaInvitado)
    VALUES (@descripcion, @horaInicio, @horaFin, @tarifaSocio, @tarifaInvitado);

    SELECT SCOPE_IDENTITY() AS idActividadInsertada; -- Esta sentencia lo que hace es devolver el ID de la actividad insertada
END;
GO

-- Modificar Actividad Recreativa
CREATE PROCEDURE actividades.modificarActividadRecreativa (
    @idActividad INT,
    @descripcion VARCHAR(50),
    @horaInicio VARCHAR(50),
    @horaFin VARCHAR(50),
    @tarifaSocio DECIMAL(10, 2),
    @tarifaInvitado DECIMAL(10, 2)
)
AS
BEGIN
    IF @idActividad IS NULL OR @idActividad <= 0
    BEGIN
        RAISERROR('El ID de la actividad debe ser un valor positivo.', 16, 1);
        RETURN;
    END
    IF @descripcion IS NULL OR @descripcion = ''
    BEGIN
        RAISERROR('La descripci�n de la actividad no puede estar vac�a.', 16, 1);
        RETURN;
    END
    IF @horaInicio IS NULL OR @horaInicio = ''
    BEGIN
        RAISERROR('La hora de inicio de la actividad no puede estar vac�a.', 16, 1);
        RETURN;
    END
    IF @horaFin IS NULL OR @horaFin = ''
    BEGIN
        RAISERROR('La hora de fin de la actividad no puede estar vac�a.', 16, 1);
        RETURN;
    END
    IF @tarifaSocio IS NULL OR @tarifaSocio <= 0
    BEGIN
        RAISERROR('La tarifa para socios debe ser mayor que cero.', 16, 1);
        RETURN;
    END
    IF @tarifaInvitado IS NULL OR @tarifaInvitado <= 0
    BEGIN
        RAISERROR('La tarifa para invitados debe ser mayor que cero.', 16, 1);
        RETURN;
    END
    -- Actualizaci�n de la actividad
    UPDATE actividades.actividadRecreativa
    SET descripcion = @descripcion,
        horaInicio = @horaInicio,
        horaFin = @horaFin,
        tarifaSocio = @tarifaSocio,
        tarifaInvitado = @tarifaInvitado
    WHERE idActividad = @idActividad;
    -- Verificar si se actualiz� alguna fila
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No se encontr� ninguna actividad con el ID especificado.', 16, 1);
        RETURN;
    END
END;
GO

-- Eliminar Actividad Recreativa
CREATE PROCEDURE actividades.eliminarActividadRecreativa (
    @idActividad INT
)
AS
BEGIN
    IF @idActividad IS NULL OR @idActividad <= 0
    BEGIN
        RAISERROR('El ID de la actividad debe ser un valor positivo.', 16, 1);
        RETURN;
    END
    -- Eliminaci�n de la actividad
    DELETE FROM actividades.actividadRecreativa
    WHERE idActividad = @idActividad;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No se encontr� ninguna actividad con el ID especificado.', 16, 1);
        RETURN;
    END
END;
GO

-- ###### TABLA DEPORTEACTIVO ######

-- INSERTAR DEPORTE ACTIVO

CREATE OR ALTER PROCEDURE actividades.insertarDeporteActivo
    @idSocio INT,
    @idDeporte INT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @estadoMembresia VARCHAR(8);

    SET @estadoMembresia = (SELECT s.estadoMembresia FROM socios.socio s WHERE s.idSocio = @idSocio)
	IF NOT (@estadoMembresia IN ('Activo','Moroso'))
    BEGIN
        RAISERROR('Miembro no v�lido.', 16, 1);
        RETURN;
    END;

	IF NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte)
    BEGIN
        RAISERROR('Error: Ese deporte no existe', 16, 1);
        RETURN;
    END

    INSERT INTO actividades.deporteActivo (idSocio, idDeporte, estadoMembresia)
    VALUES (@idSocio, @idDeporte, @estadoMembresia);
END;
GO

-- MODIFICAR DEPORTE ACTIVO

CREATE OR ALTER PROCEDURE actividades.modificarDeporteActivo
    @idDeporteActivo    INT,
    @idSocio            INT = NULL,
    @idDeporte          INT = NULL,
    @estadoMembresia    VARCHAR(8) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @estadoMembresia IS NOT NULL AND NOT (@estadoMembresia IN ('Activo', 'Moroso', 'Inactivo'))
    BEGIN
        RAISERROR('Error: Estado de membres�a debe ser Activo, Moroso o Inactivo.', 16, 1);
        RETURN;
    END

    -- Validaci�n existencia de socio si se quiere modificar
    IF @idSocio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
    BEGIN
        RAISERROR('Error: El socio especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validaci�n existencia de deporte si se quiere modificar
    IF @idDeporte IS NOT NULL AND NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte)
    BEGIN
        RAISERROR('Error: El deporte especificado no existe.', 16, 1);
        RETURN;
    END

    -- Actualizaci�n condicional
    UPDATE actividades.deporteActivo
    SET
        idSocio         = COALESCE(@idSocio, idSocio),
        idDeporte       = COALESCE(@idDeporte, idDeporte),
        estadoMembresia = COALESCE(@estadoMembresia, estadoMembresia)
    WHERE idDeporteActivo = @idDeporteActivo;

    -- Verificaci�n de actualizaci�n
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No existe una fila con idDeporteActivo = %d.', 16, 1, @idDeporteActivo);
    END
END;
GO

-- ELIMINAR DEPORTE ACTIVO

CREATE PROCEDURE actividades.eliminarDeporteActivo
    @idDeporteActivo INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM actividades.deporteActivo
    WHERE idDeporteActivo = @idDeporteActivo;
END;
GO

-- :::::::::::::::::::::::::::::::::::::::::::: ITINERARIOS ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA ITINERARIO ######

-- INSERTAR ITINERARIO

CREATE OR ALTER PROCEDURE itinerarios.insertarItinerario
    @dia VARCHAR(9),
    @idDeporte INT,
    @horaInicio TIME,
    @horaFin TIME
AS
BEGIN
    IF NOT (LEN(@dia) >= 5 AND LEN(@dia) <= 9)
    BEGIN
        RAISERROR('Error: El d�a de la semana debe tener entre 5 y 9 letras', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte)
    BEGIN
        RAISERROR('Error: Ese deporte no existe', 16, 1);
        RETURN;
    END
    IF @horaInicio >= @horaFin
    BEGIN
        RAISERROR('Error: La hora de inicio debe ser menor que la hora de fin', 16, 1);
        RETURN;
    END

    -- Inserci�n v�lida
    INSERT INTO itinerarios.itinerario (dia, idDeporte, horaInicio, horaFin)
    VALUES (@dia, @idDeporte, @horaInicio, @horaFin);
END;
GO

-- MODIFICAR ITINERARIO

CREATE OR ALTER PROCEDURE itinerarios.modificarItinerario
    @idItinerario INT,
    @dia VARCHAR(9) = NULL,
    @idDeporte INT = NULL,
    @horaInicio TIME = NULL,
    @horaFin TIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar d�a
    IF @dia IS NOT NULL AND NOT (LEN(@dia) >= 5 AND LEN(@dia) <= 9)
    BEGIN
        RAISERROR('Error: El d�a de la semana debe tener entre 5 y 9 letras', 16, 1);
        RETURN;
    END

    -- Validar existencia de deporte
    IF @idDeporte IS NOT NULL AND NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte)
    BEGIN
        RAISERROR('Error: Ese deporte no existe', 16, 1);
        RETURN;
    END

    -- Validar que horaInicio < horaFin
    IF @horaInicio IS NOT NULL AND @horaFin IS NOT NULL AND @horaInicio >= @horaFin
    BEGIN
        RAISERROR('Error: La hora de inicio debe ser menor que la hora de fin', 16, 1);
        RETURN;
    END

    -- Actualizar valores
    UPDATE itinerarios.itinerario
    SET
        dia = COALESCE(@dia, dia),
        idDeporte = COALESCE(@idDeporte, idDeporte),
        horaInicio = COALESCE(@horaInicio, horaInicio),
        horaFin = COALESCE(@horaFin, horaFin)
    WHERE idItinerario = @idItinerario;

    -- Validar si se actualiz� alguna fila
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No existe un itinerario con idItinerario = %d.', 16, 1, @idItinerario);
    END
END;
GO

-- ELIMINAR ITINERARIO

CREATE OR ALTER PROCEDURE itinerarios.eliminarItinerario
    @idItinerario INT
AS
BEGIN
    SET NOCOUNT ON;

	DELETE FROM itinerarios.itinerario
	WHERE @idItinerario = @idItinerario;
    
	IF @@ROWCOUNT = 0
	BEGIN
		RAISERROR('No se encontr� ning�n itinerario con id = %d', 16, 1, @idItinerario);
	END
	
END
GO

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