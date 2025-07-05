USE Com2900G03;
GO

-- 1) Limpiar datos de prueba
DELETE FROM socios.rolVigente       WHERE idSocio > 1;
DELETE FROM pagos.cuerpoFactura    WHERE idFactura > 1;
DELETE FROM pagos.facturaEmitida    WHERE idFactura > 1;
DELETE FROM pagos.facturaActiva     WHERE idFactura > 1;
DELETE FROM actividades.deporteActivo WHERE idSocio > 1;
DELETE FROM socios.estadoMembresiaSocio WHERE idSocio > 1;
DELETE FROM socios.socio            WHERE idSocio > 1;
DELETE FROM socios.ingresoSocio     WHERE idSocio > 1;

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
    ('Mayor', 1000.00, DATEADD(YEAR,1,CAST(GETDATE() AS DATE)));
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
    ('Natación', 'Pileta', 800.00, DATEADD(YEAR,1,CAST(GETDATE() AS DATE)));
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
  ('Cadete', 500.00, DATEADD(YEAR,1,GETDATE())),
  ('Menor', 750.00, DATEADD(YEAR,1,GETDATE())),
  ('Mayor', 1000.00, DATEADD(YEAR,1,GETDATE()))
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
  ('Natación','Pileta',800.00, DATEADD(YEAR,1,GETDATE())),
  ('Fútbol','Campo',600.00,   DATEADD(YEAR,1,GETDATE())),
  ('Yoga','Sala',400.00,      DATEADD(YEAR,1,GETDATE()))
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
SELECT idSocio, categoriaSocio, nombre, apellido      FROM socios.socio      WHERE idSocio > 0;
SELECT *                                            FROM pagos.cuerpoFactura WHERE idFactura > 0;
SELECT *                                            FROM actividades.deporteActivo;
SELECT *                                            FROM socios.rolVigente;
GO