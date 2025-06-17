----------------------------------------------------------------------------------------------------
-- Fecha de entrega: 15-06-2025
-- Numero de grupo: 3
-- Materia: Bases de Datos Aplicada
-- Alumnos:
--   - Codina, Santiago Ivan - 44.391.352
--   - Santillan, Lautaro Ezequiel - 45.175.053
----------------------------------------------------------------------------------------------------

-- Crear la base de datos
CREATE DATABASE Com2900G03;
GO
-- Usar la base de datos
USE Com2900G03;
GO

-- Creación de esquemas para las diferentes gestiones (si no existen)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'socios')
    EXEC('CREATE SCHEMA socios;');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'actividades')
    EXEC('CREATE SCHEMA actividades;');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'pagos')
    EXEC('CREATE SCHEMA pagos;');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'descuentos')
    EXEC('CREATE SCHEMA descuentos;');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'itinerarios')
    EXEC('CREATE SCHEMA itinerarios;');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'coberturas')
    EXEC('CREATE SCHEMA coberturas;');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'reservas')
    EXEC('CREATE SCHEMA reservas;');
GO

-- Creacion de tablas

-- 1. Creación de tablas sin dependencias de clave foránea directas, o con claves primarias referenciables.

-- 1.1 socios.categoriaSocio
CREATE TABLE socios.categoriaSocio (
    idCategoria INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(15) NOT NULL,
    costoMembresia DECIMAL(10, 2) NOT NULL CHECK (costoMembresia > 0),
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

-- 1.3 socios.grupoFamiliar
CREATE TABLE socios.grupoFamiliar (
	idGrupoFamiliar INT PRIMARY KEY IDENTITY(1,1),
	cantidadGrupoFamiliar INT NOT NULL CHECK (cantidadGrupoFamiliar > 0)
);
GO

-- 1.4 actividades.deporteDisponible
CREATE TABLE actividades.deporteDisponible (
	idDeporte INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(20) NOT NULL,
    tipo VARCHAR(10) NOT NULL,
	costoPorMes DECIMAL(10, 2) CHECK (costoPorMes > 0) NOT NULL
);
GO

-- 1.5 actividades.actividadPileta
CREATE TABLE actividades.actividadPileta (
	idActividad INT PRIMARY KEY IDENTITY(1,1),
	tarifaSocioPorDia DECIMAL(10, 2) CHECK (tarifaSocioPorDia > 0) NOT NULL,
	tarifaInvitadoPorDia DECIMAL(10, 2) CHECK (tarifaInvitadoPorDia > 0) NOT NULL,
	horaAperturaActividad INT NOT NULL,
	horaCierreActividad INT NOT NULL
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
	horaMinimaReserva INT NOT NULL,
	horaMaximaReserva INT NOT NULL
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

-- 2. Tablas que dependen de las tablas base

-- 2.1 socios.socio
CREATE TABLE socios.socio (
    idSocio INT IDENTITY(1,1),
	categoriaSocio INT NOT NULL,
    dni varchar(10) NOT NULL,
    cuil varchar(13) NOT NULL,
    nombre VARCHAR(10) NOT NULL,
    apellido VARCHAR(10) NOT NULL,
    email VARCHAR(25),
    telefono VARCHAR(14),
    fechaNacimiento DATE,
    fechaDeVigenciaContrasenia DATE,
    contactoDeEmergencia VARCHAR(14),
    usuario VARCHAR(50) UNIQUE,
    contrasenia VARCHAR(10),
    estadoMembresia VARCHAR(22) NOT NULL CHECK (estadoMembresia IN ('Activo', 'Moroso-1er Vencimiento', 'Moroso-2do Vencimiento', 'Inactivo')),
	fechaIngresoSocio DATE,
	fechaVencimientoMembresia DATE,
    saldoAFavor DECIMAL(10, 2) CHECK (saldoAFavor >= 0),
    direccion VARCHAR(25),
	CONSTRAINT PK_socio PRIMARY KEY (idSocio),
	FOREIGN KEY (categoriaSocio) REFERENCES socios.categoriaSocio(idCategoria)
);
GO

-- 3. Tablas con dependencias de segundo nivel

-- 3.1 socios.rolVigente
CREATE TABLE socios.rolVigente (
    idRol INT NOT NULL CHECK (idRol > 0),
    idSocio INT NOT NULL CHECK (idSocio > 0),
    CONSTRAINT PK_rolVigente PRIMARY KEY (idRol, idSocio),
    FOREIGN KEY (idRol) REFERENCES socios.rolDisponible(idRol),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
	estadoRolVigente BIT NOT NULL CONSTRAINT estadoVigencia DEFAULT (1)
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

-- 3.5 pagos.facturaEmitida
CREATE TABLE pagos.facturaEmitida (
    idFactura INT PRIMARY KEY IDENTITY(1,1),
	idSocio INT,
	categoriaSocio INT NOT NULL,
	idServicioFacturado INT NOT NULL,
	descripcionServicioFacturado VARCHAR(50) NOT NULL,
	nombreSocio VARCHAR(10) NOT NULL,
	apellidoSocio VARCHAR(10) NOT NULL,
    fechaEmision DATE DEFAULT GETDATE(),
	cuilDeudor INT NOT NULL,
	domicilio VARCHAR(35) NOT NULL,
	modalidadCobro VARCHAR(25) NOT NULL,
	importeBruto DECIMAL(10, 2) NOT NULL CHECK (importeBruto >= 0),
	importeTotal DECIMAL(10, 2) NOT NULL CHECK (importeTotal >= 0),
    fechaPrimerVencimiento DATE NOT NULL,
    fechaSegundoVencimiento DATE NOT NULL,
	estadoFactura varchar(10) NOT NULL CHECK (estadoFactura IN('Pendiente', 'Pagada', 'Nulificada')),
    CONSTRAINT FK_facturaEmitida FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 3.6 pagos.cobroFactura
CREATE TABLE pagos.cobroFactura (
    idCobro INT IDENTITY(1,1),
    idFacturaCobrada INT,
    idSocio INT,
    categoriaSocio INT NOT NULL,
    idServicioCobrado INT NOT NULL,
    descripcionServicioCobrado VARCHAR(50) NOT NULL,
    fechaEmisionCobro DATE NOT NULL,
    nombreSocio VARCHAR(10) NOT NULL,
    apellidoSocio VARCHAR(10) NOT NULL,
    fechaEmision DATE DEFAULT GETDATE() NOT NULL,
    cuilDeudor INT NOT NULL,
    domicilio VARCHAR(20),
    modalidadCobro VARCHAR(25) NOT NULL,
    numeroCuota INT NOT NULL,
    totalAbonado DECIMAL(10, 2) NOT NULL CHECK (totalAbonado >= 0),
	CONSTRAINT PK_cobroFactura PRIMARY KEY (idCobro, idFacturaCobrada),
    CONSTRAINT FK_cobroFactura FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idFacturaCobrada) REFERENCES pagos.facturaEmitida(idFactura)
);
GO

-- 3.7 descuentos.descuentoVigente
CREATE TABLE descuentos.descuentoVigente (
    idDescuento INT,
    idSocio INT,
	CONSTRAINT PK_descuentoVigente PRIMARY KEY (idDescuento, idSocio),
    FOREIGN KEY (idDescuento) REFERENCES descuentos.descuentoDisponible(idDescuento), 
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 3.8 itinerarios.itinerario
CREATE TABLE itinerarios.itinerario (
    idItinerario INT PRIMARY KEY IDENTITY(1,1),
    dia VARCHAR(9) NOT NULL,
    idDeporte INT NOT NULL,
    horaInicio VARCHAR(50) NOT NULL,
    horaFin VARCHAR(50) NOT NULL,
    FOREIGN KEY (idDeporte) REFERENCES actividades.deporteDisponible(idDeporte)
);
GO

-- 3.9 coberturas.prepagaEnUso
CREATE TABLE coberturas.prepagaEnUso (
    idPrepaga INT PRIMARY KEY IDENTITY(1,1),
    idCobertura INT NOT NULL,
    idNumeroSocio INT NOT NULL,
    categoriaSocio INT NOT NULL,
    FOREIGN KEY (idCobertura) REFERENCES coberturas.coberturaDisponible(idCoberturaDisponible),
    FOREIGN KEY (idNumeroSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 3.10 reservas.reservaSum 
CREATE TABLE reservas.reservaSUM (
	idReserva INT IDENTITY(1,1),
	idSocio INT NOT NULL CHECK (idSocio >= 0), -- Porque si no es socio y es Invitado, iria 0
	idSalon INT NOT NULL,
	dniReservante INT NOT NULL,
	horaInicioReserva INT NOT NULL,
	horaFinReserva INT NOT NULL,
	tarifaFinal DECIMAL(10, 2) CHECK (tarifaFinal > 0) NOT NULL,
	CONSTRAINT PK_reservasSUM PRIMARY KEY (idReserva, idSocio, dniReservante),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
	FOREIGN KEY (idSalon) REFERENCES itinerarios.datosSUM(idSitio)
);
GO

-- 3.11 reservas.reservaPaseActividad
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

-- 4. Tablas con dependencias de tercer nivel (últimas)

-- 4.1 pagos.reembolso
CREATE TABLE pagos.reembolso (
    idFacturaReembolso INT NOT NULL IDENTITY(1,1),
    idCobroOriginal INT NOT NULL,
	idFacturaOriginal INT NOT NULL,
    idSocioDestinatario INT NOT NULL,
    montoReembolsado DECIMAL(10, 2) NOT NULL CHECK (montoReembolsado > 0),
    cuilDestinatario BIGINT NOT NULL CHECK (cuilDestinatario > 0), -- Corregido de 'cuitDestinatario' a 'cuilDestinatario'
    medioDePagoUsado VARCHAR(50) NOT NULL,
    razonReembolso VARCHAR(50) NOT NULL,
    CONSTRAINT PK_reembolso PRIMARY KEY (idFacturaReembolso, idCobroOriginal),
    FOREIGN KEY (idCobroOriginal, idFacturaOriginal) REFERENCES pagos.cobroFactura(idCobro, idFacturaCobrada),
    FOREIGN KEY (idSocioDestinatario) REFERENCES socios.socio(idSocio)
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

CREATE OR ALTER PROCEDURE socios.insertarCategoriaSocio
    @tipo VARCHAR(15),
    @costoMembresia DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
	--Verificación de tipo (cuánto menos, que no quede vacío):
    IF @tipo = ''
    BEGIN
        RAISERROR('El tipo no puede quedar vacío.', 16, 1);
        RETURN;
    END

    INSERT INTO socios.categoriaSocio (tipo, costoMembresia)
    VALUES (@tipo, @costoMembresia);
END
GO

CREATE OR ALTER PROCEDURE socios.actualizarCategoriaSocio
    @idCategoria INT,
    @tipo VARCHAR(15),
    @costoMembresia DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM socios.categoriaSocio WHERE idCategoria = @idCategoria)
    BEGIN
        RAISERROR('Categoría con ID %d no encontrada.', 16, 1, @idCategoria);
        RETURN;
    END

    UPDATE socios.categoriaSocio
    SET
        tipo = @tipo,
        costoMembresia = @costoMembresia
    WHERE idCategoria = @idCategoria;
END
GO

CREATE OR ALTER PROCEDURE socios.sp_EliminarCategoriaSocio
    @idCategoria INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM socios.categoriaSocio WHERE idCategoria = @idCategoria)
    BEGIN
        RAISERROR('Categoría con ID %d no encontrada.', 16, 1, @idCategoria);
        RETURN;
    END

    UPDATE socios.categoriaSocio
    SET estadoCategoriaSocio = 0
    WHERE idCategoria = @idCategoria;
END
GO

--socio

CREATE OR ALTER PROCEDURE socios.insertarSocio
  @categoriaSocio             INT,
  @dni                        VARCHAR(10),
  @cuil                       VARCHAR(13),
  @nombre                     VARCHAR(10),
  @apellido                   VARCHAR(10),
  @email                      VARCHAR(25)    = NULL,
  @telefono                   VARCHAR(14)    = NULL,
  @fechaNacimiento            DATE           = NULL,
  @contactoDeEmergencia       VARCHAR(14)    = NULL,
  @usuario                    VARCHAR(50),
  @contrasenia                VARCHAR(10),
  @direccion                  VARCHAR(25)    = NULL,
  @saldoAFavor                DECIMAL(10,2)  = 0
AS
BEGIN
  SET NOCOUNT ON;
  IF socios.validarDNI(@dni) = 0
  BEGIN
    RAISERROR('DNI inválido.',16,1);
    RETURN;
  END
  IF socios.validarCUIL(@cuil) = 0
  BEGIN
    RAISERROR('CUIL inválido.',16,1);
    RETURN;
  END
  IF NOT EXISTS (SELECT 1 FROM socios.categoriaSocio WHERE idCategoria = @categoriaSocio AND estadoCategoriaSocio = 1)
  BEGIN
    RAISERROR('Categoría de socio %d no existe o está inactiva.',16,1,@categoriaSocio);
    RETURN;
  END
  INSERT INTO socios.socio (
    categoriaSocio,
    dni,
    cuil,
    nombre,
    apellido,
    email,
    telefono,
    fechaNacimiento,
    fechaDeVigenciaContrasenia,
    contactoDeEmergencia,
    usuario,
    contrasenia,
    estadoMembresia,
    fechaIngresoSocio,
    fechaVencimientoMembresia,
    saldoAFavor,
    direccion
  )
  VALUES (
    @categoriaSocio,
    @dni,
    @cuil,
    @nombre,
    @apellido,
    @email,
    @telefono,
    @fechaNacimiento,
    DATEADD(MONTH,3,GETDATE()),       -- +3 meses
    @contactoDeEmergencia,
    @usuario,
    @contrasenia,
    'Activo',                          -- estado inicial
    GETDATE(),                         -- fecha de ingreso = hoy
    DATEADD(MONTH,1,GETDATE()),       -- +1 mes
    @saldoAFavor,
    @direccion
  );
END
GO

CREATE PROCEDURE socios.actualizarSocio
  @idSocio                    INT,
  @categoriaSocio             INT,
  @dni                        VARCHAR(10)           = NULL,
  @cuil                       VARCHAR(13)           = NULL,
  @nombre                     VARCHAR(10)      = NULL,
  @apellido                   VARCHAR(10)      = NULL,
  @email                      VARCHAR(25)      = NULL,
  @telefono                   VARCHAR(14)      = NULL,
  @fechaNacimiento            DATE             = NULL,
  @contraseniaNueva           VARCHAR(10)      = NULL,
  @contactoDeEmergencia       VARCHAR(14)      = NULL,
  @estadoMembresia            VARCHAR(22)      = NULL,
  @fechaVencimientoMembresia  DATE             = NULL,
  @saldoAFavor                DECIMAL(10,2)    = NULL,
  @direccion                  VARCHAR(25)      = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- 1) Verificar existencia
  IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio AND categoriaSocio = @categoriaSocio)
  BEGIN
    RAISERROR('Socio %d en categoría %d no encontrado.',16,1,@idSocio,@categoriaSocio);
    RETURN;
  END

  -- 2) Validaciones puntuales
  IF @dni IS NOT NULL AND socios.validarDNI(@dni) = 0
  BEGIN
    RAISERROR('DNI inválido.',16,1);
    RETURN;
  END
  IF @cuil IS NOT NULL AND socios.validarCUIL(@cuil) = 0
  BEGIN
    RAISERROR('CUIL inválido.',16,1);
    RETURN;
  END

  -- 3) Armado dinámico del UPDATE
  UPDATE socios.socio
  SET
    dni                       = COALESCE(@dni, dni),
    cuil                      = COALESCE(@cuil, cuil),
    nombre                    = COALESCE(@nombre, nombre),
    apellido                  = COALESCE(@apellido, apellido),
    email                     = COALESCE(@email, email),
    telefono                  = COALESCE(@telefono, telefono),
    fechaNacimiento           = COALESCE(@fechaNacimiento, fechaNacimiento),
    contactoDeEmergencia      = COALESCE(@contactoDeEmergencia, contactoDeEmergencia),
    usuario                   = COALESCE(usuario, usuario),
    -- Si la contraseña cambia, actualizo su vigencia:
    contrasenia               = CASE WHEN @contraseniaNueva IS NOT NULL THEN @contraseniaNueva ELSE contrasenia END,
    fechaDeVigenciaContrasenia= CASE 
                                   WHEN @contraseniaNueva IS NOT NULL 
                                   THEN DATEADD(MONTH,3,GETDATE()) 
                                   ELSE fechaDeVigenciaContrasenia 
                                 END,
    -- Opciones de membresía (si se pasó parámetro):
    estadoMembresia           = COALESCE(@estadoMembresia, estadoMembresia),
    fechaVencimientoMembresia = COALESCE(@fechaVencimientoMembresia, fechaVencimientoMembresia),
    saldoAFavor               = COALESCE(@saldoAFavor, saldoAFavor),
    direccion                 = COALESCE(@direccion, direccion)
  WHERE idSocio = @idSocio
    AND categoriaSocio = @categoriaSocio;
END
GO

CREATE PROCEDURE socios.eliminarSocioLogico
  @idSocio       INT,
  @categoriaSocio INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Verificar existencia
  IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio AND categoriaSocio = @categoriaSocio)
  BEGIN
    RAISERROR('Socio %d en categoría %d no encontrado.',16,1,@idSocio,@categoriaSocio);
    RETURN;
  END

  -- Cambio de estado a “Inactivo”
  UPDATE socios.socio
  SET estadoMembresia = 'Inactivo'
  WHERE idSocio = @idSocio
    AND categoriaSocio = @categoriaSocio;
END
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

--rolVigente

CREATE PROCEDURE socios.insertarRolVigente
  @usuario         VARCHAR(50),
  @descripcionRol  VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @idSocio INT,
          @idRol   INT;

  -- 1) Obtener el socio activo por usuario
  SELECT @idSocio = idSocio
  FROM socios.socio
  WHERE usuario = @usuario
    AND estadoMembresia = 'Activo';

  IF @idSocio IS NULL
  BEGIN
    RAISERROR('No se encontró socio activo con usuario "%s".',16,1,@usuario);
    RETURN;
  END

  -- 2) Obtener el rol disponible por descripción
  SELECT @idRol = idRol
  FROM socios.rolDisponible
  WHERE descripcion = @descripcionRol
    AND estadoRol = 1;

  IF @idRol IS NULL
  BEGIN
    RAISERROR('No se encontró rol activo con descripción "%s".',16,1,@descripcionRol);
    RETURN;
  END

  -- 3) Verificar que no exista ya la asignación
  IF EXISTS (
    SELECT 1 
    FROM socios.rolVigente
    WHERE idSocio = @idSocio 
      AND idRol   = @idRol
      AND estadoRolVigente  = 1
  )
  BEGIN
    RAISERROR('La asignación socio="%s" (%d) -> rol="%s" (%d) ya existe.',16,1,
               @usuario, @idSocio, @descripcionRol, @idRol);
    RETURN;
  END

  -- 4) Insertar
  INSERT INTO socios.rolVigente (idRol, idSocio)
  VALUES (@idRol, @idSocio);
END
GO

CREATE PROCEDURE socios.actualizarRolVigente
  @usuarioOld        VARCHAR(50),
  @descripcionRolOld VARCHAR(50),
  @usuarioNew        VARCHAR(50),
  @descripcionRolNew VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;
  
  DECLARE @idSocioOld INT,
          @idRolOld   INT,
          @idSocioNew INT,
          @idRolNew   INT;

  -- 1.1) Obtener IDs antiguos
  SELECT @idSocioOld = idSocio
    FROM socios.socio
   WHERE usuario = @usuarioOld
     AND estadoMembresia = 'Activo';

  SELECT @idRolOld = idRol
    FROM socios.rolDisponible
   WHERE descripcion = @descripcionRolOld
     AND estadoRol = 1;

  IF @idSocioOld IS NULL
  BEGIN
    RAISERROR('Usuario antiguo "%s" no encontrado o inactivo.',16,1,@usuarioOld);
    RETURN;
  END
  IF @idRolOld IS NULL
  BEGIN
    RAISERROR('Rol antiguo "%s" no encontrado o inactivo.',16,1,@descripcionRolOld);
    RETURN;
  END

  -- 1.2) Obtener IDs nuevos
  SELECT @idSocioNew = idSocio
    FROM socios.socio
   WHERE usuario = @usuarioNew
     AND estadoMembresia = 'Activo';

  SELECT @idRolNew = idRol
    FROM socios.rolDisponible
   WHERE descripcion = @descripcionRolNew
     AND estadoRol = 1;

  IF @idSocioNew IS NULL
  BEGIN
    RAISERROR('Usuario nuevo "%s" no encontrado o inactivo.',16,1,@usuarioNew);
    RETURN;
  END
  IF @idRolNew IS NULL
  BEGIN
    RAISERROR('Rol nuevo "%s" no encontrado o inactivo.',16,1,@descripcionRolNew);
    RETURN;
  END

  -- 1.3) Evitar que la asignación destino ya exista
  IF EXISTS (
    SELECT 1
      FROM socios.rolVigente
     WHERE idSocio = @idSocioNew
       AND idRol   = @idRolNew
       AND estadoRolVigente= 1
  )
  BEGIN
    RAISERROR('La asignación usuario="%s"→rol="%s" ya existe.',16,1,
               @usuarioNew, @descripcionRolNew);
    RETURN;
  END

  -- 1.4) Actualizar la fila
  UPDATE socios.rolVigente
  SET idSocio = @idSocioNew,
      idRol   = @idRolNew
  WHERE idSocio = @idSocioOld
    AND idRol   = @idRolOld
    AND estadoRolVigente  = 1;
END
GO

CREATE PROCEDURE socios.eliminarRolVigente
  @usuario        VARCHAR(50),
  @descripcionRol VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @idSocio INT,
          @idRol   INT;

  -- 2.1) Obtener IDs
  SELECT @idSocio = idSocio
    FROM socios.socio
   WHERE usuario = @usuario
     AND estadoMembresia = 'Activo';

  SELECT @idRol = idRol
    FROM socios.rolDisponible
   WHERE descripcion = @descripcionRol
     AND estadoRol = 1;

  IF @idSocio IS NULL
  BEGIN
    RAISERROR('Usuario "%s" no encontrado o inactivo.',16,1,@usuario);
    RETURN;
  END
  IF @idRol IS NULL
  BEGIN
    RAISERROR('Rol "%s" no encontrado o inactivo.',16,1,@descripcionRol);
    RETURN;
  END

  -- 2.2) Verificar asignación activa existente
  IF NOT EXISTS (
    SELECT 1
      FROM socios.rolVigente
     WHERE idSocio = @idSocio
       AND idRol   = @idRol
       AND estadoRolVigente  = 1
  )
  BEGIN
    RAISERROR('No existe asignación activa usuario="%s"→rol="%s".',16,1,
               @usuario, @descripcionRol);
    RETURN;
  END

  -- 2.3) Marcar como inactiva
  UPDATE socios.rolVigente
  SET estadoRolVigente = 0
  WHERE idSocio = @idSocio
    AND idRol   = @idRol
    AND estadoRolVigente  = 1;
END
GO

--grupoFamiliar

CREATE PROCEDURE socios.insertarGrupoFamiliar
  @cantidadGrupoFamiliar INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Validación
  IF @cantidadGrupoFamiliar IS NULL OR @cantidadGrupoFamiliar <= 0
  BEGIN
    RAISERROR('La cantidad debe ser un entero mayor que cero.',16,1);
    RETURN;
  END

  INSERT INTO socios.grupoFamiliar (cantidadGrupoFamiliar)
  VALUES (@cantidadGrupoFamiliar);
END
GO

CREATE OR ALTER PROCEDURE socios.actualizarGrupoFamiliar
  @idGrupoFamiliar       INT,
  @cantidadGrupoFamiliar INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Verificar existencia
  IF NOT EXISTS (SELECT 1 FROM socios.grupoFamiliar WHERE idGrupoFamiliar = @idGrupoFamiliar)
  BEGIN
    RAISERROR('Grupo familiar con ID %d no encontrado.',16,1,@idGrupoFamiliar);
    RETURN;
  END

  -- Validación
  IF @cantidadGrupoFamiliar IS NULL OR @cantidadGrupoFamiliar <= 0
  BEGIN
    RAISERROR('La cantidad debe ser un entero mayor que cero.',16,1);
    RETURN;
  END

  UPDATE socios.grupoFamiliar
  SET cantidadGrupoFamiliar = @cantidadGrupoFamiliar
  WHERE idGrupoFamiliar = @idGrupoFamiliar;
END
GO

CREATE PROCEDURE socios.eliminarGrupoFamiliar
  @idGrupoFamiliar INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Verificar existencia
  IF NOT EXISTS (SELECT 1 FROM socios.grupoFamiliar WHERE idGrupoFamiliar = @idGrupoFamiliar)
  BEGIN
    RAISERROR('Grupo familiar con ID %d no encontrado.',16,1,@idGrupoFamiliar);
    RETURN;
  END

  DELETE FROM socios.grupoFamiliar
  WHERE idGrupoFamiliar = @idGrupoFamiliar;
END
GO

--grupoFamiliarActivo

IF OBJECT_ID('socios.sp_InsertarGrupoFamiliarActivo','P') IS NOT NULL
  DROP PROCEDURE socios.insertarGrupoFamiliarActivo;
GO

CREATE PROCEDURE socios.insertarGrupoFamiliarActivo
  @usuario                  VARCHAR(50),
  @idGrupoFamiliar          INT,
  @parentescoGrupoFamiliar  VARCHAR(10)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @idSocio INT;

  -- 1) Obtener el idSocio a partir del usuario
  SELECT @idSocio = idSocio
    FROM socios.socio
   WHERE usuario = @usuario
     AND estadoMembresia = 'Activo';

  IF @idSocio IS NULL
  BEGIN
    RAISERROR('No se encontró socio activo con usuario "%s".',16,1,@usuario);
    RETURN;
  END

  -- 2) Verificar que el grupo familiar exista
  IF NOT EXISTS (
    SELECT 1
      FROM socios.grupoFamiliar
     WHERE idGrupoFamiliar = @idGrupoFamiliar
  )
  BEGIN
    RAISERROR('No existe grupo familiar con ID %d.',16,1,@idGrupoFamiliar);
    RETURN;
  END

  -- 3) Verificar que no exista ya la relación activa
  IF EXISTS (
    SELECT 1
      FROM socios.grupoFamiliarActivo
     WHERE idSocio               = @idSocio
       AND idGrupoFamiliar       = @idGrupoFamiliar
       AND estadoGrupoActivo = 1
  )
  BEGIN
    RAISERROR(
      'La relación socio="%s" (ID %d) → grupoFam ID=%d ya está activa.',
      16,1, @usuario, @idSocio, @idGrupoFamiliar
    );
    RETURN;
  END

  -- 4) Insertar nueva relación
  INSERT INTO socios.grupoFamiliarActivo
    (idSocio, idGrupoFamiliar, parentescoGrupoFamiliar)
  VALUES
    (@idSocio, @idGrupoFamiliar, @parentescoGrupoFamiliar);
END
GO

CREATE PROCEDURE socios.actualizarGrupoFamiliarActivo
  @usuarioOld                  VARCHAR(50),
  @idGrupoFamiliarOld          INT,
  @usuarioNew                  VARCHAR(50),
  @idGrupoFamiliarNew          INT,
  @parentescoGrupoFamiliarNew  VARCHAR(10)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @idSocioOld INT, @idSocioNew INT;

  -- 1.1) Traducir usuarioOld -> idSocioOld
  SELECT @idSocioOld = idSocio
    FROM socios.socio
   WHERE usuario = @usuarioOld
     AND estadoMembresia = 'Activo';

  IF @idSocioOld IS NULL
  BEGIN
    RAISERROR('No se encontró socio activo con usuario "%s".',16,1,@usuarioOld);
    RETURN;
  END

  -- 1.2) Verificar que la relación original exista
  IF NOT EXISTS (
    SELECT 1
      FROM socios.grupoFamiliarActivo
     WHERE idSocio               = @idSocioOld
       AND idGrupoFamiliar       = @idGrupoFamiliarOld
       AND estadoGrupoActivo = 1
  )
  BEGIN
    RAISERROR('No existe relación activa usuario "%s" → grupoFam ID=%d.',16,1,
               @usuarioOld, @idGrupoFamiliarOld);
    RETURN;
  END

  -- 1.3) Traducir usuarioNew -> idSocioNew
  SELECT @idSocioNew = idSocio
    FROM socios.socio
   WHERE usuario = @usuarioNew
     AND estadoMembresia = 'Activo';

  IF @idSocioNew IS NULL
  BEGIN
    RAISERROR('No se encontró socio activo con usuario "%s".',16,1,@usuarioNew);
    RETURN;
  END

  -- 1.4) Verificar que el grupo nuevo exista
  IF NOT EXISTS (
    SELECT 1
      FROM socios.grupoFamiliar
     WHERE idGrupoFamiliar = @idGrupoFamiliarNew
  )
  BEGIN
    RAISERROR('No existe grupo familiar con ID %d.',16,1,@idGrupoFamiliarNew);
    RETURN;
  END

  -- 1.5) Evitar duplicado destino
  IF EXISTS (
    SELECT 1
      FROM socios.grupoFamiliarActivo
     WHERE idSocio               = @idSocioNew
       AND idGrupoFamiliar       = @idGrupoFamiliarNew
       AND estadoGrupoActivo = 1
  )
  BEGIN
    RAISERROR('La relación usuario "%s" → grupoFam ID=%d ya existe activa.',16,1,
               @usuarioNew, @idGrupoFamiliarNew);
    RETURN;
  END

  -- 1.6) Ejecutar el UPDATE
  UPDATE socios.grupoFamiliarActivo
  SET
    idSocio               = @idSocioNew,
    idGrupoFamiliar       = @idGrupoFamiliarNew,
    parentescoGrupoFamiliar = @parentescoGrupoFamiliarNew
  WHERE
    idSocio               = @idSocioOld
    AND idGrupoFamiliar    = @idGrupoFamiliarOld
    AND estadoGrupoActivo = 1;
END
GO

CREATE PROCEDURE socios.eliminarGrupoFamiliarActivo
  @usuario               VARCHAR(50),
  @idGrupoFamiliar       INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @idSocio INT;

  -- 2.1) Traducir usuario -> idSocio
  SELECT @idSocio = idSocio
    FROM socios.socio
   WHERE usuario = @usuario
     AND estadoMembresia = 'Activo';

  IF @idSocio IS NULL
  BEGIN
    RAISERROR('No se encontró socio activo con usuario "%s".',16,1,@usuario);
    RETURN;
  END

  -- 2.2) Verificar que exista la relación activa
  IF NOT EXISTS (
    SELECT 1
      FROM socios.grupoFamiliarActivo
     WHERE idSocio               = @idSocio
       AND idGrupoFamiliar       = @idGrupoFamiliar
       AND estadoGrupoActivo = 1
  )
  BEGIN
    RAISERROR('No existe relación activa usuario "%s" → grupoFam ID=%d.',16,1,
               @usuario, @idGrupoFamiliar);
    RETURN;
  END

  -- 2.3) Marcarla como inactiva
  UPDATE socios.grupoFamiliarActivo
  SET estadoGrupoActivo = 0
  WHERE idSocio               = @idSocio
    AND idGrupoFamiliar       = @idGrupoFamiliar
    AND estadoGrupoActivo= 1;
END
GO

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

--InsertarDeportes.

EXEC actividades.insertarDeporteDisponible
  @descripcion = 'Fútbol',
  @tipo = 'Equipo',
  @costoPorMes = 25000.00;

EXEC actividades.insertarDeporteDisponible
  @descripcion = 'Natación',
  @tipo = 'Individual',
  @costoPorMes = 45000.00;

EXEC actividades.insertarDeporteDisponible
  @descripcion = 'Tenis',
  @tipo = 'Individual',
  @costoPorMes = 18000.00;

--ActualizarDeporte

  EXEC actividades.actualizarDeporteDisponible
  @idDeporte = 2,
  @descripcion = 'Natación',
  @tipo = 'Grupo',
  @costoPorMes = 26000.00;

--EliminarDeporte
EXEC actividades.eliminarDeporteDisponible
  @idDeporte = 3;
GO

--deporteActivo

CREATE OR ALTER PROCEDURE actividades.insertarDeporteActivo
  @usuario                    VARCHAR(50),
  @idDeporte                 INT,
  @estadoActividadDeporte    VARCHAR(8),
  @estadoMembresia           VARCHAR(22)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @idSocio INT;

  -- Verificar socio activo
  SELECT @idSocio = idSocio
    FROM socios.socio
   WHERE usuario = @usuario
     AND estadoMembresia = 'Activo';

  IF @idSocio IS NULL
  BEGIN
    RAISERROR('No se encontró un socio activo con el usuario "%s".', 16, 1, @usuario);
    RETURN;
  END

  -- Verificar existencia de deporte
  IF NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte)
  BEGIN
    RAISERROR('No existe un deporte con ID %d.', 16, 1, @idDeporte);
    RETURN;
  END

  INSERT INTO actividades.deporteActivo (
    idSocio, idDeporte, estadoActividadDeporte, estadoMembresia
  )
  VALUES (
    @idSocio, @idDeporte, @estadoActividadDeporte, @estadoMembresia
  );
END
GO

CREATE OR ALTER PROCEDURE actividades.actualizarDeporteActivo
  @idDeporteActivo           INT,
  @estadoActividadDeporte    VARCHAR(8),
  @estadoMembresia           VARCHAR(22)
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (
    SELECT 1 FROM actividades.deporteActivo WHERE idDeporteActivo = @idDeporteActivo
  )
  BEGIN
    RAISERROR('No existe una actividad con ID %d.', 16, 1, @idDeporteActivo);
    RETURN;
  END

  UPDATE actividades.deporteActivo
  SET
    estadoActividadDeporte = @estadoActividadDeporte,
    estadoMembresia = @estadoMembresia
  WHERE idDeporteActivo = @idDeporteActivo;
END
GO

CREATE OR ALTER PROCEDURE actividades.eliminarDeporteActivo
  @idDeporteActivo INT
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (
    SELECT 1 FROM actividades.deporteActivo
     WHERE idDeporteActivo = @idDeporteActivo
       AND estadoMembresia <> 'Inactivo'
  )
  BEGIN
    RAISERROR('No se encontró una actividad activa con ID %d.', 16, 1, @idDeporteActivo);
    RETURN;
  END

  UPDATE actividades.deporteActivo
  SET estadoMembresia = 'Inactivo'
  WHERE idDeporteActivo = @idDeporteActivo;
END
GO

--actividadPileta

CREATE OR ALTER PROCEDURE actividades.insertarActividadPileta
  @tarifaSocioPorDia     DECIMAL(10, 2),
  @tarifaInvitadoPorDia  DECIMAL(10, 2),
  @horaAperturaActividad INT,
  @horaCierreActividad   INT
AS
BEGIN
  SET NOCOUNT ON;

  IF @tarifaSocioPorDia <= 0 OR @tarifaInvitadoPorDia <= 0
  BEGIN
    RAISERROR('Las tarifas deben ser mayores a cero.', 16, 1);
    RETURN;
  END

  IF @horaAperturaActividad < 0 OR @horaAperturaActividad > 23
     OR @horaCierreActividad < 0 OR @horaCierreActividad > 23
     OR @horaCierreActividad <= @horaAperturaActividad
  BEGIN
    RAISERROR('Los horarios deben estar entre 0 y 23, y la hora de cierre debe ser mayor a la de apertura.', 16, 1);
    RETURN;
  END

  INSERT INTO actividades.actividadPileta (
    tarifaSocioPorDia, tarifaInvitadoPorDia,
    horaAperturaActividad, horaCierreActividad
  )
  VALUES (
    @tarifaSocioPorDia, @tarifaInvitadoPorDia,
    @horaAperturaActividad, @horaCierreActividad
  );
END
GO

CREATE OR ALTER PROCEDURE actividades.actualizarActividadPileta
  @idActividad            INT,
  @tarifaSocioPorDia     DECIMAL(10, 2),
  @tarifaInvitadoPorDia  DECIMAL(10, 2),
  @horaAperturaActividad INT,
  @horaCierreActividad   INT
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM actividades.actividadPileta WHERE idActividad = @idActividad)
  BEGIN
    RAISERROR('No existe una actividad con el ID especificado.', 16, 1);
    RETURN;
  END

  IF @tarifaSocioPorDia <= 0 OR @tarifaInvitadoPorDia <= 0
  BEGIN
    RAISERROR('Las tarifas deben ser mayores a cero.', 16, 1);
    RETURN;
  END

  IF @horaAperturaActividad < 0 OR @horaAperturaActividad > 23
     OR @horaCierreActividad < 0 OR @horaCierreActividad > 23
     OR @horaCierreActividad <= @horaAperturaActividad
  BEGIN
    RAISERROR('Los horarios deben estar entre 0 y 23, y la hora de cierre debe ser mayor a la de apertura.', 16, 1);
    RETURN;
  END

  UPDATE actividades.actividadPileta
  SET
    tarifaSocioPorDia = @tarifaSocioPorDia,
    tarifaInvitadoPorDia = @tarifaInvitadoPorDia,
    horaAperturaActividad = @horaAperturaActividad,
    horaCierreActividad = @horaCierreActividad
  WHERE idActividad = @idActividad;
END
GO

CREATE OR ALTER PROCEDURE actividades.eliminarActividadPileta
  @idActividad INT
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM actividades.actividadPileta WHERE idActividad = @idActividad)
  BEGIN
    RAISERROR('No existe una actividad con el ID especificado.', 16, 1);
    RETURN;
  END

  DELETE FROM actividades.actividadPileta
  WHERE idActividad = @idActividad;
END
GO

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

CREATE PROCEDURE pagos.eliminarTarjetaDisponible
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
  @idSocio       INT,
  @idTarjeta     INT,
  @tipoTarjeta   VARCHAR(7),
  @numeroTarjeta BIGINT
AS
BEGIN
  SET NOCOUNT ON;

  -- 1) Validación de tipoTarjeta
  IF @tipoTarjeta NOT IN ('Credito','Debito','Prepaga','Virtual')
  BEGIN
    RAISERROR('Tipo de tarjeta inválido.',16,1);
    RETURN;
  END

  -- 2) Validación de númeroTarjeta
  IF @numeroTarjeta <= 0
  BEGIN
    RAISERROR('El número de tarjeta debe ser > 0.',16,1);
    RETURN;
  END

  -- 3) Verificar socio activo
  IF NOT EXISTS (
    SELECT 1 FROM socios.socio
     WHERE idSocio = @idSocio
       AND estadoMembresia = 'Activo'
  )
  BEGIN
    RAISERROR('Socio inexistente o no activo.',16,1);
    RETURN;
  END

  -- 4) Verificar tarjeta válida
  IF NOT EXISTS (
    SELECT 1 FROM pagos.tarjetaDisponible
     WHERE idTarjeta = @idTarjeta
       AND tipoTarjeta = @tipoTarjeta
  )
  BEGIN
    RAISERROR('Tarjeta no disponible.',16,1);
    RETURN;
  END

  -- 5) Insertar (activo = 1 por defecto)
  INSERT INTO pagos.tarjetaEnUso
    (idSocio, idTarjeta, tipoTarjeta, numeroTarjeta)
  VALUES
    (@idSocio, @idTarjeta, @tipoTarjeta, @numeroTarjeta);
END
GO

CREATE PROCEDURE pagos.actualizarTarjetaEnUso
  @idSocio       INT,
  @idTarjeta     INT,
  @tipoTarjeta   VARCHAR(7),
  @nuevoNumero   BIGINT
AS
BEGIN
  SET NOCOUNT ON;

  -- 1) Validar nuevo número
  IF @nuevoNumero <= 0
  BEGIN
    RAISERROR('El número de tarjeta debe ser > 0.',16,1);
    RETURN;
  END

  -- 2) Verificar registro activo
  IF NOT EXISTS (
    SELECT 1 FROM pagos.tarjetaEnUso
     WHERE idSocio       = @idSocio
       AND idTarjeta     = @idTarjeta
       AND tipoTarjeta   = @tipoTarjeta
       AND estadoTarjeta        = 1
  )
  BEGIN
    RAISERROR('Tarjeta en uso no encontrada o inactiva.',16,1);
    RETURN;
  END

  -- 3) Actualizar número
  UPDATE pagos.tarjetaEnUso
  SET numeroTarjeta = @nuevoNumero
  WHERE idSocio     = @idSocio
    AND idTarjeta   = @idTarjeta
    AND tipoTarjeta = @tipoTarjeta
    AND estadoTarjeta      = 1;
END
GO

CREATE PROCEDURE pagos.eliminarTarjetaEnUso
  @idSocio       INT,
  @idTarjeta     INT,
  @tipoTarjeta   VARCHAR(7)
AS
BEGIN
  SET NOCOUNT ON;

  -- 1) Verificar registro activo
  IF NOT EXISTS (
    SELECT 1 FROM pagos.tarjetaEnUso
     WHERE idSocio       = @idSocio
       AND idTarjeta     = @idTarjeta
       AND tipoTarjeta   = @tipoTarjeta
       AND estadoTarjeta = 1
  )
  BEGIN
    RAISERROR('Tarjeta en uso no encontrada o ya inactiva.',16,1);
    RETURN;
  END

  -- 2) Marcar como inactiva
  UPDATE pagos.tarjetaEnUso
  SET estadoTarjeta   = 0
  WHERE idSocio       = @idSocio
    AND idTarjeta     = @idTarjeta
    AND tipoTarjeta   = @tipoTarjeta
    AND estadoTarjeta = 1;
END
GO

CREATE OR ALTER PROCEDURE pagos.insertarCobroFactura
  @idFacturaCobrada INT,
  @idSocio          INT,
  @categoriaSocio   INT
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE
    @idServicio           INT,
    @descrServicio        VARCHAR(50),
    @fechaFact            DATE,
    @cuilDeudor           INT,
    @domicilio            VARCHAR(20),
    @modalidad            VARCHAR(25),
    @importeTotal         DECIMAL(10,2),
    @fechaSegundoVto      DATE,
    @nombreSocio          VARCHAR(10),
    @apellidoSocio        VARCHAR(10),
    @numCuotas            INT,
    @siguienteCuota       INT,
    @totalAbonado         DECIMAL(10,2);

  -- 1) Traer datos de la factura, incluyendo segundo vencimiento
SELECT
  @idServicio        = idServicioFacturado,
  @descrServicio     = descripcionServicioFacturado,
  @fechaFact         = fechaEmision,
  @cuilDeudor        = cuilDeudor,
  @domicilio         = domicilio,
  @modalidad         = modalidadCobro,
  @importeTotal      = importeTotal,
  @fechaSegundoVto   = fechaSegundoVencimiento
FROM pagos.facturaEmitida
WHERE idFactura = @idFacturaCobrada;

  IF @@ROWCOUNT = 0
  BEGIN
    RAISERROR('Factura %d no encontrada.',16,1,@idFacturaCobrada);
    RETURN;
  END

  -- 2) Traer datos del socio
  SELECT @nombreSocio = nombre, @apellidoSocio = apellido 
  FROM socios.socio
  WHERE idSocio = @idSocio
    AND categoriaSocio = @categoriaSocio;

  IF @@ROWCOUNT = 0
  BEGIN
    RAISERROR('Socio %d / categoría %d no encontrado.',16,1,@idSocio,@categoriaSocio);
    RETURN;
  END

  -- 3) Calcular número de cuotas
  SET @numCuotas = TRY_CAST(SUBSTRING(@modalidad, CHARINDEX(':', @modalidad) + 1, 10) AS INT);
  IF @numCuotas IS NULL OR @numCuotas <= 0
  BEGIN
    RAISERROR('ModalidadCobro inválida: %s.',16,1,@modalidad);
    RETURN;
  END

  -- 4) Calcular siguiente cuota
  SELECT @siguienteCuota = COALESCE(MAX(numeroCuota), 0) + 1
  FROM pagos.cobroFactura
  WHERE idFacturaCobrada = @idFacturaCobrada;

  IF @siguienteCuota > @numCuotas
  BEGIN
    RAISERROR('Ya se cobraron las %d cuotas de la factura %d.',16,1,@numCuotas,@idFacturaCobrada);
    RETURN;
  END

  -- 5) Calcular el monto de esta cuota
  IF GETDATE() > @fechaSegundoVto
    -- aplica recargo 10% si pasó el segundo vencimiento
    SET @totalAbonado = ROUND(@importeTotal * 1.10 / @numCuotas, 2);
  ELSE
    SET @totalAbonado = ROUND(@importeTotal * 1.0 / @numCuotas, 2);

  -- 6) Insertar el cobro
  INSERT INTO pagos.cobroFactura (
    idFacturaCobrada, idSocio, categoriaSocio,
    idServicioCobrado, descripcionServicioCobrado,
    fechaEmisionCobro, nombreSocio, apellidoSocio,
    fechaEmision, cuilDeudor, domicilio, modalidadCobro,
    numeroCuota, totalAbonado
  )
  VALUES (
    @idFacturaCobrada, @idSocio, @categoriaSocio,
    @idServicio, @descrServicio,
    GETDATE(), @nombreSocio, @apellidoSocio,
    @fechaFact, @cuilDeudor, @domicilio, @modalidad,
    @siguienteCuota, @totalAbonado
  );
END
GO

CREATE OR ALTER PROCEDURE pagos.eliminarCobroFactura
  @idCobro          INT,
  @idFacturaCobrada INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Verificar existencia del cobro
  IF NOT EXISTS (
    SELECT 1 
      FROM pagos.cobroFactura
     WHERE idCobro = @idCobro
       AND idFacturaCobrada = @idFacturaCobrada
  )
  BEGIN
    RAISERROR('Cobro %d / factura %d no encontrado.', 16, 1, @idCobro, @idFacturaCobrada);
    RETURN;
  END

  -- Borrado físico del registro
  DELETE FROM pagos.cobroFactura
  WHERE idCobro = @idCobro
    AND idFacturaCobrada = @idFacturaCobrada;
END
GO

CREATE OR ALTER PROCEDURE pagos.insertarFacturaEmitida
  @idSocio                       INT,
  @categoriaSocio                INT,
  @idServicioFacturado           INT,
  @descripcionServicioFacturado VARCHAR(50),
  @domicilio                     VARCHAR(35),
  @modalidadCobro                VARCHAR(25),
  @importeBruto                  DECIMAL(10,2)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE 
    @nombreSocio         VARCHAR(10),
    @apellidoSocio       VARCHAR(10),
    @cuilDeudor          INT,
    @porcTotalDescuento  DECIMAL(5,2),
    @importeTotalCalc    DECIMAL(10,2),
    @fechaEmisionHoy     DATE = CAST(GETDATE() AS DATE),
    @fechaPrimerVto      DATE,
    @fechaSegundoVto     DATE;

  -- 1) Validar socio activo y traer datos
  SELECT 
    @nombreSocio   = nombre,
    @apellidoSocio = apellido,
    @cuilDeudor    = cuil
  FROM socios.socio
  WHERE idSocio = @idSocio
    AND categoriaSocio = @categoriaSocio
    AND estadoMembresia = 'Activo';

  IF @@ROWCOUNT = 0
  BEGIN
    RAISERROR('Socio %d / categoría %d no encontrado o inactivo.',16,1,@idSocio,@categoriaSocio);
    RETURN;
  END

  -- 2) Calcular descuentos
  SELECT @porcTotalDescuento = COALESCE(SUM(dd.porcentajeDescontado), 0)
  FROM descuentos.descuentoDisponible dd
  JOIN descuentos.descuentoVigente dv
    ON dd.idDescuento = dv.idDescuento
  WHERE dv.idSocio = @idSocio AND dd.estadoDescuento = 1;

  -- 3) Calcular importe final
  SET @importeTotalCalc = ROUND(@importeBruto * (1 - @porcTotalDescuento / 100.0), 2);

  -- 4) Vencimientos: 5 y 10 días desde hoy
  SET @fechaPrimerVto  = DATEADD(DAY, 5, @fechaEmisionHoy);
  SET @fechaSegundoVto = DATEADD(DAY, 10, @fechaEmisionHoy);

  -- 5) Insertar factura
  INSERT INTO pagos.facturaEmitida (
    idSocio, categoriaSocio,
    idServicioFacturado, descripcionServicioFacturado,
    nombreSocio, apellidoSocio,
    fechaEmision, cuilDeudor, domicilio, modalidadCobro,
    importeBruto, importeTotal,
    fechaPrimerVencimiento, fechaSegundoVencimiento,
    estadoFactura
  )
  VALUES (
    @idSocio, @categoriaSocio,
    @idServicioFacturado, @descripcionServicioFacturado,
    @nombreSocio, @apellidoSocio,
    @fechaEmisionHoy, @cuilDeudor, @domicilio, @modalidadCobro,
    @importeBruto, @importeTotalCalc,
    @fechaPrimerVto, @fechaSegundoVto,
    'Pendiente'
  );
END
GO

CREATE OR ALTER PROCEDURE pagos.actualizarEstadoFacturaEmitida
  @idFactura INT,
  @nuevoEstado VARCHAR(10)
AS
BEGIN
  SET NOCOUNT ON;

  -- Validar nuevo estado permitido
  IF @nuevoEstado NOT IN ('Pendiente', 'Pagada')
  BEGIN
    RAISERROR('Estado no válido. Solo se permite "Pendiente" o "Pagada".', 16, 1);
    RETURN;
  END

  -- Actualizar estado solo si la factura existe
  IF NOT EXISTS (SELECT 1 FROM pagos.facturaEmitida WHERE idFactura = @idFactura)
  BEGIN
    RAISERROR('La factura con ID %d no existe.', 16, 1, @idFactura);
    RETURN;
  END

  UPDATE pagos.facturaEmitida
  SET estadoFactura = @nuevoEstado
  WHERE idFactura = @idFactura;
END
GO

CREATE OR ALTER PROCEDURE pagos.nulificarFacturaEmitida
  @idFactura INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @estadoActual VARCHAR(10);

  -- Verificar que exista
  SELECT @estadoActual = estadoFactura
  FROM pagos.facturaEmitida
  WHERE idFactura = @idFactura;

  IF @estadoActual IS NULL
  BEGIN
    RAISERROR('Factura con ID %d no encontrada.', 16, 1, @idFactura);
    RETURN;
  END

  -- Validar que no esté pagada
  IF @estadoActual = 'Pagada'
  BEGIN
    RAISERROR('No se puede nulificar una factura que ya fue pagada.', 16, 1);
    RETURN;
  END

  -- Nulificar
  UPDATE pagos.facturaEmitida
  SET estadoFactura = 'Nulificada'
  WHERE idFactura = @idFactura;
END
GO

CREATE OR ALTER PROCEDURE pagos.insertarReembolso
  @idCobroOriginal     INT,
  @idFacturaOriginal   INT,
  @idSocioDestinatario INT,
  @montoReembolsado    DECIMAL(10, 2),
  @cuilDestinatario    BIGINT,
  @medioDePagoUsado    VARCHAR(50),
  @razonReembolso      VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @totalAbonado DECIMAL(10, 2),
          @socioCobro   INT;

  -- 1) Verificar existencia del cobro
  SELECT @totalAbonado = totalAbonado,
         @socioCobro   = idSocio
  FROM pagos.cobroFactura
  WHERE idCobro = @idCobroOriginal
    AND idFacturaCobrada = @idFacturaOriginal;

  IF @totalAbonado IS NULL
  BEGIN
    RAISERROR('Cobro %d para factura %d no encontrado.', 16, 1, @idCobroOriginal, @idFacturaOriginal);
    RETURN;
  END

  -- 2) Verificar que el socio sea el destinatario del cobro original
  IF @socioCobro != @idSocioDestinatario
  BEGIN
    RAISERROR('El socio destinatario no coincide con el socio original del cobro.', 16, 1);
    RETURN;
  END

  -- 3) Validar que el monto sea razonable
  IF @montoReembolsado > @totalAbonado
  BEGIN
   DECLARE @montoStr VARCHAR(20), @abonadoStr VARCHAR(20);
	SET @montoStr = CONVERT(VARCHAR(20), @montoReembolsado);
	SET @abonadoStr = CONVERT(VARCHAR(20), @totalAbonado);

	RAISERROR('El monto reembolsado (%s) no puede exceder lo abonado (%s).', 16, 1,
          @montoStr, @abonadoStr);
  RETURN;
  END

  -- 4) (Opcional) Verificar si ya existe reembolso para este cobro
  IF EXISTS (
    SELECT 1 FROM pagos.reembolso
    WHERE idCobroOriginal = @idCobroOriginal AND idFacturaOriginal = @idFacturaOriginal
  )
  BEGIN
    RAISERROR('Ya existe un reembolso registrado para este cobro.', 16, 1);
    RETURN;
  END

  -- 5) Insertar reembolso
  INSERT INTO pagos.reembolso (
    idCobroOriginal,
    idFacturaOriginal,
    idSocioDestinatario,
    montoReembolsado,
    cuilDestinatario,
    medioDePagoUsado,
    razonReembolso
  )
  VALUES (
    @idCobroOriginal,
    @idFacturaOriginal,
    @idSocioDestinatario,
    @montoReembolsado,
    @cuilDestinatario,
    @medioDePagoUsado,
    @razonReembolso
  );
END
GO

CREATE OR ALTER PROCEDURE pagos.eliminarReembolso
  @idFacturaReembolso  INT,
  @idCobroOriginal     INT,
  @idFacturaOriginal   INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @estadoFacturaActual VARCHAR(10);

  -- Verificar existencia del reembolso
  IF NOT EXISTS (
    SELECT 1
    FROM pagos.reembolso
    WHERE idFacturaReembolso = @idFacturaReembolso
      AND idCobroOriginal = @idCobroOriginal
      AND idFacturaOriginal = @idFacturaOriginal
  )
  BEGIN
    RAISERROR('No se encontró un reembolso con los datos proporcionados.', 16, 1);
    RETURN;
  END

  -- Obtener estado actual de la factura
  SELECT @estadoFacturaActual = estadoFactura
  FROM pagos.facturaEmitida
  WHERE idFactura = @idFacturaOriginal;

  -- Verificar que la factura exista
  IF @estadoFacturaActual IS NULL
  BEGIN
    RAISERROR('Factura original %d no encontrada.', 16, 1, @idFacturaOriginal);
    RETURN;
  END

  -- Eliminar el reembolso
  DELETE FROM pagos.reembolso
  WHERE idFacturaReembolso = @idFacturaReembolso
    AND idCobroOriginal = @idCobroOriginal
    AND idFacturaOriginal = @idFacturaOriginal;

  -- Restaurar factura si estaba nulificada y NO está pagada
  IF @estadoFacturaActual = 'Nulificada'
  BEGIN
    UPDATE pagos.facturaEmitida
    SET estadoFactura = 'Pendiente'
    WHERE idFactura = @idFacturaOriginal;
  END
END
GO

-- :::::::::::::::::::::::::::::::::::::::::::: DESCUENTOS ::::::::::::::::::::::::::::::::::::::::::::

-- ### descuentoDisponible ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarDescuentoDisponible
-- ------------------------------------------------------------------------------
CREATE PROCEDURE descuentos.insertarDescuentoDisponible
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
CREATE PROCEDURE descuentos.modificarDescuentoDisponible
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
CREATE PROCEDURE descuentos.eliminarDescuentoDisponible
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
CREATE PROCEDURE descuentos.insertarDescuentoVigente
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
CREATE PROCEDURE descuentos.modificarDescuentoVigente
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
CREATE PROCEDURE descuentos.eliminarDescuentoVigente
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
CREATE PROCEDURE itinerarios.insertarDatosSUM
    @tarifaHorariaSocio DECIMAL(10, 2),
    @tarifaHorariaInvitado DECIMAL(10, 2),
    @horaMinimaReserva INT,
    @horaMaximaReserva INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
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

        -- Inserción del nuevo registro de datos SUM.
        INSERT INTO itinerarios.datosSUM (tarifaHorariaSocio, tarifaHorariaInvitado, horaMinimaReserva, horaMaximaReserva)
        VALUES (@tarifaHorariaSocio, @tarifaHorariaInvitado, @horaMinimaReserva, @horaMaximaReserva);
        PRINT 'Datos SUM insertados exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar datos SUM: ' + ERROR_MESSAGE();
        THROW;
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
    @horaMinimaReserva INT,
    @horaMaximaReserva INT
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
    @idSocio INT,
    @categoriaSocio INT,
    @categoriaPase VARCHAR(9),
    @montoTotalActividad DECIMAL(10, 2),
    @newIdReservaActividad INT OUTPUT -- Para devolver el ID generado
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validaciones básicas
        IF @idSocio < 0
        BEGIN
            THROW 50020, 'El ID de socio no puede ser negativo.', 1;
        END

        IF @categoriaSocio <= 0
        BEGIN
            THROW 50021, 'La categoría de socio debe ser un número positivo.', 1;
        END

        IF @categoriaPase NOT IN ('Dia', 'Mensual', 'Temporada')
        BEGIN
            THROW 50022, 'La categoría de pase no es válida (Dia, Mensual, Temporada).', 1;
        END

        IF @montoTotalActividad <= 0
        BEGIN
            THROW 50023, 'El monto total de la actividad debe ser un valor positivo.', 1;
        END

        -- Validar existencia de idSocio en socios.socio
        IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
        BEGIN
            THROW 50024, 'El ID de socio especificado no existe en la tabla de socios.', 1;
        END

        -- Validar existencia de categoriaSocio en socios.categoriaSocio
        IF NOT EXISTS (SELECT 1 FROM socios.categoriaSocio WHERE idCategoria = @categoriaSocio)
        BEGIN
            THROW 50025, 'La categoría de socio especificada no existe en la tabla de categorías de socio.', 1;
        END

        -- Iniciar transacción
        BEGIN TRANSACTION;

        INSERT INTO reservas.reservaPaseActividad (
            idSocio,
            categoriaSocio,
            categoriaPase,
            montoTotalActividad,
            estadoPase -- Se inserta con el valor DEFAULT 'Activo'
        )
        VALUES (@idSocio, @categoriaSocio, @categoriaPase, @montoTotalActividad);
        SET @newIdReservaActividad = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
        PRINT 'Reserva de Pase de Actividad insertada con éxito. ID: ' + CAST(@newIdReservaActividad AS VARCHAR(10));

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarReservaPaseActividad
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.modificarReservaPaseActividad
    @idReservaActividad INT,
    @idSocioOriginal INT,
    @newCategoriaSocio INT = NULL,
    @newCategoriaPase VARCHAR(9) = NULL,
    @newMontoTotalActividad DECIMAL(10, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la reserva de pase de actividad a modificar existe
        IF NOT EXISTS (SELECT 1 FROM reservas.reservaPaseActividad WHERE idReservaActividad = @idReservaActividad AND idSocio = @idSocioOriginal)
        BEGIN
            THROW 50026, 'La reserva de pase de actividad especificada no existe.', 1;
        END

        -- Validaciones para los nuevos valores
        IF @newCategoriaSocio IS NOT NULL AND @newCategoriaSocio <= 0
        BEGIN
            THROW 50027, 'La nueva categoría de socio debe ser un número positivo.', 1;
        END
        IF @newCategoriaSocio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM socios.categoriaSocio WHERE idCategoria = @newCategoriaSocio)
        BEGIN
            THROW 50028, 'La nueva categoría de socio especificada no existe en la tabla de categorías de socio.', 1;
        END

        IF @newCategoriaPase IS NOT NULL AND @newCategoriaPase NOT IN ('Dia', 'Mensual', 'Temporada')
        BEGIN
            THROW 50029, 'La nueva categoría de pase no es válida (Dia, Mensual, Temporada).', 1;
        END

        IF @newMontoTotalActividad IS NOT NULL AND @newMontoTotalActividad <= 0
        BEGIN
            THROW 50030, 'El nuevo monto total de la actividad debe ser un valor positivo.', 1;
        END

        -- Iniciar transacción
        BEGIN TRANSACTION;
        UPDATE reservas.reservaPaseActividad
        SET
            categoriaSocio = ISNULL(@newCategoriaSocio, categoriaSocio),
            categoriaPase = ISNULL(@newCategoriaPase, categoriaPase),
            montoTotalActividad = ISNULL(@newMontoTotalActividad, montoTotalActividad)
        WHERE
            idReservaActividad = @idReservaActividad
            AND idSocio = @idSocioOriginal;

        COMMIT TRANSACTION;
        PRINT 'Reserva de Pase de Actividad modificada con éxito.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarReservaPaseActividad
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.eliminarReservaPaseActividad
    @idReservaActividad INT,
    @idSocio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la reserva de pase de actividad a borrar existe y está activa
        IF NOT EXISTS (SELECT 1 FROM reservas.reservaPaseActividad WHERE idReservaActividad = @idReservaActividad AND idSocio = @idSocio AND estadoPase = 'Activo')
        BEGIN
            THROW 50031, 'La reserva de pase de actividad especificada no existe o ya está inactiva.', 1;
        END

        -- Iniciar transacción
        BEGIN TRANSACTION;
        UPDATE reservas.reservaPaseActividad
        SET estadoPase = 'Inactivo'
        WHERE idReservaActividad = @idReservaActividad
              AND idSocio = @idSocio;
        COMMIT TRANSACTION;
        PRINT 'Reserva de Pase de Actividad marcada como inactiva (borrado lógico) con éxito.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO