----------------------------------------------------------------------------------------------------
-- Fecha de entrega: 01-07-2025
-- Numero de grupo: 3
-- Materia: Bases de Datos Aplicada
-- Alumnos:
--   - Codina, Santiago Ivan - 44.391.352
--   - Santillan, Lautaro Ezequiel - 45.175.053
----------------------------------------------------------------------------------------------------

-- ************************************************************************************************
-- CREAR BASE DE DATOS
-- ************************************************************************************************
CREATE DATABASE Com2900G03;
GO
-- Usar la base de datos
USE Com2900G03;
GO

-- ************************************************************************************************
-- CREACION DE SCHEMAS
-- ************************************************************************************************
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name IN ('socios', 'actividades', 'pagos', 'descuentos', 'itinerarios', 'coberturas', 'reservas'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'socios') EXEC('CREATE SCHEMA socios;');
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'actividades') EXEC('CREATE SCHEMA actividades;');
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'pagos') EXEC('CREATE SCHEMA pagos;');
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'descuentos') EXEC('CREATE SCHEMA descuentos;');
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'itinerarios') EXEC('CREATE SCHEMA itinerarios;');
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'coberturas') EXEC('CREATE SCHEMA coberturas;');
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'reservas') EXEC('CREATE SCHEMA reservas;');
END
GO

-- ************************************************************************************************
-- CREACION DE TABLAS
-- ************************************************************************************************
-- 1. Creación de tablas sin dependencias de clave foránea directas, o con claves primarias referenciables.

-- 1.1 socios.categoriaSocio
CREATE TABLE socios.categoriaMembresiaSocio (
    idCategoria INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(15) NOT NULL,
    costoMembresia DECIMAL(10, 2) NOT NULL CHECK (costoMembresia > 0),
	  vigenciaHasta DATE NOT NULL,
	  estadoCategoriaSocio BIT NOT NULL CONSTRAINT categoriaSocio_actividad DEFAULT(1)
);
GO

-- 1.2 socios.rolDisponible
CREATE TABLE socios.rolDisponible (
    idRol INT NOT NULL CHECK (idRol > 0) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL,
	  estadoRol BIT NOT NULL CONSTRAINT estadoActividad DEFAULT (1)
);
GO

-- 1.4 actividades.deporteDisponible
CREATE TABLE actividades.deporteDisponible (
	  idDeporte INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(20) NOT NULL,
    tipo VARCHAR(10), -- Capaz conviene eliminarlo
	  costoPorMes DECIMAL(10, 2) CHECK (costoPorMes > 0) NOT NULL,
	  vigenciaHasta DATE NOT NULL
);
GO

-- 1.5 actividades.actividadPileta
CREATE TABLE actividades.actividadPileta (
    idActividad INT PRIMARY KEY IDENTITY(1,1),
    tarifaSocioPorDiaAdulto DECIMAL(10, 2) CHECK (tarifaSocioPorDiaAdulto > 0) NOT NULL,
    tarifaSocioPorTemporadaAdulto DECIMAL (10,2) CHECK (tarifaSocioPorTemporadaAdulto > 0) NOT NULL,
    tarifaSocioPorMesAdulto DECIMAL (10,2) CHECK (tarifaSocioPorMesAdulto > 0) NOT NULL,
    tarifaSocioPorDiaMenor DECIMAL(10, 2) CHECK (tarifaSocioPorDiaMenor > 0) NOT NULL,
    tarifaSocioPorTemporadaMenor DECIMAL (10,2) CHECK (tarifaSocioPorTemporadaMenor > 0) NOT NULL,
    tarifaSocioPorMesMenor DECIMAL (10,2) CHECK (tarifaSocioPorMesMenor > 0) NOT NULL,
    tarifaInvitadoPorDiaAdulto DECIMAL(10, 2) CHECK (tarifaInvitadoPorDiaAdulto > 0) NOT NULL,
    tarifaInvitadoPorTemporadaAdulto DECIMAL(10, 2) CHECK (tarifaInvitadoPorTemporadaAdulto > 0) NOT NULL,
    tarifaInvitadoPorMesAdulto DECIMAL(10, 2) CHECK (tarifaInvitadoPorMesAdulto > 0) NOT NULL,
    tarifaInvitadoPorDiaMenor DECIMAL(10, 2) CHECK (tarifaInvitadoPorDiaMenor > 0) NOT NULL,
    tarifaInvitadoPorTemporadaMenor DECIMAL(10, 2) CHECK (tarifaInvitadoPorTemporadaMenor > 0) NOT NULL,
    tarifaInvitadoPorMesMenor DECIMAL(10, 2) CHECK (tarifaInvitadoPorMesMenor > 0) NOT NULL,
    horaAperturaActividad TIME NOT NULL,
    horaCierreActividad TIME NOT NULL,
    vigenciaHasta DATE NOT NULL
);
GO

-- 1.6 pagos.tarjetaDisponible
CREATE TABLE pagos.tarjetaDisponible (
    idTarjeta INT IDENTITY(1,1) NOT NULL,
    tipoTarjeta VARCHAR(7) NOT NULL CHECK (tipoTarjeta in ('Credito', 'Debito', 'Prepaga', 'Virtual')),
    descripcion VARCHAR(25) NOT NULL,
	CONSTRAINT PK_TarjetaDisponible PRIMARY KEY (idTarjeta, tipoTarjeta)
);
GO

-- 1.7 descuentos.descuentoDisponible
CREATE TABLE descuentos.descuentoDisponible (
    idDescuento INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(25) NOT NULL,
    porcentajeDescontado DECIMAL(5, 2) CHECK (porcentajeDescontado > 0),
	estadoDescuento BIT DEFAULT(1)
);
GO

-- 1.8 itinerarios.datosSum
CREATE TABLE itinerarios.datosSUM (
	idSitio INT PRIMARY KEY IDENTITY(1,1),
	tarifaHorariaSocio DECIMAL(10, 2) CHECK (tarifaHorariaSocio > 0) NOT NULL,
	tarifaHorariaInvitado DECIMAL(10, 2) CHECK (tarifaHorariaInvitado > 0) NOT NULL,
	horaMinimaReserva TIME NOT NULL,
	horaMaximaReserva TIME NOT NULL
);
GO

-- 1.9 coberturas.coberturaDisponible
CREATE TABLE coberturas.coberturaDisponible (
    idCoberturaDisponible INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(100) NOT NULL,
	descripcion VARCHAR(25) NOT NULL,
	activo BIT DEFAULT 1 -- 1 para activo, 0 para eliminado lógicamente
);
GO

-- 1.10 socios.ingresoSocio

CREATE TABLE socios.ingresoSocio (
	idSocio INT PRIMARY KEY IDENTITY (1,1),
	fechaIngreso DATE,
	primerUsuario VARCHAR(50),
	primerContrasenia VARCHAR(10) UNIQUE,
	tipoCategoriaSocio VARCHAR(15)
);
GO

-- 2. Tablas que dependen de las tablas base

-- 2.1 socios.socio
CREATE TABLE socios.socio (
    idSocio INT PRIMARY KEY,
	categoriaSocio INT NOT NULL DEFAULT (1), -- FK a categoriaMembresiaSocio, se usará '1' por defecto
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    dni VARCHAR(10) NOT NULL,
	email VARCHAR(100) NULL,
    fechaNacimiento DATE NULL,
    telefonoContacto VARCHAR(20) NULL,
    telefonoEmergencia VARCHAR(20) NULL,
    nombreObraSocial VARCHAR(50) NULL,
    nroSocioObraSocial VARCHAR(50) NULL,
	usuario VARCHAR(50) NULL,
    contrasenia VARCHAR(10) NULL,
    direccion VARCHAR(50) NULL,
	CONSTRAINT FK_socio_categoria FOREIGN KEY (categoriaSocio) REFERENCES socios.categoriaMembresiaSocio(idCategoria)
    );
GO

-- 2.2 socios.estadoMembresiaSocio
CREATE TABLE socios.estadoMembresiaSocio (
	idSocio INT PRIMARY KEY IDENTITY (1,1),
	tipoCategoriaSocio VARCHAR(15) CHECK (tipoCategoriaSocio in('Cadete', 'Mayor', 'Menor')),
	estadoMorosidadMembresia VARCHAR(22) NOT NULL CHECK (estadoMorosidadMembresia IN ('Activo', 'Moroso-1er Vencimiento', 'Moroso-2do Vencimiento', 'Inactivo')),
	fechaVencimientoMembresia DATE,
	FOREIGN KEY (idSocio) REFERENCES socios.ingresoSocio(idSocio)
)

-- 2.3 socios.saldoAFavorSocio
CREATE TABLE socios.saldoAFavorSocio (
	idSocio INT,
	saldoTotal DECIMAL(10,2)
	CONSTRAINT PK_saldo PRIMARY KEY (idSocio),
	FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);


--2.4 socios.grupoFamiliarSocio
CREATE TABLE socios.grupoFamiliar (
    idGrupoFamiliar INT PRIMARY KEY,
    idSocioResponsable INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    dni VARCHAR(10) NOT NULL UNIQUE, 
    emailPersonal VARCHAR(50) NULL,
    fechaNacimiento DATE NULL,
    telefonoContacto VARCHAR(20) NULL,
    telefonoContactoEmergencia VARCHAR(20) NULL,
    nombreObraSocial VARCHAR(50) NULL,
    nroSocioObraSocial VARCHAR(50) NULL,
    telefonoObraSocialEmergencia VARCHAR(14) NULL
	FOREIGN KEY (idSocioResponsable) REFERENCES socios.socio(idSocio)
);
GO


-- 3. Tablas con dependencias de segundo nivel

-- 3.1 socios.rolVigente
CREATE TABLE socios.rolVigente (
    idRol INT NOT NULL CHECK (idRol > 0),
    idSocio INT NOT NULL CHECK (idSocio > 0),
	  estadoRolVigente BIT NOT NULL CONSTRAINT estadoVigencia DEFAULT (1),
    CONSTRAINT PK_rolVigente PRIMARY KEY (idRol, idSocio),
    FOREIGN KEY (idRol) REFERENCES socios.rolDisponible(idRol),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 3.2 socios.grupoFamiliarActivo
CREATE TABLE socios.grupoFamiliarActivo (
	idSocio INT NOT NULL CHECK (idSocio > 0),
	idGrupoFamiliar INT NOT NULL CHECK (idGrupoFamiliar > 0),
	parentescoGrupoFamiliar VARCHAR(5) NOT NULL CHECK (parentescoGrupoFamiliar in('Tutor', 'Menor')),
	estadoGrupoActivo BIT NOT NULL CONSTRAINT estadoGrupo DEFAULT (1),
	CONSTRAINT PK_grupoFamiliarActivo PRIMARY KEY (idSocio, idGrupoFamiliar),
	FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
	FOREIGN KEY (idGrupoFamiliar) REFERENCES socios.grupoFamiliar(idGrupoFamiliar)
);
GO

-- 3.3 actividades.deporteActivo
CREATE TABLE actividades.deporteActivo (
    idDeporteActivo INT PRIMARY KEY IDENTITY(1,1),
    idSocio INT NOT NULL,
    idDeporte INT NOT NULL,
	  estadoActividadDeporte VARCHAR(8) NOT NULL CHECK (estadoActividadDeporte IN ('Activo', 'Inactivo')),
    estadoMembresia VARCHAR(22) NOT NULL CHECK (estadoMembresia IN ('Activo', 'Moroso-1er Vencimiento', 'Moroso-2do Vencimiento', 'Inactivo')),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idDeporte) REFERENCES actividades.deporteDisponible(idDeporte)
);
GO

-- 3.4 pagos.tarjetaEnUso
CREATE TABLE pagos.tarjetaEnUso (
    idSocio INT NOT NULL,
    idTarjeta INT NOT NULL,
    tipoTarjeta VARCHAR(7) NOT NULL,
    numeroTarjeta BIGINT CHECK (numeroTarjeta > 0),
	estadoTarjeta BIT NOT NULL DEFAULT(1),
    CONSTRAINT PK_tarjetaEnUso PRIMARY KEY (idSocio, idTarjeta, tipoTarjeta),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idTarjeta, tipoTarjeta) REFERENCES pagos.tarjetaDisponible(idTarjeta, tipoTarjeta)
);
GO

-- 3.5 pagos.facturaActiva
CREATE TABLE pagos.facturaActiva (
    idFactura INT PRIMARY KEY IDENTITY (1,1),
    idSocio INT NOT NULL,
    categoriaSocio INT NOT NULL,
    estadoFactura VARCHAR(15) CHECK (estadoFactura IN ('Pendiente', 'Pagada', 'Nulificada')),
    fechaEmision DATE,
    fechaPrimerVencimiento DATE,
    fechaSegundoVencimiento DATE,
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (categoriaSocio) REFERENCES socios.categoriaMembresiaSocio(idCategoria)
);
GO

-- 3.6 pagos.facturaEmitida
CREATE TABLE pagos.facturaEmitida (
    idFactura INT NOT NULL,
    nombreSocio VARCHAR(50) NOT NULL,
    apellidoSocio VARCHAR(50) NOT NULL,
    fechaEmision DATE DEFAULT GETDATE(),
    cuilDeudor VARCHAR(13) NOT NULL,
    domicilio VARCHAR(35) NOT NULL,
    modalidadCobro VARCHAR(8) NOT NULL CHECK (modalidadCobro IN ('Contado', 'Cuotas:_', 'efectivo', 'Tarjeta')),
    importeBruto DECIMAL(10, 2) NOT NULL CHECK (importeBruto >= 0),
    importeTotal DECIMAL(10, 2) NOT NULL CHECK (importeTotal >= 0),
    CONSTRAINT PK_facturaEmitida PRIMARY KEY (idFactura),
    FOREIGN KEY (idFactura) REFERENCES pagos.facturaActiva(idFactura)
);
GO

CREATE TABLE pagos.cuerpoFactura (
	idFactura INT,
	idItemFactura INT NOT NULL, 
	tipoItem VARCHAR(10),
	descripcionItem VARCHAR(15), 
	importeItem DECIMAL (10,2)
	CONSTRAINT PK_cuerpoFactura PRIMARY KEY (idFactura, idItemFactura),
	FOREIGN KEY (idFactura) REFERENCES pagos.facturaEmitida(idFactura)
)

-- 3.7 pagos.cobroFactura
CREATE TABLE pagos.cobroFactura (
    idCobro BIGINT PRIMARY KEY,
    idFacturaCobrada INT NULL,
    idSocio INT, 
    categoriaSocio INT NOT NULL,
    fechaEmisionCobro DATE NOT NULL,
    nombreSocio VARCHAR(50) NOT NULL,
    apellidoSocio VARCHAR(50) NOT NULL,
    cuilDeudor VARCHAR(13) NOT NULL, 
    domicilio VARCHAR(50) NULL,
    modalidadCobro VARCHAR(25) NOT NULL,
    numeroCuota INT NOT NULL DEFAULT 1, 
    totalAbonado DECIMAL(10, 2) NOT NULL CHECK (totalAbonado >= 0),
    CONSTRAINT FK_cobroFactura_idSocio FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    CONSTRAINT FK_cobroFactura_idFacturaCobrada FOREIGN KEY (idFacturaCobrada) REFERENCES pagos.facturaEmitida(idFactura)
);
GO

-- 3.8 pagos.cuerpoCobro
CREATE TABLE pagos.cuerpoCobro (
    idCobro BIGINT NOT NULL,
    idFactura INT NOT NULL, -- Asumo que esto se refiere a idFacturaCobrada en cobroFactura
    idItemCobro INT IDENTITY(1,1),
    tipoItem VARCHAR(20),
    despricionItem VARCHAR(25),
    importeItem DECIMAL(10,2),
    CONSTRAINT PK_cuerpoCobro PRIMARY KEY (idCobro, idFactura, idItemCobro),
    CONSTRAINT FK_cuerpoCobro_cobroFactura FOREIGN KEY (idCobro) REFERENCES pagos.cobroFactura(idCobro)
);
GO

-- 3.9 descuentos.descuentoVigente
CREATE TABLE descuentos.descuentoVigente (
    idDescuento INT,
    idSocio INT,
	CONSTRAINT PK_descuentoVigente PRIMARY KEY (idDescuento, idSocio),
    FOREIGN KEY (idDescuento) REFERENCES descuentos.descuentoDisponible(idDescuento), 
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 3.10 itinerarios.itinerario
CREATE TABLE itinerarios.itinerario (
    idItinerario INT PRIMARY KEY IDENTITY(1,1),
    dia VARCHAR(9) NOT NULL,
    idDeporte INT NOT NULL,
    horaInicio VARCHAR(50) NOT NULL,
    horaFin VARCHAR(50) NOT NULL,
    FOREIGN KEY (idDeporte) REFERENCES actividades.deporteDisponible(idDeporte)
);
GO

-- 3.11 coberturas.prepagaEnUso
CREATE TABLE coberturas.prepagaEnUso (
    idPrepaga INT PRIMARY KEY IDENTITY(1,1),
    idCobertura INT NOT NULL,
    idNumeroSocio INT NOT NULL,
    categoriaSocio INT NOT NULL,
	activo BIT DEFAULT 1, -- 1 para activo, 0 para eliminado lógicamente
    FOREIGN KEY (idCobertura) REFERENCES coberturas.coberturaDisponible(idCoberturaDisponible),
    FOREIGN KEY (idNumeroSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 3.12 reservas.reservaSum 
CREATE TABLE reservas.reservaSUM (
	idReserva INT IDENTITY(1,1),
	idSocio INT NOT NULL CHECK (idSocio >= 0), -- Porque si no es socio y es Invitado, iria 0
	idSalon INT NOT NULL,
	dniReservante INT NOT NULL,
	horaInicioReserva INT NOT NULL,
	horaFinReserva INT NOT NULL,
	tarifaHorariaSocio DECIMAL(10, 2) CHECK (tarifaHorariaSocio > 0) NOT NULL,
	tarifaHorariaInvitado DECIMAL(10, 2) CHECK (tarifaHorariaInvitado > 0) NOT NULL,
	CONSTRAINT PK_reservasSUM PRIMARY KEY (idReserva, idSocio, dniReservante),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
	FOREIGN KEY (idSalon) REFERENCES itinerarios.datosSUM(idSitio)
);
GO

-- 3.13 reservas.reservaPaseActividad
CREATE TABLE reservas.reservaPaseActividad (
	idReservaActividad INT IDENTITY (1,1),
	idSocio INT NOT NULL CHECK (idSocio >= 0), -- Porque si no es socio y es Invitado, iria 0
	categoriaSocio INT NOT NULL,
	categoriaPase VARCHAR(9) NOT NULL CHECK (categoriaPase in ('Dia', 'Mensual', 'Temporada')),
	montoTotalActividad DECIMAL(10, 2) CHECK (montoTotalActividad > 0) NOT NULL,
	CONSTRAINT PK_reservaPaseActividad PRIMARY KEY (idReservaActividad, idSocio),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 3.14 pagos.reembolso
CREATE TABLE pagos.reembolso (
    idFacturaReembolso INT NOT NULL IDENTITY(1,1),
    idCobroOriginal BIGINT NOT NULL,
    idFacturaOriginal INT NOT NULL,
    idSocioDestinatario INT NOT NULL,
    montoReembolsado DECIMAL(10, 2) NOT NULL CHECK (montoReembolsado > 0),
    cuilDestinatario BIGINT NOT NULL CHECK (cuilDestinatario > 0),
    medioDePagoUsado VARCHAR(50) NOT NULL,
    razonReembolso VARCHAR(50) NOT NULL,
    CONSTRAINT PK_reembolso PRIMARY KEY (idFacturaReembolso, idCobroOriginal),
    CONSTRAINT FK_reembolso_idCobroOriginal FOREIGN KEY (idCobroOriginal) REFERENCES pagos.cobroFactura(idCobro), -- FK ajustada
    FOREIGN KEY (idFacturaOriginal) REFERENCES pagos.facturaEmitida(idFactura), -- Mantenida, pero puede ser problemática si idFacturaCobrada en cobroFactura es NULL
    FOREIGN KEY (idSocioDestinatario) REFERENCES socios.socio(idSocio)
);
GO

-- 3.15 actividades.presentismoActividadSocio
CREATE TABLE actividades.presentismoActividadSocio (
    idSocio INT NOT NULL,
    idDeporteActivo INT NOT NULL,
    fechaActividad DATE NOT NULL,
    estadoPresentismo VARCHAR(1) NOT NULL CHECK (estadoPresentismo in ('P', 'A', 'J')), -- (P)RESENTE, (A)usente y Ausente (J)ustificado
    profesorDeporte VARCHAR(35) NOT NULL,
	CONSTRAINT PK_presentismoActividadSocio PRIMARY KEY (idSocio, idDeporteActivo, fechaActividad),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idDeporteActivo) REFERENCES actividades.deporteActivo(idDeporteActivo)
);
GO

-- :::::::::::::::::::::::::::::::::::::::::::: FUNCIONES Y STORED PROCEDURES ::::::::::::::::::::::::::::::::::::::::::::
CREATE OR ALTER FUNCTION socios.validarCUIL(@cuil VARCHAR(13))
RETURNS BIT
AS
BEGIN
    DECLARE @cuit_nro VARCHAR(11);
    DECLARE @codes VARCHAR(10) = '6789456789';
    DECLARE @resultado INT = 0;
    DECLARE @verificador INT;
    DECLARE @x INT = 0;
    DECLARE @validacion BIT = 0;

    SET @cuit_nro = REPLACE(@cuil, '-', '');

    -- Debe tener exactamente 11 dígitos
    IF LEN(@cuit_nro) <> 11 OR ISNUMERIC(@cuit_nro) = 0
        RETURN 0;

    SET @verificador = CONVERT(INT, RIGHT(@cuit_nro, 1));

    WHILE @x < 10
    BEGIN
        SET @resultado = @resultado + 
            CONVERT(INT, SUBSTRING(@codes, @x + 1, 1)) *
            CONVERT(INT, SUBSTRING(@cuit_nro, @x + 1, 1));
        SET @x = @x + 1;
    END

    SET @resultado = @resultado % 11;

    IF @resultado = @verificador
        SET @validacion = 1;

    RETURN @validacion;
END
GO

CREATE OR ALTER FUNCTION socios.validarDNI(@dni VARCHAR(10))
RETURNS BIT
AS
BEGIN
    DECLARE @clean VARCHAR(10) = REPLACE(REPLACE(@dni, '.', ''), ' ', '');

    IF LEN(@clean) < 7 OR LEN(@clean) > 8
        RETURN 0;
    IF ISNUMERIC(@clean) = 0
        RETURN 0;

    RETURN 1;
END
GO

--SPs

-- 1.1 categoriaMembresiaSocio

CREATE OR ALTER PROCEDURE socios.insertarCategoriaMembresiaSocio
  @tipo            VARCHAR(15),
  @costoMembresia  DECIMAL(10,2)
AS
BEGIN
  SET NOCOUNT ON;

  -- Validaciones
  IF LTRIM(RTRIM(@tipo)) = ''
    THROW 50001, 'El tipo no puede quedar vacío.', 1;
  IF @costoMembresia <= 0
    THROW 50002, 'El costo de membresía debe ser mayor a cero.', 1;

  INSERT INTO socios.categoriaMembresiaSocio (tipo, costoMembresia)
  VALUES (@tipo, @costoMembresia);
END;
GO

CREATE OR ALTER PROCEDURE socios.actualizarCategoriaMembresiaSocio
  @idCategoria     INT,
  @tipo            VARCHAR(15),
  @costoMembresia  DECIMAL(10,2)
AS
BEGIN
  SET NOCOUNT ON;

  -- Verificar existencia y estado activo
  IF NOT EXISTS (
    SELECT 1 FROM socios.categoriaMembresiaSocio
    WHERE idCategoria = @idCategoria
      AND estadoCategoriaSocio = 1
  )
    THROW 50003, 'Categoría no encontrada o inactiva.', 1;

  -- Validaciones
  IF LTRIM(RTRIM(@tipo)) = ''
    THROW 50004, 'El tipo no puede quedar vacío.', 1;
  IF @costoMembresia <= 0
    THROW 50005, 'El costo de membresía debe ser mayor a cero.', 1;

  UPDATE socios.categoriaMembresiaSocio
  SET
    tipo = @tipo,
    costoMembresia = @costoMembresia
  WHERE idCategoria = @idCategoria;
END;
GO

CREATE OR ALTER PROCEDURE socios.eliminarCategoriaMembresiaSocio
  @idCategoria INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Verificar existencia y estado activo
  IF NOT EXISTS (
    SELECT 1 FROM socios.categoriaMembresiaSocio
    WHERE idCategoria = @idCategoria
      AND estadoCategoriaSocio = 1
  )
    THROW 50006, 'Categoría no encontrada o ya inactiva.', 1;

  -- Marcamos como inactiva
  UPDATE socios.categoriaMembresiaSocio
  SET estadoCategoriaSocio = 0
  WHERE idCategoria = @idCategoria;
END;
GO

--socio
CREATE OR ALTER PROCEDURE socios.registrarNuevoSocio
  @fechaIngreso           DATE,
  @primerUsuario          VARCHAR(50),
  @primerContrasenia      VARCHAR(10),
  @tipoCategoriaSocio     VARCHAR(15),
  @dni                    VARCHAR(10),
  @cuil                   VARCHAR(13),
  @nombre                 VARCHAR(50),
  @apellido               VARCHAR(50),
  @email                  VARCHAR(100)   = NULL,
  @fechaNacimiento        DATE           = NULL,
  @telefonoContacto       VARCHAR(20)    = NULL,
  @telefonoEmergencia     VARCHAR(20)    = NULL,
  @nombreObraSocial       VARCHAR(50)    = NULL,
  @nroSocioObraSocial     VARCHAR(50)    = NULL,
  @usuario                VARCHAR(50)    = NULL,
  @contrasenia            VARCHAR(10)    = NULL,
  @direccion              VARCHAR(50)    = NULL,
  @deportePreferido       INT            = NULL,
  @rolAsignar             INT            = NULL,
  @newIdSocio             INT            OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  -- VALIDACIONES PRE-TRANSACCIÓN
  IF socios.validarDNI(@dni) = 0
    THROW 50010, 'DNI inválido.', 1;
  IF socios.validarCUIL(@cuil) = 0
    THROW 50011, 'CUIL inválido.', 1;
  IF @usuario IS NOT NULL
     AND EXISTS(SELECT 1 FROM socios.socio WHERE usuario = @usuario)
    THROW 50012, 'El nombre de usuario ya existe.', 1;
  IF EXISTS(SELECT 1 FROM socios.ingresoSocio WHERE primerContrasenia = @primerContrasenia)
    THROW 50013, 'La contraseña inicial ya existe.', 1;

  BEGIN TRANSACTION;
  BEGIN TRY
    -- 1) IngresoSocio
    INSERT INTO socios.ingresoSocio(
      fechaIngreso, primerUsuario, primerContrasenia, tipoCategoriaSocio
    ) VALUES (
      @fechaIngreso, @primerUsuario, @primerContrasenia, @tipoCategoriaSocio
    );
    SET @newIdSocio = SCOPE_IDENTITY();

    -- 2) Resolver categoría vigente
    DECLARE @categoriaSocioId INT;
    SELECT @categoriaSocioId = idCategoria
      FROM socios.categoriaMembresiaSocio
     WHERE tipo = @tipoCategoriaSocio
       AND estadoCategoriaSocio = 1
       AND vigenciaHasta >= CAST(GETDATE() AS DATE);
    IF @categoriaSocioId IS NULL
      THROW 50014, 'Categoría no encontrada, inactiva o vencida.', 1;

    -- 3) Socio
    INSERT INTO socios.socio(
      idSocio, categoriaSocio,
      nombre, apellido, dni, email,
      fechaNacimiento, telefonoContacto, telefonoEmergencia,
      nombreObraSocial, nroSocioObraSocial,
      usuario, contrasenia, direccion
    ) VALUES (
      @newIdSocio, @categoriaSocioId,
      @nombre, @apellido, @dni, @email,
      @fechaNacimiento, @telefonoContacto, @telefonoEmergencia,
      @nombreObraSocial, @nroSocioObraSocial,
      @usuario, @contrasenia, @direccion
    );

    -- 4) EstadoMembresiaSocio
    SET IDENTITY_INSERT socios.estadoMembresiaSocio ON;
    INSERT INTO socios.estadoMembresiaSocio(
      idSocio, tipoCategoriaSocio,
      estadoMorosidadMembresia, fechaVencimientoMembresia
    ) VALUES (
      @newIdSocio, @tipoCategoriaSocio,
      'Activo', DATEADD(MONTH,1,GETDATE())
    );
    SET IDENTITY_INSERT socios.estadoMembresiaSocio OFF;

    -- 5) FacturaActiva + Emitir
    DECLARE @newFacturaId INT;
    EXEC pagos.insertarFacturaActiva
      @idSocio        = @newIdSocio,
      @categoriaSocio = @categoriaSocioId,
      @newFacturaId   = @newFacturaId OUTPUT;
    DECLARE @domicilioFinal VARCHAR(50) = ISNULL(@direccion,'-');
    EXEC pagos.emitirFactura
      @idFactura      = @newFacturaId,
      @cuilDeudor     = @cuil,                -- uso correcto de @cuil
      @domicilio      = @domicilioFinal,
      @modalidadCobro = 'Contado',
      @importeBruto   = 0.00;

     ----------------------------------------------------------------
    -- 6) Insertar en cuerpoFactura: primero la membresía
    ----------------------------------------------------------------
    DECLARE 
      @costoMembresia DECIMAL(10,2),
      @descripcionMemb VARCHAR(50);

    SELECT 
      @costoMembresia  = costoMembresia,
      @descripcionMemb = tipo
    FROM socios.categoriaMembresiaSocio
    WHERE idCategoria = @categoriaSocioId;

    EXEC pagos.insertarCuerpoFactura
      @idFactura        = @newFacturaId,
      @tipoItem         = 'Membresía',
      @descripcionItem  = @descripcionMemb,
      @importeItem      = @costoMembresia;

    ----------------------------------------------------------------
    -- 7) Insertar en cuerpoFactura: deporte (si aplicó)
    ----------------------------------------------------------------
    IF @deportePreferido IS NOT NULL
    BEGIN
      EXEC actividades.insertarDeporteActivo
        @idSocio   = @newIdSocio,
        @idDeporte = @deportePreferido;

      DECLARE @descr NVARCHAR(50), @costo DECIMAL(10,2);
      SELECT 
        @descr = descripcion,
        @costo = costoPorMes
      FROM actividades.deporteDisponible
      WHERE idDeporte = @deportePreferido
        AND vigenciaHasta >= CAST(GETDATE() AS DATE);

      EXEC pagos.insertarCuerpoFactura
        @idFactura        = @newFacturaId,
        @tipoItem         = 'Deporte',
        @descripcionItem  = @descr,
        @importeItem      = @costo;
    END

    -- 8) RolVigente
    IF @rolAsignar IS NOT NULL
      EXEC socios.insertarRolVigente
        @idRol   = @rolAsignar,
        @idSocio = @newIdSocio;

    COMMIT TRANSACTION;
    PRINT 'Registro exitoso. Socio ID=' + CAST(@newIdSocio AS VARCHAR(10));
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
  END CATCH
END;
GO

CREATE OR ALTER PROCEDURE socios.actualizarSocio
  @idSocio                INT,
  @categoriaSocio         INT             = NULL,
  @dni                    VARCHAR(10)     = NULL,
  @nombre                 VARCHAR(50)     = NULL,
  @apellido               VARCHAR(50)     = NULL,
  @email                  VARCHAR(100)    = NULL,
  @fechaNacimiento        DATE            = NULL,
  @telefonoContacto       VARCHAR(20)     = NULL,
  @telefonoEmergencia     VARCHAR(20)     = NULL,
  @nombreObraSocial       VARCHAR(50)     = NULL,
  @nroSocioObraSocial     VARCHAR(50)     = NULL,
  @usuario                VARCHAR(50)     = NULL,
  @contraseniaNueva       VARCHAR(10)     = NULL,
  @direccion              VARCHAR(50)     = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- 1) Verificar existencia
  IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
    THROW 50201, 'Socio no encontrado.', 1;

  -- 2) Validar nueva categoría si se pasa
  IF @categoriaSocio IS NOT NULL
    AND NOT EXISTS (
      SELECT 1
        FROM socios.categoriaMembresiaSocio
       WHERE idCategoria = @categoriaSocio
         AND estadoCategoriaSocio = 1
         AND vigenciaHasta >= CAST(GETDATE() AS DATE)
    )
    THROW 50202, 'Categoría no existe, inactiva o vencida.', 1;

  -- 3) Validar DNI si se pasa
  IF @dni IS NOT NULL
    AND socios.validarDNI(@dni) = 0
    THROW 50203, 'DNI inválido.', 1;

  -- 4) Validar unicidad de usuario si se pasa
  IF @usuario IS NOT NULL
    AND EXISTS (
      SELECT 1
        FROM socios.socio
       WHERE usuario = @usuario
         AND idSocio <> @idSocio
    )
    THROW 50204, 'El usuario ya está en uso.', 1;

  -- 5) Ejecutar UPDATE
  UPDATE socios.socio
  SET
    categoriaSocio       = COALESCE(@categoriaSocio, categoriaSocio),
    dni                  = COALESCE(@dni, dni),
    nombre               = COALESCE(@nombre, nombre),
    apellido             = COALESCE(@apellido, apellido),
    email                = COALESCE(@email, email),
    fechaNacimiento      = COALESCE(@fechaNacimiento, fechaNacimiento),
    telefonoContacto     = COALESCE(@telefonoContacto, telefonoContacto),
    telefonoEmergencia   = COALESCE(@telefonoEmergencia, telefonoEmergencia),
    nombreObraSocial     = COALESCE(@nombreObraSocial, nombreObraSocial),
    nroSocioObraSocial   = COALESCE(@nroSocioObraSocial, nroSocioObraSocial),
    usuario              = COALESCE(@usuario, usuario),
    contrasenia          = COALESCE(@contraseniaNueva, contrasenia),
    direccion            = COALESCE(@direccion, direccion)
  WHERE idSocio = @idSocio;
END;
GO

CREATE OR ALTER PROCEDURE socios.eliminarSocioLogico
  @idSocio INT
AS
BEGIN
  SET NOCOUNT ON;

  -- 1. Verificar existencia en estadoMembresiaSocio
  IF NOT EXISTS (SELECT 1 FROM socios.estadoMembresiaSocio WHERE idSocio = @idSocio)
    THROW 50021, 'No existe registro de estado de membresía para ese socio.', 1;

  -- 2. Marcar como Inactivo
  UPDATE socios.estadoMembresiaSocio
  SET estadoMorosidadMembresia = 'Inactivo'
  WHERE idSocio = @idSocio;
END;
GO

--rolDisponible

CREATE OR ALTER PROCEDURE socios.insertarRolDisponible
    @idRol       INT,
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @idRol IS NULL OR @idRol <= 0
    BEGIN
        RAISERROR('El idRol debe ser mayor que cero.',16,1);
        RETURN;
    END
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
    BEGIN
        RAISERROR('La descripción no puede quedar vacía.',16,1);
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM socios.rolDisponible WHERE idRol = @idRol AND estadoRol = 1)
    BEGIN
        RAISERROR('Ya existe un rol activo con id %d.',16,1,@idRol);
        RETURN;
    END

    INSERT INTO socios.rolDisponible (idRol, descripcion)
    VALUES (@idRol, @descripcion);
END
GO

CREATE OR ALTER PROCEDURE socios.actualizarRolDisponible
    @idRol       INT,
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM socios.rolDisponible WHERE idRol = @idRol AND estadoRol = 1)
    BEGIN
        RAISERROR('No existe un rol activo con id %d.',16,1,@idRol);
        RETURN;
    END

    -- Validación de descripción
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
    BEGIN
        RAISERROR('La descripción no puede quedar vacía.',16,1);
        RETURN;
    END

    UPDATE socios.rolDisponible
    SET descripcion = @descripcion
    WHERE idRol = @idRol;
END
GO

CREATE OR ALTER PROCEDURE socios.desactivarRolDisponible
    @idRol INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM socios.rolDisponible WHERE idRol = @idRol AND estadoRol = 1)
    BEGIN
        RAISERROR('No existe un rol activo con id %d.',16,1,@idRol);
        RETURN;
    END

    UPDATE socios.rolDisponible
    SET estadoRol = 0
    WHERE idRol = @idRol;
END
GO

CREATE OR ALTER PROCEDURE socios.insertarSaldoSocio
  @idSocio INT,
  @saldoInicial DECIMAL(10,2)
AS
BEGIN
  SET NOCOUNT ON;

  -- Validar existencia del socio
  IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
    THROW 51001, 'El socio especificado no existe.', 1;

  -- Validar que no exista ya saldo
  IF EXISTS (SELECT 1 FROM socios.saldoAFavorSocio WHERE idSocio = @idSocio)
    THROW 51002, 'Ya existe un saldo registrado para este socio.', 1;

  IF @saldoInicial < 0
    THROW 51003, 'El saldo inicial no puede ser negativo.', 1;

  -- Insertar
  INSERT INTO socios.saldoAFavorSocio (idSocio, saldoTotal)
  VALUES (@idSocio, @saldoInicial);
END;
GO


CREATE OR ALTER PROCEDURE socios.actualizarSaldoSocio
  @idSocio INT,
  @montoAjuste DECIMAL(10,2) -- Puede ser positivo (suma) o negativo (resta)
AS
BEGIN
  SET NOCOUNT ON;

  -- Validar existencia
  IF NOT EXISTS (SELECT 1 FROM socios.saldoAFavorSocio WHERE idSocio = @idSocio)
    THROW 51010, 'El socio no tiene saldo registrado.', 1;

  -- Validar que el saldo resultante no sea negativo
  DECLARE @saldoActual DECIMAL(10,2);
  SELECT @saldoActual = saldoTotal FROM socios.saldoAFavorSocio WHERE idSocio = @idSocio;

  IF @saldoActual + @montoAjuste < 0
    THROW 51011, 'El ajuste dejaría el saldo en negativo.', 1;

  -- Actualizar
  UPDATE socios.saldoAFavorSocio
  SET saldoTotal = saldoTotal + @montoAjuste
  WHERE idSocio = @idSocio;
END;
GO

CREATE OR ALTER PROCEDURE socios.eliminarSaldoSocioLogico
  @idSocio INT
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM socios.saldoAFavorSocio WHERE idSocio = @idSocio)
    THROW 51020, 'El socio no tiene saldo registrado.', 1;

  -- Poner en cero
  UPDATE socios.saldoAFavorSocio
  SET saldoTotal = 0
  WHERE idSocio = @idSocio;
END;
GO

--rolVigente

CREATE OR ALTER PROCEDURE socios.insertarRolVigente
  @idRol INT,
  @idSocio INT
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM socios.rolDisponible WHERE idRol = @idRol)
  BEGIN
    THROW 51001, 'El ID de rol especificado no existe.', 1;
  END

  IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
  BEGIN
    THROW 51002, 'El ID de socio especificado no existe.', 1;
  END

  IF EXISTS (
    SELECT 1 FROM socios.rolVigente 
    WHERE idRol = @idRol AND idSocio = @idSocio
  )
  BEGIN
    THROW 51003, 'Ya existe una relación entre este rol y socio.', 1;
  END

  INSERT INTO socios.rolVigente (idRol, idSocio, estadoRolVigente)
  VALUES (@idRol, @idSocio, 1);

  PRINT 'Rol asignado correctamente.';
END;
GO

CREATE OR ALTER PROCEDURE socios.actualizarEstadoRolVigente
  @idRol INT,
  @idSocio INT,
  @nuevoEstado BIT
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (
    SELECT 1 FROM socios.rolVigente 
    WHERE idRol = @idRol AND idSocio = @idSocio
  )
  BEGIN
    THROW 51004, 'La relación rol-socio no existe.', 1;
  END

  UPDATE socios.rolVigente
  SET estadoRolVigente = @nuevoEstado
  WHERE idRol = @idRol AND idSocio = @idSocio;

  PRINT 'Estado del rol actualizado correctamente.';
END;
GO

CREATE OR ALTER PROCEDURE socios.obtenerRolesVigentesDeSocio
  @idSocio INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT rv.idRol, rd.descripcion, rv.estadoRolVigente
  FROM socios.rolVigente rv
  JOIN socios.rolDisponible rd ON rv.idRol = rd.idRol
  WHERE rv.idSocio = @idSocio;
END;
GO


--grupoFamiliar

CREATE OR ALTER PROCEDURE socios.insertarGrupoFamiliar
  @idGrupoFamiliar                   INT,
  @idSocioResponsable                INT,
  @nombre                            VARCHAR(50),
  @apellido                          VARCHAR(50),
  @dni                               VARCHAR(10),
  @emailPersonal                     VARCHAR(50)    = NULL,
  @fechaNacimiento                   DATE           = NULL,
  @telefonoContacto                  VARCHAR(20)    = NULL,
  @telefonoContactoEmergencia        VARCHAR(20)    = NULL,
  @nombreObraSocial                  VARCHAR(50)    = NULL,
  @nroSocioObraSocial                VARCHAR(50)    = NULL,
  @telefonoObraSocialEmergencia      VARCHAR(14)    = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- 1) Validar socio responsable
  IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocioResponsable)
    THROW 51001, 'Socio responsable no encontrado.', 1;

  -- 2) PK no duplicada
  IF EXISTS (SELECT 1 FROM socios.grupoFamiliar WHERE idGrupoFamiliar = @idGrupoFamiliar)
    THROW 51002, 'Ya existe un grupo con ese ID.', 1;

  -- 3) DNI único dentro del grupo
  IF EXISTS (SELECT 1 FROM socios.grupoFamiliar WHERE dni = @dni)
    THROW 51003, 'El DNI ya está registrado en otro miembro del grupo.', 1;

  -- 4) Insertar miembro
  INSERT INTO socios.grupoFamiliar (
    idGrupoFamiliar,
    idSocioResponsable,
    nombre,
    apellido,
    dni,
    emailPersonal,
    fechaNacimiento,
    telefonoContacto,
    telefonoContactoEmergencia,
    nombreObraSocial,
    nroSocioObraSocial,
    telefonoObraSocialEmergencia
  )
  VALUES (
    @idGrupoFamiliar,
    @idSocioResponsable,
    @nombre,
    @apellido,
    @dni,
    @emailPersonal,
    @fechaNacimiento,
    @telefonoContacto,
    @telefonoContactoEmergencia,
    @nombreObraSocial,
    @nroSocioObraSocial,
    @telefonoObraSocialEmergencia
  );

  -- 5) Generar descuento vigente para el socio responsable
  DECLARE @idDescuento INT;

  -- Buscar o crear el tipo de descuento “DESCUENTO GRUPO FAMILIAR”
  SELECT @idDescuento = idDescuento
    FROM descuentos.descuentoDisponible
   WHERE tipo = 'DESCUENTO GRUPO FAMILIAR'
     AND estadoDescuento = 1;

  -- Insertar en descuentoVigente
  IF NOT EXISTS (
    SELECT 1 FROM descuentos.descuentoVigente
    WHERE idDescuento = @idDescuento
      AND idSocio = @idSocioResponsable
  )
  BEGIN
    INSERT INTO descuentos.descuentoVigente (idDescuento, idSocio)
    VALUES (@idDescuento, @idSocioResponsable);
  END
END;
GO


-- ===============================================
-- Actualiza los datos de un miembro de grupo familiar
-- ===============================================
CREATE OR ALTER PROCEDURE socios.actualizarGrupoFamiliar
  @idGrupoFamiliar                   INT,
  @idSocioResponsable                INT            = NULL,
  @nombre                            VARCHAR(50)    = NULL,
  @apellido                          VARCHAR(50)    = NULL,
  @dni                               VARCHAR(10)    = NULL,
  @emailPersonal                     VARCHAR(50)    = NULL,
  @fechaNacimiento                   DATE           = NULL,
  @telefonoContacto                  VARCHAR(20)    = NULL,
  @telefonoContactoEmergencia        VARCHAR(20)    = NULL,
  @nombreObraSocial                  VARCHAR(50)    = NULL,
  @nroSocioObraSocial                VARCHAR(50)    = NULL,
  @telefonoObraSocialEmergencia      VARCHAR(14)    = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- 1) Verificar existencia del registro
  IF NOT EXISTS (SELECT 1 FROM socios.grupoFamiliar WHERE idGrupoFamiliar = @idGrupoFamiliar)
    THROW 51011, 'Miembro de grupo familiar no encontrado.', 1;

  -- 2) Validar cambio de responsable (si se pasa)
  IF @idSocioResponsable IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocioResponsable)
    THROW 51012, 'Nuevo socio responsable no existe.', 1;

  -- 3) Validar cambio de DNI (si se pasa)
  IF @dni IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM socios.grupoFamiliar 
      WHERE dni = @dni AND idGrupoFamiliar <> @idGrupoFamiliar
    )
    THROW 51013, 'El DNI ingresado ya existe en otro miembro.', 1;

  -- 4) Aplicar UPDATE
  UPDATE socios.grupoFamiliar
  SET
    idSocioResponsable           = COALESCE(@idSocioResponsable, idSocioResponsable),
    nombre                        = COALESCE(@nombre, nombre),
    apellido                      = COALESCE(@apellido, apellido),
    dni                           = COALESCE(@dni, dni),
    emailPersonal                 = COALESCE(@emailPersonal, emailPersonal),
    fechaNacimiento               = COALESCE(@fechaNacimiento, fechaNacimiento),
    telefonoContacto              = COALESCE(@telefonoContacto, telefonoContacto),
    telefonoContactoEmergencia    = COALESCE(@telefonoContactoEmergencia, telefonoContactoEmergencia),
    nombreObraSocial              = COALESCE(@nombreObraSocial, nombreObraSocial),
    nroSocioObraSocial            = COALESCE(@nroSocioObraSocial, nroSocioObraSocial),
    telefonoObraSocialEmergencia  = COALESCE(@telefonoObraSocialEmergencia, telefonoObraSocialEmergencia)
  WHERE idGrupoFamiliar = @idGrupoFamiliar;
END;
GO

-- ===============================================
-- Elimina un miembro de grupo familiar
-- ===============================================
CREATE OR ALTER PROCEDURE socios.eliminarGrupoFamiliar
  @idGrupoFamiliar INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Verificar existencia
  IF NOT EXISTS (SELECT 1 FROM socios.grupoFamiliar WHERE idGrupoFamiliar = @idGrupoFamiliar)
    THROW 51021, 'Miembro de grupo familiar no encontrado.', 1;

  DELETE FROM socios.grupoFamiliar
  WHERE idGrupoFamiliar = @idGrupoFamiliar;
END;
GO

--grupoFamiliarActivo // probablemente saquemos esta tabla.

/*CREATE OR ALTER PROCEDURE socios.insertarGrupoFamiliarActivo
  @idSocio INT,
  @idGrupoFamiliar INT,
  @parentescoGrupoFamiliar VARCHAR(5)
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (
    SELECT 1 FROM socios.socio WHERE idSocio = @idSocio
  )
  BEGIN
    THROW 50010, 'El socio especificado no existe.', 1;
  END

  IF NOT EXISTS (
    SELECT 1 FROM socios.grupoFamiliar WHERE idGrupoFamiliar = @idGrupoFamiliar
  )
  BEGIN
    THROW 50011, 'El grupo familiar especificado no existe.', 1;
  END

  IF @parentescoGrupoFamiliar NOT IN ('Tutor', 'Menor')
  BEGIN
    THROW 50012, 'Parentesco no válido. Debe ser "Tutor" o "Menor".', 1;
  END

  INSERT INTO socios.grupoFamiliarActivo (
    idSocio,
    idGrupoFamiliar,
    parentescoGrupoFamiliar,
    estadoGrupoActivo
  )
  VALUES (
    @idSocio,
    @idGrupoFamiliar,
    @parentescoGrupoFamiliar,
    1
  );
END
GO


CREATE OR ALTER PROCEDURE socios.obtenerGrupoFamiliarDeSocio
  @idSocio INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT 
    gfa.idGrupoFamiliar,
    gfa.parentescoGrupoFamiliar,
    gfa.estadoGrupoActivo
  FROM socios.grupoFamiliarActivo gfa
  WHERE gfa.idSocio = @idSocio;
END;
GO

CREATE OR ALTER PROCEDURE socios.borradoLogicoGrupoActivo
  @idSocio INT,
  @idGrupoFamiliar INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @estado VARCHAR(22);

  SELECT @estado = estadoMorosidadMembresia
  FROM socios.estadoMembresiaSocio
  WHERE idSocio = @idSocio;

  IF @estado IS NULL
  BEGIN
    THROW 50020, 'El estado de membresía del socio no fue encontrado.', 1;
  END

  IF @estado <> 'Activo'
  BEGIN
    THROW 50021, 'Solo se puede modificar el grupo familiar si el socio tiene la membresía activa.', 1;
  END

  UPDATE socios.grupoFamiliarActivo
  SET estadoGrupoActivo = 0
  WHERE idSocio = @idSocio AND idGrupoFamiliar = @idGrupoFamiliar;

  IF @@ROWCOUNT = 0
  BEGIN
    THROW 50022, 'No se encontró relación activa para modificar.', 1;
  END
END;
GO*/

--deporteDisponible

CREATE OR ALTER PROCEDURE actividades.insertarDeporteDisponible
  @descripcion   VARCHAR(20),
  @tipo          VARCHAR(10),
  @costoPorMes   DECIMAL(10,2)
AS
BEGIN
  SET NOCOUNT ON;

  IF @costoPorMes <= 0
  BEGIN
    RAISERROR('El costo por mes debe ser mayor a cero.', 16, 1);
    RETURN;
  END

  INSERT INTO actividades.deporteDisponible (descripcion, tipo, costoPorMes)
  VALUES (@descripcion, @tipo, @costoPorMes);
END
GO

CREATE OR ALTER PROCEDURE actividades.actualizarDeporteDisponible
  @idDeporte     INT,
  @descripcion   VARCHAR(20),
  @tipo          VARCHAR(10),
  @costoPorMes   DECIMAL(10,2)
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (
    SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte
  )
  BEGIN
    RAISERROR('No existe un deporte con el ID especificado.', 16, 1);
    RETURN;
  END

  IF @costoPorMes <= 0
  BEGIN
    RAISERROR('El costo por mes debe ser mayor a cero.', 16, 1);
    RETURN;
  END

  UPDATE actividades.deporteDisponible
  SET descripcion = @descripcion,
      tipo = @tipo,
      costoPorMes = @costoPorMes
  WHERE idDeporte = @idDeporte;
END
GO

CREATE OR ALTER PROCEDURE actividades.eliminarDeporteDisponible
  @idDeporte INT
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (
    SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte
  )
  BEGIN
    RAISERROR('No existe un deporte con el ID especificado.', 16, 1);
    RETURN;
  END

  DELETE FROM actividades.deporteDisponible
  WHERE idDeporte = @idDeporte;
END
GO

--deporteActivo

CREATE OR ALTER PROCEDURE actividades.insertarDeporteActivo
  @idSocio INT,
  @idDeporte INT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    -- Validar existencia y membresía activa del socio
    DECLARE @estadoMembresia VARCHAR(22);

    SELECT @estadoMembresia = estadoMorosidadMembresia
    FROM socios.estadoMembresiaSocio
    WHERE idSocio = @idSocio;

    IF @estadoMembresia <> 'Activo'
      THROW 50011, 'El socio no tiene una membresía activa.', 1;

    -- Verificar que el deporte exista
	IF NOT EXISTS (
	  SELECT 1
		FROM actividades.deporteDisponible
	   WHERE idDeporte = @idDeporte
		 AND vigenciaHasta >= CAST(GETDATE() AS DATE)
	)
	  THROW 50012, 'El deporte especificado no existe o está vencido.', 1;

    -- Insertar actividad deportiva activa
    INSERT INTO actividades.deporteActivo (
      idSocio, idDeporte, estadoActividadDeporte, estadoMembresia
    )
    VALUES (
      @idSocio, @idDeporte, 'Activo', @estadoMembresia
    );
  END TRY
  BEGIN CATCH
    THROW;
  END CATCH
END;
GO


CREATE OR ALTER PROCEDURE actividades.obtenerDeportesDeSocio
  @idSocio INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT da.idDeporteActivo, d.descripcion, d.tipo, d.costoPorMes,
         da.estadoActividadDeporte, da.estadoMembresia
  FROM actividades.deporteActivo da
  JOIN actividades.deporteDisponible d ON da.idDeporte = d.idDeporte
  WHERE da.idSocio = @idSocio;
END;
GO


CREATE OR ALTER PROCEDURE actividades.borrarLogicamenteDeporteActivo
  @idDeporteActivo INT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    DECLARE @idSocio INT, @estadoMembresia VARCHAR(22);

    SELECT @idSocio = idSocio FROM actividades.deporteActivo WHERE idDeporteActivo = @idDeporteActivo;

    IF @idSocio IS NULL
      THROW 50020, 'No se encontró la actividad deportiva especificada.', 1;

    SELECT @estadoMembresia = estadoMorosidadMembresia
    FROM socios.estadoMembresiaSocio
    WHERE idSocio = @idSocio;

    IF @estadoMembresia IS NULL OR @estadoMembresia <> 'Activo'
      THROW 50021, 'El socio no tiene membresía activa, no se puede desactivar la actividad.', 1;

    UPDATE actividades.deporteActivo
    SET estadoActividadDeporte = 'Inactivo'
    WHERE idDeporteActivo = @idDeporteActivo;
  END TRY
  BEGIN CATCH
    THROW;
  END CATCH
END;
GO


--actividadPileta
CREATE OR ALTER PROCEDURE actividades.insertarActividadPileta
  @tarifaSocioPorDiaAdulto        DECIMAL(10,2),
  @tarifaSocioPorTemporadaAdulto  DECIMAL(10,2),
  @tarifaSocioPorMesAdulto        DECIMAL(10,2),
  @tarifaSocioPorDiaMenor         DECIMAL(10,2),
  @tarifaSocioPorTemporadaMenor   DECIMAL(10,2),
  @tarifaSocioPorMesMenor         DECIMAL(10,2),
  @tarifaInvitadoPorDiaAdulto     DECIMAL(10,2),
  @tarifaInvitadoPorTemporadaAdulto DECIMAL(10,2),
  @tarifaInvitadoPorMesAdulto     DECIMAL(10,2),
  @tarifaInvitadoPorDiaMenor      DECIMAL(10,2),
  @tarifaInvitadoPorTemporadaMenor DECIMAL(10,2),
  @tarifaInvitadoPorMesMenor      DECIMAL(10,2),
  @horaAperturaActividad         TIME,
  @horaCierreActividad           TIME,
  @vigenciaHasta                 DATE
AS
BEGIN
  SET NOCOUNT ON;

  -- Validaciones de tarifas positivas
  IF @tarifaSocioPorDiaAdulto <= 0 OR
     @tarifaSocioPorTemporadaAdulto <= 0 OR
     @tarifaSocioPorMesAdulto <= 0 OR
     @tarifaSocioPorDiaMenor <= 0 OR
     @tarifaSocioPorTemporadaMenor <= 0 OR
     @tarifaSocioPorMesMenor <= 0 OR
     @tarifaInvitadoPorDiaAdulto <= 0 OR
     @tarifaInvitadoPorTemporadaAdulto <= 0 OR
     @tarifaInvitadoPorMesAdulto <= 0 OR
     @tarifaInvitadoPorDiaMenor <= 0 OR
     @tarifaInvitadoPorTemporadaMenor <= 0 OR
     @tarifaInvitadoPorMesMenor <= 0
  BEGIN
    THROW 60001, 'Todas las tarifas deben ser mayores a cero.', 1;
  END

  -- Validar horario lógico
  IF @horaCierreActividad <= @horaAperturaActividad
  BEGIN
    THROW 60002, 'La hora de cierre debe ser posterior a la de apertura.', 1;
  END

  -- Insertar
  INSERT INTO actividades.actividadPileta (
    tarifaSocioPorDiaAdulto,
    tarifaSocioPorTemporadaAdulto,
    tarifaSocioPorMesAdulto,
    tarifaSocioPorDiaMenor,
    tarifaSocioPorTemporadaMenor,
    tarifaSocioPorMesMenor,
    tarifaInvitadoPorDiaAdulto,
    tarifaInvitadoPorTemporadaAdulto,
    tarifaInvitadoPorMesAdulto,
    tarifaInvitadoPorDiaMenor,
    tarifaInvitadoPorTemporadaMenor,
    tarifaInvitadoPorMesMenor,
    horaAperturaActividad,
    horaCierreActividad,
    vigenciaHasta
  ) VALUES (
    @tarifaSocioPorDiaAdulto,
    @tarifaSocioPorTemporadaAdulto,
    @tarifaSocioPorMesAdulto,
    @tarifaSocioPorDiaMenor,
    @tarifaSocioPorTemporadaMenor,
    @tarifaSocioPorMesMenor,
    @tarifaInvitadoPorDiaAdulto,
    @tarifaInvitadoPorTemporadaAdulto,
    @tarifaInvitadoPorMesAdulto,
    @tarifaInvitadoPorDiaMenor,
    @tarifaInvitadoPorTemporadaMenor,
    @tarifaInvitadoPorMesMenor,
    @horaAperturaActividad,
    @horaCierreActividad,
    @vigenciaHasta
  );
END;
GO

-- ===============================================
-- Procedure: Actualizar tarifa de actividad pileta
-- ===============================================
CREATE OR ALTER PROCEDURE actividades.actualizarActividadPileta
  @idActividad                    INT,
  @tarifaSocioPorDiaAdulto        DECIMAL(10,2)    = NULL,
  @tarifaSocioPorTemporadaAdulto  DECIMAL(10,2)    = NULL,
  @tarifaSocioPorMesAdulto        DECIMAL(10,2)    = NULL,
  @tarifaSocioPorDiaMenor         DECIMAL(10,2)    = NULL,
  @tarifaSocioPorTemporadaMenor   DECIMAL(10,2)    = NULL,
  @tarifaSocioPorMesMenor         DECIMAL(10,2)    = NULL,
  @tarifaInvitadoPorDiaAdulto     DECIMAL(10,2)    = NULL,
  @tarifaInvitadoPorTemporadaAdulto DECIMAL(10,2)  = NULL,
  @tarifaInvitadoPorMesAdulto     DECIMAL(10,2)    = NULL,
  @tarifaInvitadoPorDiaMenor      DECIMAL(10,2)    = NULL,
  @tarifaInvitadoPorTemporadaMenor DECIMAL(10,2)   = NULL,
  @tarifaInvitadoPorMesMenor      DECIMAL(10,2)    = NULL,
  @horaAperturaActividad         TIME             = NULL,
  @horaCierreActividad           TIME             = NULL,
  @vigenciaHasta                 DATE             = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- Verificar existencia
  IF NOT EXISTS (SELECT 1 FROM actividades.actividadPileta WHERE idActividad = @idActividad)
    THROW 60011, 'Actividad de pileta no encontrada.', 1;

  -- Validaciones de tarifas positivas si cambian
  IF @tarifaSocioPorDiaAdulto IS NOT NULL AND @tarifaSocioPorDiaAdulto <= 0 OR
     @tarifaSocioPorTemporadaAdulto IS NOT NULL AND @tarifaSocioPorTemporadaAdulto <= 0 OR
     @tarifaSocioPorMesAdulto IS NOT NULL AND @tarifaSocioPorMesAdulto <= 0 OR
     @tarifaSocioPorDiaMenor IS NOT NULL AND @tarifaSocioPorDiaMenor <= 0 OR
     @tarifaSocioPorTemporadaMenor IS NOT NULL AND @tarifaSocioPorTemporadaMenor <= 0 OR
     @tarifaSocioPorMesMenor IS NOT NULL AND @tarifaSocioPorMesMenor <= 0 OR
     @tarifaInvitadoPorDiaAdulto IS NOT NULL AND @tarifaInvitadoPorDiaAdulto <= 0 OR
     @tarifaInvitadoPorTemporadaAdulto IS NOT NULL AND @tarifaInvitadoPorTemporadaAdulto <= 0 OR
     @tarifaInvitadoPorMesAdulto IS NOT NULL AND @tarifaInvitadoPorMesAdulto <= 0 OR
     @tarifaInvitadoPorDiaMenor IS NOT NULL AND @tarifaInvitadoPorDiaMenor <= 0 OR
     @tarifaInvitadoPorTemporadaMenor IS NOT NULL AND @tarifaInvitadoPorTemporadaMenor <= 0 OR
     @tarifaInvitadoPorMesMenor IS NOT NULL AND @tarifaInvitadoPorMesMenor <= 0
  BEGIN
    THROW 60012, 'Todas las tarifas deben ser mayores a cero.', 1;
  END

  -- Validar horario lógico si cambian
  IF @horaAperturaActividad IS NOT NULL AND @horaCierreActividad IS NOT NULL
     AND @horaCierreActividad <= @horaAperturaActividad
  BEGIN
    THROW 60013, 'La hora de cierre debe ser posterior a apertura.', 1;
  END

  -- Aplicar UPDATE
  UPDATE actividades.actividadPileta
  SET
    tarifaSocioPorDiaAdulto        = COALESCE(@tarifaSocioPorDiaAdulto, tarifaSocioPorDiaAdulto),
    tarifaSocioPorTemporadaAdulto  = COALESCE(@tarifaSocioPorTemporadaAdulto, tarifaSocioPorTemporadaAdulto),
    tarifaSocioPorMesAdulto        = COALESCE(@tarifaSocioPorMesAdulto, tarifaSocioPorMesAdulto),
    tarifaSocioPorDiaMenor         = COALESCE(@tarifaSocioPorDiaMenor, tarifaSocioPorDiaMenor),
    tarifaSocioPorTemporadaMenor   = COALESCE(@tarifaSocioPorTemporadaMenor, tarifaSocioPorTemporadaMenor),
    tarifaSocioPorMesMenor         = COALESCE(@tarifaSocioPorMesMenor, tarifaSocioPorMesMenor),
    tarifaInvitadoPorDiaAdulto     = COALESCE(@tarifaInvitadoPorDiaAdulto, tarifaInvitadoPorDiaAdulto),
    tarifaInvitadoPorTemporadaAdulto = COALESCE(@tarifaInvitadoPorTemporadaAdulto, tarifaInvitadoPorTemporadaAdulto),
    tarifaInvitadoPorMesAdulto     = COALESCE(@tarifaInvitadoPorMesAdulto, tarifaInvitadoPorMesAdulto),
    tarifaInvitadoPorDiaMenor      = COALESCE(@tarifaInvitadoPorDiaMenor, tarifaInvitadoPorDiaMenor),
    tarifaInvitadoPorTemporadaMenor= COALESCE(@tarifaInvitadoPorTemporadaMenor, tarifaInvitadoPorTemporadaMenor),
    tarifaInvitadoPorMesMenor      = COALESCE(@tarifaInvitadoPorMesMenor, tarifaInvitadoPorMesMenor),
    horaAperturaActividad         = COALESCE(@horaAperturaActividad, horaAperturaActividad),
    horaCierreActividad           = COALESCE(@horaCierreActividad, horaCierreActividad),
    vigenciaHasta                 = COALESCE(@vigenciaHasta, vigenciaHasta)
  WHERE idActividad = @idActividad;
END;
GO

CREATE OR ALTER PROCEDURE actividades.eliminarActividadPileta
  @idActividad INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Verificar existencia
  IF NOT EXISTS (SELECT 1 FROM actividades.actividadPileta WHERE idActividad = @idActividad)
    THROW 60021, 'Actividad de pileta no encontrada.', 1;

  DELETE FROM actividades.actividadPileta
  WHERE idActividad = @idActividad;
END;
GO

-- :::::::::::::::::::::::::::::::::::::::::::: ACTIVIDADES ::::::::::::::::::::::::::::::::::::::::::::

-- ### presentismoActividadSocio ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarPresentismoActividadSocio
-- ------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE actividades.insertarPresentismoActividadSocio
    @idSocio INT,
    @idDeporteActivo INT,
    @fechaActividad VARCHAR(10),
    @estadoPresentismo VARCHAR(8),
    @profesorDeporte VARCHAR(35)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @estadoPresentismo NOT IN ('Activo', 'Inactivo')
        BEGIN
            ;THROW 50007, 'El estado de presentismo debe ser ''Activo'' o ''Inactivo''.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
        BEGIN
            ;THROW 50008, 'El socio con idSocio especificado no existe.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM actividades.deporteActivo WHERE idDeporteActivo = @idDeporteActivo)
        BEGIN
            ;THROW 50009, 'El deporte activo con idDeporteActivo especificado no existe.', 1;
        END

        IF EXISTS (SELECT 1 FROM actividades.presentismoActividadSocio WHERE idSocio = @idSocio AND idDeporteActivo = @idDeporteActivo)
        BEGIN
            ;THROW 50010, 'Ya existe un registro de presentismo para este socio y deporte activo.', 1;
        END

        BEGIN TRANSACTION;
        INSERT INTO actividades.presentismoActividadSocio (idSocio, idDeporteActivo, fechaActividad, estadoPresentismo, profesorDeporte)
        VALUES (@idSocio, @idDeporteActivo, @fechaActividad, @estadoPresentismo, @profesorDeporte);
        COMMIT TRANSACTION;
        PRINT 'Registro de presentismo insertado exitosamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarPresentismoActividadSocio
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE actividades.modificarPresentismoActividadSocio
    @idSocio INT,
    @idDeporteActivo INT,
    @nuevaFechaActividad VARCHAR(10),
    @nuevoEstadoPresentismo VARCHAR(8),
    @nuevoProfesorDeporte VARCHAR(35)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @nuevoEstadoPresentismo NOT IN ('Activo', 'Inactivo')
        BEGIN
            ;THROW 50011, 'El nuevo estado de presentismo debe ser ''Activo'' o ''Inactivo''.', 1;
        END

        BEGIN TRANSACTION;
        UPDATE actividades.presentismoActividadSocio
        SET
            fechaActividad = @nuevaFechaActividad,
            estadoPresentismo = @nuevoEstadoPresentismo,
            profesorDeporte = @nuevoProfesorDeporte
        WHERE
            idSocio = @idSocio AND idDeporteActivo = @idDeporteActivo;

        -- Verificar si se actualizó alguna fila
        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            ;THROW 50012, 'No se encontró el registro de presentismo con el idSocio y idDeporteActivo especificados para actualizar.', 1;
        END
        COMMIT TRANSACTION;
        PRINT 'Registro de presentismo actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarPresentismoActividadSocio
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE actividades.eliminarPresentismoActividadSocio
    @idSocio INT,
    @idDeporteActivo INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM actividades.presentismoActividadSocio
        WHERE idSocio = @idSocio AND idDeporteActivo = @idDeporteActivo;
        -- Verificar si se eliminó alguna fila
        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            ;THROW 50013, 'No se encontró el registro de presentismo con el idSocio y idDeporteActivo especificados para eliminar.', 1;
        END
        COMMIT TRANSACTION;
        PRINT 'Registro de presentismo eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;
GO

-- :::::::::::::::::::::::::::::::::::::::::::: PAGOS ::::::::::::::::::::::::::::::::::::::::::::

CREATE OR ALTER PROCEDURE pagos.insertarTarjetaDisponible
  @tipoTarjeta VARCHAR(7),
  @descripcion VARCHAR(25)
AS
BEGIN
  SET NOCOUNT ON;

  IF @tipoTarjeta NOT IN ('Credito', 'Debito', 'Prepaga', 'Virtual')
  BEGIN
    RAISERROR('El tipo de tarjeta debe ser uno de: Credito, Debito, Prepaga, Virtual.', 16, 1);
    RETURN;
  END

  INSERT INTO pagos.tarjetaDisponible (tipoTarjeta, descripcion)
  VALUES (@tipoTarjeta, @descripcion);
END
GO

CREATE OR ALTER PROCEDURE pagos.actualizarTarjetaDisponible
  @idTarjeta   INT,
  @tipoTarjeta VARCHAR(7),
  @descripcion VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  IF @tipoTarjeta NOT IN ('Credito', 'Debito', 'Prepaga', 'Virtual')
  BEGIN
    RAISERROR('El tipo de tarjeta debe ser uno de: Credito, Debito, Prepaga, Virtual.', 16, 1);
    RETURN;
  END

  IF NOT EXISTS (
    SELECT 1 FROM pagos.tarjetaDisponible
    WHERE idTarjeta = @idTarjeta AND tipoTarjeta = @tipoTarjeta
  )
  BEGIN
    RAISERROR('No se encontró una tarjeta con el ID y tipo especificados.', 16, 1);
    RETURN;
  END

  UPDATE pagos.tarjetaDisponible
  SET descripcion = @descripcion
  WHERE idTarjeta = @idTarjeta AND tipoTarjeta = @tipoTarjeta;
END
GO

CREATE OR ALTER PROCEDURE pagos.eliminarTarjetaDisponible
  @idTarjeta   INT,
  @tipoTarjeta VARCHAR(7)
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (
    SELECT 1 FROM pagos.tarjetaDisponible
    WHERE idTarjeta = @idTarjeta AND tipoTarjeta = @tipoTarjeta
  )
  BEGIN
    RAISERROR('No se encontró una tarjeta con el ID y tipo especificados.', 16, 1);
    RETURN;
  END

  DELETE FROM pagos.tarjetaDisponible
  WHERE idTarjeta = @idTarjeta AND tipoTarjeta = @tipoTarjeta;
END
GO

CREATE OR ALTER PROCEDURE pagos.insertarTarjetaEnUso
  @idSocio INT,
  @idTarjeta INT,
  @tipoTarjeta VARCHAR(7),
  @numeroTarjeta BIGINT
AS
BEGIN
  SET NOCOUNT ON;

  -- 1. Validar membresía activa
  /*IF NOT EXISTS (
    SELECT 1
    FROM socios.estadoMembresiaSocio
    WHERE idSocio = @idSocio AND estadoMorosidadMembresia = 'Activo'
  )
  BEGIN
    RAISERROR('El socio no tiene una membresía activa.', 16, 1);
    RETURN;
  END;*/

  -- 2. Validar existencia de la tarjeta disponible
  IF NOT EXISTS (
    SELECT 1
    FROM pagos.tarjetaDisponible
    WHERE idTarjeta = @idTarjeta AND tipoTarjeta = @tipoTarjeta
  )
  BEGIN
    RAISERROR('La tarjeta especificada no está registrada como disponible.', 16, 1);
    RETURN;
  END;

  -- 3. Insertar relación tarjeta-socio
  INSERT INTO pagos.tarjetaEnUso (
    idSocio, idTarjeta, tipoTarjeta, numeroTarjeta, estadoTarjeta
  )
  VALUES (
    @idSocio, @idTarjeta, @tipoTarjeta, @numeroTarjeta, 1
  );
END;
GO


CREATE OR ALTER PROCEDURE pagos.consultarTarjetasEnUsoPorSocio
  @idSocio INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT 
    t.idTarjeta,
    t.tipoTarjeta,
    t.descripcion,
    tu.numeroTarjeta,
    tu.estadoTarjeta
  FROM pagos.tarjetaEnUso tu
  JOIN pagos.tarjetaDisponible t
    ON tu.idTarjeta = t.idTarjeta AND tu.tipoTarjeta = t.tipoTarjeta
  WHERE tu.idSocio = @idSocio;
END;
GO

CREATE OR ALTER PROCEDURE pagos.borrarLogicoTarjetaEnUso
  @idSocio INT,
  @idTarjeta INT,
  @tipoTarjeta VARCHAR(7)
AS
BEGIN
  SET NOCOUNT ON;

  -- Validar membresía
  IF NOT EXISTS (
    SELECT 1
    FROM socios.estadoMembresiaSocio
    WHERE idSocio = @idSocio AND estadoMorosidadMembresia = 'Activo'
  )
  BEGIN
    RAISERROR('El socio no tiene una membresía activa.', 16, 1);
    RETURN;
  END;

  -- Actualizar estadoTarjeta a 0 (borrado lógico)
  UPDATE pagos.tarjetaEnUso
  SET estadoTarjeta = 0
  WHERE idSocio = @idSocio AND idTarjeta = @idTarjeta AND tipoTarjeta = @tipoTarjeta;

  IF @@ROWCOUNT = 0
  BEGIN
    RAISERROR('No se encontró una tarjeta en uso con esos datos.', 16, 1);
  END;
END;
GO

CREATE OR ALTER PROCEDURE pagos.insertarFacturaActiva
  @idSocio          INT,
  @categoriaSocio   INT,
  @newFacturaId     INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @hoy DATE = CAST(GETDATE() AS DATE);

  IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
     OR NOT EXISTS (
       SELECT 1 FROM socios.categoriaMembresiaSocio
       WHERE idCategoria = @categoriaSocio AND estadoCategoriaSocio = 1)
    THROW 60001,'Socio o categoría no válidos.',1;

  INSERT INTO pagos.facturaActiva
    (idSocio,categoriaSocio,estadoFactura,fechaEmision,
     fechaPrimerVencimiento,fechaSegundoVencimiento)
  VALUES
    (@idSocio,@categoriaSocio,'Pendiente',
     @hoy, DATEADD(DAY,5,@hoy), DATEADD(DAY,10,@hoy));

  SET @newFacturaId = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE pagos.actualizarEstadoFacturaActiva
  @idFactura    INT,
  @nuevoEstado  VARCHAR(15)
AS
BEGIN
  SET NOCOUNT ON;

  -- 1) Validar estado permitido
  IF @nuevoEstado NOT IN ('Pendiente','Pagada','Nulificada')
    THROW 60002, 'Estado no válido.', 1;

  -- 2) Verificar que exista la factura
  IF NOT EXISTS (
    SELECT 1 FROM pagos.facturaActiva WHERE idFactura = @idFactura
  )
    THROW 60003, 'Factura activa no encontrada.', 1;

  -- 3) Actualizar
  UPDATE pagos.facturaActiva
  SET estadoFactura = @nuevoEstado
  WHERE idFactura = @idFactura;
END;
GO

CREATE OR ALTER PROCEDURE pagos.emitirFactura
  @idFactura         INT,
  @cuilDeudor        VARCHAR(13),
  @domicilio         VARCHAR(35),
  @modalidadCobro    VARCHAR(25)  -- e.g. 'Contado' o 'Cuotas:6'
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRANSACTION;
  BEGIN TRY
    -- 1) Validar existencia y estado de la factura activa
    DECLARE @estadoActiva VARCHAR(15);
    SELECT @estadoActiva = estadoFactura
      FROM pagos.facturaActiva
     WHERE idFactura = @idFactura;

    IF @estadoActiva IS NULL
      THROW 60010, 'Factura activa no encontrada.', 1;
    IF @estadoActiva <> 'Pendiente'
      THROW 60011, 'Solo se puede emitir una factura pendiente.', 1;

    -- 2) Validar CUIL
    IF socios.validarCUIL(@cuilDeudor) = 0
      THROW 60012, 'CUIL inválido.', 1;

    -- 3) Obtener nombre y apellido del socio
    DECLARE @nombreSocio VARCHAR(50), @apellidoSocio VARCHAR(50);
    SELECT @nombreSocio = nombre, @apellidoSocio = apellido
      FROM socios.socio
     WHERE idSocio = (
       SELECT idSocio FROM pagos.facturaActiva WHERE idFactura = @idFactura
     );

    -- 4) Insertar en facturaEmitida con importes en cero
    INSERT INTO pagos.facturaEmitida (
      idFactura,
      nombreSocio,
      apellidoSocio,
      fechaEmision,
      cuilDeudor,
      domicilio,
      modalidadCobro,
      importeBruto,
      importeTotal
    )
    VALUES (
      @idFactura,
      @nombreSocio,
      @apellidoSocio,
      GETDATE(),
      @cuilDeudor,
      @domicilio,
      @modalidadCobro,
      0.00,    -- se inicializa en cero
      0.00     -- se inicializa en cero
    );

    -- 5) Marcar activa como emitida (Pagada)
    UPDATE pagos.facturaActiva
    SET estadoFactura = 'Pagada'
    WHERE idFactura = @idFactura;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
  END CATCH
END;
GO

CREATE OR ALTER PROCEDURE pagos.insertarCuerpoFactura
  @idFactura        INT,
  @tipoItem         VARCHAR(20),
  @descripcionItem  VARCHAR(25),
  @importeItem      DECIMAL(10,2)
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRANSACTION;
  BEGIN TRY
    -- 0) Aplicar descuentos según tipo de ítem
    IF UPPER(@tipoItem) = 'MEMBRESIA'
    BEGIN
      -- 15% de descuento en membresía
      SET @importeItem = ROUND(@importeItem * 0.85, 2);
    END

    -- 1) Validar existencia de factura emitida
    IF NOT EXISTS (SELECT 1 FROM pagos.facturaEmitida WHERE idFactura = @idFactura)
      THROW 61001, 'Factura no encontrada.', 1;

    -- 2) Generar nuevo idItemFactura
    DECLARE @newItem INT;
    SELECT @newItem = COALESCE(MAX(idItemFactura), 0) + 1
      FROM pagos.cuerpoFactura
     WHERE idFactura = @idFactura;

    -- 3) Insertar ítem
    INSERT INTO pagos.cuerpoFactura (
      idFactura, idItemFactura, tipoItem, descripcionItem, importeItem
    ) VALUES (
      @idFactura, @newItem, @tipoItem, @descripcionItem, @importeItem
    );

    -- 4) Si es deporte, verificar número de deportes para descuento adicional
    IF UPPER(@tipoItem) = 'DEPORTE'
    BEGIN
      DECLARE @countDeporte INT;
      SELECT @countDeporte = COUNT(*)
        FROM pagos.cuerpoFactura
       WHERE idFactura = @idFactura
         AND UPPER(tipoItem) = 'DEPORTE';
      IF @countDeporte > 1
      BEGIN
        -- Aplicar 10% de descuento a todos los deportes
        UPDATE pagos.cuerpoFactura
        SET importeItem = ROUND(importeItem * 0.90, 2)
        WHERE idFactura = @idFactura
          AND UPPER(tipoItem) = 'DEPORTE';
      END
    END

    -- 5) Ajuste de saldo o importes generales
    DECLARE @idSocio INT, @saldo DECIMAL(10,2);
    SELECT @idSocio = fa.idSocio
      FROM pagos.facturaActiva fa
     WHERE fa.idFactura = @idFactura;

    SELECT @saldo = saldoTotal
      FROM socios.saldoAFavorSocio
     WHERE idSocio = @idSocio;

    IF @saldo >= @importeItem
    BEGIN
      -- Descontar del saldo a favor
      UPDATE socios.saldoAFavorSocio
      SET saldoTotal = saldoTotal - @importeItem
      WHERE idSocio = @idSocio;
    END
    ELSE
    BEGIN
      -- Acumular al importe bruto
      UPDATE pagos.facturaEmitida
      SET importeBruto = importeBruto + @importeItem
      WHERE idFactura = @idFactura;

      UPDATE pagos.facturaEmitida
      SET importeTotal = importeBruto
      WHERE idFactura = @idFactura;
    END

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
  END CATCH
END;
GO

CREATE OR ALTER PROCEDURE pagos.actualizarCobroFactura
  @idCobro           INT,
  @idFacturaCobrada  INT,
  @nuevoDomicilio    VARCHAR(20)    = NULL,
  @nuevoTotalAbonado DECIMAL(10,2)  = NULL
AS
BEGIN
  SET NOCOUNT ON;
  IF NOT EXISTS (
    SELECT 1 FROM pagos.cobroFactura cf WHERE cf.idCobro = @idCobro AND cf.idFacturaCobrada = @idFacturaCobrada
  ) THROW 63010, 'Cobro no encontrado.', 1;

  UPDATE pagos.cobroFactura
  SET
    domicilio    = COALESCE(@nuevoDomicilio, domicilio),
    totalAbonado = COALESCE(@nuevoTotalAbonado, totalAbonado)
  WHERE idCobro = @idCobro AND idFacturaCobrada = @idFacturaCobrada;

  -- Revalidar estado facturaActiva si cambió monto
  DECLARE @importeTotal DECIMAL(10,2), @sumCobros DECIMAL(10,2);
  SELECT @importeTotal = fe.importeTotal
    FROM pagos.facturaEmitida fe
    WHERE fe.idFactura = @idFacturaCobrada;
  SELECT @sumCobros = SUM(cf.totalAbonado)
    FROM pagos.cobroFactura cf
    WHERE cf.idFacturaCobrada = @idFacturaCobrada;
  IF @sumCobros = @importeTotal
    UPDATE pagos.facturaActiva
    SET estadoFactura = 'Pagada'
    WHERE idFactura = @idFacturaCobrada;
END;
GO

CREATE OR ALTER PROCEDURE pagos.eliminarCobroFactura
  @idCobro           INT,
  @idFacturaCobrada  INT,
  @cuilDestinatario  BIGINT,
  @medioDePagoUsado  VARCHAR(50),
  @razonReembolso    VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRANSACTION;
  BEGIN TRY
    -- Verificar existencia del cobro
    DECLARE @monto DECIMAL(10,2), @idSocio INT;
    SELECT @monto = totalAbonado, @idSocio = idSocio
      FROM pagos.cobroFactura
     WHERE idCobro = @idCobro AND idFacturaCobrada = @idFacturaCobrada;
    IF @monto IS NULL
      THROW 63020, 'Cobro no encontrado.', 1;

    -- Insertar reembolso
    INSERT INTO pagos.reembolso (
      idCobroOriginal,
      idFacturaOriginal,
      idSocioDestinatario,
      montoReembolsado,
      cuilDestinatario,
      medioDePagoUsado,
      razonReembolso
    ) VALUES (
      @idCobro,
      @idFacturaCobrada,
      @idSocio,
      @monto,
      @cuilDestinatario,
      @medioDePagoUsado,
      @razonReembolso
    );

	 -- Devolver importe al saldoAFavorSocio
    UPDATE socios.saldoAFavorSocio
    SET saldoTotal = saldoTotal + @monto
    WHERE idSocio = @idSocio;


    -- Eliminar cobro
    DELETE FROM pagos.cobroFactura
    WHERE idCobro = @idCobro AND idFacturaCobrada = @idFacturaCobrada;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
  END CATCH
END;
GO

CREATE OR ALTER PROCEDURE pagos.insertarCuerpoCobro
  @idCobro       INT,
  @idFactura     INT,
  @tipoItem      VARCHAR(20),
  @descripcion   VARCHAR(25),
  @importeItem   DECIMAL(10,2)
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRANSACTION;
  BEGIN TRY
    -- Validar cobro
    IF NOT EXISTS(
      SELECT 1 FROM pagos.cobroFactura cf WHERE cf.idCobro = @idCobro AND cf.idFacturaCobrada = @idFactura
    ) THROW 63030, 'CobroFactura no encontrado.', 1;

    -- Ajuste por morosidad
    DECLARE @estadoMorosidad VARCHAR(22);
    SELECT @estadoMorosidad = ems.estadoMorosidadMembresia
    FROM socios.estadoMembresiaSocio ems
    WHERE ems.idSocio = (
      SELECT cf2.idSocio FROM pagos.cobroFactura cf2 WHERE cf2.idCobro = @idCobro
    );
    IF @estadoMorosidad = 'Moroso-1er Vencimiento'
      SET @importeItem = ROUND(@importeItem * 1.15, 2);

    -- Nuevo idItemCobro
    DECLARE @newItem INT;
    SELECT @newItem = COALESCE(MAX(cc.idItemCobro), 0) + 1
      FROM pagos.cuerpoCobro cc
     WHERE cc.idCobro = @idCobro AND cc.idFactura = @idFactura;

    INSERT INTO pagos.cuerpoCobro (
      idCobro, idFactura, idItemCobro, tipoItem, despricionItem, importeItem
    ) VALUES (
      @idCobro, @idFactura, @newItem, @tipoItem, @descripcion, @importeItem
    );

    -- Ajustar totalAbonado
    UPDATE cf
    SET totalAbonado = totalAbonado + @importeItem
    FROM pagos.cobroFactura cf
    WHERE cf.idCobro = @idCobro AND cf.idFacturaCobrada = @idFactura;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
  END CATCH
END;
GO

CREATE OR ALTER PROCEDURE pagos.actualizarCuerpoCobro
  @idCobro       INT,
  @idFactura     INT,
  @idItemCobro   INT,
  @nuevoTipo     VARCHAR(20)   = NULL,
  @nuevaDesc     VARCHAR(25)   = NULL,
  @nuevoImporte  DECIMAL(10,2) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRANSACTION;
  BEGIN TRY
    DECLARE @oldImp DECIMAL(10,2);
    SELECT @oldImp = cc.importeItem
      FROM pagos.cuerpoCobro cc
     WHERE cc.idCobro = @idCobro AND cc.idFactura = @idFactura AND cc.idItemCobro = @idItemCobro;
    IF @oldImp IS NULL THROW 63040, 'Ítem no encontrado.', 1;

    DECLARE @newImp DECIMAL(10,2) = COALESCE(@nuevoImporte, @oldImp);
    DECLARE @delta DECIMAL(10,2) = @newImp - @oldImp;

    UPDATE pagos.cuerpoCobro
    SET
      tipoItem      = COALESCE(@nuevoTipo, tipoItem),
      despricionItem= COALESCE(@nuevaDesc, despricionItem),
      importeItem   = @newImp
    WHERE idCobro = @idCobro AND idFactura = @idFactura AND idItemCobro = @idItemCobro;

    UPDATE cf
    SET totalAbonado = totalAbonado + @delta
    FROM pagos.cobroFactura cf
    WHERE cf.idCobro = @idCobro AND cf.idFacturaCobrada = @idFactura;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
  END CATCH
END;
GO

CREATE OR ALTER PROCEDURE pagos.eliminarCobroFactura
  @idCobroOriginal     INT,
  @idFacturaOriginal   INT,
  @idSocioDestinatario INT,
  @cuilDestinatario    BIGINT,
  @medioDePagoUsado    VARCHAR(50),
  @razonReembolso      VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRANSACTION;
  BEGIN TRY
    -- Obtener datos del cobro
    DECLARE @montoTotal DECIMAL(10,2), @socioOriginal INT;
    SELECT
      @montoTotal = cf.totalAbonado,
      @socioOriginal = cf.idSocio
    FROM pagos.cobroFactura cf
    WHERE cf.idCobro = @idCobroOriginal
      AND cf.idFacturaCobrada = @idFacturaOriginal;
    IF @montoTotal IS NULL
      THROW 65001, 'Cobro no encontrado.', 1;

    -- Verificar destinatario
    IF @socioOriginal <> @idSocioDestinatario
      THROW 65002, 'El socio destinatario no coincide con el socio del cobro.', 1;

    -- Calcular monto de reembolso: 60% si lluvia
    DECLARE @montoReembolso DECIMAL(10,2);
    IF UPPER(@razonReembolso) = 'DÍA DE LLUVIA'
      SET @montoReembolso = ROUND(@montoTotal * 0.60, 2);
    ELSE
      SET @montoReembolso = @montoTotal;

    -- Insertar en reembolso
    INSERT INTO pagos.reembolso (
      idCobroOriginal,
      idFacturaOriginal,
      idSocioDestinatario,
      montoReembolsado,
      cuilDestinatario,
      medioDePagoUsado,
      razonReembolso
    ) VALUES (
      @idCobroOriginal,
      @idFacturaOriginal,
      @idSocioDestinatario,
      @montoReembolso,
      @cuilDestinatario,
      @medioDePagoUsado,
      @razonReembolso
    );

    -- Eliminar el cobro original
    DELETE FROM pagos.cobroFactura
    WHERE idCobro = @idCobroOriginal
      AND idFacturaCobrada = @idFacturaOriginal;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
  END CATCH
END;
GO

-- :::::::::::::::::::::::::::::::::::::::::::: DESCUENTOS ::::::::::::::::::::::::::::::::::::::::::::

-- ### descuentoDisponible ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarDescuentoDisponible
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE descuentos.insertarDescuentoDisponible
    @tipo VARCHAR(100),
    @porcentajeDescontado DECIMAL(5, 2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @tipo IS NULL OR LTRIM(RTRIM(@tipo)) = ''
        BEGIN
            RAISERROR('El campo "tipo" no puede ser nulo o vacío. Por favor, proporcione un valor.', 16, 1);
            RETURN;
        END

        IF @porcentajeDescontado <= 0
        BEGIN
            RAISERROR('El porcentaje de descuento debe ser mayor que cero.', 16, 1);
            RETURN;
        END

        -- Inserción del nuevo descuento en la tabla.
        INSERT INTO descuentos.descuentoDisponible (tipo, porcentajeDescontado)
        VALUES (@tipo, @porcentajeDescontado);
        PRINT 'Descuento disponible insertado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar descuento disponible: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarDescuentoDisponible
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE descuentos.modificarDescuentoDisponible
    @idDescuento INT,
    @tipo VARCHAR(100),
    @porcentajeDescontado DECIMAL(5, 2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idDescuento IS NULL OR @idDescuento <= 0
        BEGIN
            RAISERROR('El ID de descuento debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM descuentos.descuentoDisponible WHERE idDescuento = @idDescuento)
        BEGIN
            RAISERROR('El descuento con el ID especificado no existe. No se puede actualizar.', 16, 1);
            RETURN;
        END

        IF @tipo IS NULL OR LTRIM(RTRIM(@tipo)) = ''
        BEGIN
            RAISERROR('El campo "tipo" no puede ser nulo o vacío. Por favor, proporcione un valor.', 16, 1);
            RETURN;
        END

        IF @porcentajeDescontado <= 0
        BEGIN
            RAISERROR('El porcentaje de descuento debe ser mayor que cero.', 16, 1);
            RETURN;
        END

        -- Actualización de los campos del descuento.
        UPDATE descuentos.descuentoDisponible
        SET
            tipo = @tipo,
            porcentajeDescontado = @porcentajeDescontado
        WHERE idDescuento = @idDescuento;
        PRINT 'Descuento disponible actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar descuento disponible: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarDescuentoDisponible
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE descuentos.eliminarDescuentoDisponible
    @idDescuento INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idDescuento IS NULL OR @idDescuento <= 0
        BEGIN
            RAISERROR('El ID de descuento debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM descuentos.descuentoDisponible WHERE idDescuento = @idDescuento)
        BEGIN
            RAISERROR('El descuento con el ID especificado no existe. No se puede eliminar.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM descuentos.descuentoVigente WHERE idDescuento = @idDescuento)
        BEGIN
            RAISERROR('Existen registros en descuentos.descuentoVigente que dependen de este descuento. Elimine primero los registros dependientes.', 16, 1);
            RETURN;
        END

        -- Eliminación física del registro de descuento disponible.
        DELETE FROM descuentos.descuentoDisponible
        WHERE idDescuento = @idDescuento;
        PRINT 'Descuento disponible eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar descuento disponible: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ### descuentoVigente ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarDescuentoVigente
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE descuentos.insertarDescuentoVigente
    @idDescuento INT,
    @idSocio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idDescuento IS NULL OR @idDescuento <= 0
        BEGIN
            RAISERROR('El ID de descuento debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @idSocio IS NULL OR @idSocio <= 0
        BEGIN
            RAISERROR('El ID de socio debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM descuentos.descuentoDisponible WHERE idDescuento = @idDescuento)
        BEGIN
            RAISERROR('El ID de descuento especificado no existe en la tabla descuentos.descuentoDisponible.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
        BEGIN
            RAISERROR('El ID de socio especificado no existe en la tabla socios.socio.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM descuentos.descuentoVigente WHERE idDescuento = @idDescuento AND idSocio = @idSocio)
        BEGIN
            RAISERROR('Este descuento ya está vigente para el socio especificado.', 16, 1);
            RETURN;
        END

        -- Inserción del nuevo registro de descuento vigente.
        INSERT INTO descuentos.descuentoVigente (idDescuento, idSocio)
        VALUES (@idDescuento, @idSocio);
        PRINT 'Descuento vigente insertado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar descuento vigente: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarDescuentoVigente
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE descuentos.modificarDescuentoVigente
    @old_idDescuento INT,
    @old_idSocio INT,
    @new_idDescuento INT,
    @new_idSocio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF @old_idDescuento IS NULL OR @old_idDescuento <= 0
        BEGIN
            RAISERROR('El ID de descuento antiguo debe ser un valor positivo y no nulo.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @old_idSocio IS NULL OR @old_idSocio <= 0
        BEGIN
            RAISERROR('El ID de socio antiguo debe ser un valor positivo y no nulo.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @new_idDescuento IS NULL OR @new_idDescuento <= 0
        BEGIN
            RAISERROR('El nuevo ID de descuento debe ser un valor positivo y no nulo.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @new_idSocio IS NULL OR @new_idSocio <= 0
        BEGIN
            RAISERROR('El nuevo ID de socio debe ser un valor positivo y no nulo.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM descuentos.descuentoVigente WHERE idDescuento = @old_idDescuento AND idSocio = @old_idSocio)
        BEGIN
            RAISERROR('El descuento vigente original con los IDs especificados no existe. No se puede actualizar.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM descuentos.descuentoDisponible WHERE idDescuento = @new_idDescuento)
        BEGIN
            RAISERROR('El nuevo ID de descuento especificado no existe en la tabla descuentos.descuentoDisponible.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @new_idSocio)
        BEGIN
            RAISERROR('El nuevo ID de socio especificado no existe en la tabla socios.socio.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF (@old_idDescuento != @new_idDescuento OR @old_idSocio != @new_idSocio)
        BEGIN
            IF EXISTS (SELECT 1 FROM descuentos.descuentoVigente WHERE idDescuento = @new_idDescuento AND idSocio = @new_idSocio)
            BEGIN
                RAISERROR('La nueva combinación de descuento y socio ya existe como descuento vigente.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        -- Eliminar el registro antiguo.
        DELETE FROM descuentos.descuentoVigente
        WHERE idDescuento = @old_idDescuento AND idSocio = @old_idSocio;
        -- Insertar el nuevo registro.
        INSERT INTO descuentos.descuentoVigente (idDescuento, idSocio)
        VALUES (@new_idDescuento, @new_idSocio);
        COMMIT TRANSACTION; 
        PRINT 'Descuento vigente actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        PRINT 'Error al actualizar descuento vigente: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarDescuentoVigente
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE descuentos.eliminarDescuentoVigente
    @idDescuento INT,
    @idSocio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idDescuento IS NULL OR @idDescuento <= 0
        BEGIN
            RAISERROR('El ID de descuento debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @idSocio IS NULL OR @idSocio <= 0
        BEGIN
            RAISERROR('El ID de socio debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM descuentos.descuentoVigente WHERE idDescuento = @idDescuento AND idSocio = @idSocio)
        BEGIN
            RAISERROR('El descuento vigente especificado para el socio no existe. No se puede eliminar.', 16, 1);
            RETURN;
        END

        -- Eliminación física del registro de descuento vigente.
        DELETE FROM descuentos.descuentoVigente
        WHERE idDescuento = @idDescuento AND idSocio = @idSocio;
        PRINT 'Descuento vigente eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar descuento vigente: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- :::::::::::::::::::::::::::::::::::::::::::: ITINERARIOS ::::::::::::::::::::::::::::::::::::::::::::

-- ### itinerario ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarItinerario
-- ------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE itinerarios.insertarItinerario
    @dia VARCHAR(9),
    @idDeporte INT,
    @horaInicio TIME,
    @horaFin TIME
AS
BEGIN
    IF NOT (LEN(@dia) >= 5 AND LEN(@dia) <= 9)
    BEGIN
        RAISERROR('Error: El día de la semana debe tener entre 5 y 9 letras', 16, 1);
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

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarItinerario
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE itinerarios.modificarItinerario
    @idItinerario INT,
    @dia VARCHAR(9) = NULL,
    @idDeporte INT = NULL,
    @horaInicio TIME = NULL,
    @horaFin TIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @dia IS NOT NULL AND NOT (LEN(@dia) >= 5 AND LEN(@dia) <= 9)
    BEGIN
        RAISERROR('Error: El día de la semana debe tener entre 5 y 9 letras', 16, 1);
        RETURN;
    END

    IF @idDeporte IS NOT NULL AND NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte)
    BEGIN
        RAISERROR('Error: Ese deporte no existe', 16, 1);
        RETURN;
    END

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

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No existe un itinerario con idItinerario = %d.', 16, 1, @idItinerario);
    END
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarItinerario
-- ------------------------------------------------------------------------------
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

-- ### datosSUM ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarDatosSUM
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE itinerarios.insertarDatosSUM
    @tarifaHorariaSocio     DECIMAL(10, 2),
    @tarifaHorariaInvitado  DECIMAL(10, 2),
    @horaMinimaReserva      TIME,
    @horaMaximaReserva      TIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar tarifas
        IF @tarifaHorariaSocio <= 0
            THROW 52001, 'La tarifa horaria para socios debe ser mayor que cero.', 1;

        IF @tarifaHorariaInvitado <= 0
            THROW 52002, 'La tarifa horaria para invitados debe ser mayor que cero.', 1;

        -- Validar rangos de tiempo
        IF @horaMinimaReserva IS NULL
            THROW 52003, 'La hora mínima de reserva no puede ser nula.', 1;
        IF @horaMaximaReserva IS NULL
            THROW 52004, 'La hora máxima de reserva no puede ser nula.', 1;

        IF @horaMinimaReserva >= @horaMaximaReserva
            THROW 52005, 'La hora mínima debe ser anterior a la hora máxima.', 1;

        -- Inserción del nuevo registro de datos SUM
        INSERT INTO itinerarios.datosSUM (
            tarifaHorariaSocio,
            tarifaHorariaInvitado,
			horaMinReserva,
            horaMaxReserva
        ) VALUES (
            @tarifaHorariaSocio,
            @tarifaHorariaInvitado,
            @horaMinimaReserva,
            @horaMaximaReserva
        );

        PRINT 'Datos SUM insertados exitosamente.';
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @sev INT = ERROR_SEVERITY();
        DECLARE @state INT = ERROR_STATE();
        THROW @sev, @msg, @state;
    END CATCH
END;
GO



-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarDatosSUM
-- ------------------------------------------------------------------------------
CREATE PROCEDURE itinerarios.modificarDatosSUM
    @idSitio INT,
    @tarifaHorariaSocio DECIMAL(10, 2),
    @tarifaHorariaInvitado DECIMAL(10, 2),
    @horaMinimaReserva int,
    @horaMaximaReserva int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idSitio IS NULL OR @idSitio <= 0
        BEGIN
            RAISERROR('El ID de sitio debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM itinerarios.datosSUM WHERE idSitio = @idSitio)
        BEGIN
            RAISERROR('El sitio con el ID especificado no existe. No se puede actualizar.', 16, 1);
            RETURN;
        END

        IF @tarifaHorariaSocio <= 0
        BEGIN
            RAISERROR('La tarifa horaria para socios debe ser mayor que cero.', 16, 1);
            RETURN;
        END

        IF @tarifaHorariaInvitado <= 0
        BEGIN
            RAISERROR('La tarifa horaria para invitados debe ser mayor que cero.', 16, 1);
            RETURN;
        END

        IF @horaMinimaReserva < 0 OR @horaMinimaReserva > 23
        BEGIN
            RAISERROR('La hora mínima de reserva debe estar entre 0 y 23.', 16, 1);
            RETURN;
        END

        IF @horaMaximaReserva < 0 OR @horaMaximaReserva > 23
        BEGIN
            RAISERROR('La hora máxima de reserva debe estar entre 0 y 23.', 16, 1);
            RETURN;
        END

        IF @horaMinimaReserva >= @horaMaximaReserva
        BEGIN
            RAISERROR('La hora mínima de reserva debe ser menor que la hora máxima de reserva.', 16, 1);
            RETURN;
        END

        -- Actualización del registro de datos SUM.
        UPDATE itinerarios.datosSUM
        SET
            tarifaHorariaSocio = @tarifaHorariaSocio,
            tarifaHorariaInvitado = @tarifaHorariaInvitado,
            horaMinimaReserva = @horaMinimaReserva,
            horaMaximaReserva = @horaMaximaReserva
        WHERE idSitio = @idSitio;

        PRINT 'Datos SUM actualizados exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar datos SUM: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarDatosSUM
-- ------------------------------------------------------------------------------
CREATE PROCEDURE itinerarios.eliminarDatosSUM
    @idSitio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idSitio IS NULL OR @idSitio <= 0
        BEGIN
            RAISERROR('El ID de sitio debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM itinerarios.datosSUM WHERE idSitio = @idSitio)
        BEGIN
            RAISERROR('El sitio con el ID especificado no existe. No se puede eliminar.', 16, 1);
            RETURN;
        END

        -- Eliminación física del registro de datos SUM.
        DELETE FROM itinerarios.datosSUM
        WHERE idSitio = @idSitio;
        PRINT 'Datos SUM eliminados exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar datos SUM: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- :::::::::::::::::::::::::::::::::::::::::::: COBERTURAS ::::::::::::::::::::::::::::::::::::::::::::

-- ### coberturaDisponible ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarCoberturaDisponible
-- ------------------------------------------------------------------------------
CREATE PROCEDURE coberturas.insertarCoberturaDisponible
    @tipo VARCHAR(100),
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @tipo IS NULL OR LTRIM(RTRIM(@tipo)) = ''
        BEGIN
            RAISERROR('El campo "tipo" no puede ser nulo o vacío. Por favor, proporcione un valor.', 16, 1);
            RETURN;
        END

        IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        BEGIN
            RAISERROR('El campo "descripcion" no puede ser nulo o vacío. Por favor, proporcione una descripción.', 16, 1);
            RETURN;
        END

        -- 'activo' se inserta como 1 por defecto, indicando que la cobertura está activa.
        INSERT INTO coberturas.coberturaDisponible (tipo, descripcion, activo)
        VALUES (@tipo, @descripcion, 1);
        PRINT 'Cobertura disponible insertada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar cobertura disponible: ' + ERROR_MESSAGE();
        THROW; -- Re-lanza el error para que la app pueda manejarlo.
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarCoberturaDisponible
-- ------------------------------------------------------------------------------
CREATE PROCEDURE coberturas.modificarCoberturaDisponible
    @idCobertura INT,
    @tipo VARCHAR(100),
    @descripcion VARCHAR(50),
    @activo BIT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idCobertura IS NULL OR @idCobertura <= 0
        BEGIN
            RAISERROR('El ID de cobertura debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @tipo IS NULL OR LTRIM(RTRIM(@tipo)) = ''
        BEGIN
            RAISERROR('El campo "tipo" no puede ser nulo o vacío. Por favor, proporcione un valor.', 16, 1);
            RETURN;
        END

        IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        BEGIN
            RAISERROR('El campo "descripcion" no puede ser nulo o vacío. Por favor, proporcione una descripción.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM coberturas.coberturaDisponible WHERE idCoberturaDisponible = @idCobertura)
        BEGIN
            RAISERROR('La cobertura con el ID especificado no existe. No se puede actualizar.', 16, 1);
            RETURN;
        END

        -- Actualización de los campos de la cobertura.
        UPDATE coberturas.coberturaDisponible
        SET
            tipo = @tipo,
            descripcion = @descripcion,
            activo = @activo
        WHERE idCoberturaDisponible = @idCobertura;

        PRINT 'Cobertura disponible actualizada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar cobertura disponible: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarCoberturaDisponible
-- ------------------------------------------------------------------------------
CREATE PROCEDURE coberturas.eliminarCoberturaDisponible
    @idCobertura INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idCobertura IS NULL OR @idCobertura <= 0
        BEGIN
            RAISERROR('El ID de cobertura debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM coberturas.coberturaDisponible WHERE idCoberturaDisponible = @idCobertura)
        BEGIN
            RAISERROR('La cobertura con el ID especificado no existe. No se puede eliminar lógicamente.', 16, 1);
            RETURN;
        END

        IF (SELECT activo FROM coberturas.coberturaDisponible WHERE idCoberturaDisponible = @idCobertura) = 0
        BEGIN
            RAISERROR('La cobertura ya se encuentra inactiva. No es necesario realizar el borrado lógico nuevamente.', 16, 1);
            RETURN;
        END

        -- Actualización del estado 'activo' a 0 para realizar el borrado lógico.
        UPDATE coberturas.coberturaDisponible
        SET activo = 0
        WHERE idCoberturaDisponible = @idCobertura;

        PRINT 'Cobertura disponible eliminada lógicamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar lógicamente cobertura disponible: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ### prepagaEnUso ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarPrepagaEnUso
-- ------------------------------------------------------------------------------
CREATE PROCEDURE coberturas.insertarPrepagaEnUso
    @idCobertura INT,
    @idNumeroSocio INT,
    @categoriaSocio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idCobertura IS NULL OR @idCobertura <= 0
        BEGIN
            RAISERROR('El ID de cobertura debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @idNumeroSocio IS NULL OR @idNumeroSocio <= 0
        BEGIN
            RAISERROR('El ID de socio debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @categoriaSocio IS NULL OR @categoriaSocio <= 0
        BEGIN
            RAISERROR('La categoría del socio debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM coberturas.coberturaDisponible WHERE idCoberturaDisponible = @idCobertura)
        BEGIN
            RAISERROR('El ID de cobertura especificado no existe en la tabla coberturas.coberturaDisponible.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idNumeroSocio)
        BEGIN
            RAISERROR('El ID de socio especificado no existe en la tabla socios.socio.', 16, 1);
            RETURN;
        END

        -- Inserción del nuevo registro de prepaga en uso.
        INSERT INTO coberturas.prepagaEnUso (idCobertura, idNumeroSocio, categoriaSocio)
        VALUES (@idCobertura, @idNumeroSocio, @categoriaSocio);

        PRINT 'Registro de prepaga en uso insertado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar registro de prepaga en uso: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarPrepagaEnUso
-- ------------------------------------------------------------------------------
CREATE PROCEDURE coberturas.ActualizarPrepagaEnUso
    @idPrepaga INT,
    @idCobertura INT,
    @idNumeroSocio INT,
    @categoriaSocio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idPrepaga IS NULL OR @idPrepaga <= 0
        BEGIN
            RAISERROR('El ID de prepaga en uso debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @idCobertura IS NULL OR @idCobertura <= 0
        BEGIN
            RAISERROR('El ID de cobertura debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @idNumeroSocio IS NULL OR @idNumeroSocio <= 0
        BEGIN
            RAISERROR('El ID de socio debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @categoriaSocio IS NULL OR @categoriaSocio <= 0
        BEGIN
            RAISERROR('La categoría del socio debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM coberturas.prepagaEnUso WHERE idPrepaga = @idPrepaga)
        BEGIN
            RAISERROR('El registro de prepaga en uso con el ID especificado no existe. No se puede actualizar.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM coberturas.coberturaDisponible WHERE idCoberturaDisponible = @idCobertura)
        BEGIN
            RAISERROR('El ID de cobertura especificado no existe en la tabla coberturas.coberturaDisponible.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idNumeroSocio)
        BEGIN
            RAISERROR('El ID de socio especificado no existe en la tabla socios.socio.', 16, 1);
            RETURN;
        END

        -- Actualización del registro de prepaga en uso.
        UPDATE coberturas.prepagaEnUso
        SET
            idCobertura = @idCobertura,
            idNumeroSocio = @idNumeroSocio,
            categoriaSocio = @categoriaSocio
        WHERE idPrepaga = @idPrepaga;

        PRINT 'Registro de prepaga en uso actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar registro de prepaga en uso: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarPrepagaEnUso
-- ------------------------------------------------------------------------------
CREATE PROCEDURE coberturas.eliminarPrepagaEnUso
    @idPrepaga INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idPrepaga IS NULL OR @idPrepaga <= 0
        BEGIN
            RAISERROR('El ID de prepaga en uso debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM coberturas.prepagaEnUso WHERE idPrepaga = @idPrepaga)
        BEGIN
            RAISERROR('El registro de prepaga en uso con el ID especificado no existe. No se puede eliminar.', 16, 1);
            RETURN;
        END

        -- Eliminación física del registro de prepaga en uso.
        DELETE FROM coberturas.prepagaEnUso
        WHERE idPrepaga = @idPrepaga;

        PRINT 'Registro de prepaga en uso eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar registro de prepaga en uso: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- :::::::::::::::::::::::::::::::::::::::::::: RESERVAS ::::::::::::::::::::::::::::::::::::::::::::

-- ### reservasSum ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarReservaSum
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.insertarReservaSum
    @idSocio INT,
    @dniReservante BIGINT,
    @horaInicioReserva INT,
    @horaFinReserva INT,
    @tarifaFinal DECIMAL(10, 2),
	@idSalon INT,
    @newIdReserva INT OUTPUT -- Para devolver el ID generado por IDENTITY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idSocio < 0
        BEGIN
            THROW 50001, 'El ID de socio no puede ser negativo.', 1;
        END

        IF @dniReservante <= 0
        BEGIN
            THROW 50002, 'El DNI del reservante debe ser un número positivo.', 1;
        END

        IF @horaInicioReserva < 0 OR @horaFinReserva < 0 OR @horaFinReserva <= @horaInicioReserva
        BEGIN
            THROW 50003, 'Las horas de inicio y fin de reserva deben ser válidas y la hora de fin debe ser posterior a la de inicio.', 1;
        END

        IF @tarifaFinal <= 0
        BEGIN
            THROW 50004, 'La tarifa final debe ser un valor positivo.', 1;
        END

		IF @idSalon < 0
		BEGIN
			THROW 50005, 'el número del Salón SUM reservado debe ser positivo', 1;
		END;

        -- Validar existencia de idSocio en socios.socio
        IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
        BEGIN
            -- Si @idSocio = 0 está permitido para "invitados" y no referencia socio.socio,
            THROW 50006, 'El ID de socio especificado no existe en la tabla de socios.', 1;
        END

		-- Validar existencia del idSitio en datosSUM
		IF NOT EXISTS (SELECT 1 FROM itinerarios.datosSUM WHERE idSitio = @idSalon)
		BEGIN
			THROW 50007, 'EL ID del Salón especificado no existe en la tabla de SUMs', 1;
		END

        -- Iniciar transacción
        BEGIN TRANSACTION;

        INSERT INTO reservas.reservasSUM (idSocio, idSalon, dniReservante, horaInicioReserva, horaFinReserva,tarifaFinal)
        VALUES (@idSocio, @idSalon, @dniReservante, @horaInicioReserva, @horaFinReserva, @tarifaFinal);
        SET @newIdReserva = SCOPE_IDENTITY(); -- Obtener el ID generado
        COMMIT TRANSACTION;
        PRINT 'Reserva SUM insertada con éxito. ID de Reserva: ' + CAST(@newIdReserva AS VARCHAR(10));

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarReservaSum
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.modificarReservaSum
    @idReserva INT,
    @idSocioOriginal INT,
	@idSalon INT,
    @dniReservanteOriginal BIGINT,
    @newIdSocio INT = NULL, -- Nuevos valores para posible actualización
    @newDniReservante BIGINT = NULL,
    @newHoraInicioReserva INT = NULL,
    @newHoraFinReserva INT = NULL,
    @newTarifaFinal DECIMAL(10, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la reserva SUM a modificar existe
        IF NOT EXISTS (SELECT 1 FROM reservas.reservasSUM WHERE idReserva = @idReserva AND idSocio = @idSocioOriginal AND dniReservante = @dniReservanteOriginal)
        BEGIN
            THROW 50006, 'La reserva SUM especificada no existe.', 1;
        END

        -- Validaciones para los nuevos valores (si existieran)
        IF @newIdSocio IS NOT NULL AND @newIdSocio < 0
        BEGIN
            THROW 50007, 'El nuevo ID de socio no puede ser negativo.', 1;
        END
        IF @newIdSocio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @newIdSocio) AND @newIdSocio != 0 -- Ajuste si 0 es un ID de invitado especial
        BEGIN
            THROW 50008, 'El nuevo ID de socio especificado no existe en la tabla de socios.', 1;
        END

        IF @newDniReservante IS NOT NULL AND @newDniReservante <= 0
        BEGIN
            THROW 50009, 'El nuevo DNI del reservante debe ser un número positivo.', 1;
        END

        IF (@newHoraInicioReserva IS NOT NULL AND @newHoraFinReserva IS NOT NULL AND @newHoraFinReserva <= @newHoraInicioReserva)
           OR (@newHoraInicioReserva IS NOT NULL AND @newHoraFinReserva IS NULL AND @newHoraInicioReserva < 0)
           OR (@newHoraFinReserva IS NOT NULL AND @newHoraInicioReserva IS NULL AND @newHoraFinReserva < 0)
        BEGIN
            THROW 50010, 'Las nuevas horas de inicio y fin de reserva deben ser válidas y la hora de fin debe ser posterior a la de inicio.', 1;
        END

        IF @newTarifaFinal IS NOT NULL AND @newTarifaFinal <= 0
        BEGIN
            THROW 50011, 'La nueva tarifa final debe ser un valor positivo.', 1;
        END

        -- Iniciar transacción
        BEGIN TRANSACTION;

        UPDATE reservas.reservasSUM
        SET
            idSocio = ISNULL(@newIdSocio, idSocio),
            dniReservante = ISNULL(@newDniReservante, dniReservante),
            horaInicioReserva = ISNULL(@newHoraInicioReserva, horaInicioReserva),
            horaFinReserva = ISNULL(@newHoraFinReserva, horaFinReserva),
            tarifaFinal = ISNULL(@newTarifaFinal, tarifaFinal)
        WHERE
            idReserva = @idReserva
            AND idSocio = @idSocioOriginal
            AND dniReservante = @dniReservanteOriginal;

        COMMIT TRANSACTION;
        PRINT 'Reserva SUM modificada con éxito.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarReservaSum
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.eliminarReservaSum
    @idReserva INT,
    @idSocio INT,
    @dniReservante BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la reserva SUM a borrar existe
        IF NOT EXISTS (SELECT 1 FROM reservas.reservasSUM WHERE idReserva = @idReserva AND idSocio = @idSocio AND dniReservante = @dniReservante)
        BEGIN
            THROW 50012, 'La reserva SUM especificada no existe.', 1;
        END

        -- Iniciar transacción
        BEGIN TRANSACTION;
        DELETE FROM reservas.reservasSUM
        WHERE idReserva = @idReserva
              AND idSocio = @idSocio
              AND dniReservante = @dniReservante;
        COMMIT TRANSACTION;
        PRINT 'Reserva SUM eliminada físicamente con éxito.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ### reservaPaseActividad ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarReservaPaseActividad
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.insertarReservaPaseActividad
  @idSocio            INT,
  @categoriaSocio     INT,
  @idActividad        INT,
  @categoriaPase      VARCHAR(9)  -- 'Dia', 'Mensual', 'Temporada'
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRANSACTION;
  BEGIN TRY
    -- Validar socio (0 = invitado)
    IF @idSocio <> 0 AND NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
      THROW 70001, 'Socio no encontrado.', 1;

    -- Validar categoriaPase
    IF UPPER(@categoriaPase) NOT IN ('DIA','MENSUAL','TEMPORADA')
      THROW 70002, 'Categoría de pase inválida.', 1;

    -- Validar actividad
    IF NOT EXISTS (SELECT 1 FROM actividades.actividadPileta WHERE idActividad = @idActividad)
      THROW 70003, 'Actividad de pileta no encontrada.', 1;

    -- Calcular monto según pase y tipo de usuario
    DECLARE @monto DECIMAL(10,2);
    IF @idSocio = 0
    BEGIN
      -- Invitado
      SELECT @monto =
        CASE UPPER(@categoriaPase)
          WHEN 'DIA'      THEN tarifaInvitadoPorDiaAdulto
          WHEN 'MENSUAL'  THEN tarifaInvitadoPorMesAdulto
          WHEN 'TEMPORADA' THEN tarifaInvitadoPorTemporadaAdulto
        END
      FROM actividades.actividadPileta
      WHERE idActividad = @idActividad;
    END
    ELSE
    BEGIN
      -- Socio
      SELECT @monto =
        CASE UPPER(@categoriaPase)
          WHEN 'DIA'      THEN tarifaSocioPorDiaAdulto
          WHEN 'MENSUAL'  THEN tarifaSocioPorMesAdulto
          WHEN 'TEMPORADA' THEN tarifaSocioPorTemporadaAdulto
        END
      FROM actividades.actividadPileta
      WHERE idActividad = @idActividad;
    END

    -- Insertar reserva
    INSERT INTO reservas.reservaPaseActividad (
      idSocio, categoriaSocio, categoriaPase, montoTotalActividad
    ) VALUES (
      @idSocio, @categoriaSocio, @categoriaPase, @monto
    );

    COMMIT TRANSACTION;
    PRINT 'Reserva de pase insertada. Monto: ' + CAST(@monto AS VARCHAR(10));
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
  END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarReservaPaseActividad
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.actualizarReservaPaseActividad
  @idReservaActividad  INT,
  @categoriaPase       VARCHAR(9),
  @idActividad         INT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRANSACTION;
  BEGIN TRY
    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM reservas.reservaPaseActividad WHERE idReservaActividad = @idReservaActividad)
      THROW 70011, 'Reserva no encontrada.', 1;

    -- Validar categoriaPase
    IF UPPER(@categoriaPase) NOT IN ('DIA','MENSUAL','TEMPORADA')
      THROW 70012, 'Categoría de pase inválida.', 1;

    -- Validar actividad
    IF NOT EXISTS (SELECT 1 FROM actividades.actividadPileta WHERE idActividad = @idActividad)
      THROW 70013, 'Actividad de pileta no encontrada.', 1;

    -- Obtener idSocio y categoriaSocio
    DECLARE @idSocio INT, @categoriaSoc INT;
    SELECT @idSocio = idSocio, @categoriaSoc = categoriaSocio
      FROM reservas.reservaPaseActividad
     WHERE idReservaActividad = @idReservaActividad;

    -- Recalcular monto
    DECLARE @nuevoMonto DECIMAL(10,2);
    IF @idSocio = 0
    BEGIN
      SELECT @nuevoMonto =
        CASE UPPER(@categoriaPase)
          WHEN 'DIA'      THEN tarifaInvitadoPorDiaAdulto
          WHEN 'MENSUAL'  THEN tarifaInvitadoPorMesAdulto
          WHEN 'TEMPORADA' THEN tarifaInvitadoPorTemporadaAdulto
        END
      FROM actividades.actividadPileta
      WHERE idActividad = @idActividad;
    END
    ELSE
    BEGIN
      SELECT @nuevoMonto =
        CASE UPPER(@categoriaPase)
          WHEN 'DIA'      THEN tarifaSocioPorDiaAdulto
          WHEN 'MENSUAL'  THEN tarifaSocioPorMesAdulto
          WHEN 'TEMPORADA' THEN tarifaSocioPorTemporadaAdulto
        END
      FROM actividades.actividadPileta
      WHERE idActividad = @idActividad;
    END

    -- Aplicar actualización
    UPDATE reservas.reservaPaseActividad
    SET
      categoriaPase = @categoriaPase,
      montoTotalActividad = @nuevoMonto
    WHERE idReservaActividad = @idReservaActividad;

    COMMIT TRANSACTION;
    PRINT 'Reserva actualizada. Nuevo monto: ' + CAST(@nuevoMonto AS VARCHAR(10));
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
  END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarReservaPaseActividad
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.eliminarReservaPaseActividad
  @idReservaActividad INT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM reservas.reservaPaseActividad WHERE idReservaActividad = @idReservaActividad)
      THROW 70021, 'Reserva no encontrada.', 1;

    DELETE FROM reservas.reservaPaseActividad
    WHERE idReservaActividad = @idReservaActividad;

    PRINT 'Reserva eliminada exitosamente.';
  END TRY
  BEGIN CATCH
    DECLARE @msg NVARCHAR(4000)=ERROR_MESSAGE(), @sev INT=ERROR_SEVERITY(), @st INT=ERROR_STATE();
    THROW @sev, @msg, @st;
  END CATCH
END;
GO