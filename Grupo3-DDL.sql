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

SELECT * FROM socios.socio

-- Creación de tablas
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

CREATE TABLE actividades.actividadRecreativa (
    idActividad INT PRIMARY KEY IDENTITY(1,1),
	descripcion VARCHAR(50) NOT NULL,
	horaInicio VARCHAR(50) NOT NULL,
	horaFin VARCHAR(50) NOT NULL,
	tarifaSocio DECIMAL(10, 2) CHECK (tarifaSocio > 0),
	tarifaInvitado DECIMAL(10, 2) CHECK (tarifaInvitado > 0)
);
GO

CREATE TABLE actividades.deporteDisponible (
    idDeporte INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    costoPorMes DECIMAL(10, 2) CHECK (costoPorMes > 0)
);
GO

CREATE TABLE actividades.deporteActivo (
    idDeporteActivo INT PRIMARY KEY IDENTITY(1,1),
    idSocio INT NOT NULL,
    idDeporte INT NOT NULL,
    estadoMembresia VARCHAR(8) NOT NULL CHECK (estadoMembresia IN ('Activo', 'Moroso', 'Inactivo')),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idDeporte) REFERENCES actividades.deporteDisponible(idDeporte)
);
GO

CREATE TABLE itinerarios.itinerario (
    idItinerario INT PRIMARY KEY IDENTITY(1,1),
    dia VARCHAR(9) NOT NULL,
	idDeporte INT NOT NULL,
	horaInicio VARCHAR(50) NOT NULL,
	horaFin VARCHAR(50) NOT NULL,
	FOREIGN KEY (idDeporte) REFERENCES actividades.deporteDisponible(idDeporte),
);
GO

CREATE TABLE pagos.medioDePago (
    idMedioDePago INT NOT NULL,
    tipoMedioDePago VARCHAR(50) NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
	CONSTRAINT PKMediosDePago PRIMARY KEY (idMedioDePago,tipoMedioDePago)
);
GO

CREATE TABLE pagos.facturaCobro (
    idFactura INT PRIMARY KEY IDENTITY(1,1),
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
	CONSTRAINT FKFacturaCobro FOREIGN KEY (idMedioDePago,tipoMedioDePago) REFERENCES pagos.medioDePago(idMedioDePago,tipoMedioDePago) -- FK X2
);
GO

CREATE TABLE pagos.reembolso (
    idFacturaReembolso INT NOT NULL IDENTITY(1,1),
	idFacturaOriginal INT NOT NULL,
    montoReembolsado DECIMAL(10, 2) NOT NULL CHECK (montoReembolsado > 0),
	cuitDestinatario BIGINT NOT NULL CHECK (cuitDestinatario > 0),
	medioDePago VARCHAR(50) NOT NULL,
	CONSTRAINT PKReembolso PRIMARY KEY (idFacturaReembolso,idFacturaOriginal),
	CONSTRAINT FKReembolso FOREIGN KEY (idFacturaOriginal) REFERENCES pagos.facturaCobro(idFactura)
);
GO

CREATE TABLE pagos.medioEnUso (
    idPago INT PRIMARY KEY IDENTITY(1,1),
	idSocio INT NOT NULL,
    idMedioDePago INT NOT NULL,
	tipoMedioDePago VARCHAR(50) NOT NULL,
	numeroTarjeta BIGINT CHECK (numeroTarjeta > 0),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idMedioDePago,tipoMedioDePago) REFERENCES pagos.medioDePago(idMedioDePago,tipoMedioDePago)
);
GO

CREATE TABLE coberturas.coberturaDisponible (
    idCoberturaDisponible INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(50) NOT NULL
);
GO

CREATE TABLE coberturas.prepagaEnUso (
    idPrepaga INT PRIMARY KEY IDENTITY(1,1),
    idNumeroSocio INT NOT NULL,  
    idCobertura INT NOT NULL,
    FOREIGN KEY (idNumeroSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idCobertura) REFERENCES coberturas.coberturaDisponible(idCoberturaDisponible)
);
GO

CREATE TABLE socios.categoriaSocio (
    idCategoria INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(50) NOT NULL,
    costoMembresia DECIMAL(10, 2) NOT NULL CHECK (costoMembresia > 0)
);
GO

CREATE TABLE descuentos.descuento (
    idDescuento INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(100) NOT NULL,
    porcentajeDescontado DECIMAL(5, 2) CHECK (porcentajeDescontado > 0)
);
GO

CREATE TABLE socios.tutorACargo (
    dniTutor BIGINT CHECK (dniTutor > 0) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
	email VARCHAR(100) UNIQUE,
	telefono VARCHAR(11),
	parentescoConMenor VARCHAR(10)
);
GO

CREATE TABLE socios.rolDisponible (
    idRol INT NOT NULL CHECK (idRol > 0) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);
GO

CREATE TABLE socios.rolVigente (
    idRol INT NOT NULL CHECK (idRol > 0),
	idSocio INT NOT NULL CHECK (idSocio > 0),
	CONSTRAINT PKRolVigente PRIMARY KEY (idRol,idSocio),
    FOREIGN KEY (idRol) REFERENCES socios.rolDisponible(idRol),
	FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);
GO