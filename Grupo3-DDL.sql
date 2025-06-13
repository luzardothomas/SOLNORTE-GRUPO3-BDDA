----------------------------------------------------------------------------------------------------
-- Fecha de entrega: 19-05-2025
-- Número de grupo: 3
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

CREATE SCHEMA reservas;
GO

-- Creación de tablas

-- 1.1 socios.categoriaSocio
CREATE TABLE socios.categoriaSocio (
    idCategoria INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(50) NOT NULL,
    costoMembresia DECIMAL(10, 2) NOT NULL CHECK (costoMembresia > 0)
);
GO

-- 1.2 socios.socio
CREATE TABLE socios.socio (
    idSocio INT IDENTITY(1,1),
	categoriaSocio INT NOT NULL, -- Habria que poner que categorias van
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
	fechaIngresoSocio DATE,
	fechaVencimientoMembresia DATE,
    saldoAFavor DECIMAL(10, 2) CHECK (saldoAFavor >= 0),
    direccion VARCHAR(100),
	CONSTRAINT PK_socio PRIMARY KEY (idSocio, categoriaSocio),
	FOREIGN KEY (categoriaSocio) REFERENCES socios.categoriaSocio(idCategoria)
);
GO

-- 1.3 socios.rolDisponible
CREATE TABLE socios.rolDisponible (
    idRol INT NOT NULL CHECK (idRol > 0) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);
GO

-- 1.4 socios.rolVigente
CREATE TABLE socios.rolVigente (
    idRol INT NOT NULL CHECK (idRol > 0),
    idSocio INT NOT NULL CHECK (idSocio > 0),
    CONSTRAINT PK_rolVigente PRIMARY KEY (idRol, idSocio),
    FOREIGN KEY (idRol) REFERENCES socios.rolDisponible(idRol),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 1.5 socios.grupoFamiliar
CREATE TABLE socios.grupoFamiliar (
	igGrupoFamiliar INT PRIMARY KEY IDENTITY(1,1),
	cantidadGrupoFamiliar INT NOT NULL CHECK (cantidadGrupoFamiliar > 0)
);
GO

-- 1.6 socios.grupoFamiliarActivo
CREATE TABLE socios.grupoFamiliarActivo (
	idSocio INT NOT NULL CHECK (idSocio > 0),
	igGrupoFamiliar INT NOT NULL CHECK (igGrupoFamiliar > 0),
	parentescoGrupoFamiliar VARCHAR(50) NOT NULL,
	CONSTRAINT PK_grupoFamiliarActivo PRIMARY KEY (idSocio, igGrupoFamiliar),
	FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
	FOREIGN KEY (igGrupoFamiliar) REFERENCES socios.grupoFamiliar(igGrupoFamiliar)
);
GO

-- 2.1 actividades.deporteDisponible
CREATE TABLE actividades.deporteDisponible (
	idDeporte INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(50) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
	costoPorMes DECIMAL(10, 2) CHECK (costoPorMes > 0) NOT NULL
);
GO

-- 2.2 actividades.deporteActivo
CREATE TABLE actividades.deporteActivo (
    idDeporteActivo INT PRIMARY KEY IDENTITY(1,1),
    idSocio INT NOT NULL,
    idDeporte INT NOT NULL,
	estadoActividadDeporte VARCHAR(8) NOT NULL CHECK (estadoActividadDeporte IN ('Activo', 'Inactivo')),
    estadoMorosidadSocio VARCHAR(8) NOT NULL CHECK (estadoMorosidadSocio IN ('Activo', 'Moroso', 'Inactivo')),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio),
    FOREIGN KEY (idDeporte) REFERENCES actividades.deporteDisponible(idDeporte)
);
GO

-- 2.3 actividades.actividadPileta
CREATE TABLE actividades.actividadPileta (
	idActividad INT PRIMARY KEY IDENTITY(1,1),
	tarifaSocioPorDia DECIMAL(10, 2) CHECK (tarifaSocioPorDia > 0) NOT NULL,
	tarifaInvitadoPorDia DECIMAL(10, 2) CHECK (tarifaInvitadoPorDia > 0) NOT NULL,
	horaAperturaActividad INT NOT NULL,
	horaCierreActividad INT NOT NULL
);
GO

-- 3.1 pagos.tarjetaDisponible
CREATE TABLE pagos.tarjetaDisponible (
    idTarjeta INT IDENTITY(1,1) NOT NULL,
    tipoTarjeta VARCHAR(7) NOT NULL CHECK (tipoTarjeta in ('Credito', 'Debito', 'Prepaga', 'Virtual')),
    descripcion VARCHAR(50) NOT NULL,
	CONSTRAINT PK_TarjetaDisponible PRIMARY KEY (idTarjeta, tipoTarjeta)
);
GO

-- 3.2 pagos.tarjetaEnUso
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

-- 3.3 pagos.cobroFactura
CREATE TABLE pagos.cobroFactura (
    idFacturaCobrada INT PRIMARY KEY IDENTITY(1,1),
	idSocio INT,
	categoriaSocio INT NOT NULL,
	idServicioCobrado INT NOT NULL,
	descripcionServicioCobrado VARCHAR(50) NOT NULL,
	fechaEmisionCobro DATE NOT NULL,
	nombreSocio VARCHAR(100) NOT NULL,
	apellidoSocio VARCHAR(100) NOT NULL,
    fechaEmision DATE DEFAULT GETDATE() NOT NULL,
	cuilDeudor INT NOT NULL,
	domicilio VARCHAR(100),
	modalidadCobro VARCHAR(25) NOT NULL,
	numeroCuota INT NOT NULL,
	cantidadDeportes INT NOT NULL,
	totalAbonado DECIMAL(10, 2) NOT NULL CHECK (totalAbonado >= 0),
    CONSTRAINT FK_cobroFactura FOREIGN KEY (idSocio, categoriaSocio) REFERENCES socios.socio(idSocio, categoriaSocio)
);
GO

-- 3.4 pagos.facturaEmitida
CREATE TABLE pagos.facturaEmitida (
    idFactura INT PRIMARY KEY IDENTITY(1,1),
	idSocio INT,
	categoriaSocio INT NOT NULL,
	idServicioFacturado INT NOT NULL,
	descripcionServicioFacturado VARCHAR(50) NOT NULL,
	nombreSocio VARCHAR(100) NOT NULL,
	apellidoSocio VARCHAR(100) NOT NULL,
    fechaEmision DATE DEFAULT GETDATE(),
	cuilDeudor INT NOT NULL,
	domicilio VARCHAR(100) NOT NULL,
	modalidadCobro VARCHAR(25) NOT NULL,
	subtotalCuota DECIMAL(10, 2) NOT NULL CHECK (importeBruto >= 0),
	importeTotal DECIMAL(10, 2) NOT NULL CHECK (importeTotal >= 0),
	detalleGimnasio VARCHAR(50),
	/* Incluir esto? ¿No hace falta agregar la tarjeta?
    fechaPrimerVencimiento DATE NOT NULL,
    fechaSegundoVencimiento DATE NOT NULL,
	*/
    CONSTRAINT FK_facturaEmitida FOREIGN KEY (idSocio, categoriaSocio) REFERENCES socios.socio(idSocio, categoriaSocio)
);
GO

-- 3.5 pagos.reembolso
CREATE TABLE pagos.reembolso (
    idFacturaReembolso INT NOT NULL IDENTITY(1,1),
    idFacturaOriginal INT NOT NULL,
	idSocioDestinatario INT NOT NULL,
    montoReembolsado DECIMAL(10, 2) NOT NULL CHECK (montoReembolsado > 0),
    cuilDestinatario BIGINT NOT NULL CHECK (cuitDestinatario > 0),
    medioDePagoUsado VARCHAR(50) NOT NULL,
	razonReembolso VARCHAR(50) NOT NULL,
    CONSTRAINT PK_reembolso PRIMARY KEY (idFacturaReembolso, idFacturaOriginal),
    FOREIGN KEY (idFacturaOriginal) REFERENCES pagos.facturaEmitida(idFactura),
	FOREIGN KEY (idSocioDestinatario) REFERENCES socios.socio(idSocio)
);
GO

-- 4.1 descuentos.descuentoDisponible
CREATE TABLE descuentos.descuentoDisponible (
    idDescuento INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(100) NOT NULL,
    porcentajeDescontado DECIMAL(5, 2) CHECK (porcentajeDescontado > 0)
);
GO

-- 4.2 descuentos.descuentoVigente
CREATE TABLE descuentos.descuentoVigente (
    idDescuento INT,
    idSocio INT,
	CONSTRAINT PK_descuentoVigente PRIMARY KEY (idDescuento, idSocio),
    FOREIGN KEY (idDescuento) REFERENCES descuentos.descuentoDisponible(idDescuento), 
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 5.1 itinerarios.itinerario
CREATE TABLE itinerarios.itinerario (
    idItinerario INT PRIMARY KEY IDENTITY(1,1),
    dia VARCHAR(9) NOT NULL,
    idDeporte INT NOT NULL,
    horaInicio VARCHAR(50) NOT NULL,
    horaFin VARCHAR(50) NOT NULL,
    FOREIGN KEY (idDeporte) REFERENCES actividades.deporteDisponible(idDeporte)
);
GO

-- 5.2 itinerarios.datosSum
CREATE TABLE itinerarios.datosSUM (
	idSitio INT PRIMARY KEY IDENTITY(1,1),
	tarifaHorariaSocio DECIMAL(10, 2) CHECK (tarifaHorariaSocio > 0) NOT NULL,
	tarifaHorariaInvitado DECIMAL(10, 2) CHECK (tarifaHorariaInvitado > 0) NOT NULL,
	horaMinimaReserva INT NOT NULL,
	horaMaximaReserva INT NOT NULL
);
GO

-- 6.1 coberturas.coberturaDisponible
CREATE TABLE coberturas.coberturaDisponible (
    idCoberturaDisponible INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(100) NOT NULL,
	descripcion VARCHAR(50) NOT NULL
);
GO

-- 6.2 coberturas.prepagaEnUso
CREATE TABLE coberturas.prepagaEnUso (
    idPrepaga INT PRIMARY KEY IDENTITY(1,1),
    idCobertura INT NOT NULL,
    idNumeroSocio INT NOT NULL,  
	FOREIGN KEY (idCobertura) REFERENCES coberturas.coberturaDisponible(idCoberturaDisponible),
    FOREIGN KEY (idNumeroSocio) REFERENCES socios.socio(idSocio)
);
GO

-- 7.1 reservas.reservasSum 
CREATE TABLE reservas.reservasSUM (
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

-- 7.2 reservas.reservaPaseActividad
CREATE TABLE reservas.reservaPaseActividad (
	idReservaActividad INT IDENTITY (1,1),
	idSocio INT NOT NULL CHECK (idSocio >= 0), -- Porque si no es socio y es Invitado, iria 0
	categoriaSocio INT NOT NULL,
	categoriaPase VARCHAR(9) NOT NULL CHECK (categoriaPase in ('Dia', 'Mensual', 'Temporada')),
	montoTotalActividad DECIMAL(10, 2) CHECK (montoTotalActividad > 0) NOT NULL,
	CONSTRAINT PK_reservaPaseActividad PRIMARY KEY (idReservaActividad, idSocio),
    FOREIGN KEY (idSocio, categoriaSocio) REFERENCES socios.socio(idSocio, categoriaSocio)
);
GO