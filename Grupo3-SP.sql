USE SolNorte_Grupo3
GO

-- :::::::::::::::::::::::::::::::::::::::::::: SOCIOS ::::::::::::::::::::::::::::::::::::::::::::

-- INSERTAR SOCIO

CREATE OR ALTER PROCEDURE socios.insertarSocio
    @dni BIGINT,
    @cuil BIGINT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @email VARCHAR(100) = NULL,
    @telefono VARCHAR(14) = NULL,
    @fechaNacimiento DATE = NULL,
    @fechaDeVigenciaContrasenia DATE = NULL,
    @contactoDeEmergencia VARCHAR(14) = NULL,
    @usuario VARCHAR(50) = NULL,
    @contrasenia VARCHAR(10) = NULL,
    @estadoMembresia VARCHAR(8),
    @saldoAFavor DECIMAL(10,2) = NULL,
	@direccion VARCHAR(100) = NULL
AS
BEGIN

	IF NOT (@dni >= 4000000 AND @dni <= 99999999)
	BEGIN
		RAISERROR('Error: DNI fuera de rango (4.000.000 - 99.999.999)', 16, 1);
		RETURN;
	END

	IF NOT (@cuil >= 2040000001 AND @cuil <= 27999999999)
	BEGIN
		RAISERROR('Error: CUIL fuera de rango (2.040.000.001 - 27.999.999.999)', 16, 1);
		RETURN;
	END

	IF NOT (LEN(@nombre) >= 3)
	BEGIN
		RAISERROR('Error: Nombre debe tener al menos 3 caracteres', 16, 1);
		RETURN;
	END

	IF NOT (LEN(@apellido) >= 3)
	BEGIN
		RAISERROR('Error: Apellido debe tener al menos 3 caracteres', 16, 1);
		RETURN;
	END

	IF NOT (@email LIKE '_%@_%._%' OR @email IS NULL)
	BEGIN
		RAISERROR('Error: Email no válido o es NULL', 16, 1);
		RETURN;
	END

	IF NOT ((LEN(@telefono) >= 10 AND LEN(@telefono) <= 14) OR  @telefono IS NULL)
	BEGIN
		RAISERROR('Error: Teléfono debe tener al menos 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF NOT ((@fechaNacimiento >= '1920-01-01' AND @fechaNacimiento <= GETDATE()) OR @fechaNacimiento IS NULL)
	BEGIN
		RAISERROR('Error: Fecha de nacimiento fuera de rango o es NULL', 16, 1);
		RETURN;
	END

	IF NOT (@fechaDeVigenciaContrasenia > GETDATE() OR @fechaDeVigenciaContrasenia IS NULL)
	BEGIN
		RAISERROR('Error: Fecha de vigencia de contraseña inválida o es NULL', 16, 1);
		RETURN;
	END

	IF NOT ((LEN(@contactoDeEmergencia) >= 10 AND LEN(@contactoDeEmergencia) <= 14) OR @contactoDeEmergencia IS NULL)
	BEGIN
		RAISERROR('Error: Contacto de emergencia debe tener al menos 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF NOT (LEN(@usuario) >= 3 OR @usuario IS NULL)
	BEGIN
		RAISERROR('Error: Usuario debe tener al menos 3 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF NOT ((LEN(@contrasenia) >= 5 AND LEN(@contrasenia) <= 10) OR @contrasenia IS NULL)
	BEGIN
		RAISERROR('Error: Contraseña debe tener entre 5 y 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF NOT (@estadoMembresia IN ('Activo', 'Moroso', 'Inactivo'))
	BEGIN
		RAISERROR('Error: Estado de membresía inválido', 16, 1);
		RETURN;
	END

	IF NOT (@saldoAFavor >= 0 OR @saldoAFavor IS NULL)
	BEGIN
		RAISERROR('Error: Saldo a favor debe ser mayor o igual a cero o NULL', 16, 1);
		RETURN;
	END

	IF NOT ((LEN(@direccion) >= 3 AND LEN(@direccion) <= 100) OR @direccion IS NULL)
	BEGIN
		RAISERROR('Error: Dirección debe tener entre 3 y 100 caracteres o ser NULL', 16, 1);
		RETURN;
	END

    INSERT INTO socios.socio
        (dni, cuil, nombre, apellido, email, telefono,
         fechaNacimiento, fechaDeVigenciaContrasenia, contactoDeEmergencia,
         usuario, contrasenia, estadoMembresia, saldoAFavor, direccion)
    VALUES
        (@dni, @cuil, @nombre, @apellido, @email, @telefono,
         @fechaNacimiento, @fechaDeVigenciaContrasenia, @contactoDeEmergencia,
         @usuario, @contrasenia, @estadoMembresia, @saldoAFavor, @direccion);

END
GO

-- MODIFICAR SOCIO

CREATE OR ALTER PROCEDURE socios.modificarSocio
    @idSocio                    INT,
    @dni                        BIGINT        = NULL,
    @cuil                       BIGINT        = NULL,
    @nombre                     VARCHAR(100)  = NULL,
    @apellido                   VARCHAR(100)  = NULL,
    @email                      VARCHAR(100)  = NULL,
    @telefono                   VARCHAR(14)   = NULL,
    @fechaNacimiento            DATE          = NULL,
    @fechaDeVigenciaContrasenia DATE          = NULL,
    @contactoDeEmergencia       VARCHAR(14)   = NULL,
    @usuario                    VARCHAR(50)   = NULL,
    @contrasenia                VARCHAR(10)   = NULL,
    @estadoMembresia            VARCHAR(8)    = NULL,
    @saldoAFavor                DECIMAL(10,2) = NULL,
    @direccion                  VARCHAR(100)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

	IF @dni IS NOT NULL AND NOT (@dni >= 4000000 AND @dni <= 99999999)
	BEGIN
		RAISERROR('Error: DNI fuera de rango (4.000.000 - 99.999.999)', 16, 1);
		RETURN;
	END

	IF @cuil IS NOT NULL AND NOT (@cuil >= 2040000001 AND @cuil <= 27999999999)
	BEGIN
		RAISERROR('Error: CUIL fuera de rango (2.040.000.001 - 27.999.999.999)', 16, 1);
		RETURN;
	END

	IF @nombre IS NOT NULL AND NOT (LEN(@nombre) >= 3)
	BEGIN
		RAISERROR('Error: Nombre debe tener al menos 3 caracteres', 16, 1);
		RETURN;
	END

	IF @apellido IS NOT NULL AND NOT (LEN(@apellido) >= 3)
	BEGIN
		RAISERROR('Error: Apellido debe tener al menos 3 caracteres', 16, 1);
		RETURN;
	END

	IF @email IS NOT NULL AND NOT (@email LIKE '_%@_%._%')
	BEGIN
		RAISERROR('Error: Email no válido o es NULL', 16, 1);
		RETURN;
	END

	IF @telefono IS NOT NULL AND NOT ((LEN(@telefono) >= 10 AND LEN(@telefono) <= 14))
	BEGIN
		RAISERROR('Error: Teléfono debe tener al menos 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF @fechaNacimiento IS NOT NULL AND NOT ((@fechaNacimiento >= '1920-01-01' AND @fechaNacimiento <= GETDATE()))
	BEGIN
		RAISERROR('Error: Fecha de nacimiento fuera de rango o es NULL', 16, 1);
		RETURN;
	END

	IF @fechaDeVigenciaContrasenia IS NOT NULL AND NOT (@fechaDeVigenciaContrasenia > GETDATE() OR @fechaDeVigenciaContrasenia IS NULL)
	BEGIN
		RAISERROR('Error: Fecha de vigencia de contraseña inválida o es NULL', 16, 1);
		RETURN;
	END

	IF @contactoDeEmergencia IS NOT NULL AND NOT ((LEN(@contactoDeEmergencia) >= 10 AND LEN(@contactoDeEmergencia) <= 14))
	BEGIN
		RAISERROR('Error: Contacto de emergencia debe tener al menos 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF @usuario IS NOT NULL AND NOT (LEN(@usuario) >= 3)
	BEGIN
		RAISERROR('Error: Usuario debe tener al menos 3 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF @contrasenia IS NOT NULL AND NOT ((LEN(@contrasenia) >= 5 AND LEN(@contrasenia) <= 10))
	BEGIN
		RAISERROR('Error: Contraseña debe tener entre 5 y 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF @estadoMembresia IS NOT NULL AND NOT (@estadoMembresia IN ('Activo', 'Moroso', 'Inactivo'))
	BEGIN
		RAISERROR('Error: Estado de membresía inválido', 16, 1);
		RETURN;
	END

	IF @saldoAFavor IS NOT NULL AND NOT (@saldoAFavor >= 0)
	BEGIN
		RAISERROR('Error: Saldo a favor debe ser mayor o igual a cero o NULL', 16, 1);
		RETURN;
	END

	IF @direccion IS NOT NULL AND NOT ((LEN(@direccion) >= 3 AND LEN(@direccion) <= 100))
	BEGIN
		RAISERROR('Error: Dirección debe tener entre 3 y 100 caracteres o ser NULL', 16, 1);
		RETURN;
	END

    UPDATE socios.socio
    SET
        dni                       = COALESCE(@dni, dni),
        cuil                      = COALESCE(@cuil, cuil),
        nombre                    = COALESCE(@nombre, nombre),
        apellido                  = COALESCE(@apellido, apellido),
        email                     = COALESCE(@email, email),
        telefono                  = COALESCE(@telefono, telefono),
        fechaNacimiento           = COALESCE(@fechaNacimiento, fechaNacimiento),
        fechaDeVigenciaContrasenia= COALESCE(@fechaDeVigenciaContrasenia, fechaDeVigenciaContrasenia),
        contactoDeEmergencia      = COALESCE(@contactoDeEmergencia, contactoDeEmergencia),
        usuario                   = COALESCE(@usuario, usuario),
        contrasenia               = COALESCE(@contrasenia, contrasenia),
        estadoMembresia           = COALESCE(@estadoMembresia, estadoMembresia),
        saldoAFavor               = COALESCE(@saldoAFavor, saldoAFavor),
        direccion                 = COALESCE(@direccion, direccion)
    WHERE idSocio = @idSocio;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No existe un socio con idSocio = %d.', 16, 1, @idSocio);
    END
END;
GO

-- ELIMINAR SOCIO

CREATE OR ALTER PROCEDURE socios.eliminarSocio
    @idSocio INT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @estadoMembresia VARCHAR(8) = (SELECT s.estadoMembresia FROM socios.socio s WHERE idSocio = @idSocio);

	IF @estadoMembresia IN('Moroso','Activo')
	BEGIN
		UPDATE socios.socio
		SET estadoMembresia = 'Inactivo'
		WHERE idSocio = @idSocio
	END
	ELSE
	BEGIN
		DELETE FROM socios.socio
		WHERE idSocio = @idSocio;
    
		IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR('No se encontró ningún socio con id = %d', 16, 1, @idSocio);
		END
	END

END
GO


--INSERTAR CATEGORÍA DE SOCIO

CREATE OR ALTER PROCEDURE socios.insertarCategoriaSocio
    @tipo           VARCHAR(50),
    @costoMembresia DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    IF (@costoMembresia>0)
	BEGIN
    INSERT INTO socios.categoriaSocio (tipo, costoMembresia)
    VALUES (@tipo, @costoMembresia) ;
	END
END
GO

EXEC socios.insertarCategoriaSocio Cadete, 5000

select * from socios.categoriaSocio

--MODIFICAR CATEGORÍA DE SOCIO

CREATE OR ALTER PROCEDURE socios.modificarCategoriaSocio
    @idCategoria    INT,
    @tipo           VARCHAR(50)     = NULL,
    @costoMembresia DECIMAL(10,2)   = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE socios.categoriaSocio
    SET
        tipo           = COALESCE(@tipo, tipo),
        costoMembresia = COALESCE(@costoMembresia, costoMembresia)
    WHERE idCategoria = @idCategoria AND (@costoMembresia>0)

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontró categoría con id=%d.',16,1,@idCategoria);
END
GO

EXEC socios.modificarCategoriaSocio 1, Joven, 5500
GO
--ELIMINAR CATEGORÍA DE SOCIO

CREATE OR ALTER PROCEDURE socios.eliminarCategoriaSocio
    @idCategoria INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM socios.categoriaSocio
    WHERE categoriaSocio.idCategoria = @idCategoria

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontró categoría activa con id=%d.',16,1,@idCategoria);
END
GO

EXEC socios.eliminarCategoriaSocio 2
GO

CREATE OR ALTER PROCEDURE socios.insertarRolDisponible
    @idRol       INT,
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	IF(@idRol > 0)
	BEGIN
    INSERT INTO socios.rolDisponible (idRol, descripcion)
    VALUES (@idRol, @descripcion);
	END
END
GO

EXEC socios.insertarRolDisponible 1, Administrador
GO

CREATE OR ALTER PROCEDURE socios.modificarRolDisponible
    @idRol       INT,
    @descripcion VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE socios.rolDisponible
    SET
        descripcion = COALESCE(@descripcion, descripcion)  -- mantendrá su valor inicial si es NULL
    WHERE idRol = @idRol

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontró rol con id=%d.', 16, 1, @idRol);
END
GO

EXEC socios.modificarRolDisponible 1, 'Mate sin Azucar'

CREATE OR ALTER PROCEDURE socios.eliminarRolDisponible
    @idRol INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM socios.rolDisponible
    WHERE idRol = @idRol

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontró rol activo con id=%d.', 16, 1, @idRol);
END
GO

EXEC socios.eliminarRolDisponible 1

SELECT * FROM socios.rolDisponible

CREATE OR ALTER PROCEDURE pagos.insertarMedioDePago
    @idMedioDePago     INT,
    @tipoMedioDePago   VARCHAR(50),
    @descripcion       VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	IF(@idMedioDePago>0)
	BEGIN
    INSERT INTO pagos.medioDePago (idMedioDePago, tipoMedioDePago, descripcion)
    VALUES (@idMedioDePago, @tipoMedioDePago, @descripcion);
	END
END
GO

EXEC pagos.insertarMedioDePago 1,'Debito','Mastercard Debito'
GO

SELECT * FROM pagos.medioDePago
GO

CREATE OR ALTER PROCEDURE pagos.modificarMedioDePago
    @idMedioDePago     INT,
    @tipoMedioDePago   VARCHAR(50),
    @descripcion       VARCHAR(50) = NULL
AS
BEGIN

    UPDATE pagos.medioDePago
    SET
        descripcion = COALESCE(@descripcion, descripcion)
    WHERE idMedioDePago   = @idMedioDePag AND (@idMedioDePago>0)

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontró medio de pago con id=%d.', 16, 1, @idMedioDePago, @tipoMedioDePago);
END
GO

EXEC pagos.modificarMedioDePago -1, 'Credito', 'Mastercard Crédito'

CREATE OR ALTER PROCEDURE pagos.eliminarMedioDePago
    @idMedioDePago     INT,
    @tipoMedioDePago   VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM pagos.medioDePago
    WHERE idMedioDePago   = @idMedioDePago
      AND tipoMedioDePago = @tipoMedioDePago

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontró medio de pago activo con id=%d y tipo="%s".', 16, 1, @idMedioDePago, @tipoMedioDePago);
END
GO

EXEC pagos.eliminarMedioDePago 1, 'Debito'