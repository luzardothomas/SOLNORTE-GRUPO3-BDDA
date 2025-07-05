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

-- 6) Verificación de resultados
SELECT * 
  FROM socios.ingresoSocio 
 WHERE idSocio = @newSocioId;

SELECT * 
  FROM socios.socio 
 WHERE idSocio = @newSocioId;

SELECT * 
  FROM socios.estadoMembresiaSocio 
 WHERE idSocio = @newSocioId;

SELECT * 
  FROM pagos.facturaActiva 
 WHERE idSocio = @newSocioId;

SELECT * 
  FROM pagos.facturaEmitida 
 WHERE idFactura = (SELECT MAX(idFactura) FROM pagos.facturaActiva);

SELECT * 
  FROM pagos.cuerpoFactura 
 WHERE idFactura = (SELECT MAX(idFactura) FROM pagos.facturaActiva);

SELECT * 
  FROM actividades.deporteActivo 
 WHERE idSocio = @newSocioId;

SELECT * 
  FROM socios.rolVigente 
 WHERE idSocio = @newSocioId;
GO

SELECT * FROM actividades.deporteDisponible