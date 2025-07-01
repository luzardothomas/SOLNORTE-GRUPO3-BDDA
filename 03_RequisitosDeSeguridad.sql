----------------------------------------------------------------------------------------------------
-- Fecha de entrega: 01-07-2025
-- Numero de grupo: 3
-- Materia: Bases de Datos Aplicada
-- Alumnos:
--   - Codina, Santiago Ivan - 44.391.352
--   - Santillan, Lautaro Ezequiel - 45.175.053
----------------------------------------------------------------------------------------------------

-- Usar la base de datos
USE Com2900G03;
GO

-- =============================================
-- Creación de Roles de Base de Datos
-- =============================================

-- Roles de Tesorería
CREATE ROLE Tesoreria_JefeDeTesoreria;
CREATE ROLE Tesoreria_AdministrativoDeCobranza;
CREATE ROLE Tesoreria_AdministrativoDeMorosidad;
CREATE ROLE Tesoreria_AdministrativoDeFacturacion;

-- Roles de Socios
CREATE ROLE Socios_AdministrativoSocio;
CREATE ROLE Socios_SociosWeb; 

-- Roles de Autoridades
CREATE ROLE Autoridades_Presidente;
CREATE ROLE Autoridades_Vicepresidente;
CREATE ROLE Autoridades_Secretario;
CREATE ROLE Autoridades_Vocales;

PRINT 'Roles de base de datos creados con exito.';
GO

-- =============================================
-- Asignación de Permisos a los Roles
-- =============================================

-- 1. Roles de Tesorería

-- Tesoreria_JefeDeTesoreria: Supervisión y gestión completa de pagos, descuentos y estados financieros.
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::pagos TO Tesoreria_JefeDeTesoreria;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::descuentos TO Tesoreria_JefeDeTesoreria;
GRANT SELECT, UPDATE ON socios.saldoAFavorSocio TO Tesoreria_JefeDeTesoreria;
GRANT SELECT, UPDATE ON socios.estadoMembresiaSocio TO Tesoreria_JefeDeTesoreria;
GRANT SELECT ON SCHEMA::socios TO Tesoreria_JefeDeTesoreria; -- Para consultas generales de socios.
PRINT 'Permisos para Tesoreria_JefeDeTesoreria asignados.';

-- Tesoreria_AdministrativoDeCobranza: Registro de cobros, consulta de facturas y estados de morosidad.
GRANT INSERT ON pagos.cobroFactura TO Tesoreria_AdministrativoDeCobranza;
GRANT INSERT ON pagos.cuerpoCobro TO Tesoreria_AdministrativoDeCobranza;
GRANT SELECT ON pagos.facturaActiva TO Tesoreria_AdministrativoDeCobranza;
GRANT SELECT ON pagos.facturaEmitida TO Tesoreria_AdministrativoDeCobranza;
GRANT SELECT ON socios.estadoMembresiaSocio TO Tesoreria_AdministrativoDeCobranza;
GRANT SELECT ON socios.socio TO Tesoreria_AdministrativoDeCobranza; -- Para buscar socios.
PRINT 'Permisos para Tesoreria_AdministrativoDeCobranza asignados.';

-- Tesoreria_AdministrativoDeMorosidad: Consulta y gestión de estados de morosidad.
GRANT SELECT, UPDATE ON socios.estadoMembresiaSocio TO Tesoreria_AdministrativoDeMorosidad;
GRANT SELECT ON pagos.facturaActiva TO Tesoreria_AdministrativoDeMorosidad;
GRANT SELECT ON socios.socio TO Tesoreria_AdministrativoDeMorosidad;
PRINT 'Permisos para Tesoreria_AdministrativoDeMorosidad asignados.';

-- Tesoreria_AdministrativoDeFacturacion: Emisión y gestión de facturas.
GRANT INSERT, UPDATE, SELECT ON pagos.facturaActiva TO Tesoreria_AdministrativoDeFacturacion;
GRANT INSERT, UPDATE, SELECT ON pagos.facturaEmitida TO Tesoreria_AdministrativoDeFacturacion;
GRANT INSERT, UPDATE, SELECT ON pagos.cuerpoFactura TO Tesoreria_AdministrativoDeFacturacion;
GRANT SELECT ON socios.socio TO Tesoreria_AdministrativoDeFacturacion;
GRANT SELECT ON socios.categoriaMembresiaSocio TO Tesoreria_AdministrativoDeFacturacion;
PRINT 'Permisos para Tesoreria_AdministrativoDeFacturacion asignados.';

-- 2. Roles de Socios

-- Socios_AdministrativoSocio: Gestión completa de la información de socios, roles, grupos familiares y actividades.
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::socios TO Socios_AdministrativoSocio;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::actividades TO Socios_AdministrativoSocio;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::reservas TO Socios_AdministrativoSocio;
GRANT SELECT ON SCHEMA::coberturas TO Socios_AdministrativoSocio; -- Para asignar coberturas/prepagas.
PRINT 'Permisos para Socios_AdministrativoSocio asignados.';

-- Socios_SociosWeb: Permisos de lectura muy limitados para un portal web de socios.
GRANT SELECT ON socios.socio TO Socios_SociosWeb;
GRANT SELECT ON socios.estadoMembresiaSocio TO Socios_SociosWeb;
GRANT SELECT ON socios.saldoAFavorSocio TO Socios_SociosWeb;
GRANT SELECT ON actividades.deporteActivo TO Socios_SociosWeb;
GRANT SELECT ON actividades.presentismoActividadSocio TO Socios_SociosWeb;
GRANT SELECT ON pagos.facturaActiva TO Socios_SociosWeb;
GRANT SELECT ON pagos.facturaEmitida TO Socios_SociosWeb;
GRANT SELECT ON pagos.cobroFactura TO Socios_SociosWeb;
-- Para este rol, es importante implementar Row-Level Security (RLS) para que cada socio solo vea sus propios datos.
PRINT 'Permisos para Socios_SociosWeb asignados.';

-- 3. Roles de Autoridades

-- Autoridades Presidente: Acceso de lectura a toda la información relevante para la gestión.
GRANT SELECT ON SCHEMA::socios TO Autoridades_Presidente;
GRANT SELECT ON SCHEMA::actividades TO Autoridades_Presidente;
GRANT SELECT ON SCHEMA::pagos TO Autoridades_Presidente;
GRANT SELECT ON SCHEMA::descuentos TO Autoridades_Presidente;
GRANT SELECT ON SCHEMA::itinerarios TO Autoridades_Presidente;
GRANT SELECT ON SCHEMA::coberturas TO Autoridades_Presidente;
GRANT SELECT ON SCHEMA::reservas TO Autoridades_Presidente;
PRINT 'Permisos para Autoridades_Presidente asignados.';

-- Autoridades Vicepresidente, Secretario, Vocales: Permisos similares al Presidente (se les podria restringir algun schema si se quiere).
GRANT SELECT ON SCHEMA::socios TO Autoridades_Vicepresidente;
GRANT SELECT ON SCHEMA::actividades TO Autoridades_Vicepresidente;
GRANT SELECT ON SCHEMA::pagos TO Autoridades_Vicepresidente;
GRANT SELECT ON SCHEMA::descuentos TO Autoridades_Vicepresidente;
GRANT SELECT ON SCHEMA::itinerarios TO Autoridades_Vicepresidente;
GRANT SELECT ON SCHEMA::coberturas TO Autoridades_Vicepresidente;
GRANT SELECT ON SCHEMA::reservas TO Autoridades_Vicepresidente;
PRINT 'Permisos para Autoridades_Vicepresidente asignados.';

GRANT SELECT ON SCHEMA::socios TO Autoridades_Secretario;
GRANT SELECT ON SCHEMA::actividades TO Autoridades_Secretario;
GRANT SELECT ON SCHEMA::pagos TO Autoridades_Secretario;
GRANT SELECT ON SCHEMA::descuentos TO Autoridades_Secretario;
GRANT SELECT ON SCHEMA::itinerarios TO Autoridades_Secretario;
GRANT SELECT ON SCHEMA::coberturas TO Autoridades_Secretario;
GRANT SELECT ON SCHEMA::reservas TO Autoridades_Secretario;
PRINT 'Permisos para Autoridades_Secretario asignados.';

GRANT SELECT ON SCHEMA::socios TO Autoridades_Vocales;
GRANT SELECT ON SCHEMA::actividades TO Autoridades_Vocales;
GRANT SELECT ON SCHEMA::pagos TO Autoridades_Vocales;
GRANT SELECT ON SCHEMA::descuentos TO Autoridades_Vocales;
GRANT SELECT ON SCHEMA::itinerarios TO Autoridades_Vocales;
GRANT SELECT ON SCHEMA::coberturas TO Autoridades_Vocales;
GRANT SELECT ON SCHEMA::reservas TO Autoridades_Vocales;
PRINT 'Permisos para Autoridades_Vocales asignados.';
GO