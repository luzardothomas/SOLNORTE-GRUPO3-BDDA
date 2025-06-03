----------------------------------------------------------------------------------------------------
-- Fecha de entrega: 19-05-2025
-- Número de grupo: 3
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

-- Eliminar si es que existe

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
--DROP TABLE socios.gruposFamiliaresActivos
--DROP TABLE pagos.tarjetasEnUso
--DROP TABLE pagos.tarjetaDisponible
--DROP TABLE socios.socio
--DROP TABLE socios.grupoFamiliar

--DROP SCHEMA socios;
--DROP SCHEMA pagos;
--DROP SCHEMA descuentos;
--DROP SCHEMA intinerarios;
--DROP SCHEMA coberturas;
	
-- Creación de esquemas para las diferentes gestiones
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

-- Creación de tablas

-- 1. socios.grupoFamiliar

CREATE TABLE socios.grupoFamiliar (
    idGrupoFamiliar INT PRIMARY KEY IDENTITY(1,1),
	cantidadGrupoFamiliar SMALLINT
);
GO

-- 2. socios.socio
CREATE TABLE socios.socio (
    idSocio INT PRIMARY KEY IDENTITY(1,1),
    dni BIGINT NOT NULL CHECK (dni > 0),
    cuil BIGINT NOT NULL CHECK (cuil > 0),
    nomyap varchar(30) NOT NULL,
    email VARCHAR(30),
    telefono CHAR(14),
    fechaNacimiento DATE,
    fechaDeVigenciaContrasenia DATE,
	fechaVencimientoMembresia DATE,
	estadoMembresia varchar (25) CHECK (estadoMembresia='ACTIVO' OR estadoMembresia='MOROSO - 1ER VENCIMIENTO' OR estadoMembresia='MOROSO - 2DO VENCIMIENTO' OR estadoMembresia='INACTIVO'),
    contactoDeEmergencia CHAR(14),
    usuario VARCHAR(25) UNIQUE,
    contrasenia VARCHAR(10),
    saldoAFavor DECIMAL(10, 2) CHECK (saldoAFavor >= 0),
    direccion VARCHAR(25),
	idGrupo INT,
	FOREIGN KEY (idGrupo) REFERENCES socios.grupoFamiliar(idGrupoFamiliar)
);
GO

-- 3. socios.gruposFamiliaresActivos
CREATE TABLE socios.gruposFamiliaresActivos (
    idGrupoFamiliar INT NOT NULL,
	idSocio INT NOT NULL,
	parentescoGrupoFamiliar SMALLINT
	CONSTRAINT PKGrupos PRIMARY KEY (idGrupoFamiliar, idSocio),
	FOREIGN KEY (idGrupoFamiliar) REFERENCES socios.grupoFamiliar(idGrupoFamiliar),
	FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 4. actividades.actividadRecreativa
CREATE TABLE actividades.actividadRecreativa (
    idSitio INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(50) NOT NULL,
    horaInicio TIME NOT NULL,
    horaFin TIME NOT NULL,
    tarifaSocio DECIMAL(10, 2) CHECK (tarifaSocio > 0) NOT NULL,
    tarifaInvitado DECIMAL(10, 2) CHECK (tarifaInvitado > 0) NOT NULL
);
GO

-- 5. actividades.deporteDisponible
CREATE TABLE actividades.deporteDisponible (
    idDeporte INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    costoPorMes DECIMAL(10, 2) CHECK (costoPorMes > 0) NOT NULL
);
GO

-- 6. pagos.medioDePago
CREATE TABLE pagos.tarjetaDisponible (
    idTarjeta INT NOT NULL,
    tipoTarjeta VARCHAR(50) NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    CONSTRAINT PKMediosDePago PRIMARY KEY (idTarjeta, tipoTarjeta)
);
GO

-- 7. coberturas.coberturaDisponible
CREATE TABLE coberturas.coberturaDisponible (
    idCoberturaDisponible INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(50) NOT NULL
);
GO

-- 8. socios.categoriaSocio
CREATE TABLE socios.categoriaSocio (
    idCategoria INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(50) CHECK (tipo='MENOR' OR tipo='CADETE' or tipo='MAYOR'),
    costoMembresia DECIMAL(10, 2) NOT NULL CHECK (costoMembresia > 0)
);
GO

-- 9. descuentos.descuentoDisponible
CREATE TABLE descuentos.descuentoDisponible (
    idDescuento INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(100) NOT NULL,
    porcentajeDescontado DECIMAL(5, 2) CHECK (porcentajeDescontado > 0)
);
GO

-- 10. socios.rolDisponible
CREATE TABLE socios.rolDisponible (
    idRol INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(25) NOT NULL
);
GO

-- 10. actividades.deporteActivo
CREATE TABLE actividades.deporteActivo (
    idSocioActivo INT NOT NULL,
    idDeporteActivo INT NOT NULL,
    estadoMembresia VARCHAR(25) NOT NULL CHECK (estadoMembresia='ACTIVO' OR estadoMembresia='MOROSO - 1ER VENCIMIENTO' OR estadoMembresia='MOROSO - 2DO VENCIMIENTO' OR estadoMembresia='INACTIVO'),
    FOREIGN KEY (idSocioActivo) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idDeporteActivo) REFERENCES actividades.deporteDisponible(idDeporte),
	CONSTRAINT PKDeportesActivos PRIMARY KEY (idSocioActivo, idDeporteActivo)
);
GO

-- 11. itinerarios.itinerario
CREATE TABLE itinerarios.itinerario (
    idItinerario INT PRIMARY KEY IDENTITY(1,1),
    dia VARCHAR(9) NOT NULL,
    idDeporte INT NOT NULL,
    horaInicio TIME NOT NULL,
    horaFin TIME NOT NULL,
    FOREIGN KEY (idDeporte) REFERENCES actividades.deporteDisponible(idDeporte)
);
GO

-- 12. pagos.tarjetasEnUso
CREATE TABLE pagos.tarjetasEnUso (
	idSocio int NOT NULL,
    idTarjetaEnUso INT NOT NULL,
    tipoTarjetaEnUso VARCHAR(50) NOT NULL,
    numeroTarjetaEnUso BIGINT CHECK (numeroTarjetaEnUso > 0),
    CONSTRAINT PKMedioEnUso PRIMARY KEY (idSocio, idTarjetaEnUso, tipoTarjetaEnUso),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idTarjetaEnUso, tipoTarjetaEnUso) REFERENCES pagos.tarjetaDisponible(idTarjeta, tipoTarjeta)
);
GO

-- 13. coberturas.prepagaEnUso
CREATE TABLE coberturas.prepagaEnUso (
    idSocio INT IDENTITY(1,1),
    numeroPrepagaSocio INT NOT NULL,  
    idCobertura INT NOT NULL,
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idCobertura) REFERENCES coberturas.coberturaDisponible(idCoberturaDisponible),
	CONSTRAINT PKPrepaga PRIMARY KEY (idSocio, idCobertura)
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
GO
CREATE TABLE pagos.facturaCobro (
    idFactura INT PRIMARY KEY IDENTITY(1,1),
    fechaEmision DATE DEFAULT GETDATE(),
    cuitDeudor INT NOT NULL,
	medioDePagoUsado varchar(25),
    direccion VARCHAR(100) NOT NULL,
    tipoCobro VARCHAR(25) NOT NULL,
    numeroCuota INT NOT NULL CHECK (numeroCuota > 0),
	cantidadDeportes SMALLINT NOT NULL CHECK (cantidadDeportes > 0),
    importeBruto DECIMAL(10, 2) NOT NULL CHECK (importeBruto > 0),
    importeTotal DECIMAL(10, 2) NOT NULL CHECK (importeTotal > 0),
	detalle varchar(100) NOT NULL
);
GO

-- 17. pagos.reembolso
CREATE TABLE pagos.reembolso (
    idFacturaReembolso INT NOT NULL IDENTITY(1,1),
    idFacturaOriginal INT NOT NULL,
    montoReembolsado DECIMAL(10, 2) NOT NULL CHECK (montoReembolsado > 0),
    cuitDestinatario BIGINT NOT NULL CHECK (cuitDestinatario > 0),
    medioDePagoUsado VARCHAR(25) NOT NULL,
    CONSTRAINT PKReembolso PRIMARY KEY (idFacturaReembolso, idFacturaOriginal),
    CONSTRAINT FKReembolso FOREIGN KEY (idFacturaOriginal) REFERENCES pagos.facturaCobro(idFactura)
);
GO

-- :::::::::::::::::::::::::::::::::::::::::::: SOCIOS ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA SOCIO ######

-- INSERTAR SOCIO

CREATE OR ALTER PROCEDURE socios.InsertarSocio
    @dni                       BIGINT,
    @cuil                      BIGINT,
    @nomyap                    VARCHAR(30),
    @email                     VARCHAR(30)      = NULL,
    @telefono                  CHAR(14)         = NULL,
    @fechaNacimiento           DATE             = NULL,
    @idGrupo                   INT              = NULL,
    @usuario                   VARCHAR(25)      = NULL,
    @contrasenia               VARCHAR(10)      = NULL,
    @saldoAFavor               DECIMAL(10,2)    = 0,
    @direccion                 VARCHAR(25)      = NULL,
    @contactoDeEmergencia      CHAR(14)         = NULL
AS
BEGIN
    SET NOCOUNT ON;

    /*
      - Calculamos:
        fechaVencimientoMembresia  = un mes después de hoy
        fechaDeVigenciaContrasenia = tres meses después de hoy
        estadoMembresia             = 'ACTIVO'
    */
    INSERT INTO socios.socio (
        dni,
        cuil,
        nomyap,
        email,
        telefono,
        fechaNacimiento,
        fechaDeVigenciaContrasenia,
        fechaVencimientoMembresia,
        estadoMembresia,
        contactoDeEmergencia,
        usuario,
        contrasenia,
        saldoAFavor,
        direccion,
        idGrupo
    )
    VALUES (
        @dni,
        @cuil,
        @nomyap,
        @email,
        @telefono,
        @fechaNacimiento,
        -- Vigencia de Contraseña: 3 meses
        DATEADD(MONTH, 3, CAST(GETDATE() AS DATE)),
        -- Vigencia de Membresía: 1 mes.
        DATEADD(MONTH, 1, CAST(GETDATE() AS DATE)),
        'ACTIVO',
        @contactoDeEmergencia,
        @usuario,
        @contrasenia,
        @saldoAFavor,
        @direccion,
        @idGrupo
    );
    SELECT SCOPE_IDENTITY() AS NuevoIdSocio;
END;
GO;


EXEC socios.InsertarSocio
    @dni                  = 12345678,
    @cuil                 = 20123456789,
    @nomyap               = 'María Gómez',
    @email                = 'maria.gomez@mail.com',
    @telefono             = '01155667788',
    @fechaNacimiento      = '1990-03-22',
    @usuario              = 'mariag',
    @contrasenia          = 'ClaveSegura',
    @saldoAFavor          = 50.00,
    @direccion            = 'Av. Siempre Viva 742',
    @contactoDeEmergencia = '01188776655'

SELECT *
FROM socios.socio s 

-- MODIFICAR SOCIO

CREATE OR ALTER PROCEDURE socios.ModificarSocio
    @idSocio                    INT,
    @dni                        BIGINT              = NULL,
    @cuil                       BIGINT              = NULL,
    @nomyap                     VARCHAR(30)         = NULL,
    @email                      VARCHAR(30)         = NULL,
    @telefono                   CHAR(14)            = NULL,
    @fechaNacimiento            DATE                = NULL,
    @fechaDeVigenciaContrasenia DATE                = NULL,
    @fechaVencimientoMembresia  DATE                = NULL,
    @estadoMembresia            VARCHAR(25)         = NULL,
    @contactoDeEmergencia       CHAR(14)            = NULL,
    @usuario                    VARCHAR(25)         = NULL,
    @contrasenia                VARCHAR(10)         = NULL,
    @saldoAFavor                DECIMAL(10,2)       = NULL,
    @direccion                  VARCHAR(25)         = NULL,
    @idGrupo                    INT                 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE socios.socio
    SET
        dni                        = COALESCE(@dni,                        dni),
        cuil                       = COALESCE(@cuil,                       cuil),
        nomyap                     = COALESCE(@nomyap,                     nomyap),
        email                      = COALESCE(@email,                      email),
        telefono                   = COALESCE(@telefono,                   telefono),
        fechaNacimiento            = COALESCE(@fechaNacimiento,            fechaNacimiento),
        fechaDeVigenciaContrasenia = COALESCE(@fechaDeVigenciaContrasenia, fechaDeVigenciaContrasenia),
        fechaVencimientoMembresia  = COALESCE(@fechaVencimientoMembresia,  fechaVencimientoMembresia),
        estadoMembresia            = COALESCE(@estadoMembresia,            estadoMembresia),
        contactoDeEmergencia       = COALESCE(@contactoDeEmergencia,       contactoDeEmergencia),
        usuario                    = COALESCE(@usuario,                    usuario),
        contrasenia                = COALESCE(@contrasenia,                contrasenia),
        saldoAFavor                = COALESCE(@saldoAFavor,                saldoAFavor),
        direccion                  = COALESCE(@direccion,                  direccion),
        idGrupo                    = COALESCE(@idGrupo,                    idGrupo)
    WHERE idSocio = @idSocio;
END;
GO

EXEC socios.ModificarSocio
    @idSocio  = 6,
    @email    = 'nuevo.email@mail.com'
GO

-- ELIMINAR SOCIO

CREATE OR ALTER PROCEDURE socios.eliminarSocio
    @idSocio INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM socios.socio
    WHERE idSocio = @idSocio and estadoMembresia = 'INACTIVO';
END
GO

EXEC socios.eliminarSocio @idSocio = 1

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

EXEC socios.insertarCategoriaSocio CADETE, 5000
SELECT * FROM socios.categoriaSocio

-- MODIFICAR CATEGORIAS DE SOCIO

CREATE OR ALTER PROCEDURE socios.modificarCategoriaSocio
    @idCategoria    INT,
    @tipo           VARCHAR(50)     = NULL,
    @costoMembresia DECIMAL(10,2)   = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF (@costoMembresia>0)
	BEGIN
    UPDATE socios.categoriaSocio
    SET
        tipo           = COALESCE(@tipo, tipo),
        costoMembresia = COALESCE(@costoMembresia, costoMembresia)
    WHERE idCategoria = @idCategoria AND (@costoMembresia>0)
	END
END
GO

EXEC socios.modificarCategoriaSocio 1, 'MENOR', 5500
SELECT * FROM socios.categoriaSocio

-- ELIMINAR CATEGORIAS DE SOCIO

CREATE OR ALTER PROCEDURE socios.eliminarCategoriaSocio
    @idCategoria INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM socios.categoriaSocio
    WHERE categoriaSocio.idCategoria = @idCategoria
END
GO

EXEC socios.eliminarCategoriaSocio 2
SELECT * FROM socios.categoriaSocio


-- ###### TABLA ROLDISPONIBLE ######

-- INSERTAR ROL DISPONIBLE

CREATE OR ALTER PROCEDURE socios.insertarRolDisponible
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO socios.rolDisponible (descripcion)
    VALUES (@descripcion);
END
GO

EXEC socios.insertarRolDisponible @descripcion='admin'
GO

SELECT * FROM socios.rolDisponible

-- MODIFICAR ROL DISPONIBLE

CREATE OR ALTER PROCEDURE socios.modificarRolDisponible
    @idRol       INT,
    @descripcion VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE socios.rolDisponible
    SET
        descripcion = COALESCE(@descripcion, descripcion)  -- mantendrá su valor inicial si es NULL
    WHERE idRol = @idRol

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontró rol con id=%d.', 16, 1, @idRol);
END
GO

EXEC socios.modificarRolDisponible 1, 'Mate sin Azucar'
SELECT * FROM socios.rolDisponible

-- ELIMINAR ROL DISPONIBLE

CREATE OR ALTER PROCEDURE socios.eliminarRolDisponible
    @idRol INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM socios.rolDisponible
    WHERE idRol = @idRol

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontró rol activo con id=%d.', 16, 1, @idRol);
END
GO

EXEC socios.eliminarRolDisponible 1
SELECT * FROM socios.rolDisponible

-- ###### TABLA MEDIODEPAGO ######

-- INSERTAR TARJETAS DISPONIBLE

CREATE OR ALTER PROCEDURE pagos.InsertarTarjetaDisponible
    @tipoTarjeta VARCHAR(50),
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO pagos.tarjetaDisponible (
        tipoTarjeta,
        descripcion
    )
    VALUES (
        @tipoTarjeta,
        @descripcion
    );

    -- Devolver los valores de la PK recién creados
    SELECT 
        CAST(SCOPE_IDENTITY() AS INT) AS NuevoIdTarjeta,
        @tipoTarjeta                   AS TipoTarjeta;
END;
GO


EXEC pagos.InsertarTarjetaDisponible 'Debito','Mastercard Debito'
SELECT * FROM pagos.tarjetaDisponible

-- MODIFICAR TARJETAS DISPONIBLE

CREATE OR ALTER PROCEDURE pagos.ModificarTarjetaDisponible
    @idTarjeta        INT,
    @tipoTarjeta      VARCHAR(50),
    @nuevaDescripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE pagos.tarjetaDisponible
    SET descripcion = @nuevaDescripcion
    WHERE idTarjeta   = @idTarjeta
      AND tipoTarjeta = @tipoTarjeta;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR(
            'No se encontró ninguna tarjeta con (idTarjeta=%d, tipoTarjeta=''%s'').',
            16, 1,
            @idTarjeta, @tipoTarjeta
        );
    END
END;
GO

EXEC pagos.ModificarTarjetaDisponible -1, 'Credito', 'Mastercard Crédito'
SELECT * FROM pagos.tarjetaDisponible

-- ELIMINAR MEDIO DE PAGO

CREATE OR ALTER PROCEDURE pagos.EliminarTarjetaDisponible
    @idTarjeta   INT,
    @tipoTarjeta VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    /*
      Borrado físico de la fila que coincide exactamente con la clave compuesta.
      Si no existe, devolvemos un error.
    */
    DELETE FROM pagos.tarjetaDisponible
    WHERE idTarjeta   = @idTarjeta
      AND tipoTarjeta = @tipoTarjeta;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR(
            'No se encontró ninguna tarjeta con (idTarjeta=%d, tipoTarjeta=''%s'') para eliminar.',
            16, 1,
            @idTarjeta, @tipoTarjeta
        );
    END
END;
GO

EXEC pagos.EliminarTarjetaDisponible 1, 'Debito'
SELECT * FROM pagos.tarjetaDisponible

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

EXEC actividades.insertarDeporteDisponible 'Fútbol', 'Fútbol 5', 1500.00;
EXEC actividades.insertarDeporteDisponible 'Basquet', 'Cancha profesional', 1500.00;
EXEC actividades.insertarDeporteDisponible 'Tenis', 'Cancha ladrillo', 1500.00;

SELECT TOP 3 *
FROM actividades.DeporteDisponible

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


EXEC actividades.modificarDeporteDisponible @idDeporte = 1, @tipo = 'Kickboxing',@descripcion = 'Cuadrilatero',@costoPorMes = 1250.25;

SELECT TOP 3 *
FROM actividades.DeporteDisponible

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
		RAISERROR('No se encontró ningún deporte con id = %d', 16, 1, @idDeporte);
	END
	
END
GO

EXEC actividades.eliminarDeporteDisponible @idDeporte = 1

-- ###### TABLA ACTIVIDAD RECREATIVA ######

--Insertar Actividad Recreativa
CREATE OR ALTER PROCEDURE actividades.insertarActividadRecreativa (
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
        RAISERROR('La descripción de la actividad no puede estar vacía.', 16, 1);
        RETURN;
    END
    IF @horaInicio IS NULL OR @horaInicio = ''
    BEGIN
        RAISERROR('La hora de inicio de la actividad no puede estar vacía.', 16, 1);
        RETURN;
    END
    IF @horaFin IS NULL OR @horaFin = ''
    BEGIN
        RAISERROR('La hora de fin de la actividad no puede estar vacía.', 16, 1);
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

    -- Inserción de la actividad
    INSERT INTO actividades.actividadRecreativa (descripcion, horaInicio, horaFin, tarifaSocio, tarifaInvitado)
    VALUES (@descripcion, @horaInicio, @horaFin, @tarifaSocio, @tarifaInvitado);

    SELECT SCOPE_IDENTITY() AS idActividadInsertada; -- Esta sentencia lo que hace es devolver el ID de la actividad insertada
END;
GO

-- Casos Validos
EXEC actividades.insertarActividadRecreativa 'Fútbol', '18:00', '20:00', 50.00, 75.00;
EXEC actividades.insertarActividadRecreativa 'Bochas', '08:30', '10:00', 15.00, 20.00;
EXEC actividades.insertarActividadRecreativa 'Ajedrez', '09:00', '11:00', 20.00, 35.00;

SELECT *
FROM actividades.actividadRecreativa 
-- Casos Invalidos
EXEC actividades.insertarActividadRecreativa '', '18:00', '20:00', 50.00, 75.00; -- Descripción vacía
EXEC actividades.insertarActividadRecreativa 'Fútbol', '', '20:00', 50.00, 75.00; -- Hora de inicio vacía
EXEC actividades.insertarActividadRecreativa 'Fútbol', '18:00', '', 50.00, 75.00; -- Hora de fin vacía
EXEC actividades.insertarActividadRecreativa 'Fútbol', '18:00', '20:00', 0, 75.00;    -- Tarifa socio inválida
EXEC actividades.insertarActividadRecreativa 'Fútbol', '18:00', '20:00', 50.00, 0;    -- Tarifa invitado inválida
EXEC actividades.insertarActividadRecreativa 'Fútbol', '18:00', '20:00', -10, 75.00;  -- Tarifa socio negativa
EXEC actividades.insertarActividadRecreativa 'Fútbol', '18:00', '20:00', 50.00, -10;  -- Tarifa invitado negativa

-- Modificar Actividad Recreativa
CREATE OR ALTER PROCEDURE actividades.modificarActividadRecreativa (
    @idSitio INT,
    @descripcion VARCHAR(50),
    @horaInicio VARCHAR(50),
    @horaFin VARCHAR(50),
    @tarifaSocio DECIMAL(10, 2),
    @tarifaInvitado DECIMAL(10, 2)
)
AS
BEGIN
    IF @idSitio IS NULL OR @idSitio <= 0
    BEGIN
        RAISERROR('El ID de la actividad debe ser un valor positivo.', 16, 1);
        RETURN;
    END
    IF @descripcion IS NULL OR @descripcion = ''
    BEGIN
        RAISERROR('La descripción de la actividad no puede estar vacía.', 16, 1);
        RETURN;
    END
    IF @horaInicio IS NULL OR @horaInicio = ''
    BEGIN
        RAISERROR('La hora de inicio de la actividad no puede estar vacía.', 16, 1);
        RETURN;
    END
    IF @horaFin IS NULL OR @horaFin = ''
    BEGIN
        RAISERROR('La hora de fin de la actividad no puede estar vacía.', 16, 1);
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
    -- Actualización de la actividad
    UPDATE actividades.actividadRecreativa
    SET descripcion = @descripcion,
        horaInicio = @horaInicio,
        horaFin = @horaFin,
        tarifaSocio = @tarifaSocio,
        tarifaInvitado = @tarifaInvitado
    WHERE idSitio = @idSitio;
    -- Verificar si se actualizó alguna fila
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No se encontró ninguna actividad con el ID especificado.', 16, 1);
        RETURN;
    END
END;
GO

-- Caso Valido
DECLARE @idActividadModificar INT;
SELECT @idActividadModificar = 2;
EXEC actividades.modificarActividadRecreativa @idActividadModificar, 'Fútbol Recreativo', '13:00', '15:00', 35.00, 55.00;
-- Casos Invalidos
EXEC actividades.modificarActividadRecreativa 9999, 'Tenis', '10:00', '12:00', 60.00, 90.00; -- ID inexistente
EXEC actividades.modificarActividadRecreativa 1, '', '10:00', '12:00', 60.00, 90.00;    -- Descripción vacía
EXEC actividades.modificarActividadRecreativa 1, 'Tenis', '', '12:00', 60.00, 90.00;    -- Hora inicio vacía
EXEC actividades.modificarActividadRecreativa 1, 'Tenis', '10:00', '', 60.00, 90.00;    -- Hora fin vacía
EXEC actividades.modificarActividadRecreativa 1, 'Tenis', '10:00', '12:00', 0, 90.00;       -- Tarifa socio inválida
EXEC actividades.modificarActividadRecreativa 1, 'Tenis', '10:00', '12:00', 60.00, 0;       -- Tarifa invitado inválida

-- Eliminar Actividad Recreativa
CREATE PROCEDURE actividades.eliminarActividadRecreativa (
    @idSitio INT
)
AS
BEGIN
    IF @idSitio IS NULL OR @idSitio <= 0
    BEGIN
        RAISERROR('El ID de la actividad debe ser un valor positivo.', 16, 1);
        RETURN;
    END
    -- Eliminación de la actividad
    DELETE FROM actividades.actividadRecreativa
    WHERE idSitio = @idSitio;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No se encontró ninguna actividad con el ID especificado.', 16, 1);
        RETURN;
    END
END;
GO

-- Caso Valido
DECLARE @ultimaActividad INT;
SELECT @ultimaActividad = MAX(idSitio) FROM actividades.actividadRecreativa
EXEC actividades.eliminarActividadRecreativa @ultimaActividad;
-- Caso Invalido
EXEC actividades.eliminarActividadRecreativa 9999; -- ID inexistente

-- ###### TABLA DEPORTEACTIVO ######

-- INSERTAR DEPORTE ACTIVO

CREATE OR ALTER PROCEDURE actividades.insertarDeporteActivo
    @idSocioActivo INT,
    @idDeporteActivo INT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @estadoMembresia VARCHAR(8);

    SET @estadoMembresia = (SELECT s.estadoMembresia FROM socios.socio s WHERE s.idSocio = @idSocioActivo)
	IF NOT (@estadoMembresia IN ('ACTIVO','MOROSO - 1ER VENCIMIENTO','MOROSO - 2DO VENCIMIENTO'))
    BEGIN
        RAISERROR('Miembro no válido.', 16, 1);
        RETURN;
    END;

	IF NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible a WHERE a.idDeporte = @idDeporteActivo)
    BEGIN
        RAISERROR('Error: Ese deporte no existe', 16, 1);
        RETURN;
    END

    INSERT INTO actividades.deporteActivo (idSocioActivo, idDeporteActivo, estadoMembresia)
    VALUES (@idSocioActivo, @idDeporteActivo, @estadoMembresia);
END;
GO

EXEC actividades.insertarDeporteActivo @idSocioActivo = 1, @idDeporteActivo = 2
SELECT * FROM actividades.deporteActivo

-- MODIFICAR DEPORTE ACTIVO

CREATE OR ALTER PROCEDURE actividades.modificarDeporteActivo
    @idDeporteActivo    INT,
    @idSocioActivo      INT = NULL,
    @estadoMembresia    VARCHAR(8) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @estadoMembresia IS NOT NULL AND NOT (@estadoMembresia IN ('ACTIVO', 'MOROSO - 1ER VENCIMIENTO', 'MOROSO - 2DO VENCIMIENTO', 'INACTIVO'))
    BEGIN
        RAISERROR('Error: Estado de membresía debe ser: ACTIVO, MOROSO - 1ER VENCIMIENTO, MOROSO - 2DO VENCIMIENTO o INACTIVO.', 16, 1);
        RETURN;
    END

    -- Validación existencia de socio si se quiere modificar
    IF @idSocioActivo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocioActivo)
    BEGIN
        RAISERROR('Error: El socio especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validación existencia de deporte si se quiere modificar
    IF @idDeporteActivo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporteActivo)
    BEGIN
        RAISERROR('Error: El deporte especificado no existe.', 16, 1);
        RETURN;
    END

    -- Actualización condicional
    UPDATE actividades.deporteActivo
    SET
        idSocioActivo         = COALESCE(@idSocioActivo, idSocioActivo),
        idDeporteActivo       = COALESCE(@idDeporteActivo, idDeporteActivo),
        estadoMembresia = COALESCE(@estadoMembresia, estadoMembresia)
    WHERE idDeporteActivo = @idDeporteActivo;

    -- Verificación de actualización
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No existe una fila con idDeporteActivo = %d.', 16, 1, @idDeporteActivo);
    END
END;
GO

EXEC actividades.modificarDeporteActivo @idDeporteActivo = 2, @idSocioActivo = 1, @estadoMembresia = 'ACTIVO';
SELECT * FROM actividades.deporteActivo

-- ELIMINAR DEPORTE ACTIVO

CREATE OR ALTER PROCEDURE actividades.eliminarDeporteActivo
    @idDeporteActivo INT,
	@idSocioActivo INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM actividades.deporteActivo
    WHERE idDeporteActivo = @idDeporteActivo OR idSocioActivo=@idSocioActivo;
END;
GO

EXEC actividades.eliminarDeporteActivo @idDeporteActivo = 1, @idSocioActivo=0
SELECT * FROM actividades.deporteActivo

-- :::::::::::::::::::::::::::::::::::::::::::: ITINERARIOS ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA ITINERARIO ######

-- INSERTAR ITINERARIO

CREATE OR ALTER PROCEDURE itinerarios.insertarItinerario
    @dia char(2), --L,M,X,J,V,S,D
    @idDeporte INT,
    @horaInicio TIME,
    @horaFin TIME
AS
BEGIN
    IF NOT (LEN(@dia) <> 2)
    BEGIN
        RAISERROR('Error: El día de la semana se representa con un caracter', 16, 1);
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

    -- Inserción válida
    INSERT INTO itinerarios.itinerario (dia, idDeporte, horaInicio, horaFin)
    VALUES (@dia, @idDeporte, @horaInicio, @horaFin);
END;
GO

EXEC itinerarios.insertarItinerario @dia ='L', @idDeporte = 2, @horaInicio = '08:00', @horaFin = '10:00';

SELECT *
FROM itinerarios.itinerario

-- MODIFICAR ITINERARIO

CREATE OR ALTER PROCEDURE itinerarios.modificarItinerario
    @idItinerario INT,
    @dia CHAR(2) = NULL,
    @idDeporte INT = NULL,
    @horaInicio TIME = NULL,
    @horaFin TIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar día
    IF @dia IS NOT NULL AND NOT (LEN(@dia) <>2)
    BEGIN
        RAISERROR('Error: El día de la semana debe tener solo un caracter', 16, 1);
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

    -- Validar si se actualizó alguna fila
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No existe un itinerario con idItinerario = %d.', 16, 1, @idItinerario);
    END
END;
GO

EXEC itinerarios.modificarItinerario @idItinerario = 1, @horaFin = '11:30';

SELECT *
FROM itinerarios.itinerario

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
		RAISERROR('No se encontró ningún itinerario con id = %d', 16, 1, @idItinerario);
	END
	
END
GO

EXEC itinerarios.eliminarItinerario @idItinerario = 1;

SELECT *
FROM itinerarios.itinerario

CREATE OR ALTER PROCEDURE pagos.ActualizarEstadoMembresia
AS
BEGIN
    -- 1) Actualizar registros morosos de 1er vencimiento (fechaActual > vencimiento+5 AND <= vencimiento+10)
    UPDATE socios.socio
    SET estadoMembresia = 'MOROSO - 1ER VENCIMIENTO'
    WHERE GETDATE() > DATEADD(DAY, 5, fechaVencimientoMembresia)
      AND GETDATE() <= DATEADD(DAY, 10, fechaVencimientoMembresia);

    -- 2) Actualizar registros morosos de 2do vencimiento (fechaActual > vencimiento+10 AND <= vencimiento+15)
    UPDATE socios.socio
    SET estadoMembresia = 'MOROSO - 2DO VENCIMIENTO'
    WHERE GETDATE() > DATEADD(DAY, 10, fechaVencimientoMembresia)
      AND GETDATE() <= DATEADD(DAY, 15, fechaVencimientoMembresia);

    -- 3) Actualizar registros inactivos (fechaActual > vencimiento+15)
    UPDATE socios.socio
    SET estadoMembresia = 'INACTIVO'
    WHERE GETDATE() > DATEADD(DAY, 15, fechaVencimientoMembresia);

    -- 4) Actualizar registros activos (fechaActual <= vencimiento)
    UPDATE socios.socio
    SET estadoMembresia = 'ACTIVO'
    WHERE GETDATE() <= fechaVencimientoMembresia;
END;
