USE SolNorte_Grupo3
GO

-- :::::::::::::::::::::::::::::::::::::::::::: SOCIOS ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA SOCIO ######

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
		RAISERROR('Error: Email no v�lido o es NULL', 16, 1);
		RETURN;
	END

	IF NOT ((LEN(@telefono) >= 10 AND LEN(@telefono) <= 14) OR  @telefono IS NULL)
	BEGIN
		RAISERROR('Error: Tel�fono debe tener al menos 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF NOT ((@fechaNacimiento >= '1920-01-01' AND @fechaNacimiento <= GETDATE()) OR @fechaNacimiento IS NULL)
	BEGIN
		RAISERROR('Error: Fecha de nacimiento fuera de rango o es NULL', 16, 1);
		RETURN;
	END

	IF NOT (@fechaDeVigenciaContrasenia > GETDATE() OR @fechaDeVigenciaContrasenia IS NULL)
	BEGIN
		RAISERROR('Error: Fecha de vigencia de contrase�a inv�lida o es NULL', 16, 1);
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
		RAISERROR('Error: Contrase�a debe tener entre 5 y 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF NOT (@estadoMembresia IN ('Activo', 'Moroso', 'Inactivo'))
	BEGIN
		RAISERROR('Error: Estado de membres�a inv�lido', 16, 1);
		RETURN;
	END

	IF NOT (@saldoAFavor >= 0 OR @saldoAFavor IS NULL)
	BEGIN
		RAISERROR('Error: Saldo a favor debe ser mayor o igual a cero o NULL', 16, 1);
		RETURN;
	END

	IF NOT ((LEN(@direccion) >= 3 AND LEN(@direccion) <= 100) OR @direccion IS NULL)
	BEGIN
		RAISERROR('Error: Direcci�n debe tener entre 3 y 100 caracteres o ser NULL', 16, 1);
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
		RAISERROR('Error: Email no v�lido o es NULL', 16, 1);
		RETURN;
	END

	IF @telefono IS NOT NULL AND NOT ((LEN(@telefono) >= 10 AND LEN(@telefono) <= 14))
	BEGIN
		RAISERROR('Error: Tel�fono debe tener al menos 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF @fechaNacimiento IS NOT NULL AND NOT ((@fechaNacimiento >= '1920-01-01' AND @fechaNacimiento <= GETDATE()))
	BEGIN
		RAISERROR('Error: Fecha de nacimiento fuera de rango o es NULL', 16, 1);
		RETURN;
	END

	IF @fechaDeVigenciaContrasenia IS NOT NULL AND NOT (@fechaDeVigenciaContrasenia > GETDATE() OR @fechaDeVigenciaContrasenia IS NULL)
	BEGIN
		RAISERROR('Error: Fecha de vigencia de contrase�a inv�lida o es NULL', 16, 1);
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
		RAISERROR('Error: Contrase�a debe tener entre 5 y 10 caracteres o ser NULL', 16, 1);
		RETURN;
	END

	IF @estadoMembresia IS NOT NULL AND NOT (@estadoMembresia IN ('Activo', 'Moroso', 'Inactivo'))
	BEGIN
		RAISERROR('Error: Estado de membres�a inv�lido', 16, 1);
		RETURN;
	END

	IF @saldoAFavor IS NOT NULL AND NOT (@saldoAFavor >= 0)
	BEGIN
		RAISERROR('Error: Saldo a favor debe ser mayor o igual a cero o NULL', 16, 1);
		RETURN;
	END

	IF @direccion IS NOT NULL AND NOT ((LEN(@direccion) >= 3 AND LEN(@direccion) <= 100))
	BEGIN
		RAISERROR('Error: Direcci�n debe tener entre 3 y 100 caracteres o ser NULL', 16, 1);
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
			RAISERROR('No se encontr� ning�n socio con id = %d', 16, 1, @idSocio);
		END
	END

END
GO

-- ###### TABLA TUTORACARGO

-- INSERTAR TUTOR A CARGO
CREATE OR ALTER PROCEDURE socios.insertarTutorACargo  
    @dniTutor BIGINT,  
    @nombre VARCHAR(100),  
    @apellido VARCHAR(100),  
    @email VARCHAR(100) = NULL,  
    @telefono VARCHAR(11) = NULL,  
    @parentescoConMenor VARCHAR(10) = NULL  
AS  
BEGIN  
    SET NOCOUNT ON;  

    -- Validaciones  
    IF @dniTutor <= 0  
    BEGIN  
        RAISERROR('El DNI del tutor debe ser mayor a 0.', 16, 1);  
        RETURN;  
    END  

    IF LEN(@nombre) = 0 OR LEN(@nombre) > 100  
    BEGIN  
        RAISERROR('El nombre debe tener entre 1 y 100 caracteres.', 16, 1);  
        RETURN;  
    END  

    IF LEN(@apellido) = 0 OR LEN(@apellido) > 100  
    BEGIN  
        RAISERROR('El apellido debe tener entre 1 y 100 caracteres.', 16, 1);  
        RETURN;  
    END  

    IF @email IS NOT NULL AND LEN(@email) > 100  
    BEGIN  
        RAISERROR('El email no debe superar los 100 caracteres.', 16, 1);  
        RETURN;  
    END  

    IF @telefono IS NOT NULL AND LEN(@telefono) > 11  
    BEGIN  
        RAISERROR('El tel�fono no debe superar los 11 caracteres.', 16, 1);  
        RETURN;  
    END  

    IF @parentescoConMenor IS NOT NULL AND LEN(@parentescoConMenor) > 10  
    BEGIN  
        RAISERROR('El parentesco no debe superar los 10 caracteres.', 16, 1);  
        RETURN;  
    END  

    INSERT INTO socios.tutorACargo (dniTutor, nombre, apellido, email, telefono, parentescoConMenor)  
    VALUES (@dniTutor, @nombre, @apellido, @email, @telefono, @parentescoConMenor);  
END;  
GO  

-- MODIFICAR TUTOR A CARGO 
CREATE OR ALTER PROCEDURE socios.modificarTutorACargo  
    @dniTutor BIGINT,  
    @nombre VARCHAR(100) = NULL,  
    @apellido VARCHAR(100) = NULL,  
    @email VARCHAR(100) = NULL,  
    @telefono VARCHAR(11) = NULL,  
    @parentescoConMenor VARCHAR(10) = NULL  
AS  
BEGIN  
    SET NOCOUNT ON;  

    -- Validaciones  
    IF @dniTutor <= 0  
    BEGIN  
        RAISERROR('El DNI del tutor debe ser mayor a 0.', 16, 1);  
        RETURN;  
    END  

    IF @nombre IS NOT NULL AND (LEN(@nombre) = 0 OR LEN(@nombre) > 100)  
    BEGIN  
        RAISERROR('El nombre debe tener entre 1 y 100 caracteres.', 16, 1);  
        RETURN;  
    END  

    IF @apellido IS NOT NULL AND (LEN(@apellido) = 0 OR LEN(@apellido) > 100)  
    BEGIN  
        RAISERROR('El apellido debe tener entre 1 y 100 caracteres.', 16, 1);  
        RETURN;  
    END  

    IF @email IS NOT NULL AND LEN(@email) > 100  
    BEGIN  
        RAISERROR('El email no debe superar los 100 caracteres.', 16, 1);  
        RETURN;  
    END  

    IF @telefono IS NOT NULL AND LEN(@telefono) > 11  
    BEGIN  
        RAISERROR('El tel�fono no debe superar los 11 caracteres.', 16, 1);  
        RETURN;  
    END  

    IF @parentescoConMenor IS NOT NULL AND LEN(@parentescoConMenor) > 10  
    BEGIN  
        RAISERROR('El parentesco no debe superar los 10 caracteres.', 16, 1);  
        RETURN;  
    END  

    UPDATE socios.tutorACargo  
    SET  
        nombre = COALESCE(@nombre, nombre),  
        apellido = COALESCE(@apellido, apellido),  
        email = COALESCE(@email, email),  
        telefono = COALESCE(@telefono, telefono),  
        parentescoConMenor = COALESCE(@parentescoConMenor, parentescoConMenor)  
    WHERE dniTutor = @dniTutor;  

    IF @@ROWCOUNT = 0  
    BEGIN  
        RAISERROR('No existe tutorACargo con dniTutor = %d.', 16, 1, @dniTutor);  
    END  
END;  
GO  

-- ELIMINAR TUTOR A CARGO  
CREATE OR ALTER PROCEDURE socios.eliminarTutorACargo  
    @dniTutor BIGINT  
AS  
BEGIN  
    SET NOCOUNT ON;  

    DELETE FROM socios.tutorACargo  
    WHERE dniTutor = @dniTutor;  

    IF @@ROWCOUNT = 0  
    BEGIN  
        RAISERROR('No existe tutorACargo con dniTutor = %d.', 16, 1, @dniTutor);  
    END  
END;  
GO  

-- ###### TABLA CATEGORIASSOCIO ######

-- INSERTAR CATEGORIAS DE SOCIO

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

-- MODIFICAR CATEGORIAS DE SOCIO

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
        RAISERROR('No se encontr� categor�a con id=%d.',16,1,@idCategoria);
END
GO

-- ELIMINAR CATEGORIAS DE SOCIO

CREATE OR ALTER PROCEDURE socios.eliminarCategoriaSocio
    @idCategoria INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM socios.categoriaSocio
    WHERE categoriaSocio.idCategoria = @idCategoria

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontr� categor�a activa con id=%d.',16,1,@idCategoria);
END
GO


-- ###### TABLA ROLDISPONIBLE ######

-- INSERTAR ROL DISPONIBLE

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

-- MODIFICAR ROL DISPONIBLE

CREATE OR ALTER PROCEDURE socios.modificarRolDisponible
    @idRol       INT,
    @descripcion VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE socios.rolDisponible
    SET
        descripcion = COALESCE(@descripcion, descripcion)  -- mantendr� su valor inicial si es NULL
    WHERE idRol = @idRol

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontr� rol con id=%d.', 16, 1, @idRol);
END
GO

-- ELIMINAR ROL DISPONIBLE

CREATE OR ALTER PROCEDURE socios.eliminarRolDisponible
    @idRol INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM socios.rolDisponible
    WHERE idRol = @idRol

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontr� rol activo con id=%d.', 16, 1, @idRol);
END
GO

-- ###### TABLA ROLVIGENTE

-- INSERTAR ROL VIGENTE
CREATE OR ALTER PROCEDURE socios.insertarRolVigente  
    @idRol INT,  
    @idSocio INT  
AS  
BEGIN  
    SET NOCOUNT ON;  

    -- Validaciones  
    IF @idRol <= 0  
    BEGIN  
        RAISERROR('idRol debe ser mayor que 0.', 16, 1);  
        RETURN;  
    END  

    IF @idSocio <= 0  
    BEGIN  
        RAISERROR('idSocio debe ser mayor que 0.', 16, 1);  
        RETURN;  
    END  

    -- Insertar  
    BEGIN TRY
        INSERT INTO socios.rolVigente (idRol, idSocio)  
        VALUES (@idRol, @idSocio);  
    END TRY
    BEGIN CATCH
        RAISERROR('Error al insertar. Puede que la clave primaria ya exista o las claves for�neas no sean v�lidas.', 16, 1);
        RETURN;
    END CATCH
END;  
GO  

-- MODIFICAR ROL VIGENTE
CREATE OR ALTER PROCEDURE socios.modificarRolVigente  
    @idRol INT,  
    @idSocio INT,  
    @nuevoIdRol INT = NULL,  
    @nuevoIdSocio INT = NULL  
AS  
BEGIN  
    SET NOCOUNT ON;  

    IF (@nuevoIdRol IS NOT NULL AND @nuevoIdRol <= 0)  
    BEGIN  
        RAISERROR('nuevoIdRol debe ser mayor que 0 si se especifica.', 16, 1);  
        RETURN;  
    END  

    IF (@nuevoIdSocio IS NOT NULL AND @nuevoIdSocio <= 0)  
    BEGIN  
        RAISERROR('nuevoIdSocio debe ser mayor que 0 si se especifica.', 16, 1);  
        RETURN;  
    END  

    UPDATE socios.rolVigente  
    SET  
        idRol = COALESCE(@nuevoIdRol, idRol),  
        idSocio = COALESCE(@nuevoIdSocio, idSocio)  
    WHERE idRol = @idRol AND idSocio = @idSocio;  

    IF @@ROWCOUNT = 0  
    BEGIN  
        RAISERROR('No existe rolVigente con idRol = %d e idSocio = %d.', 16, 1, @idRol, @idSocio);  
    END  
END;  
GO  

-- ELIMINAR  ROL VIGENTE
CREATE OR ALTER PROCEDURE socios.eliminarRolVigente  
    @idRol INT,  
    @idSocio INT  
AS  
BEGIN  
    SET NOCOUNT ON;  

    DELETE FROM socios.rolVigente  
    WHERE idRol = @idRol AND idSocio = @idSocio;  

    IF @@ROWCOUNT = 0  
    BEGIN  
        RAISERROR('No existe rolVigente con idRol = %d e idSocio = %d.', 16, 1, @idRol, @idSocio);  
    END  
END;  
GO  

-- :::::::::::::::::::::::::::::::::::::::::::: PAGOS ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA FACTURACOBRO

-- INSERTAR FACTURA 
CREATE OR ALTER PROCEDURE pagos.insertarFacturaCobro  
    @idSocio INT = NULL,  
    @fechaEmision DATE = NULL,  -- opcional, usa default si NULL  
    @fechaPrimerVencimiento DATE,  
    @fechaSegundoVencimiento DATE,  
    @cuitDeudor INT,  
    @idMedioDePago INT,  
    @tipoMedioDePago VARCHAR(50),  
    @direccion VARCHAR(100),  
    @tipoCobro VARCHAR(25),  
    @numeroCuota INT,  
    @servicioPagado VARCHAR(50),  
    @importeBruto DECIMAL(10,2),  
    @importeTotal DECIMAL(10,2)  
AS  
BEGIN  
    SET NOCOUNT ON;  

    -- Validaciones b�sicas  
    IF @fechaPrimerVencimiento IS NULL OR @fechaSegundoVencimiento IS NULL  
    BEGIN  
        RAISERROR('Las fechas de vencimiento no pueden ser NULL.', 16, 1);  
        RETURN;  
    END  

    IF @fechaSegundoVencimiento < @fechaPrimerVencimiento  
    BEGIN  
        RAISERROR('La fecha de segundo vencimiento debe ser igual o mayor a la fecha de primer vencimiento.', 16, 1);  
        RETURN;  
    END  

    IF @cuitDeudor <= 0  
    BEGIN  
        RAISERROR('cuitDeudor debe ser mayor que 0.', 16, 1);  
        RETURN;  
    END  

    IF @idMedioDePago <= 0  
    BEGIN  
        RAISERROR('idMedioDePago debe ser mayor que 0.', 16, 1);  
        RETURN;  
    END  

    IF @numeroCuota <= 0  
    BEGIN  
        RAISERROR('numeroCuota debe ser mayor que 0.', 16, 1);  
        RETURN;  
    END  

    IF @importeBruto <= 0  
    BEGIN  
        RAISERROR('importeBruto debe ser mayor que 0.', 16, 1);  
        RETURN;  
    END  

    IF @importeTotal <= 0  
    BEGIN  
        RAISERROR('importeTotal debe ser mayor que 0.', 16, 1);  
        RETURN;  
    END  

    IF @tipoMedioDePago IS NULL OR LEN(@tipoMedioDePago) = 0  
    BEGIN  
        RAISERROR('tipoMedioDePago no puede ser vac�o.', 16, 1);  
        RETURN;  
    END  

    IF @direccion IS NULL OR LEN(@direccion) = 0  
    BEGIN  
        RAISERROR('direccion no puede ser vac�a.', 16, 1);  
        RETURN;  
    END  

    IF @tipoCobro IS NULL OR LEN(@tipoCobro) = 0  
    BEGIN  
        RAISERROR('tipoCobro no puede ser vac�o.', 16, 1);  
        RETURN;  
    END  

    IF @servicioPagado IS NULL OR LEN(@servicioPagado) = 0  
    BEGIN  
        RAISERROR('servicioPagado no puede ser vac�o.', 16, 1);  
        RETURN;  
    END  

    -- Insertar  
    INSERT INTO pagos.facturaCobro  
    (idSocio, fechaEmision, fechaPrimerVencimiento, fechaSegundoVencimiento, cuitDeudor, idMedioDePago, tipoMedioDePago, direccion, tipoCobro, numeroCuota, servicioPagado, importeBruto, importeTotal)  
    VALUES  
    (@idSocio, COALESCE(@fechaEmision, CAST(GETDATE() AS DATE)), @fechaPrimerVencimiento, @fechaSegundoVencimiento, @cuitDeudor, @idMedioDePago, @tipoMedioDePago, @direccion, @tipoCobro, @numeroCuota, @servicioPagado, @importeBruto, @importeTotal);  
END;  
GO  

-- MODIFICAR FACTURA
CREATE OR ALTER PROCEDURE pagos.modificarFacturaCobro  
    @idFactura INT,  
    @idSocio INT = NULL,  
    @fechaEmision DATE = NULL,  
    @fechaPrimerVencimiento DATE = NULL,  
    @fechaSegundoVencimiento DATE = NULL,  
    @cuitDeudor INT = NULL,  
    @idMedioDePago INT = NULL,  
    @tipoMedioDePago VARCHAR(50) = NULL,  
    @direccion VARCHAR(100) = NULL,  
    @tipoCobro VARCHAR(25) = NULL,  
    @numeroCuota INT = NULL,  
    @servicioPagado VARCHAR(50) = NULL,  
    @importeBruto DECIMAL(10,2) = NULL,  
    @importeTotal DECIMAL(10,2) = NULL  
AS  
BEGIN  
    SET NOCOUNT ON;  

    -- Validaciones si llegan par�metros  
    IF (@fechaPrimerVencimiento IS NOT NULL AND @fechaSegundoVencimiento IS NOT NULL AND @fechaSegundoVencimiento < @fechaPrimerVencimiento)  
    BEGIN  
        RAISERROR('La fecha de segundo vencimiento debe ser igual o mayor a la fecha de primer vencimiento.', 16, 1);  
        RETURN;  
    END  

    IF (@cuitDeudor IS NOT NULL AND @cuitDeudor <= 0)  
    BEGIN  
        RAISERROR('cuitDeudor debe ser mayor que 0 si se especifica.', 16, 1);  
        RETURN;  
    END  

    IF (@idMedioDePago IS NOT NULL AND @idMedioDePago <= 0)  
    BEGIN  
        RAISERROR('idMedioDePago debe ser mayor que 0 si se especifica.', 16, 1);  
        RETURN;  
    END  

    IF (@numeroCuota IS NOT NULL AND @numeroCuota <= 0)  
    BEGIN  
        RAISERROR('numeroCuota debe ser mayor que 0 si se especifica.', 16, 1);  
        RETURN;  
    END  

    IF (@importeBruto IS NOT NULL AND @importeBruto <= 0)  
    BEGIN  
        RAISERROR('importeBruto debe ser mayor que 0 si se especifica.', 16, 1);  
        RETURN;  
    END  

    IF (@importeTotal IS NOT NULL AND @importeTotal <= 0)  
    BEGIN  
        RAISERROR('importeTotal debe ser mayor que 0 si se especifica.', 16, 1);  
        RETURN;  
    END  

    UPDATE pagos.facturaCobro  
    SET  
        idSocio = COALESCE(@idSocio, idSocio),  
        fechaEmision = COALESCE(@fechaEmision, fechaEmision),  
        fechaPrimerVencimiento = COALESCE(@fechaPrimerVencimiento, fechaPrimerVencimiento),  
        fechaSegundoVencimiento = COALESCE(@fechaSegundoVencimiento, fechaSegundoVencimiento),  
        cuitDeudor = COALESCE(@cuitDeudor, cuitDeudor),  
        idMedioDePago = COALESCE(@idMedioDePago, idMedioDePago),  
        tipoMedioDePago = COALESCE(@tipoMedioDePago, tipoMedioDePago),  
        direccion = COALESCE(@direccion, direccion),  
        tipoCobro = COALESCE(@tipoCobro, tipoCobro),  
        numeroCuota = COALESCE(@numeroCuota, numeroCuota),  
        servicioPagado = COALESCE(@servicioPagado, servicioPagado),  
        importeBruto = COALESCE(@importeBruto, importeBruto),  
        importeTotal = COALESCE(@importeTotal, importeTotal)  
    WHERE idFactura = @idFactura;  

    IF @@ROWCOUNT = 0  
    BEGIN  
        RAISERROR('No existe facturaCobro con idFactura = %d.', 16, 1, @idFactura);  
    END  
END;  
GO  

-- ELIMINAR FACTURA
CREATE OR ALTER PROCEDURE pagos.eliminarFacturaCobro  
    @idFactura INT  
AS  
BEGIN  
    SET NOCOUNT ON;  

    DELETE FROM pagos.facturaCobro  
    WHERE idFactura = @idFactura;  

    IF @@ROWCOUNT = 0  
    BEGIN  
        RAISERROR('No existe facturaCobro con idFactura = %d.', 16, 1, @idFactura);  
    END  
END;  
GO  

-- ###### TABLA REEMBOLSO


-- INSERTAR REEMBOLSO
CREATE OR ALTER PROCEDURE pagos.insertarReembolso  
    @idFacturaOriginal INT,  
    @montoReembolsado DECIMAL(10,2),  
    @cuitDestinatario BIGINT,  
    @medioDePago VARCHAR(50)  
AS  
BEGIN  
    SET NOCOUNT ON;  

    -- Validaciones  
    IF @idFacturaOriginal <= 0  
    BEGIN  
        RAISERROR('idFacturaOriginal debe ser mayor que 0.', 16, 1);  
        RETURN;  
    END  

    IF @montoReembolsado <= 0  
    BEGIN  
        RAISERROR('montoReembolsado debe ser mayor que 0.', 16, 1);  
        RETURN;  
    END  

    IF @cuitDestinatario <= 0  
    BEGIN  
        RAISERROR('cuitDestinatario debe ser mayor que 0.', 16, 1);  
        RETURN;  
    END  

    IF @medioDePago IS NULL OR LEN(@medioDePago) = 0  
    BEGIN  
        RAISERROR('medioDePago no puede ser vac�o.', 16, 1);  
        RETURN;  
    END  

    INSERT INTO pagos.reembolso (idFacturaOriginal, montoReembolsado, cuitDestinatario, medioDePago)  
    VALUES (@idFacturaOriginal, @montoReembolsado, @cuitDestinatario, @medioDePago);  
END;  
GO  

-- MODIFICAR REEMBOLSO  
CREATE OR ALTER PROCEDURE pagos.modificarReembolso  
    @idFacturaReembolso INT,  
    @idFacturaOriginal INT,  
    @montoReembolsado DECIMAL(10,2) = NULL,  
    @cuitDestinatario BIGINT = NULL,  
    @medioDePago VARCHAR(50) = NULL  
AS  
BEGIN  
    SET NOCOUNT ON;  

    IF (@montoReembolsado IS NOT NULL AND @montoReembolsado <= 0)  
    BEGIN  
        RAISERROR('montoReembolsado debe ser mayor que 0 si se especifica.', 16, 1);  
        RETURN;  
    END  

    IF (@cuitDestinatario IS NOT NULL AND @cuitDestinatario <= 0)  
    BEGIN  
        RAISERROR('cuitDestinatario debe ser mayor que 0 si se especifica.', 16, 1);  
        RETURN;  
    END  

    UPDATE pagos.reembolso  
    SET  
        montoReembolsado = COALESCE(@montoReembolsado, montoReembolsado),  
        cuitDestinatario = COALESCE(@cuitDestinatario, cuitDestinatario),  
        medioDePago = COALESCE(@medioDePago, medioDePago)  
    WHERE idFacturaReembolso = @idFacturaReembolso AND idFacturaOriginal = @idFacturaOriginal;  

    IF @@ROWCOUNT = 0  
    BEGIN  
        RAISERROR('No existe reembolso con idFacturaReembolso = %d e idFacturaOriginal = %d.', 16, 1, @idFacturaReembolso, @idFacturaOriginal);  
    END  
END;  
GO  

-- ELIMINAR REEMBOLSO
CREATE OR ALTER PROCEDURE pagos.eliminarReembolso  
    @idFacturaReembolso INT,  
    @idFacturaOriginal INT  
AS  
BEGIN  
    SET NOCOUNT ON;  

    DELETE FROM pagos.reembolso  
    WHERE idFacturaReembolso = @idFacturaReembolso AND idFacturaOriginal = @idFacturaOriginal;  

    IF @@ROWCOUNT = 0  
    BEGIN  
        RAISERROR('No existe reembolso con idFacturaReembolso = %d e idFacturaOriginal = %d.', 16, 1, @idFacturaReembolso, @idFacturaOriginal);  
    END  
END;  
GO  

-- ###### TABLA MEDIODEPAGO ######

-- INSERTAR MEDIO DE PAGO

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

-- MODIFICAR MEDIO DE PAGO

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
        RAISERROR('No se encontr� medio de pago con id=%d.', 16, 1, @idMedioDePago, @tipoMedioDePago);
END
GO

-- ELIMINAR MEDIO DE PAGO

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
        RAISERROR('No se encontr� medio de pago activo con id=%d y tipo="%s".', 16, 1, @idMedioDePago, @tipoMedioDePago);
END
GO

-- :::::::::::::::::::::::::::::::::::::::::::: ACTIVIDADES ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA DEPORTEDISPONIBLE ######

-- INSERTAR DEPORTE DISPONIBLE

CREATE OR ALTER PROCEDURE actividades.insertarDeporteDisponible
    @tipo VARCHAR(50),
    @descripcion VARCHAR(50),
    @costoPorMes DECIMAL(10, 2)
AS
BEGIN

	IF NOT (LEN(@tipo) >= 4)
	BEGIN
		RAISERROR('Error: El deporte tiene que tener por lo menos 4 letras', 16, 1);
		RETURN;
	END

	IF NOT (LEN(@descripcion) >= 4)
	BEGIN
		RAISERROR('Error: El deporte tiene que tener por lo menos 4 letras', 16, 1);
		RETURN;
	END

	IF NOT (@costoPorMes > 0)
	BEGIN
		RAISERROR('Error: El costo tiene que ser mayor a cero', 16, 1);
		RETURN;
	END

    INSERT INTO actividades.deporteDisponible
        (tipo,descripcion,costoPorMes)
    VALUES
        (@tipo,@descripcion,@costoPorMes)

END
GO

-- MODIFICAR DEPORTE DISPONIBLE

CREATE OR ALTER PROCEDURE actividades.modificarDeporteDisponible
    @idDeporte INT,
    @tipo VARCHAR(50) = NULL,
    @descripcion VARCHAR(50) = NULL,
    @costoPorMes DECIMAL(10, 2) = NULL

AS
BEGIN
    SET NOCOUNT ON;

	IF @tipo IS NOT NULL AND NOT (LEN(@tipo) >= 4)
	BEGIN
		RAISERROR('Error: Tipo tiene que tener mas de 4 letras', 16, 1);
		RETURN;
	END

	IF @descripcion IS NOT NULL AND NOT(LEN(@descripcion) >= 4)
	BEGIN
		RAISERROR('Error: El deporte tiene que tener por lo menos 4 letras', 16, 1);
		RETURN;
	END

	IF @costoPorMes IS NOT NULL AND NOT (@costoPorMes > 0)
	BEGIN
		RAISERROR('Error: El costo tiene que ser mayor a cero', 16, 1);
		RETURN;
	END

    UPDATE actividades.deporteDisponible
    SET
		tipo                      = COALESCE(@tipo, tipo),
		descripcion               = COALESCE(@descripcion, descripcion),
		costoPorMes               = COALESCE(@costoPorMes, costoPorMes)
    WHERE idDeporte = @idDeporte;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No existe un deporte con idDeporte = %d.', 16, 1, @idDeporte);
    END
END;
GO

-- ELIMINAR DEPORTE DISPONIBLE

CREATE OR ALTER PROCEDURE actividades.eliminarDeporteDisponible
    @idDeporte INT
AS
BEGIN
    SET NOCOUNT ON;

	DELETE FROM actividades.deporteDisponible
	WHERE idDeporte = @idDeporte;
    
	IF @@ROWCOUNT = 0
	BEGIN
		RAISERROR('No se encontr� ning�n deporte con id = %d', 16, 1, @idDeporte);
	END
	
END
GO

-- ###### TABLA ACTIVIDAD RECREATIVA ######

--Insertar Actividad Recreativa
CREATE PROCEDURE actividades.insertarActividadRecreativa (
    @descripcion VARCHAR(50),
    @horaInicio VARCHAR(50),
    @horaFin VARCHAR(50),
    @tarifaSocio DECIMAL(10, 2),
    @tarifaInvitado DECIMAL(10, 2)
)
AS
BEGIN
    IF @descripcion IS NULL OR @descripcion = ''
    BEGIN
        RAISERROR('La descripci�n de la actividad no puede estar vac�a.', 16, 1);
        RETURN;
    END
    IF @horaInicio IS NULL OR @horaInicio = ''
    BEGIN
        RAISERROR('La hora de inicio de la actividad no puede estar vac�a.', 16, 1);
        RETURN;
    END
    IF @horaFin IS NULL OR @horaFin = ''
    BEGIN
        RAISERROR('La hora de fin de la actividad no puede estar vac�a.', 16, 1);
        RETURN;
    END
    IF @tarifaSocio IS NULL OR @tarifaSocio <= 0
    BEGIN
        RAISERROR('La tarifa para socios debe ser mayor que cero.', 16, 1);
        RETURN;
    END
    IF @tarifaInvitado IS NULL OR @tarifaInvitado <= 0
    BEGIN
        RAISERROR('La tarifa para invitados debe ser mayor que cero.', 16, 1);
        RETURN;
    END

    -- Inserci�n de la actividad
    INSERT INTO actividades.actividadRecreativa (descripcion, horaInicio, horaFin, tarifaSocio, tarifaInvitado)
    VALUES (@descripcion, @horaInicio, @horaFin, @tarifaSocio, @tarifaInvitado);

    SELECT SCOPE_IDENTITY() AS idActividadInsertada; -- Esta sentencia lo que hace es devolver el ID de la actividad insertada
END;
GO

-- Modificar Actividad Recreativa
CREATE PROCEDURE actividades.modificarActividadRecreativa (
    @idActividad INT,
    @descripcion VARCHAR(50),
    @horaInicio VARCHAR(50),
    @horaFin VARCHAR(50),
    @tarifaSocio DECIMAL(10, 2),
    @tarifaInvitado DECIMAL(10, 2)
)
AS
BEGIN
    IF @idActividad IS NULL OR @idActividad <= 0
    BEGIN
        RAISERROR('El ID de la actividad debe ser un valor positivo.', 16, 1);
        RETURN;
    END
    IF @descripcion IS NULL OR @descripcion = ''
    BEGIN
        RAISERROR('La descripci�n de la actividad no puede estar vac�a.', 16, 1);
        RETURN;
    END
    IF @horaInicio IS NULL OR @horaInicio = ''
    BEGIN
        RAISERROR('La hora de inicio de la actividad no puede estar vac�a.', 16, 1);
        RETURN;
    END
    IF @horaFin IS NULL OR @horaFin = ''
    BEGIN
        RAISERROR('La hora de fin de la actividad no puede estar vac�a.', 16, 1);
        RETURN;
    END
    IF @tarifaSocio IS NULL OR @tarifaSocio <= 0
    BEGIN
        RAISERROR('La tarifa para socios debe ser mayor que cero.', 16, 1);
        RETURN;
    END
    IF @tarifaInvitado IS NULL OR @tarifaInvitado <= 0
    BEGIN
        RAISERROR('La tarifa para invitados debe ser mayor que cero.', 16, 1);
        RETURN;
    END
    -- Actualizaci�n de la actividad
    UPDATE actividades.actividadRecreativa
    SET descripcion = @descripcion,
        horaInicio = @horaInicio,
        horaFin = @horaFin,
        tarifaSocio = @tarifaSocio,
        tarifaInvitado = @tarifaInvitado
    WHERE idActividad = @idActividad;
    -- Verificar si se actualiz� alguna fila
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No se encontr� ninguna actividad con el ID especificado.', 16, 1);
        RETURN;
    END
END;
GO

-- Eliminar Actividad Recreativa
CREATE PROCEDURE actividades.eliminarActividadRecreativa (
    @idActividad INT
)
AS
BEGIN
    IF @idActividad IS NULL OR @idActividad <= 0
    BEGIN
        RAISERROR('El ID de la actividad debe ser un valor positivo.', 16, 1);
        RETURN;
    END
    -- Eliminaci�n de la actividad
    DELETE FROM actividades.actividadRecreativa
    WHERE idActividad = @idActividad;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No se encontr� ninguna actividad con el ID especificado.', 16, 1);
        RETURN;
    END
END;
GO

-- ###### TABLA DEPORTEACTIVO ######

-- INSERTAR DEPORTE ACTIVO

CREATE OR ALTER PROCEDURE actividades.insertarDeporteActivo
    @idSocio INT,
    @idDeporte INT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @estadoMembresia VARCHAR(8);

    SET @estadoMembresia = (SELECT s.estadoMembresia FROM socios.socio s WHERE s.idSocio = @idSocio)
	IF NOT (@estadoMembresia IN ('Activo','Moroso'))
    BEGIN
        RAISERROR('Miembro no v�lido.', 16, 1);
        RETURN;
    END;

	IF NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte)
    BEGIN
        RAISERROR('Error: Ese deporte no existe', 16, 1);
        RETURN;
    END

    INSERT INTO actividades.deporteActivo (idSocio, idDeporte, estadoMembresia)
    VALUES (@idSocio, @idDeporte, @estadoMembresia);
END;
GO

-- MODIFICAR DEPORTE ACTIVO

CREATE OR ALTER PROCEDURE actividades.modificarDeporteActivo
    @idDeporteActivo    INT,
    @idSocio            INT = NULL,
    @idDeporte          INT = NULL,
    @estadoMembresia    VARCHAR(8) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @estadoMembresia IS NOT NULL AND NOT (@estadoMembresia IN ('Activo', 'Moroso', 'Inactivo'))
    BEGIN
        RAISERROR('Error: Estado de membres�a debe ser Activo, Moroso o Inactivo.', 16, 1);
        RETURN;
    END

    -- Validaci�n existencia de socio si se quiere modificar
    IF @idSocio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
    BEGIN
        RAISERROR('Error: El socio especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validaci�n existencia de deporte si se quiere modificar
    IF @idDeporte IS NOT NULL AND NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte)
    BEGIN
        RAISERROR('Error: El deporte especificado no existe.', 16, 1);
        RETURN;
    END

    -- Actualizaci�n condicional
    UPDATE actividades.deporteActivo
    SET
        idSocio         = COALESCE(@idSocio, idSocio),
        idDeporte       = COALESCE(@idDeporte, idDeporte),
        estadoMembresia = COALESCE(@estadoMembresia, estadoMembresia)
    WHERE idDeporteActivo = @idDeporteActivo;

    -- Verificaci�n de actualizaci�n
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No existe una fila con idDeporteActivo = %d.', 16, 1, @idDeporteActivo);
    END
END;
GO

-- ELIMINAR DEPORTE ACTIVO

CREATE PROCEDURE actividades.eliminarDeporteActivo
    @idDeporteActivo INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM actividades.deporteActivo
    WHERE idDeporteActivo = @idDeporteActivo;
END;
GO

-- :::::::::::::::::::::::::::::::::::::::::::: ITINERARIOS ::::::::::::::::::::::::::::::::::::::::::::

-- ###### TABLA ITINERARIO ######

-- INSERTAR ITINERARIO

CREATE OR ALTER PROCEDURE itinerarios.insertarItinerario
    @dia VARCHAR(9),
    @idDeporte INT,
    @horaInicio TIME,
    @horaFin TIME
AS
BEGIN
    IF NOT (LEN(@dia) >= 5 AND LEN(@dia) <= 9)
    BEGIN
        RAISERROR('Error: El d�a de la semana debe tener entre 5 y 9 letras', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte)
    BEGIN
        RAISERROR('Error: Ese deporte no existe', 16, 1);
        RETURN;
    END
    IF @horaInicio >= @horaFin
    BEGIN
        RAISERROR('Error: La hora de inicio debe ser menor que la hora de fin', 16, 1);
        RETURN;
    END

    -- Inserci�n v�lida
    INSERT INTO itinerarios.itinerario (dia, idDeporte, horaInicio, horaFin)
    VALUES (@dia, @idDeporte, @horaInicio, @horaFin);
END;
GO

-- MODIFICAR ITINERARIO

CREATE OR ALTER PROCEDURE itinerarios.modificarItinerario
    @idItinerario INT,
    @dia VARCHAR(9) = NULL,
    @idDeporte INT = NULL,
    @horaInicio TIME = NULL,
    @horaFin TIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar d�a
    IF @dia IS NOT NULL AND NOT (LEN(@dia) >= 5 AND LEN(@dia) <= 9)
    BEGIN
        RAISERROR('Error: El d�a de la semana debe tener entre 5 y 9 letras', 16, 1);
        RETURN;
    END

    -- Validar existencia de deporte
    IF @idDeporte IS NOT NULL AND NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte)
    BEGIN
        RAISERROR('Error: Ese deporte no existe', 16, 1);
        RETURN;
    END

    -- Validar que horaInicio < horaFin
    IF @horaInicio IS NOT NULL AND @horaFin IS NOT NULL AND @horaInicio >= @horaFin
    BEGIN
        RAISERROR('Error: La hora de inicio debe ser menor que la hora de fin', 16, 1);
        RETURN;
    END

    -- Actualizar valores
    UPDATE itinerarios.itinerario
    SET
        dia = COALESCE(@dia, dia),
        idDeporte = COALESCE(@idDeporte, idDeporte),
        horaInicio = COALESCE(@horaInicio, horaInicio),
        horaFin = COALESCE(@horaFin, horaFin)
    WHERE idItinerario = @idItinerario;

    -- Validar si se actualiz� alguna fila
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No existe un itinerario con idItinerario = %d.', 16, 1, @idItinerario);
    END
END;
GO

-- ELIMINAR ITINERARIO

CREATE OR ALTER PROCEDURE itinerarios.eliminarItinerario
    @idItinerario INT
AS
BEGIN
    SET NOCOUNT ON;

	DELETE FROM itinerarios.itinerario
	WHERE @idItinerario = @idItinerario;
    
	IF @@ROWCOUNT = 0
	BEGIN
		RAISERROR('No se encontr� ning�n itinerario con id = %d', 16, 1, @idItinerario);
	END
	
END
GO