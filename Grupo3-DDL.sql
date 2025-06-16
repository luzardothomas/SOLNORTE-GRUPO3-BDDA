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
    costoMembresia DECIMAL(10, 2) NOT NULL CHECK (costoMembresia > 0)
);
GO

-- 1.2 socios.rolDisponible
CREATE TABLE socios.rolDisponible (
    idRol INT NOT NULL CHECK (idRol > 0) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);

-- 1.3 socios.grupoFamiliar
CREATE TABLE socios.grupoFamiliar (
	igGrupoFamiliar INT PRIMARY KEY IDENTITY(1,1),
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
    porcentajeDescontado DECIMAL(5, 2) CHECK (porcentajeDescontado > 0)
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
    idSocio INT PRIMARY KEY IDENTITY(1,1),
	categoriaSocio INT NOT NULL,
    dni BIGINT NOT NULL CHECK (dni > 0),
    cuil BIGINT NOT NULL CHECK (cuil > 0),
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
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 3.2 socios.grupoFamiliarActivo
CREATE TABLE socios.grupoFamiliarActivo (
	idSocio INT NOT NULL CHECK (idSocio > 0),
	igGrupoFamiliar INT NOT NULL CHECK (igGrupoFamiliar > 0),
	parentescoGrupoFamiliar VARCHAR(10) NOT NULL,
	CONSTRAINT PK_grupoFamiliarActivo PRIMARY KEY (idSocio, igGrupoFamiliar),
	FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
	FOREIGN KEY (igGrupoFamiliar) REFERENCES socios.grupoFamiliar(igGrupoFamiliar)
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
	subtotalCuota DECIMAL(10, 2) NOT NULL CHECK (subtotalcuota >= 0),
	importeTotal DECIMAL(10, 2) NOT NULL CHECK (importeTotal >= 0),
    fechaPrimerVencimiento DATE NOT NULL,
    fechaSegundoVencimiento DATE NOT NULL,
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
    cantidadDeportes INT NOT NULL,
    totalAbonado DECIMAL(10, 2) NOT NULL CHECK (totalAbonado >= 0),
	CONSTRAINT PK_cobroFactura PRIMARY KEY (idCobro, idFacturaCobrada),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
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
    idFacturaOriginal INT NOT NULL,
    idSocioDestinatario INT NOT NULL,
    montoReembolsado DECIMAL(10, 2) NOT NULL CHECK (montoReembolsado > 0),
    cuilDestinatario BIGINT NOT NULL CHECK (cuilDestinatario > 0), -- Corregido de 'cuitDestinatario' a 'cuilDestinatario'
    medioDePagoUsado VARCHAR(50) NOT NULL,
    razonReembolso VARCHAR(50) NOT NULL,
    CONSTRAINT PK_reembolso PRIMARY KEY (idFacturaReembolso, idFacturaOriginal),
    FOREIGN KEY (idFacturaOriginal) REFERENCES pagos.facturaEmitida(idFactura),
    FOREIGN KEY (idSocioDestinatario) REFERENCES socios.socio(idSocio)
);
GO