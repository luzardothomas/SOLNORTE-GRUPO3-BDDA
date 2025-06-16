----------------------------------------------------------------------------------------------------
-- Fecha de entrega: 15-06-2025
-- Numero de grupo: 3
-- Materia: Bases de Datos Aplicada
-- Alumnos:
--   - Codina, Santiago Ivan - 44.391.352
--   - Santillan, Lautaro Ezequiel - 45.175.053
----------------------------------------------------------------------------------------------------

-- Crear la base de datos SolNorte_Grupo3
CREATE DATABASE SolNorte_Grupo3;
GO
-- Usar la base de datos SolNorte_Grupo3
USE SolNorte_Grupo3;
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
    dni varchar(8) NOT NULL,
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
	parentescoGrupoFamiliar VARCHAR(10) NOT NULL,
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
	dniReservante INT NOT NULL,
	horaInicioReserva INT NOT NULL,
	horaFinReserva INT NOT NULL,
	tarifaFinal DECIMAL(10, 2) CHECK (tarifaFinal > 0) NOT NULL,
	CONSTRAINT PK_reservasSUM PRIMARY KEY (idReserva, idSocio, dniReservante),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
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

CREATE OR ALTER FUNCTION socios.validarDNI(@dni VARCHAR(15))
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

PRINT '--- Pruebas de Inserción ---';

-- 2.1 inserción válida
EXEC socios.insertarCategoriaSocio @tipo = 'Cadete', @costoMembresia = 25000.00;

-- 2.2 inserción con costo inválido (negativo) -> falla por CHECK de tabla
BEGIN TRY
    EXEC socios.insertarCategoriaSocio @tipo = 'Mayor', @costoMembresia = -50.00;
END TRY
BEGIN CATCH
    PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH;

-- 2.3 inserción con tipo vacío -> falla por SP
BEGIN TRY
    EXEC socios.insertarCategoriaSocio @tipo = '', @costoMembresia = 50.00;
END TRY
BEGIN CATCH
    PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH;
GO

--socio

CREATE OR ALTER PROCEDURE socios.insertarSocio
  @categoriaSocio             INT,
  @dni                        BIGINT,
  @cuil                       BIGINT,
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
  @dni                        BIGINT           = NULL,
  @cuil                       BIGINT           = NULL,
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

PRINT '*** INSERCIÓN VÁLIDA ***';
EXEC socios.insertarSocio
    @categoriaSocio = 1,
    @dni = '12345678',
    @cuil = '20-12345678-3',
    @nombre = 'Juan',
    @apellido = 'Perez',
    @usuario = 'juan.perez',
    @contrasenia = 'abc123';

PRINT '*** DNI INVÁLIDO (demasiado corto) ***';
BEGIN TRY
    EXEC socios.insertarSocio
        @categoriaSocio = 1,
        @dni = '123456',
        @cuil = '20-12345678-3',
        @nombre = 'Ana',
        @apellido = 'Gomez',
        @usuario = 'ana.gomez',
        @contrasenia = 'pass';
END TRY BEGIN CATCH
    PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH;

PRINT '*** CUIL INVÁLIDO (checksum incorrecto) ***';
BEGIN TRY
    EXEC socios.insertarSocio
        @categoriaSocio = 1,
        @dni = '87654321',
        @cuil = '27-87654321-0',
        @nombre = 'Luis',
        @apellido = 'Lopez',
        @usuario = 'luis.lopez',
        @contrasenia = 'pass';
END TRY BEGIN CATCH
    PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH;

PRINT '*** CATEGORÍA INEXISTENTE ***';
BEGIN TRY
    EXEC socios.insertarSocio
        @categoriaSocio = 99,
        @dni = '11223344',
        @cuil = '23-11223344-2',
        @nombre = 'Carlos',
        @apellido = 'Diaz',
        @usuario = 'carlos.diaz',
        @contrasenia = 'pass';
END TRY BEGIN CATCH
    PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH;

PRINT '*** ACTUALIZACIÓN VÁLIDA: nombre y nueva contraseña ***';
EXEC socios.actualizarSocio
    @idSocio = 1,
    @categoriaSocio = 1,
    @nombre = 'Juan Carlos',
    @contraseniaNueva = 'xyz789';

PRINT '*** ACTUALIZACIÓN ERROR: DNI inválido ***';
BEGIN TRY
    EXEC socios.actualizarSocio
        @idSocio = 1,
        @categoriaSocio = 1,
        @dni = 'abc1234';
END TRY BEGIN CATCH
    PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH;

PRINT '*** ACTUALIZACIÓN ERROR: socio inexistente ***';
BEGIN TRY
    EXEC socios.actualizarSocio
        @idSocio = 99,
        @categoriaSocio = 1,
        @nombre = 'Inexistente';
END TRY BEGIN CATCH
    PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH;

PRINT '*** BORRADO LÓGICO VÁLIDO ***';
EXEC socios.eliminarSocioLogico
    @idSocio = 1,
    @categoriaSocio = 1;

PRINT '*** BORRADO ERROR: socio ya inactivo/inexistente ***';
BEGIN TRY
    EXEC socios.eliminarSocioLogico
        @idSocio = 99,
        @categoriaSocio = 1;
END TRY BEGIN CATCH
    PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH;
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

PRINT '--- Inserción válida ---';
EXEC socios.insertarGrupoFamiliar @cantidadGrupoFamiliar = 4;

PRINT '--- Inserción inválida (0) ---';
BEGIN TRY
  EXEC socios.insertarGrupoFamiliar @cantidadGrupoFamiliar = 0;
END TRY BEGIN CATCH
  PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH;

-- =============================================
-- C) Pruebas de Actualización
-- =============================================
PRINT '--- Actualización válida (ID = 1) ---';
EXEC socios.actualizarGrupoFamiliar @idGrupoFamiliar = 1, @cantidadGrupoFamiliar = 5;

PRINT '--- Actualización inválida (cantidad negativa) ---';
BEGIN TRY
  EXEC socios.actualizarGrupoFamiliar @idGrupoFamiliar = 1, @cantidadGrupoFamiliar = -3;
END TRY BEGIN CATCH
  PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH;

PRINT '--- Actualización inválida (ID inexistente) ---';
BEGIN TRY
  EXEC socios.actualizarGrupoFamiliar @idGrupoFamiliar = 99, @cantidadGrupoFamiliar = 2;
END TRY BEGIN CATCH
  PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH;

-- =============================================
-- D) Pruebas de Eliminación
-- =============================================
PRINT '--- Eliminación válida (ID = 1) ---';
EXEC socios.eliminarGrupoFamiliar @idGrupoFamiliar = 1;

PRINT '--- Eliminación inválida (ID inexistente) ---';
BEGIN TRY
  EXEC socios.eliminarGrupoFamiliar @idGrupoFamiliar = 99;
END TRY BEGIN CATCH
  PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH;

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