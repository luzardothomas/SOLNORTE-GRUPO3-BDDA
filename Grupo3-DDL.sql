----------------------------------------------------------------------------------------------------
-- Fecha de entrega: 19-05-2025
-- N�mero de grupo: 3
-- Materia: Bases de Datos Aplicada
-- Alumnos:
--   - Codina, Santiago Ivan - 44.391.352
--   - Meynet, Mauro Fernando - 43.252.948
--   - Santillan, Lautaro Ezequiel - 45.175.053
--   - [Thomas] - [DNI]
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
CREATE TABLE socios.socio (
    idSocio INT PRIMARY KEY IDENTITY(1,1),
	dni VARCHAR(8) UNIQUE NOT NULL,
	cuil VARCHAR(11) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
	email VARCHAR(100) UNIQUE,
	telefono VARCHAR(11),
    fechaNacimiento DATE,
    fechaDeVigenciaContrase�a DATE,
	contactoDeEmergencia VARCHAR(11),
	usuario VARCHAR(50) UNIQUE,
	contrase�a VARCHAR(10),
	estadoMembresia VARCHAR(8) NOT NULL CHECK (estadoMembresia IN ('Activo', 'Moroso', 'Inactivo')),
	saldoAFavor DECIMAL(10, 2)
	-- PODRIAN IR...
    --direccion VARCHAR(100),
    --fechaAlta DATE DEFAULT GETDATE()
);
GO

CREATE TABLE actividades.actividadRecreativa (
    idActividad INT PRIMARY KEY IDENTITY(1,1), -- Aunque dice idSitio y no recuerdo el porque
	descripcion TEXT NOT NULL,
	horario INT,
	tarifaSocio DECIMAL(10, 2),
	tarifaInvitado DECIMAL(10, 2)
);
GO

CREATE TABLE actividades.deporteDisponible (
    idDeporte INT PRIMARY KEY IDENTITY(1,1), -- Corregir en el DER que solo dice "id"
    tipo VARCHAR(50) NOT NULL,
    descripcion TEXT,
	horario INT,
    costoPorMes DECIMAL(10, 2)
);
GO

CREATE TABLE actividades.deporteActivo (
    idDeporteActivo INT PRIMARY KEY IDENTITY(1,1), -- Tuve que crear este campo porque no me admitia multiples PK en una instancia
    idSocio INT NOT NULL,  -- Cambiado de dniSocio
    idDeporte INT NOT NULL,
    estadoMembresia VARCHAR(8) NOT NULL CHECK (estadoMembresia IN ('Activo', 'Moroso', 'Inactivo')),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idDeporte) REFERENCES actividades.deporteDisponible(idDeporte)
);
GO

CREATE TABLE pagos.medioDePago (
    idMedioPago INT PRIMARY KEY IDENTITY(1,1), -- Corregir en el DER que solo dice "id"
    tipo VARCHAR(50) NOT NULL,
    descripcion TEXT,
);
GO

CREATE TABLE pagos.facturaCobro (
    idFactura INT PRIMARY KEY IDENTITY(1,1),
    fechaEmision DATE DEFAULT GETDATE(), -- O "fechaFacturacion", puse Emision porque asi dice en las fact.
    fechaPrimerVencimiento DATE NOT NULL,
	fechaSegundoVencimiento DATE NOT NULL,
    cuitDeudor INT NOT NULL,
	tipoMedioDePago INT NOT NULL, -- Agregar FK en el DER
	direccion VARCHAR(100),
	tipoCobro VARCHAR(25),
	numeroCuota INT,
	servicioPagado VARCHAR(50),
	importeBruto DECIMAL(10, 2) NOT NULL,
    importeTotal DECIMAL(10, 2) NOT NULL,
	FOREIGN KEY (tipoMedioDePago) REFERENCES pagos.medioDePago(idMedioPago)
);
GO

CREATE TABLE pagos.reembolso (
    idFacturaReembolso INT PRIMARY KEY IDENTITY(1,1),
    montoReembolsado DECIMAL(10, 2) NOT NULL,
	cuitDestinatario INT NOT NULL,
	medioDePago INT
);
GO

CREATE TABLE pagos.medioEnUso (
    idPago INT PRIMARY KEY IDENTITY(1,1),
	idSocio INT NOT NULL, -- No puse DNI del socio
    idMedioDePago INT NOT NULL,
	numeroTarjeta INT,
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idMedioDePago) REFERENCES pagos.medioDePago(idMedioPago)
);
GO

CREATE TABLE coberturas.coberturaDisponible (
    idCoberturaDisponible INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(100) NOT NULL,
    descripcion TEXT
);
GO

CREATE TABLE coberturas.prepagaEnUso (
    idPrepaga INT PRIMARY KEY IDENTITY(1,1),
    idNumeroSocio INT NOT NULL,  
    idCobertura INT NOT NULL,
	-- No pude agregar el tema del DNI del socio
    FOREIGN KEY (idNumeroSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idCobertura) REFERENCES coberturas.coberturaDisponible(idCoberturaDisponible)
);
GO

CREATE TABLE socios.categoriaSocio (
    idCategoria INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(50) NOT NULL,
    costoMembresia DECIMAL(10, 2) NOT NULL
	-- Capaz nos convendr�a poner fecha de inicio y fin (si tuviera) de la categoria
);
GO

CREATE TABLE descuentos.descuento (
    idDescuento INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(100) NOT NULL,
    porcentajeDescontado DECIMAL(5, 2)
);
GO

CREATE TABLE itinerarios.itinerario (
    idItinerario INT PRIMARY KEY IDENTITY(1,1),
    dia VARCHAR(9) NOT NULL, -- Puse 9 porque el dia con m�s letras es Mi�rcoles
	idDeporteTurnoMa�ana INT,
	idDeporteTurnoTarde INT,
	idDeporteTurnoNoche INT,
	FOREIGN KEY (idDeporteTurnoMa�ana) REFERENCES actividades.deporteDisponible(idDeporte),
	FOREIGN KEY (idDeporteTurnoTarde) REFERENCES actividades.deporteDisponible(idDeporte),
	FOREIGN KEY (idDeporteTurnoNoche) REFERENCES actividades.deporteDisponible(idDeporte)
);
GO

CREATE TABLE tutorACargo (
    dniTutor INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
	email VARCHAR(100) UNIQUE,
	telefono VARCHAR(11),
	parentescoConMenor VARCHAR(10)
);
GO

CREATE TABLE socios.rolVigente (
    idRol INT PRIMARY KEY IDENTITY(1,1),
    descripcion TEXT
	-- Capaz podr�an ir tambi�n para tener una relaci�n entre el rol y el socio en cuesti�n
	-- idSocioReferido INT NOT NULL,
    -- FOREIGN KEY (idSocioReferido) REFERENCES socios.socio(idSocio)
);
GO