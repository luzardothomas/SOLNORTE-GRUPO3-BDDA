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

-- 1) Limpiar datos de prueba
DELETE FROM socios.rolVigente			WHERE idSocio > 1;
DELETE FROM pagos.cuerpoFactura			WHERE idFactura > 1;
DELETE FROM pagos.facturaEmitida		WHERE idFactura > 1;
DELETE FROM pagos.facturaActiva			WHERE idFactura > 1;
DELETE FROM actividades.deporteActivo	WHERE idSocio > 1;
DELETE FROM socios.estadoMembresiaSocio WHERE idSocio > 1;
DELETE FROM socios.socio				WHERE idSocio > 1;
DELETE FROM socios.ingresoSocio			WHERE idSocio > 1;

-- 2) Asegurar categoría de socio vigente
IF NOT EXISTS (
  SELECT 1 FROM socios.categoriaMembresiaSocio 
  WHERE tipo = 'Mayor' 
    AND estadoCategoriaSocio = 1
    AND vigenciaHasta >= CAST(GETDATE() AS DATE)
)
BEGIN
  INSERT INTO socios.categoriaMembresiaSocio
    (tipo, costoMembresia, vigenciaHasta)
  VALUES 
    ('Mayor', 25000.00, DATEADD(YEAR,1,CAST(GETDATE() AS DATE)));
END

-- 3) Asegurar deporte “Natación” vigente
IF NOT EXISTS (
  SELECT 1 FROM actividades.deporteDisponible
  WHERE descripcion = 'Natación'
    AND vigenciaHasta >= CAST(GETDATE() AS DATE)
)
BEGIN
  INSERT INTO actividades.deporteDisponible
    (descripcion, tipo, costoPorMes, vigenciaHasta)
  VALUES
    ('Natación', 'Pileta', 45000.00, DATEADD(YEAR,1,CAST(GETDATE() AS DATE)));
END

-- 4) Asegurar un rol disponible
IF NOT EXISTS (SELECT 1 FROM socios.rolDisponible WHERE idRol = 2 AND estadoRol = 1)
  INSERT INTO socios.rolDisponible (idRol, descripcion)
  VALUES (2, 'SOCIODEPOR');

-- 5) Invocar el SP de registro completo
DECLARE @newSocioId INT;
DECLARE @fechaIngreso DATE;
SET @fechaIngreso=GETDATE()
DECLARE @deportePreferido INT;
SELECT TOP 1 @deportePreferido = idDeporte
FROM actividades.deporteDisponible
WHERE descripcion = 'Natación';

EXEC socios.registrarNuevoSocio
  @fechaIngreso		  = @fechaIngreso,
  @primerUsuario      = 'ana.lopez',
  @primerContrasenia  = 'InitPass42',
  @tipoCategoriaSocio = 'Mayor',
  @dni                = '30234567',
  @cuil				  = '20-30234567-9',
  @nombre             = 'Ana',
  @apellido           = 'López',
  @email              = 'ana.lopez@mail.com',
  @fechaNacimiento    = '1990-07-20',
  @telefonoContacto   = '1155667788',
  @telefonoEmergencia = '1199776655',
  @nombreObraSocial   = 'OS Salud',
  @nroSocioObraSocial = 'OS67890',
  @usuario            = 'ana.lopez',
  @contrasenia        = 'UserPass42',
  @direccion          = 'Av. Siempre Viva 742',
  @deportePreferido	  = @deportePreferido,
  @rolAsignar         = 2,
  @newIdSocio         = @newSocioId OUTPUT;

PRINT '>> Nuevo Socio ID: ' + CAST(@newSocioId AS VARCHAR(10));

-- 2) Asegurar categorías vigentes: Cadete, Menor, Mayor
MERGE INTO socios.categoriaMembresiaSocio AS T
USING (VALUES
	  ('Cadete', 15000.00, DATEADD(YEAR,1,GETDATE())),
	  ('Menor', 10000.00, DATEADD(YEAR,1,GETDATE())),
	  ('Mayor', 25000.00, DATEADD(YEAR,1,GETDATE()))
) AS S(tipo,costo,vig)
ON T.tipo = S.tipo
WHEN MATCHED THEN
  UPDATE SET T.costoMembresia = S.costo, T.vigenciaHasta = S.vig, T.estadoCategoriaSocio = 1
WHEN NOT MATCHED THEN
  INSERT(tipo,costoMembresia,vigenciaHasta,estadoCategoriaSocio)
  VALUES (S.tipo,S.costo,S.vig,1);
GO

-- 3) Asegurar deportes vigentes: Natación, Fútbol, Yoga
MERGE INTO actividades.deporteDisponible AS T
USING (VALUES
  ('Natación','Pileta', 45000.00,	DATEADD(YEAR,1,GETDATE())),
  ('Fútbol','Campo', 600.00,		DATEADD(YEAR,1,GETDATE())),
  ('Yoga','Sala', 400.00,			DATEADD(YEAR,1,GETDATE()))
) AS S(descr,tipo,costo,vig)
ON T.descripcion = S.descr
WHEN MATCHED THEN
  UPDATE SET T.tipo = S.tipo, T.costoPorMes = S.costo, T.vigenciaHasta = S.vig
WHEN NOT MATCHED THEN
  INSERT(descripcion,tipo,costoPorMes,vigenciaHasta)
  VALUES (S.descr,S.tipo,S.costo,S.vig);
GO

-- 4) Asegurar rol disponible: 1=Socio, 2=Deportista, 3=Instructor
MERGE INTO socios.rolDisponible AS T
USING (VALUES
  (1,'Socio'),
  (2,'Deportista'),
  (3,'Instructor')
) AS S(id,descr)
ON T.idRol = S.id
WHEN MATCHED THEN
  UPDATE SET T.descripcion = S.descr, T.estadoRol = 1
WHEN NOT MATCHED THEN
  INSERT(idRol,descripcion,estadoRol)
  VALUES (S.id,S.descr,1);
GO

-- 5) Variables comunes
DECLARE @newSocio INT,
        @depNata INT = (SELECT idDeporte FROM actividades.deporteDisponible WHERE descripcion='Natación'),
        @depFut  INT = (SELECT idDeporte FROM actividades.deporteDisponible WHERE descripcion='Fútbol'),
        @depYoga INT = (SELECT idDeporte FROM actividades.deporteDisponible WHERE descripcion='Yoga'),
		@fechaIngreso DATE = GETDATE();

-- 6) Tres registros distintos
EXEC socios.registrarNuevoSocio
  @fechaIngreso       = @fechaIngreso,
  @primerUsuario      = 'luis.perez',
  @primerContrasenia  = 'InitLP1',
  @tipoCategoriaSocio = 'Cadete',
  @dni                = '44391352',
  @cuil               = '20-44391352-2',
  @nombre             = 'Luis',
  @apellido           = 'Pérez',
  @email              = 'luis.perez@mail.com',
  @fechaNacimiento    = '2008-05-21',
  @telefonoContacto   = '1120001111',
  @telefonoEmergencia = '1190001111',
  @nombreObraSocial   = 'OS Juvenil',
  @nroSocioObraSocial = 'OSJ123',
  @usuario            = 'luis.p',
  @contrasenia        = 'passLP1',
  @direccion          = 'Calle A 123',
  @deportePreferido   = @depNata,
  @rolAsignar         = 2,
  @newIdSocio         = @newSocio OUTPUT;
PRINT 'Socio Cadete ID=' + CAST(@newSocio AS VARCHAR);

SET @fechaIngreso=GETDATE()
EXEC socios.registrarNuevoSocio
  @fechaIngreso       = @fechaIngreso,
  @primerUsuario      = 'maria.gomez',
  @primerContrasenia  = 'InitMG2',
  @tipoCategoriaSocio = 'Menor',
  @dni                = '30122333',
  @cuil               = '27-30122333-7',
  @nombre             = 'María',
  @apellido           = 'Gómez',
  @email              = 'maria.gomez@mail.com',
  @fechaNacimiento    = '2005-11-10',
  @telefonoContacto   = '1120002222',
  @telefonoEmergencia = '1190002222',
  @nombreObraSocial   = 'OS Menor',
  @nroSocioObraSocial = 'OSM456',
  @usuario            = 'maria.g',
  @contrasenia        = 'passMG2',
  @direccion          = 'Calle B 456',
  @deportePreferido   = @depFut,
  @rolAsignar         = 2,
  @newIdSocio         = @newSocio OUTPUT;
PRINT 'Socio Menor ID=' + CAST(@newSocio AS VARCHAR);

SET @fechaIngreso=GETDATE()
EXEC socios.registrarNuevoSocio
  @fechaIngreso       = @fechaIngreso,
  @primerUsuario      = 'carlos.sanchez',
  @primerContrasenia  = 'InitCS3',
  @tipoCategoriaSocio = 'Mayor',
  @dni                = '30133444',
  @cuil               = '23-30133444-3',
  @nombre             = 'Carlos',
  @apellido           = 'Sánchez',
  @email              = 'carlos.sanchez@mail.com',
  @fechaNacimiento    = '1980-02-28',
  @telefonoContacto   = '1120003333',
  @telefonoEmergencia = '1190003333',
  @nombreObraSocial   = 'OS Adulto',
  @nroSocioObraSocial = 'OSA789',
  @usuario            = 'carlos.s',
  @contrasenia        = 'passCS3',
  @direccion          = 'Calle C 789',
  @deportePreferido   = @depYoga,
  @rolAsignar         = 3,
  @newIdSocio         = @newSocio OUTPUT;
PRINT 'Socio Mayor ID=' + CAST(@newSocio AS VARCHAR);

-- 7) Verificación rápida
SELECT idSocio, categoriaSocio, nombre, apellido    FROM socios.socio				WHERE idSocio > 0;
SELECT *                                            FROM pagos.cuerpoFactura		WHERE idFactura > 0;
SELECT *                                            FROM actividades.deporteActivo;
SELECT *                                            FROM socios.rolVigente;
GO

-- ********************************************************************************
-- CARGAR DATOS DE SOCIOS PARA LOS IMPORTS
-- ********************************************************************************

-- Desactivar temporalmente las restricciones de clave foránea para la inserción masiva
ALTER TABLE socios.socio NOCHECK CONSTRAINT FK_socio_categoria;
GO

INSERT INTO socios.socio (
    idSocio, categoriaSocio, nombre, apellido, dni, email, fechaNacimiento, telefonoContacto, telefonoEmergencia, nombreObraSocial, nroSocioObraSocial, usuario, contrasenia, direccion
) VALUES
(4028, 1, 'PATRICIA A', 'SANDOVAL', '232359550', 'SANDOVAL_PATRICIA A @email.com', '1990-07-25', '1120639588', '1120639608', 'OSMTT', 'OTT-2585', NULL, NULL, NULL),
(4030, 1, 'Mariela', 'NANIN', '232475210', 'NANIN_ Mariela@email.com', '1991-01-12', '1120639590', '1120639610', 'OSPACP', '147858', NULL, NULL, NULL),
(4114, 1, 'OSNAGHI ANDREA', 'LORENA', '232738140', 'LORENA_OSNAGHI ANDREA@email.com', '1990-05-03', '1120639674', '1120639694', 'Sancor Salud.', 'SS-85741', NULL, NULL, NULL),
(4055, 1, 'ALEJANDRA', 'PAULETTE', '232850890', 'PAULETTE_ ALEJANDRA@email.com', '1990-11-16', '1120639615', '1120639635', 'Omint', 'O125874', NULL, NULL, NULL),
(4115, 1, 'LUCIANA VANESA', 'FERNANDEZ LOPEZ', '233038280', 'FERNANDEZ LOPEZ_LUCIANA VANESA @email.com', '1990-03-06', '1120639675', '1120639695', 'OSPROTURA', '698524', NULL, NULL, NULL),
(4065, 1, 'JAIME DANIEL', 'MORENO', '233329760', 'MORENO_JAIME DANIEL @email.com', '1990-02-08', '1120639625', '1120639645', 'OSPIFSE', '1258747', NULL, NULL, NULL),
(4046, 1, 'Santiago', 'Latrecchiana', '233424100', 'Latrecchiana_Santiago@email.com', '1990-05-26', '1120639606', '1120639626', 'OSPIFSE', '1258746', NULL, NULL, NULL),
(4089, 1, 'PAMELA GABRIELA', 'MINO', '233429380', 'MINO_PAMELA GABRIELA@email.com', '1991-12-11', '1120639649', '1120639669', 'Hominis', 'H-1245', NULL, NULL, NULL),
(4034, 1, 'SILVIO IVAN', 'MENES', '233481990', 'MENES_SILVIO IVAN@email.com', '1990-09-10', '1120639594', '1120639614', 'Swiss Medical', '2589655', NULL, NULL, NULL),
(4090, 1, 'ALEJANDRA GABRIELA', 'SALEMME', '233553600', 'SALEMME_ALEJANDRA GABRIELA @email.com', '1991-08-12', '1120639650', '1120639670', 'Medifé', 'ME-852785963', NULL, NULL, NULL),
(4004, 1, 'SAMANTA L', 'GARCIA', '233816799', 'GARCIA_ SAMANTA L@email.com', '1991-04-03', '1120639564', '1120639584', 'OSAMOC', 'MCO-698521', NULL, NULL, NULL),
(4091, 1, 'FLAVIA MIRIAM', 'GIRA', '242455860', 'GIRA_FLAVIA MIRIAM@email.com', '1992-06-24', '1120639651', '1120639671', 'Swiss Medical', '2589658', NULL, NULL, NULL),
(4092, 1, 'PAMELA E CARABAJAL', 'GONZALEZ', '243067770', 'GONZALEZ_PAMELA E CARABAJAL@email.com', '1992-08-03', '1120639652', '1120639672', 'Medicus', 'M-125897', NULL, NULL, NULL),
(4093, 1, 'GRACIELA JUDITH', 'SANCHEZ', '243690280', 'SANCHEZ_GRACIELA JUDITH @email.com', '1993-09-06', '1120639653', '1120639673', 'Omint', 'O125874', NULL, NULL, NULL),
(4001, 1, 'SILVIA VIVIANA', 'CARNERO', '271696263', 'CARNERO_ SILVIA VIVIANA@email.com', '1985-09-05', '1120639561', '1120639581', 'OSPROTURA', '698524', NULL, NULL, NULL),
(4094, 1, 'ZURITA GLORIA R', 'SANCHEZ', '271902620', 'SANCHEZ_ZURITA GLORIA R@email.com', '1983-11-06', '1120639654', '1120639674', 'Plan de Salud Hospital Italiano', 'PS-748596', NULL, NULL, NULL),
(4116, 1, 'GLADYS BEATRIZ', 'PIZARRO', '272293780', 'PIZARRO_GLADYS BEATRIZ @email.com', '1985-07-12', '1120639676', '1120639696', 'OSMISS', 'OSM-98523', NULL, NULL, NULL),
(4117, 1, 'CARLA ELIANA', 'BRAVO', '272497690', 'BRAVO_CARLA ELIANA @email.com', '1983-11-12', '1120639677', '1120639697', 'OSTCARA', 'ASC-25841', NULL, NULL, NULL),
(4020, 1, 'EMILSE VIRGINIA', 'ACHEGA', '272506040', 'ACHEGA_ EMILSE VIRGINIA@email.com', '1982-07-06', '1120639580', '1120639600', 'OSPROTURA', '698524', NULL, NULL, NULL),
(4058, 1, 'ARACELLI MARIA A', 'MERCADO', '272563840', 'MERCADO_ARACELLI MARIA A @email.com', '1983-03-02', '1120639618', '1120639638', 'OSPROTURA', '698524', NULL, NULL, NULL),
(4118, 1, 'MALENA VIVIANA', 'ARIAS', '272586980', 'ARIAS_MALENA VIVIANA@email.com', '1982-07-15', '1120639678', '1120639698', 'OSAMOC', 'MCO-698527', NULL, NULL, NULL),
(4095, 1, 'ELIANA SOLEDAD', 'DIAZ', '272704890', 'DIAZ_ELIANA SOLEDAD @email.com', '1982-09-12', '1120639655', '1120639675', 'Sancor Salud.', 'SS-85741', NULL, NULL, NULL),
(4096, 1, 'MARIA EVA', 'FERREYRA', '272739810', 'FERREYRA_MARIA EVA @email.com', '1984-08-12', '1120639656', '1120639676', 'OSPROTURA', '698524', NULL, NULL, NULL),
(4097, 1, 'María Lorena', 'Ojeda', '272802800', 'Ojeda_María Lorena @email.com', '1984-06-12', '1120639657', '1120639677', 'OSMISS', 'OSM-98523', NULL, NULL, NULL),
(4012, 1, 'VIRGINIA SOLEDAD', 'RODRIGUEZ', '272877720', 'RODRIGUEZ_VIRGINIA SOLEDAD@email.com', '1983-07-23', '1120639572', '1120639592', 'Federada', 'FS-2587415', NULL, NULL, NULL),
(4021, 1, 'MARIANA SABRINA', 'PEREZ', '272947010', 'PEREZ_ MARIANA SABRINA@email.com', '1985-11-25', '1120639581', '1120639601', 'OSMISS', 'OSM-98523', NULL, NULL, NULL),
(4098, 1, 'PATRICIA NATALIA', 'TRINIDAD', '272968240', 'TRINIDAD_PATRICIA NATALIA@email.com', '1984-12-21', '1120639658', '1120639678', 'OSTCARA', 'ASC-25841', NULL, NULL, NULL),
(4052, 1, 'MARIA ESTER', 'ACUÑA', '272970390', 'ACUÑA_ MARIA ESTER@email.com', '1983-04-02', '1120639612', '1120639632', 'Medifé', 'ME-852785963', NULL, NULL, NULL),
(4007, 1, 'JESICA PAOLA', 'FERREYRA', '272978950', 'FERREYRA_ JESICA PAOLA@email.com', '1982-10-25', '1120639567', '1120639587', 'OSPEDICI', 'DAS-9658', NULL, NULL, NULL),
(4099, 1, 'SILVINA FERNANDA', 'YEGROS', '272979170', 'YEGROS_SILVINA FERNANDA@email.com', '1985-05-22', '1120639659', '1120639679', 'OSAMOC', 'MCO-698526', NULL, NULL, NULL),
(4066, 1, 'RUTH ELIZABETH', 'TOLOZA', '272987150', 'TOLOZA_RUTH ELIZABETH @email.com', '1983-06-11', '1120639626', '1120639646', 'OSMTT', 'OTT-2587', NULL, NULL, NULL),
(4100, 1, 'SALINAS CARMEN', 'SOLEDAD', '273049410', 'SOLEDAD_SALINAS CARMEN@email.com', '1985-09-15', '1120639660', '1120639680', 'OSPM', 'OP-25478', NULL, NULL, NULL),
(4070, 1, 'SOLANGE B', 'GONZALEZ', '273104920', 'GONZALEZ_SOLANGE B@email.com', '1984-05-12', '1120639630', '1120639650', 'Hominis', 'H-1245', NULL, NULL, NULL),
(4006, 1, 'JULIANA VANESA', 'MAIDANA', '273134447', 'MAIDANA_ JULIANA VANESA@email.com', '1985-09-08', '1120639566', '1120639586', 'OSOC', 'OUY-8547', NULL, NULL, NULL),
(4011, 1, 'JOSEFINA', 'SUAREZ', '273177970', 'SUAREZJOSEF_INA@email.com', '1985-04-13', '1120639571', '1120639591', 'OSPACP', '147857', NULL, NULL, NULL),
(4119, 1, 'NATALIA VERONICA', 'LOPEZ', '273183150', 'LOPEZ_NATALIA VERONICA@email.com', '1985-08-16', '1120639679', '1120639699', 'OSPM', 'OP-25478', NULL, NULL, NULL),
(4071, 1, 'ROSALIA ANAHI', 'ALEGRE', '273188300', 'ALEGRE_ROSALIA ANAHI@email.com', '1983-09-17', '1120639631', '1120639651', 'Medifé', 'ME-852785963', NULL, NULL, NULL),
(4010, 1, 'ANABELA E', 'SARDA', '273317650', 'SARDA_ANABELA E@email.com', '1985-08-22', '1120639570', '1120639590', 'OSEAM', 'OS-852', NULL, NULL, NULL),
(4101, 1, 'LEILA', 'CHEQUIN', '273355110', 'CHEQUIN_LEILA @email.com', '1983-07-23', '1120639661', '1120639681', 'OSOC', 'OUY-8552', NULL, NULL, NULL),
(4022, 1, 'XOANA DENISA', 'LUNA', '273372660', 'LUNA_ XOANA DENISA@email.com', '1985-05-30', '1120639582', '1120639602', 'OSTCARA', 'ASC-25841', NULL, NULL, NULL),
(4049, 1, 'SONIA GLADYS', 'TARCAYA', '273390150', 'TARCAYA_SONIA GLADYS@email.com', '1985-05-06', '1120639609', '1120639629', 'OSPACP', '147859', NULL, NULL, NULL),
(4025, 1, 'DAMARIS ELIANA', 'ZURRIAN', '273410240', 'ZURRIAN_ DAMARIS ELIANA@email.com', '1985-09-17', '1120639585', '1120639605', 'OSOC', 'OUY-8548', NULL, NULL, NULL),
(4102, 1, 'NATALIA VANESA', 'CORIA', '273429360', 'CORIA_NATALIA VANESA@email.com', '1985-06-19', '1120639662', '1120639682', 'OSPEDICI', 'DAS-9663', NULL, NULL, NULL),
(4103, 1, 'PAMELA D', 'MACIEL', '273436950', 'MACIEL_PAMELA D@email.com', '1985-05-22', '1120639663', '1120639683', 'OSPIFSE', '1258749', NULL, NULL, NULL),
(4047, 1, 'MICAELA S', 'MORALES', '273446350', 'MORALES_MICAELA S@email.com', '1984-12-24', '1120639607', '1120639627', 'OSMTT', 'OTT-2586', NULL, NULL, NULL),
(4104, 1, 'Gisele', 'Armani', '273448110', 'Armani_Gisele@email.com', '1985-08-26', '1120639664', '1120639684', 'OSMTT', 'OTT-2589', NULL, NULL, NULL),
(4105, 1, 'MARIA FERNANDA', 'VILLEGAS', '273492230', 'VILLEGAS_MARIA FERNANDA@email.com', '1985-05-11', '1120639665', '1120639685', 'OSEAM', 'OS-857', NULL, NULL, NULL),
(4026, 1, 'VANINA SOLEDAD', 'ACUÑA', '273507820', 'ACUÑA_ VANINA SOLEDAD@email.com', '1984-06-12', '1120639586', '1120639606', 'OSPEDICI', 'DAS-9659', NULL, NULL, NULL),
(4106, 1, 'deborah yanina', 'vieyra', '273529610', 'vieyra_deborah yanina@email.com', '1985-05-15', '1120639666', '1120639686', 'OSPACP', '147862', NULL, NULL, NULL),
(4107, 1, 'MARA LUCILA', 'PRUNESTI', '273537830', 'PRUNESTI_MARA LUCILA @email.com', '1985-05-17', '1120639667', '1120639687', 'Federada', 'FS-2587415', NULL, NULL, NULL),
(4108, 1, 'MARIANA G', 'GAUNA', '273546630', 'GAUNA_MARIANA G@email.com', '1984-06-18', '1120639668', '1120639688', 'Hominis', 'H-1245', NULL, NULL, NULL),
(4109, 1, 'ESTEFANIA DEL', 'POZO', '273553710', 'POZO_ESTEFANIA DEL@email.com', '1984-06-20', '1120639669', '1120639689', 'Medifé', 'ME-852785963', NULL, NULL, NULL),
(4120, 1, 'ARACELI A', 'SALINA', '273660610', 'SALINA_ARACELI A@email.com', '1984-06-24', '1120639680', '1120639700', 'OSOC', 'OUY-8553', NULL, NULL, NULL),
(4039, 1, 'MARGARITA SOLEDAD', 'SANDOVAL', '273680140', 'SANDOVAL_MARGARITA SOLEDAD@email.com', '1984-07-23', '1120639599', '1120639619', 'OSPROTURA', '698524', NULL, NULL, NULL),
(4029, 1, 'EVELYN CYNTHIA', 'ALONSO', '273755160', 'ALONSO_EVELYN CYNTHIA @email.com', '1985-05-22', '1120639589', '1120639609', 'OSEAM', 'OS-853', NULL, NULL, NULL),
(4050, 1, 'SABRINA J', 'RODRIGUEZ', '273766700', 'RODRIGUEZ_ SABRINA J@email.com', '1985-05-13', '1120639610', '1120639630', 'Federada', 'FS-2587415', NULL, NULL, NULL),
(4018, 1, 'KAREN SOLEDAD', 'POTES', '273830310', 'POTES_ KAREN SOLEDAD@email.com', '1985-09-18', '1120639578', '1120639598', 'Plan de Salud Hospital Italiano', 'PS-748596', NULL, NULL, NULL),
(4023, 1, 'SOFIA ABRIL', 'BUSTOS RODRIGUEZ', '273844530', 'BUSTOS RODRIGUEZ_ SOFIA ABRIL@email.com', '1985-05-13', '1120639583', '1120639603', 'OSAMOC', 'MCO-698522', NULL, NULL, NULL),
(4072, 1, 'MARIA B', 'ESQUIVEL', '273885930', 'ESQUIVEL_MARIA B@email.com', '1984-11-02', '1120639632', '1120639652', 'Swiss Medical', '2589657', NULL, NULL, NULL),
(4036, 1, 'GISELLE A', 'GALELLI', '274067500', 'GALELLI_GISELLE A@email.com', '1985-07-03', '1120639596', '1120639616', 'Omint', 'O125874', NULL, NULL, NULL),
(4037, 1, 'DAIANA A', 'SANDOVAL', '274169300', 'SANDOVAL_DAIANA A@email.com', '1984-08-06', '1120639597', '1120639617', 'Plan de Salud Hospital Italiano', 'PS-748596', NULL, NULL, NULL),
(4054, 1, 'MELINA ROCIO', 'LUCERO', '274837270', 'LUCERO_ MELINA ROCIO@email.com', '1985-11-02', '1120639614', '1120639634', 'Medicus', 'M-125897', NULL, NULL, NULL),
(4038, 1, 'JARA C P', 'DELGADO', '279362300', 'DELGADO_JARA C P@email.com', '1984-10-10', '1120639598', '1120639618', 'Sancor Salud.', 'SS-85741', NULL, NULL, NULL),
(4048, 1, 'DIANA VICTORIA ARCILA', 'MARTINEZ', '279543990', 'MARTINEZ_DIANA VICTORIA ARCILA@email.com', '1985-03-12', '1120639608', '1120639628', 'OSEAM', 'OS-854', NULL, NULL, NULL),
(4075, 1, 'FAUSTO', 'MALDONADO', '291830520', 'MALDONADO_FAUSTO @email.com', '1980-03-12', '1120639635', '1120639655', 'Plan de Salud Hospital Italiano', 'PS-748596', NULL, NULL, NULL),
(4076, 1, 'CUBILLA FERNANDO J', 'MEDINA', '291901700', 'MEDINA_CUBILLA FERNANDO J @email.com', '1980-07-03', '1120639636', '1120639656', 'Sancor Salud.', 'SS-85741', NULL, NULL, NULL),
(4015, 1, 'CLAUDIO FABIAN', 'MACELLARI', '292294360', 'MACELLARI_CLAUDIO FABIAN@email.com', '1980-08-06', '1120639575', '1120639595', 'Swiss Medical', '2589654', NULL, NULL, NULL),
(4060, 1, 'GUSTAVO ALBERTO', 'BANEGAS', '292297650', 'BANEGAS_GUSTAVO ALBERTO @email.com', '1980-11-06', '1120639620', '1120639640', 'OSTCARA', 'ASC-25841', NULL, NULL, NULL),
(4051, 1, 'FACUNDO N', 'ROSON', '292466330', 'ROSON_ FACUNDO N@email.com', '1980-10-25', '1120639611', '1120639631', 'Hominis', 'H-1245', NULL, NULL, NULL),
(4061, 1, 'HECTOR DIEGO', 'RODRIGUEZ', '292539690', 'RODRIGUEZ_HECTOR DIEGO @email.com', '1980-05-22', '1120639621', '1120639641', 'OSAMOC', 'MCO-698524', NULL, NULL, NULL),
(4062, 1, 'GASTON MIGUEL', 'LOPEZ', '292563830', 'LOPEZ_GASTON MIGUEL@email.com', '1980-05-30', '1120639622', '1120639642', 'OSPM', 'OP-25478', NULL, NULL, NULL),
(4077, 1, 'DIEGO GABRIEL', 'LAVIZZARI', '292564720', 'LAVIZZARI_DIEGO GABRIEL @email.com', '1980-06-14', '1120639637', '1120639657', 'OSPROTURA', '698524', NULL, NULL, NULL),
(4074, 1, 'Héctor', 'Fernandez', '292590900', 'Fernandez_Héctor@email.com', '1980-07-26', '1120639634', '1120639654', 'Omint', 'O125874', NULL, NULL, NULL),
(4063, 1, 'MARCELO MIGUEL', 'GIANETTA', '292600810', 'GIANETTA_MARCELO MIGUEL @email.com', '1980-10-22', '1120639623', '1120639643', 'OSOC', 'OUY-8550', NULL, NULL, NULL),
(4032, 1, 'ALEJANDRO ESTEBAN', 'PEDERNERA', '292619730', 'PEDERNERA_ ALEJANDRO ESTEBAN@email.com', '1980-09-06', '1120639592', '1120639612', 'Hominis', 'H-1245', NULL, NULL, NULL),
(4005, 1, 'LUCAS SALVADOR', 'ACCORINTI', '292632869', 'ACCORINTI_ LUCAS SALVADOR@email.com', '1980-08-02', '1120639565', '1120639585', 'OSPM', 'OP-25478', NULL, NULL, NULL),
(4035, 1, 'GUSTAVO ARIEL', 'CHAVEZ', '292703050', 'CHAVEZ_GUSTAVO ARIEL@email.com', '1980-04-06', '1120639595', '1120639615', 'Medicus', 'M-125897', NULL, NULL, NULL),
(4110, 1, 'CLAUDIO JOSE', 'ORMENO', '292761630', 'ORMENO_CLAUDIO JOSE @email.com', '1980-03-12', '1120639670', '1120639690', 'Swiss Medical', '2589659', NULL, NULL, NULL),
(4009, 1, 'LEANDRO ENRIQUE', 'IRIBARNE', '292780420', 'IRIBARNE_ LEANDRO ENRIQUE@email.com', '1980-08-11', '1120639569', '1120639589', 'OSMTT', 'OTT-2584', NULL, NULL, NULL),
(4033, 1, 'ALEJANDRO ALBERTO R', 'CIPRIANO', '292795130', 'CIPRIANO_ALEJANDRO ALBERTO R@email.com', '1980-06-23', '1120639593', '1120639613', 'Medifé', 'ME-852785963', NULL, NULL, NULL),
(4008, 1, 'PABLO DARIO', 'BIEN', '292844597', 'BIEN_ PABLO DARIO@email.com', '1980-05-21', '1120639568', '1120639588', 'OSPIFSE', '1258744', NULL, NULL, NULL),
(4014, 1, 'JESUS PAUL', 'MARCOS', '292879750', 'MARCOS_ JESUS PAUL@email.com', '1980-09-04', '1120639574', '1120639594', 'Medifé', 'ME-852785963', NULL, NULL, NULL),
(4078, 1, 'RICARDO ALBERTO', 'PAROL', '292936830', 'PAROL_RICARDO ALBERTO@email.com', '1980-08-06', '1120639638', '1120639658', 'OSMISS', 'OSM-98523', NULL, NULL, NULL),
(4041, 1, 'ELIAS E', 'PEDROZO', '293001110', 'PEDROZO_ELIAS E@email.com', '1981-06-03', '1120639601', '1120639621', 'OSTCARA', 'ASC-25841', NULL, NULL, NULL),
(4059, 1, 'MARTIN EMILIANO', 'VASQUEZ', '293052750', 'VASQUEZ_MARTIN EMILIANO@email.com', '1981-06-21', '1120639619', '1120639639', 'OSMISS', 'OSM-98523', NULL, NULL, NULL),
(4073, 1, 'ALEJANDRO GUILLERMO', 'ESCUDERO', '293086160', 'ESCUDERO_ALEJANDRO GUILLERMO @email.com', '1981-05-23', '1120639633', '1120639653', 'Medicus', 'M-125897', NULL, NULL, NULL),
(4080, 1, 'LUCAS MARCELO', 'BIANCHI', '293225500', 'BIANCHI_LUCAS MARCELO@email.com', '1981-11-02', '1120639640', '1120639660', 'OSAMOC', 'MCO-698525', NULL, NULL, NULL),
(4002, 1, 'SERGIO JAVIER', 'FIGUEROA', '293242468', 'FIGUEROA_ SERGIO JAVIER@email.com', '1981-07-02', '1120639562', '1120639582', 'OSMISS', 'OSM-98523', NULL, NULL, NULL),
(4013, 1, 'MAURO MARTIN', 'GONZALEZ', '293258600', 'GONZALEZ_MAURO MARTIN@email.com', '1981-05-03', '1120639573', '1120639593', 'Hominis', 'H-1245', NULL, NULL, NULL),
(4019, 1, 'DARIO PEDRO', 'SILVA', '293275960', 'SILVA_ DARIO PEDRO@email.com', '1981-11-25', '1120639579', '1120639599', 'Sancor Salud.', 'SS-85741', NULL, NULL, NULL),
(4056, 1, 'MATIAS EMANUEL', 'BERARDI', '293278160', 'BERARDI_MATIAS EMANUEL@email.com', '1981-12-06', '1120639616', '1120639636', 'Plan de Salud Hospital Italiano', 'PS-748596', NULL, NULL, NULL),
(4079, 1, 'PABLO FABIAN', 'PERRANDO', '293291070', 'PERRANDO_PABLO FABIAN@email.com', '1981-05-01', '1120639639', '1120639659', 'OSTCARA', 'ASC-25841', NULL, NULL, NULL),
(4081, 1, 'JORGE DANIEL', 'ROJAS', '293335880', 'ROJAS_JORGE DANIEL@email.com', '1981-07-02', '1120639641', '1120639661', 'OSPM', 'OP-25478', NULL, NULL, NULL),
(4045, 1, 'HUGO ALBERTO', 'GIMENEZ', '293340620', 'GIMENEZ_HUGO ALBERTO@email.com', '1981-05-03', '1120639605', '1120639625', 'OSPEDICI', 'DAS-9660', NULL, NULL, NULL),
(4067, 1, 'PABLO MARTIN', 'GONZALEZ', '293362640', 'GONZALEZ_PABLO MARTIN @email.com', '1981-08-16', '1120639627', '1120639647', 'OSEAM', 'OS-855', NULL, NULL, NULL),
(4111, 1, 'ELIAS N', 'RAMALLO', '293367480', 'RAMALLO_ELIAS N @email.com', '1981-10-20', '1120639671', '1120639691', 'Medicus', 'M-125897', NULL, NULL, NULL),
(4112, 1, 'GONZALO E', 'FRIAS', '293378190', 'FRIAS_GONZALO E @email.com', '1981-04-22', '1120639672', '1120639692', 'Omint', 'O125874', NULL, NULL, NULL),
(4068, 1, 'ADRIAN MATIAS', 'VALLEJOS', '293390680', 'VALLEJOS_ADRIAN MATIAS @email.com', '1981-08-27', '1120639628', '1120639648', 'OSPACP', '147860', NULL, NULL, NULL),
(4040, 1, 'PABLO LUIS', 'ROGGERO', '293391400', 'ROGGERO_PABLO LUIS@email.com', '1981-06-30', '1120639600', '1120639620', 'OSMISS', 'OSM-98523', NULL, NULL, NULL),
(4003, 1, 'GASTON ARIEL', 'CRUZ', '293414722', 'CRUZ_ GASTON ARIEL@email.com', '1981-06-20', '1120639563', '1120639583', 'OSTCARA', 'ASC-25841', NULL, NULL, NULL),
(4053, 1, 'WALTER DAMIAN', 'INSFRAN', '293422500', 'INSFRAN_ WALTER DAMIAN@email.com', '1981-06-23', '1120639613', '1120639633', 'Swiss Medical', '2589656', NULL, NULL, NULL),
(4113, 1, 'NICOLAS DANIEL', 'PALACIOS', '293448100', 'PALACIOS_NICOLAS DANIEL @email.com', '1981-06-24', '1120639673', '1120639693', 'Plan de Salud Hospital Italiano', 'PS-748596', NULL, NULL, NULL),
(4069, 1, 'MAXIMILIANO DAVID', 'PENKALUK', '293448110', 'PENKALUK_MAXIMILIANO DAVID @email.com', '1981-10-30', '1120639629', '1120639649', 'Federada', 'FS-2587415', NULL, NULL, NULL),
(4016, 1, 'FERNANDO DIEGO RAUL', 'QUIROZ', '293456690', 'QUIROZ_ FERNANDO DIEGO RAUL@email.com', '1982-09-16', '1120639576', '1120639596', 'Medicus', 'M-125897', NULL, NULL, NULL),
(4031, 1, 'NAHUEL SANTIAGO', 'SCARSINI', '293535780', 'SCARSINI_ NAHUEL SANTIAGO@email.com', '1982-05-16', '1120639591', '1120639611', 'Federada', 'FS-2587415', NULL, NULL, NULL),
(4057, 1, 'ALBERTO EMANUEL', 'FERNANDEZ CALDERON', '293547960', 'FERNANDEZ CALDERON_ALBERTO EMANUEL @email.com', '1982-05-14', '1120639617', '1120639637', 'Sancor Salud.', 'SS-85741', NULL, NULL, NULL),
(4082, 1, 'RODIS OSVALDO', 'PEREZ', '293568300', 'PEREZ_RODIS OSVALDO @email.com', '1982-06-17', '1120639642', '1120639662', 'OSOC', 'OUY-8551', NULL, NULL, NULL),
(4083, 1, 'MAURO GASTON', 'GONZALEZ', '293590020', 'GONZALEZ_MAURO GASTON @email.com', '1982-05-06', '1120639643', '1120639663', 'OSPEDICI', 'DAS-9662', NULL, NULL, NULL),
(4084, 1, 'EDUARDO JAVIER', 'GRISEK', '293641390', 'GRISEK_EDUARDO JAVIER @email.com', '1982-07-03', '1120639644', '1120639664', 'OSPIFSE', '1258748', NULL, NULL, NULL),
(4085, 1, 'NAHUEL FERNANDO', 'VELIZ', '293641390', 'VELIZ_NAHUEL FERNANDO @email.com', '1982-06-12', '1120639645', '1120639665', 'OSMTT', 'OTT-2588', NULL, NULL, NULL),
(4064, 1, 'FACUNDO N', 'ALFONZO', '293669870', 'ALFONZO_FACUNDO N@email.com', '1982-08-11', '1120639624', '1120639644', 'OSPEDICI', 'DAS-9661', NULL, NULL, NULL),
(4086, 1, 'LEONARDO JAVIER', 'MORANDI', '293709790', 'MORANDI_LEONARDO JAVIER @email.com', '1982-09-14', '1120639646', '1120639666', 'OSEAM', 'OS-856', NULL, NULL, NULL),
(4087, 1, 'FRANCO EZEQUIEL', 'FORMOSO', '293723850', 'FORMOSO_FRANCO EZEQUIEL@email.com', '1982-03-20', '1120639647', '1120639667', 'OSPACP', '147861', NULL, NULL, NULL),
(4024, 1, 'LEANDRO EZEQUIEL', 'NIETO', '293740660', 'NIETO_ LEANDRO EZEQUIEL@email.com', '1982-04-17', '1120639584', '1120639604', 'OSPM', 'OP-25478', NULL, NULL, NULL),
(4027, 1, 'LEANDRO AGUSTIN EZEQUIEL', 'MARQUEZ', '293842780', 'MARQUEZ_ LEANDRO AGUSTIN EZEQUIEL@email.com', '1982-10-11', '1120639587', '1120639607', 'OSPIFSE', '1258745', NULL, NULL, NULL),
(4043, 1, 'ELIAS N AYALA', 'FERNANDEZ', '293886380', 'FERNANDEZ_ELIAS N AYALA@email.com', '1982-04-16', '1120639603', '1120639623', 'OSPM', 'OP-25478', NULL, NULL, NULL),
(4017, 1, 'JUAN RAUL', 'FERRARI', '294079530', 'FERRARI_ JUAN RAUL@email.com', '1982-05-13', '1120639577', '1120639597', 'Omint', 'O125874', NULL, NULL, NULL),
(4044, 1, 'DARIO N', 'MORENO', '294112990', 'MORENO_DARIO N@email.com', '1982-03-12', '1120639604', '1120639624', 'OSOC', 'OUY-8549', NULL, NULL, NULL),
(4088, 1, 'TORRANO JOSE E', 'RODRIGUEZ', '299375030', 'RODRIGUEZ_TORRANO JOSE E@email.com', '1982-09-15', '1120639648', '1120639668', 'Federada', 'FS-2587415', NULL, NULL, NULL),
(4042, 1, 'JOSE M', 'CORDONERO', '299545440', 'CORDONERO_JOSE M@email.com', '1982-04-12', '1120639602', '1120639622', 'OSAMOC', 'MCO-698523', NULL, NULL, NULL);
GO

-- Reactivar las restricciones de clave foránea (si las desactivamos al insertar, en mi caso si)
ALTER TABLE socios.socio CHECK CONSTRAINT FK_socio_categoria;
GO

-- VER DATOS CARGADOS
SELECT * FROM socios.socio ORDER BY idSocio;

-- *****************************************************************************************************
-- CARGAR DATOS EN DEPORTE ACTIVO Y MAS SOCIOS PARA LOS IMPORTS (actividades.presentismoActividadSocio)
-- *****************************************************************************************************

DELETE FROM actividades.presentismoActividadSocio;
DBCC CHECKIDENT ('actividades.presentismoActividadSocio', RESEED, 0);
DELETE FROM actividades.deporteActivo;
DBCC CHECKIDENT ('actividades.deporteActivo', RESEED, 0); 

INSERT INTO socios.socio (
    idSocio, categoriaSocio, nombre, apellido, dni, email, fechaNacimiento, telefonoContacto, telefonoEmergencia, nombreObraSocial, nroSocioObraSocial, usuario, contrasenia, direccion
) VALUES
(4148, 1, 'Nuevo', 'Socio 4148', '991480000', 'socio4148@email.com', '1995-01-01', '1112345678', '1112345679', 'Particular', 'N/A', NULL, NULL, NULL),
(4144, 1, 'Nuevo', 'Socio 4144', '991440000', 'socio4144@email.com', '1996-02-02', '1112345680', '1112345681', 'Particular', 'N/A', NULL, NULL, NULL),
(4149, 1, 'Nuevo', 'Socio 4149', '991490000', 'socio4149@email.com', '1997-03-03', '1112345682', '1112345683', 'Particular', 'N/A', NULL, NULL, NULL),
(4150, 1, 'Nuevo', 'Socio 4150', '991500000', 'socio4150@email.com', '1998-04-04', '1112345684', '1112345685', 'Particular', 'N/A', NULL, NULL, NULL),
(4129, 1, 'Nuevo', 'Socio 4129', '991290000', 'socio4129@email.com', '1999-05-05', '1112345686', '1112345687', 'Particular', 'N/A', NULL, NULL, NULL),
(4132, 1, 'Nuevo', 'Socio 4132', '991320000', 'socio4132@email.com', '2000-06-06', '1112345688', '1112345689', 'Particular', 'N/A', NULL, NULL, NULL),
(4133, 1, 'Nuevo', 'Socio 4133', '991330000', 'socio4133@email.com', '2001-07-07', '1112345690', '1112345691', 'Particular', 'N/A', NULL, NULL, NULL),
(4143, 1, 'Nuevo', 'Socio 4143', '991430000', 'socio4143@email.com', '2002-08-08', '1112345692', '1112345693', 'Particular', 'N/A', NULL, NULL, NULL),
(4154, 1, 'Nuevo', 'Socio 4154', '991540000', 'socio4154@email.com', '2003-09-09', '1112345694', '1112345695', 'Particular', 'N/A', NULL, NULL, NULL),
(4134, 1, 'Nuevo', 'Socio 4134', '991340000', 'socio4134@email.com', '2004-10-10', '1112345696', '1112345697', 'Particular', 'N/A', NULL, NULL, NULL),
(4137, 1, 'Nuevo', 'Socio 4137', '991370000', 'socio4137@email.com', '2005-11-11', '1112345698', '1112345699', 'Particular', 'N/A', NULL, NULL, NULL),
(4151, 1, 'Nuevo', 'Socio 4151', '991510000', 'socio4151@email.com', '2006-12-12', '1112345700', '1112345701', 'Particular', 'N/A', NULL, NULL, NULL),
(4145, 1, 'Nuevo', 'Socio 4145', '991450000', 'socio4145@email.com', '2007-01-13', '1112345702', '1112345703', 'Particular', 'N/A', NULL, NULL, NULL),
(4139, 1, 'Nuevo', 'Socio 4139', '991390000', 'socio4139@email.com', '2008-02-14', '1112345704', '1112345705', 'Particular', 'N/A', NULL, NULL, NULL),
(4142, 1, 'Nuevo', 'Socio 4142', '991420000', 'socio4142@email.com', '2009-03-15', '1112345706', '1112345707', 'Particular', 'N/A', NULL, NULL, NULL),
(4146, 1, 'Nuevo', 'Socio 4146', '991460000', 'socio4146@email.com', '2010-04-16', '1112345708', '1112345709', 'Particular', 'N/A', NULL, NULL, NULL),
(4141, 1, 'Nuevo', 'Socio 4141', '991410000', 'socio4141@email.com', '2011-05-17', '1112345710', '1112345711', 'Particular', 'N/A', NULL, NULL, NULL),
(4152, 1, 'Nuevo', 'Socio 4152', '991520000', 'socio4152@email.com', '2012-06-18', '1112345712', '1112345713', 'Particular', 'N/A', NULL, NULL, NULL),
(4147, 1, 'Nuevo', 'Socio 4147', '991470000', 'socio4147@email.com', '2013-07-19', '1112345714', '1112345715', 'Particular', 'N/A', NULL, NULL, NULL),
(4153, 1, 'Nuevo', 'Socio 4153', '991530000', 'socio4153@email.com', '2014-08-20', '1112345716', '1112345717', 'Particular', 'N/A', NULL, NULL, NULL),
(4127, 1, 'Nuevo', 'Socio 4127', '991270000', 'socio4127@email.com', '1990-09-21', '1112345718', '1112345719', 'Particular', 'N/A', NULL, NULL, NULL),
(4128, 1, 'Nuevo', 'Socio 4128', '991280000', 'socio4128@email.com', '1991-10-22', '1112345720', '1112345721', 'Particular', 'N/A', NULL, NULL, NULL),
(4130, 1, 'Nuevo', 'Socio 4130', '991300000', 'socio4130@email.com', '1992-11-23', '1112345722', '1112345723', 'Particular', 'N/A', NULL, NULL, NULL),
(4131, 1, 'Nuevo', 'Socio 4131', '991310000', 'socio4131@email.com', '1993-12-24', '1112345724', '1112345725', 'Particular', 'N/A', NULL, NULL, NULL),
(4135, 1, 'Nuevo', 'Socio 4135', '991350000', 'socio4135@email.com', '1994-01-25', '1112345726', '1112345727', 'Particular', 'N/A', NULL, NULL, NULL),
(4136, 1, 'Nuevo', 'Socio 4136', '991360000', 'socio4136@email.com', '1995-02-26', '1112345728', '1112345729', 'Particular', 'N/A', NULL, NULL, NULL),
(4138, 1, 'Nuevo', 'Socio 4138', '991380000', 'socio4138@email.com', '1996-03-27', '1112345730', '1112345731', 'Particular', 'N/A', NULL, NULL, NULL),
(4140, 1, 'Nuevo', 'Socio 4140', '991400000', 'socio4140@email.com', '1997-04-28', '1112345732', '1112345733', 'Particular', 'N/A', NULL, NULL, NULL),
(4122, 1, 'Nuevo', 'Socio 4122', '991220000', 'socio4122@email.com', '1998-05-29', '1112345734', '1112345735', 'Particular', 'N/A', NULL, NULL, NULL),
(4123, 1, 'Nuevo', 'Socio 4123', '991230000', 'socio4123@email.com', '1999-06-30', '1112345736', '1112345737', 'Particular', 'N/A', NULL, NULL, NULL),
(4124, 1, 'Nuevo', 'Socio 4124', '991240000', 'socio4124@email.com', '2000-07-01', '1112345738', '1112345739', 'Particular', 'N/A', NULL, NULL, NULL),
(4126, 1, 'Nuevo', 'Socio 4126', '991260000', 'socio4126@email.com', '2001-08-02', '1112345740', '1112345741', 'Particular', 'N/A', NULL, NULL, NULL);
GO

INSERT INTO actividades.deporteActivo (idSocio, idDeporte, estadoActividadDeporte, estadoMembresia) VALUES
-- Socios con Futsal (idDeporte = 1)
(4148, 1, 'Activo', 'Activo'),
(4144, 1, 'Activo', 'Activo'),
(4149, 1, 'Activo', 'Activo'),
(4150, 1, 'Activo', 'Activo'),
(4129, 1, 'Activo', 'Activo'),
(4132, 1, 'Activo', 'Activo'),
(4133, 1, 'Activo', 'Activo'),
(4143, 1, 'Activo', 'Activo'),
(4154, 1, 'Activo', 'Activo'),
(4134, 1, 'Activo', 'Activo'),
(4137, 1, 'Activo', 'Activo'),
(4151, 1, 'Activo', 'Activo'),
(4145, 1, 'Activo', 'Activo'),
(4139, 1, 'Activo', 'Activo'),
(4142, 1, 'Activo', 'Activo'),
(4146, 1, 'Activo', 'Activo'),
(4141, 1, 'Activo', 'Activo'),
(4152, 1, 'Activo', 'Activo'),
(4147, 1, 'Activo', 'Activo'),
(4153, 1, 'Activo', 'Activo'),
-- Socios con Vóley (idDeporte = 2)
(4148, 2, 'Activo', 'Activo'),
(4144, 2, 'Activo', 'Activo'),
(4149, 2, 'Activo', 'Activo'),
(4150, 2, 'Activo', 'Activo'),
(4129, 2, 'Activo', 'Activo'),
(4132, 2, 'Activo', 'Activo'),
(4133, 2, 'Activo', 'Activo'),
(4143, 2, 'Activo', 'Activo'),
(4154, 2, 'Activo', 'Activo'),
(4134, 2, 'Activo', 'Activo'),
-- Socios con Taekwondo (idDeporte = 3)
(4127, 3, 'Activo', 'Activo'),
(4128, 3, 'Activo', 'Activo'),
(4130, 3, 'Activo', 'Activo'),
(4131, 3, 'Activo', 'Activo'),
(4135, 3, 'Activo', 'Activo'),
(4136, 3, 'Activo', 'Activo'),
(4138, 3, 'Activo', 'Activo'),
(4140, 3, 'Activo', 'Activo'),
-- Socios con Baile artístico (idDeporte = 4)
(4144, 4, 'Activo', 'Activo'),
(4122, 4, 'Activo', 'Activo'),
(4123, 4, 'Activo', 'Activo'),
(4124, 4, 'Activo', 'Activo'),
(4126, 4, 'Activo', 'Activo'),
(4129, 4, 'Activo', 'Activo'),
(4131, 4, 'Activo', 'Activo'),
(4133, 4, 'Activo', 'Activo'),
-- Socios con Natación (idDeporte = 5)
(4127, 5, 'Activo', 'Activo'),
(4130, 5, 'Activo', 'Activo'),
(4132, 5, 'Activo', 'Activo'),
(4134, 5, 'Activo', 'Activo'),
(4135, 5, 'Activo', 'Activo'),
(4137, 5, 'Activo', 'Activo'),
(4139, 5, 'Activo', 'Activo'),
(4141, 5, 'Activo', 'Activo'),
(4143, 5, 'Activo', 'Activo'),
(4145, 5, 'Activo', 'Activo'),
(4147, 5, 'Activo', 'Activo'),
(4149, 5, 'Activo', 'Activo'),
(4151, 5, 'Activo', 'Activo'),
(4153, 5, 'Activo', 'Activo'),
-- Socios con Ajedrez (idDeporte = 6)
(4122, 6, 'Activo', 'Activo'),
(4123, 6, 'Activo', 'Activo'),
(4124, 6, 'Activo', 'Activo'),
(4126, 6, 'Activo', 'Activo'),
(4128, 6, 'Activo', 'Activo'),
(4136, 6, 'Activo', 'Activo'),
(4138, 6, 'Activo', 'Activo'),
(4140, 6, 'Activo', 'Activo'),
(4150, 6, 'Activo', 'Activo'),
(4152, 6, 'Activo', 'Activo'),
(4154, 6, 'Activo', 'Activo');
GO

-- VER DATOS CARGADOS
SELECT * FROM actividades.deporteActivo

-- ******************************************************************
-- CARGAR DATOS EN CUERPO FACTURA Y FACTURA ACTIVO PARA LOS REPORTES
-- ******************************************************************

DELETE FROM pagos.cuerpoFactura;
DBCC CHECKIDENT ('pagos.cuerpoFactura', RESEED, 0);
DELETE FROM pagos.facturaActiva;
DBCC CHECKIDENT ('pagos.facturaActiva', RESEED, 0);

-- Inserción de datos en pagos.facturaActiva (para 2024 y 2025)
INSERT INTO pagos.facturaActiva (idSocio, categoriaSocio, estadoFactura, fechaEmision, fechaPrimerVencimiento, fechaSegundoVencimiento) VALUES
-- Facturas de 2024 (Pagadas)
(4001, 1, 'Pagada', '2024-01-10', '2024-01-20', '2024-01-30'), -- Enero
(4002, 1, 'Pagada', '2024-01-15', '2024-01-25', '2024-02-04'),
(4003, 1, 'Pagada', '2024-02-05', '2024-02-15', '2024-02-25'), -- Febrero
(4004, 1, 'Pagada', '2024-02-20', '2024-03-01', '2024-03-11'),
(4005, 1, 'Pagada', '2024-03-12', '2024-03-22', '2024-04-01'), -- Marzo
(4006, 1, 'Pagada', '2024-03-25', '2024-04-04', '2024-04-14'),
(4007, 1, 'Pagada', '2024-04-01', '2024-04-11', '2024-04-21'), -- Abril
(4008, 1, 'Pagada', '2024-04-18', '2024-04-28', '2024-05-08'),
(4009, 1, 'Pagada', '2024-05-03', '2024-05-13', '2024-05-23'), -- Mayo
(4010, 1, 'Pagada', '2024-05-22', '2024-06-01', '2024-06-11'),
(4011, 1, 'Pagada', '2024-06-10', '2024-06-20', '2024-06-30'), -- Junio
(4012, 1, 'Pagada', '2024-06-28', '2024-07-08', '2024-07-18'),
(4013, 1, 'Pagada', '2024-07-07', '2024-07-17', '2024-07-27'), -- Julio
(4014, 1, 'Pagada', '2024-07-19', '2024-07-29', '2024-08-08'),
(4015, 1, 'Pagada', '2024-08-08', '2024-08-18', '2024-08-28'), -- Agosto
(4016, 1, 'Pagada', '2024-08-21', '2024-08-31', '2024-09-10'),
(4017, 1, 'Pagada', '2024-09-05', '2024-09-15', '2024-09-25'), -- Septiembre
(4018, 1, 'Pagada', '2024-09-17', '2024-09-27', '2024-10-07'),
(4019, 1, 'Pagada', '2024-10-10', '2024-10-20', '2024-10-30'), -- Octubre
(4020, 1, 'Pagada', '2024-10-25', '2024-11-04', '2024-11-14'),
(4021, 1, 'Pagada', '2024-11-01', '2024-11-11', '2024-11-21'), -- Noviembre
(4022, 1, 'Pagada', '2024-11-15', '2024-11-25', '2024-12-05'),
(4023, 1, 'Pagada', '2024-12-09', '2024-12-19', '2024-12-29'), -- Diciembre
(4024, 1, 'Pagada', '2024-12-20', '2024-12-30', '2025-01-09'),
-- Facturas de 2025 (Pagadas y Pendientes para mostrar filtro)
(4028, 1, 'Pagada', '2025-01-05', '2025-01-15', '2025-01-25'),
(4030, 1, 'Pagada', '2025-01-10', '2025-01-20', '2025-01-30'),
(4114, 1, 'Pendiente', '2025-01-20', '2025-01-30', '2025-02-09'), -- Pendiente, no debería aparecer en el reporte
(4055, 1, 'Pagada', '2025-02-01', '2025-02-11', '2025-02-21'),
(4115, 1, 'Pagada', '2025-02-14', '2025-02-24', '2025-03-06'),
(4065, 1, 'Pagada', '2025-03-01', '2025-03-11', '2025-03-21'),
(4046, 1, 'Pagada', '2025-03-10', '2025-03-20', '2025-03-30'),
(4089, 1, 'Pagada', '2025-04-05', '2025-04-15', '2025-04-25'),
(4034, 1, 'Pagada', '2025-04-20', '2025-04-30', '2025-05-10'),
(4090, 1, 'Pagada', '2025-05-01', '2025-05-11', '2025-05-21'),
(4004, 1, 'Pendiente', '2025-05-15', '2025-05-25', '2025-06-04'); -- Pendiente
GO

-- Inserción de datos en pagos.cuerpoFactura
-- 1. Eliminar la clave foránea existente que apunta a pagos.facturaEmitida
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK__cuerpoFac__idFac__25518C17' AND parent_object_id = OBJECT_ID('pagos.cuerpoFactura'))
BEGIN
    ALTER TABLE pagos.cuerpoFactura
    DROP CONSTRAINT FK__cuerpoFac__idFac__25518C17;
    PRINT 'Clave foránea FK__cuerpoFac__idFac__25518C17 eliminada de pagos.cuerpoFactura.';
END
GO

-- 2. Añadir una nueva clave foránea que apunte a pagos.facturaActiva
ALTER TABLE pagos.cuerpoFactura
ADD CONSTRAINT FK_cuerpoFactura_facturaActiva FOREIGN KEY (idFactura)
REFERENCES pagos.facturaActiva(idFactura);
PRINT 'Nueva clave foránea FK_cuerpoFactura_facturaActiva creada en pagos.cuerpoFactura apuntando a pagos.facturaActiva.';
GO

MERGE pagos.cuerpoFactura AS Target
USING (
    SELECT
        fa.idFactura,
        1 AS idItemFactura, -- Siempre 1, ya que cada factura tiene un solo item principal de actividad
        'Mensual' AS tipoItem,
        CASE
            WHEN fa.idFactura % 6 = 1 THEN 'Futsal'
            WHEN fa.idFactura % 6 = 2 THEN 'Vóley'
            WHEN fa.idFactura % 6 = 3 THEN 'Taekwondo'
            WHEN fa.idFactura % 6 = 4 THEN 'Baile artístico'
            WHEN fa.idFactura % 6 = 5 THEN 'Natación'
            WHEN fa.idFactura % 6 = 0 THEN 'Ajedrez'
            ELSE 'Desconocido' -- En caso de que idFactura % 6 no caiga en los casos esperados
        END AS descripcionItem,
        CASE
			WHEN fa.idFactura % 6 = 1 THEN 25000.00
            WHEN fa.idFactura % 6 = 2 THEN 30000.00
            WHEN fa.idFactura % 6 = 3 THEN 25000.00
            WHEN fa.idFactura % 6 = 4 THEN 30000.00
            WHEN fa.idFactura % 6 = 5 THEN 45000.00
            WHEN fa.idFactura % 6 = 6 THEN 2000.00
            ELSE 0.00
        END AS importeItem
    FROM
        pagos.facturaActiva fa
) AS Source (idFactura, idItemFactura, tipoItem, descripcionItem, importeItem)
ON (Target.idFactura = Source.idFactura AND Target.idItemFactura = Source.idItemFactura)
WHEN MATCHED THEN
    UPDATE SET
        Target.tipoItem = Source.tipoItem,
        Target.descripcionItem = Source.descripcionItem,
        Target.importeItem = Source.importeItem
WHEN NOT MATCHED BY TARGET THEN
    INSERT (idFactura, idItemFactura, tipoItem, descripcionItem, importeItem)
    VALUES (Source.idFactura, Source.idItemFactura, Source.tipoItem, Source.descripcionItem, Source.importeItem);
GO

-- VER DATOS CARGADOS
SELECT * FROM pagos.cuerpoFactura;
SELECT * FROM pagos.facturaActiva;

-- ******************************************************************
-- CARGAR DATOS EN ESTADO MEMBRESIA SOCIO PARA LOS REPORTES
-- ******************************************************************

-- Paso 1: Eliminar la tabla si existe para recrearla con otra estructura
IF OBJECT_ID('socios.estadoMembresiaSocio', 'U') IS NOT NULL
BEGIN
    DROP TABLE socios.estadoMembresiaSocio;
    PRINT 'Tabla socios.estadoMembresiaSocio eliminada para recreación.';
END
GO

-- Paso 2: Recrear la tabla socios.estadoMembresiaSocio con otra estructura
CREATE TABLE socios.estadoMembresiaSocio (
    idSocio INT NOT NULL, -- Ya NO es IDENTITY
    tipoCategoriaSocio VARCHAR(15) CHECK (tipoCategoriaSocio IN ('Cadete', 'Mayor', 'Menor')),
    estadoMorosidadMembresia VARCHAR(22) NOT NULL CHECK (estadoMorosidadMembresia IN ('Activo', 'Moroso-1er Vencimiento', 'Moroso-2do Vencimiento', 'Inactivo')),
    fechaVencimientoMembresia DATE NOT NULL,
    CONSTRAINT PK_estadoMembresiaSocio PRIMARY KEY (idSocio, fechaVencimientoMembresia),
    FOREIGN KEY (idSocio) REFERENCES socios.socio(idSocio)
);
GO

-- Inserción de datos en socios.estadoMembresiaSocio
INSERT INTO socios.estadoMembresiaSocio (idSocio, tipoCategoriaSocio, fechaVencimientoMembresia, estadoMorosidadMembresia) VALUES
-- Socio 4001: Moroso recurrente (4 incumplimientos en 2024)
(4001, 'Mayor', '2024-01-31', 'Moroso-1er Vencimiento'),
(4001, 'Mayor', '2024-02-29', 'Moroso-1er Vencimiento'),
(4001, 'Mayor', '2024-03-31', 'Moroso-2do Vencimiento'),
(4001, 'Mayor', '2024-04-30', 'Inactivo'),
(4001, 'Mayor', '2024-05-31', 'Activo'),
(4001, 'Mayor', '2024-06-30', 'Moroso-1er Vencimiento'),
-- Socio 4002: Moroso recurrente (3 incumplimientos en 2024)
(4002, 'Mayor', '2024-01-31', 'Activo'),
(4002, 'Mayor', '2024-02-29', 'Moroso-1er Vencimiento'),
(4002, 'Mayor', '2024-03-31', 'Moroso-1er Vencimiento'),
(4002, 'Mayor', '2024-04-30', 'Moroso-2do Vencimiento'),
(4002, 'Mayor', '2024-05-31', 'Activo'),
-- Socio 4003: Moroso recurrente (4 incumplimientos en 2024)
(4003, 'Mayor', '2024-01-31', 'Moroso-1er Vencimiento'),
(4003, 'Mayor', '2024-02-29', 'Moroso-2do Vencimiento'),
(4003, 'Mayor', '2024-03-31', 'Inactivo'),
(4003, 'Mayor', '2024-04-30', 'Moroso-1er Vencimiento'),
(4003, 'Mayor', '2024-05-31', 'Activo'),
-- Socio 4004: Solo 2 incumplimientos (no aparecerá en el reporte con >2)
(4004, 'Mayor', '2024-01-31', 'Activo'),
(4004, 'Mayor', '2024-02-29', 'Activo'),
(4004, 'Mayor', '2024-03-31', 'Moroso-1er Vencimiento'),
(4004, 'Mayor', '2024-04-30', 'Moroso-2do Vencimiento'),
(4004, 'Mayor', '2024-05-31', 'Activo'),
-- Socio 4005: Sin incumplimientos en 2024
(4005, 'Mayor', '2024-01-31', 'Activo'),
(4005, 'Mayor', '2024-02-29', 'Activo'),
(4005, 'Mayor', '2024-03-31', 'Activo'),
(4005, 'Mayor', '2024-04-30', 'Activo'),
(4005, 'Mayor', '2024-05-31', 'Activo'),
-- Socio 4006: Moroso recurrente (3 incumplimientos en 2024, mezclado con 2025)
(4006, 'Mayor', '2024-01-31', 'Moroso-1er Vencimiento'),
(4006, 'Mayor', '2024-02-29', 'Activo'),
(4006, 'Mayor', '2024-03-31', 'Moroso-2do Vencimiento'),
(4006, 'Mayor', '2024-04-30', 'Activo'),
(4006, 'Mayor', '2024-05-31', 'Inactivo'),
(4006, 'Mayor', '2025-01-31', 'Moroso-1er Vencimiento'),
-- Socio 4007: Moroso recurrente (3 incumplimientos en 2025)
(4007, 'Mayor', '2025-01-31', 'Moroso-1er Vencimiento'),
(4007, 'Mayor', '2025-02-28', 'Moroso-1er Vencimiento'),
(4007, 'Mayor', '2025-03-31', 'Moroso-2do Vencimiento'),
(4007, 'Mayor', '2025-04-30', 'Activo');
GO

-- VER DATOS CARGADOS
SELECT * FROM socios.estadoMembresiaSocio;