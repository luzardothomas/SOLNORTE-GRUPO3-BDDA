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
        RAISERROR('El teléfono no debe superar los 11 caracteres.', 16, 1);  
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
        RAISERROR('El teléfono no debe superar los 11 caracteres.', 16, 1);  
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
        RAISERROR('No se encontró categoría con id=%d.',16,1,@idCategoria);
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
        RAISERROR('No se encontró categoría activa con id=%d.',16,1,@idCategoria);
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
        descripcion = COALESCE(@descripcion, descripcion)  -- mantendrá su valor inicial si es NULL
    WHERE idRol = @idRol

    IF @@ROWCOUNT = 0
        RAISERROR('No se encontró rol con id=%d.', 16, 1, @idRol);
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
        RAISERROR('No se encontró rol activo con id=%d.', 16, 1, @idRol);
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
        RAISERROR('Error al insertar. Puede que la clave primaria ya exista o las claves foráneas no sean válidas.', 16, 1);
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

    -- Validaciones básicas  
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
        RAISERROR('tipoMedioDePago no puede ser vacío.', 16, 1);  
        RETURN;  
    END  

    IF @direccion IS NULL OR LEN(@direccion) = 0  
    BEGIN  
        RAISERROR('direccion no puede ser vacía.', 16, 1);  
        RETURN;  
    END  

    IF @tipoCobro IS NULL OR LEN(@tipoCobro) = 0  
    BEGIN  
        RAISERROR('tipoCobro no puede ser vacío.', 16, 1);  
        RETURN;  
    END  

    IF @servicioPagado IS NULL OR LEN(@servicioPagado) = 0  
    BEGIN  
        RAISERROR('servicioPagado no puede ser vacío.', 16, 1);  
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

    -- Validaciones si llegan parámetros  
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
        RAISERROR('medioDePago no puede ser vacío.', 16, 1);  
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
        RAISERROR('No se encontró medio de pago con id=%d.', 16, 1, @idMedioDePago, @tipoMedioDePago);
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
        RAISERROR('No se encontró medio de pago activo con id=%d y tipo="%s".', 16, 1, @idMedioDePago, @tipoMedioDePago);
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
		RAISERROR('No se encontró ningún deporte con id = %d', 16, 1, @idDeporte);
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
        RAISERROR('La descripción de la actividad no puede estar vacía.', 16, 1);
        RETURN;
    END
    IF @horaInicio IS NULL OR @horaInicio = ''
    BEGIN
        RAISERROR('La hora de inicio de la actividad no puede estar vacía.', 16, 1);
        RETURN;
    END
    IF @horaFin IS NULL OR @horaFin = ''
    BEGIN
        RAISERROR('La hora de fin de la actividad no puede estar vacía.', 16, 1);
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

    -- Inserción de la actividad
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
        RAISERROR('La descripción de la actividad no puede estar vacía.', 16, 1);
        RETURN;
    END
    IF @horaInicio IS NULL OR @horaInicio = ''
    BEGIN
        RAISERROR('La hora de inicio de la actividad no puede estar vacía.', 16, 1);
        RETURN;
    END
    IF @horaFin IS NULL OR @horaFin = ''
    BEGIN
        RAISERROR('La hora de fin de la actividad no puede estar vacía.', 16, 1);
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
    -- Actualización de la actividad
    UPDATE actividades.actividadRecreativa
    SET descripcion = @descripcion,
        horaInicio = @horaInicio,
        horaFin = @horaFin,
        tarifaSocio = @tarifaSocio,
        tarifaInvitado = @tarifaInvitado
    WHERE idActividad = @idActividad;
    -- Verificar si se actualizó alguna fila
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No se encontró ninguna actividad con el ID especificado.', 16, 1);
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
    -- Eliminación de la actividad
    DELETE FROM actividades.actividadRecreativa
    WHERE idActividad = @idActividad;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No se encontró ninguna actividad con el ID especificado.', 16, 1);
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
        RAISERROR('Miembro no válido.', 16, 1);
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
        RAISERROR('Error: Estado de membresía debe ser Activo, Moroso o Inactivo.', 16, 1);
        RETURN;
    END

    -- Validación existencia de socio si se quiere modificar
    IF @idSocio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
    BEGIN
        RAISERROR('Error: El socio especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validación existencia de deporte si se quiere modificar
    IF @idDeporte IS NOT NULL AND NOT EXISTS (SELECT 1 FROM actividades.deporteDisponible WHERE idDeporte = @idDeporte)
    BEGIN
        RAISERROR('Error: El deporte especificado no existe.', 16, 1);
        RETURN;
    END

    -- Actualización condicional
    UPDATE actividades.deporteActivo
    SET
        idSocio         = COALESCE(@idSocio, idSocio),
        idDeporte       = COALESCE(@idDeporte, idDeporte),
        estadoMembresia = COALESCE(@estadoMembresia, estadoMembresia)
    WHERE idDeporteActivo = @idDeporteActivo;

    -- Verificación de actualización
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
        RAISERROR('Error: El día de la semana debe tener entre 5 y 9 letras', 16, 1);
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

    -- Inserción válida
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

    -- Validar día
    IF @dia IS NOT NULL AND NOT (LEN(@dia) >= 5 AND LEN(@dia) <= 9)
    BEGIN
        RAISERROR('Error: El día de la semana debe tener entre 5 y 9 letras', 16, 1);
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

    -- Validar si se actualizó alguna fila
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
		RAISERROR('No se encontró ningún itinerario con id = %d', 16, 1, @idItinerario);
	END
	
END
GO

-- :::::::::::::::::::::::::::::::::::::::::::: COBERTURAS ::::::::::::::::::::::::::::::::::::::::::::

-- ### coberturaDisponible ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarCoberturaDisponible
-- ------------------------------------------------------------------------------
CREATE PROCEDURE coberturas.insertarCoberturaDisponible
    @tipo VARCHAR(100),
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @tipo IS NULL OR LTRIM(RTRIM(@tipo)) = ''
        BEGIN
            RAISERROR('El campo "tipo" no puede ser nulo o vacío. Por favor, proporcione un valor.', 16, 1);
            RETURN;
        END

        IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        BEGIN
            RAISERROR('El campo "descripcion" no puede ser nulo o vacío. Por favor, proporcione una descripción.', 16, 1);
            RETURN;
        END

        -- 'activo' se inserta como 1 por defecto, indicando que la cobertura está activa.
        INSERT INTO coberturas.coberturaDisponible (tipo, descripcion, activo)
        VALUES (@tipo, @descripcion, 1);
        PRINT 'Cobertura disponible insertada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar cobertura disponible: ' + ERROR_MESSAGE();
        THROW; -- Re-lanza el error para que la app pueda manejarlo.
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarCoberturaDisponible
-- ------------------------------------------------------------------------------
CREATE PROCEDURE coberturas.modificarCoberturaDisponible
    @idCobertura INT,
    @tipo VARCHAR(100),
    @descripcion VARCHAR(50),
    @activo BIT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idCobertura IS NULL OR @idCobertura <= 0
        BEGIN
            RAISERROR('El ID de cobertura debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @tipo IS NULL OR LTRIM(RTRIM(@tipo)) = ''
        BEGIN
            RAISERROR('El campo "tipo" no puede ser nulo o vacío. Por favor, proporcione un valor.', 16, 1);
            RETURN;
        END

        IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        BEGIN
            RAISERROR('El campo "descripcion" no puede ser nulo o vacío. Por favor, proporcione una descripción.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM coberturas.coberturaDisponible WHERE idCoberturaDisponible = @idCobertura)
        BEGIN
            RAISERROR('La cobertura con el ID especificado no existe. No se puede actualizar.', 16, 1);
            RETURN;
        END

        -- Actualización de los campos de la cobertura.
        UPDATE coberturas.coberturaDisponible
        SET
            tipo = @tipo,
            descripcion = @descripcion,
            activo = @activo
        WHERE idCoberturaDisponible = @idCobertura;

        PRINT 'Cobertura disponible actualizada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar cobertura disponible: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarCoberturaDisponible
-- ------------------------------------------------------------------------------
CREATE PROCEDURE coberturas.eliminarCoberturaDisponible
    @idCobertura INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idCobertura IS NULL OR @idCobertura <= 0
        BEGIN
            RAISERROR('El ID de cobertura debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM coberturas.coberturaDisponible WHERE idCoberturaDisponible = @idCobertura)
        BEGIN
            RAISERROR('La cobertura con el ID especificado no existe. No se puede eliminar lógicamente.', 16, 1);
            RETURN;
        END

        IF (SELECT activo FROM coberturas.coberturaDisponible WHERE idCoberturaDisponible = @idCobertura) = 0
        BEGIN
            RAISERROR('La cobertura ya se encuentra inactiva. No es necesario realizar el borrado lógico nuevamente.', 16, 1);
            RETURN;
        END

        -- Actualización del estado 'activo' a 0 para realizar el borrado lógico.
        UPDATE coberturas.coberturaDisponible
        SET activo = 0
        WHERE idCoberturaDisponible = @idCobertura;

        PRINT 'Cobertura disponible eliminada lógicamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar lógicamente cobertura disponible: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ### prepagaEnUso ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarPrepagaEnUso
-- ------------------------------------------------------------------------------
CREATE PROCEDURE coberturas.insertarPrepagaEnUso
    @idCobertura INT,
    @idNumeroSocio INT,
    @categoriaSocio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idCobertura IS NULL OR @idCobertura <= 0
        BEGIN
            RAISERROR('El ID de cobertura debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @idNumeroSocio IS NULL OR @idNumeroSocio <= 0
        BEGIN
            RAISERROR('El ID de socio debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @categoriaSocio IS NULL OR @categoriaSocio <= 0
        BEGIN
            RAISERROR('La categoría del socio debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM coberturas.coberturaDisponible WHERE idCoberturaDisponible = @idCobertura)
        BEGIN
            RAISERROR('El ID de cobertura especificado no existe en la tabla coberturas.coberturaDisponible.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idNumeroSocio)
        BEGIN
            RAISERROR('El ID de socio especificado no existe en la tabla socios.socio.', 16, 1);
            RETURN;
        END

        -- Inserción del nuevo registro de prepaga en uso.
        INSERT INTO coberturas.prepagaEnUso (idCobertura, idNumeroSocio, categoriaSocio)
        VALUES (@idCobertura, @idNumeroSocio, @categoriaSocio);

        PRINT 'Registro de prepaga en uso insertado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar registro de prepaga en uso: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarPrepagaEnUso
-- ------------------------------------------------------------------------------
CREATE PROCEDURE coberturas.ActualizarPrepagaEnUso
    @idPrepaga INT,
    @idCobertura INT,
    @idNumeroSocio INT,
    @categoriaSocio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idPrepaga IS NULL OR @idPrepaga <= 0
        BEGIN
            RAISERROR('El ID de prepaga en uso debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @idCobertura IS NULL OR @idCobertura <= 0
        BEGIN
            RAISERROR('El ID de cobertura debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @idNumeroSocio IS NULL OR @idNumeroSocio <= 0
        BEGIN
            RAISERROR('El ID de socio debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF @categoriaSocio IS NULL OR @categoriaSocio <= 0
        BEGIN
            RAISERROR('La categoría del socio debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM coberturas.prepagaEnUso WHERE idPrepaga = @idPrepaga)
        BEGIN
            RAISERROR('El registro de prepaga en uso con el ID especificado no existe. No se puede actualizar.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM coberturas.coberturaDisponible WHERE idCoberturaDisponible = @idCobertura)
        BEGIN
            RAISERROR('El ID de cobertura especificado no existe en la tabla coberturas.coberturaDisponible.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idNumeroSocio)
        BEGIN
            RAISERROR('El ID de socio especificado no existe en la tabla socios.socio.', 16, 1);
            RETURN;
        END

        -- Actualización del registro de prepaga en uso.
        UPDATE coberturas.prepagaEnUso
        SET
            idCobertura = @idCobertura,
            idNumeroSocio = @idNumeroSocio,
            categoriaSocio = @categoriaSocio
        WHERE idPrepaga = @idPrepaga;

        PRINT 'Registro de prepaga en uso actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar registro de prepaga en uso: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarPrepagaEnUso
-- ------------------------------------------------------------------------------
CREATE PROCEDURE coberturas.eliminarPrepagaEnUso
    @idPrepaga INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idPrepaga IS NULL OR @idPrepaga <= 0
        BEGIN
            RAISERROR('El ID de prepaga en uso debe ser un valor positivo y no nulo.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM coberturas.prepagaEnUso WHERE idPrepaga = @idPrepaga)
        BEGIN
            RAISERROR('El registro de prepaga en uso con el ID especificado no existe. No se puede eliminar.', 16, 1);
            RETURN;
        END

        -- Eliminación física del registro de prepaga en uso.
        DELETE FROM coberturas.prepagaEnUso
        WHERE idPrepaga = @idPrepaga;

        PRINT 'Registro de prepaga en uso eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar registro de prepaga en uso: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- :::::::::::::::::::::::::::::::::::::::::::: RESERVAS ::::::::::::::::::::::::::::::::::::::::::::

-- ### reservasSum ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarReservaSum
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.insertarReservaSum
    @idSocio INT,
    @dniReservante BIGINT,
    @horaInicioReserva INT,
    @horaFinReserva INT,
    @tarifaFinal DECIMAL(10, 2),
    @newIdReserva INT OUTPUT -- Para devolver el ID generado por IDENTITY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @idSocio < 0
        BEGIN
            THROW 50001, 'El ID de socio no puede ser negativo.', 1;
        END

        IF @dniReservante <= 0
        BEGIN
            THROW 50002, 'El DNI del reservante debe ser un número positivo.', 1;
        END

        IF @horaInicioReserva < 0 OR @horaFinReserva < 0 OR @horaFinReserva <= @horaInicioReserva
        BEGIN
            THROW 50003, 'Las horas de inicio y fin de reserva deben ser válidas y la hora de fin debe ser posterior a la de inicio.', 1;
        END

        IF @tarifaFinal <= 0
        BEGIN
            THROW 50004, 'La tarifa final debe ser un valor positivo.', 1;
        END

        -- Validar existencia de idSocio en socios.socio
        IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
        BEGIN
            -- Si @idSocio = 0 está permitido para "invitados" y no referencia socio.socio,
            THROW 50005, 'El ID de socio especificado no existe en la tabla de socios.', 1;
        END

        -- Iniciar transacción
        BEGIN TRANSACTION;

        INSERT INTO reservas.reservasSUM (idSocio, dniReservante, horaInicioReserva, horaFinReserva,tarifaFinal)
        VALUES (@idSocio, @dniReservante, @horaInicioReserva, @horaFinReserva, @tarifaFinal);
        SET @newIdReserva = SCOPE_IDENTITY(); -- Obtener el ID generado
        COMMIT TRANSACTION;
        PRINT 'Reserva SUM insertada con éxito. ID de Reserva: ' + CAST(@newIdReserva AS VARCHAR(10));

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarReservaSum
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.modificarReservaSum
    @idReserva INT,
    @idSocioOriginal INT,
    @dniReservanteOriginal BIGINT,
    @newIdSocio INT = NULL, -- Nuevos valores para posible actualización
    @newDniReservante BIGINT = NULL,
    @newHoraInicioReserva INT = NULL,
    @newHoraFinReserva INT = NULL,
    @newTarifaFinal DECIMAL(10, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la reserva SUM a modificar existe
        IF NOT EXISTS (SELECT 1 FROM reservas.reservasSUM WHERE idReserva = @idReserva AND idSocio = @idSocioOriginal AND dniReservante = @dniReservanteOriginal)
        BEGIN
            THROW 50006, 'La reserva SUM especificada no existe.', 1;
        END

        -- Validaciones para los nuevos valores (si existieran)
        IF @newIdSocio IS NOT NULL AND @newIdSocio < 0
        BEGIN
            THROW 50007, 'El nuevo ID de socio no puede ser negativo.', 1;
        END
        IF @newIdSocio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @newIdSocio) AND @newIdSocio != 0 -- Ajuste si 0 es un ID de invitado especial
        BEGIN
            THROW 50008, 'El nuevo ID de socio especificado no existe en la tabla de socios.', 1;
        END

        IF @newDniReservante IS NOT NULL AND @newDniReservante <= 0
        BEGIN
            THROW 50009, 'El nuevo DNI del reservante debe ser un número positivo.', 1;
        END

        IF (@newHoraInicioReserva IS NOT NULL AND @newHoraFinReserva IS NOT NULL AND @newHoraFinReserva <= @newHoraInicioReserva)
           OR (@newHoraInicioReserva IS NOT NULL AND @newHoraFinReserva IS NULL AND @newHoraInicioReserva < 0)
           OR (@newHoraFinReserva IS NOT NULL AND @newHoraInicioReserva IS NULL AND @newHoraFinReserva < 0)
        BEGIN
            THROW 50010, 'Las nuevas horas de inicio y fin de reserva deben ser válidas y la hora de fin debe ser posterior a la de inicio.', 1;
        END

        IF @newTarifaFinal IS NOT NULL AND @newTarifaFinal <= 0
        BEGIN
            THROW 50011, 'La nueva tarifa final debe ser un valor positivo.', 1;
        END

        -- Iniciar transacción
        BEGIN TRANSACTION;

        UPDATE reservas.reservasSUM
        SET
            idSocio = ISNULL(@newIdSocio, idSocio),
            dniReservante = ISNULL(@newDniReservante, dniReservante),
            horaInicioReserva = ISNULL(@newHoraInicioReserva, horaInicioReserva),
            horaFinReserva = ISNULL(@newHoraFinReserva, horaFinReserva),
            tarifaFinal = ISNULL(@newTarifaFinal, tarifaFinal)
        WHERE
            idReserva = @idReserva
            AND idSocio = @idSocioOriginal
            AND dniReservante = @dniReservanteOriginal;

        COMMIT TRANSACTION;
        PRINT 'Reserva SUM modificada con éxito.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarReservaSum
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.eliminarReservaSum
    @idReserva INT,
    @idSocio INT,
    @dniReservante BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la reserva SUM a borrar existe
        IF NOT EXISTS (SELECT 1 FROM reservas.reservasSUM WHERE idReserva = @idReserva AND idSocio = @idSocio AND dniReservante = @dniReservante)
        BEGIN
            THROW 50012, 'La reserva SUM especificada no existe.', 1;
        END

        -- Iniciar transacción
        BEGIN TRANSACTION;
        DELETE FROM reservas.reservasSUM
        WHERE idReserva = @idReserva
              AND idSocio = @idSocio
              AND dniReservante = @dniReservante;
        COMMIT TRANSACTION;
        PRINT 'Reserva SUM eliminada físicamente con éxito.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ### reservaPaseActividad ###

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: insertarReservaPaseActividad
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.insertarReservaPaseActividad
    @idSocio INT,
    @categoriaSocio INT,
    @categoriaPase VARCHAR(9),
    @montoTotalActividad DECIMAL(10, 2),
    @newIdReservaActividad INT OUTPUT -- Para devolver el ID generado
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validaciones básicas
        IF @idSocio < 0
        BEGIN
            THROW 50020, 'El ID de socio no puede ser negativo.', 1;
        END

        IF @categoriaSocio <= 0
        BEGIN
            THROW 50021, 'La categoría de socio debe ser un número positivo.', 1;
        END

        IF @categoriaPase NOT IN ('Dia', 'Mensual', 'Temporada')
        BEGIN
            THROW 50022, 'La categoría de pase no es válida (Dia, Mensual, Temporada).', 1;
        END

        IF @montoTotalActividad <= 0
        BEGIN
            THROW 50023, 'El monto total de la actividad debe ser un valor positivo.', 1;
        END

        -- Validar existencia de idSocio en socios.socio
        IF NOT EXISTS (SELECT 1 FROM socios.socio WHERE idSocio = @idSocio)
        BEGIN
            THROW 50024, 'El ID de socio especificado no existe en la tabla de socios.', 1;
        END

        -- Validar existencia de categoriaSocio en socios.categoriaSocio
        IF NOT EXISTS (SELECT 1 FROM socios.categoriaSocio WHERE idCategoria = @categoriaSocio)
        BEGIN
            THROW 50025, 'La categoría de socio especificada no existe en la tabla de categorías de socio.', 1;
        END

        -- Iniciar transacción
        BEGIN TRANSACTION;

        INSERT INTO reservas.reservaPaseActividad (
            idSocio,
            categoriaSocio,
            categoriaPase,
            montoTotalActividad,
            estadoPase -- Se inserta con el valor DEFAULT 'Activo'
        )
        VALUES (@idSocio, @categoriaSocio, @categoriaPase, @montoTotalActividad);
        SET @newIdReservaActividad = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
        PRINT 'Reserva de Pase de Actividad insertada con éxito. ID: ' + CAST(@newIdReservaActividad AS VARCHAR(10));

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: modificarReservaPaseActividad
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.modificarReservaPaseActividad
    @idReservaActividad INT,
    @idSocioOriginal INT,
    @newCategoriaSocio INT = NULL,
    @newCategoriaPase VARCHAR(9) = NULL,
    @newMontoTotalActividad DECIMAL(10, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la reserva de pase de actividad a modificar existe
        IF NOT EXISTS (SELECT 1 FROM reservas.reservaPaseActividad WHERE idReservaActividad = @idReservaActividad AND idSocio = @idSocioOriginal)
        BEGIN
            THROW 50026, 'La reserva de pase de actividad especificada no existe.', 1;
        END

        -- Validaciones para los nuevos valores
        IF @newCategoriaSocio IS NOT NULL AND @newCategoriaSocio <= 0
        BEGIN
            THROW 50027, 'La nueva categoría de socio debe ser un número positivo.', 1;
        END
        IF @newCategoriaSocio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM socios.categoriaSocio WHERE idCategoria = @newCategoriaSocio)
        BEGIN
            THROW 50028, 'La nueva categoría de socio especificada no existe en la tabla de categorías de socio.', 1;
        END

        IF @newCategoriaPase IS NOT NULL AND @newCategoriaPase NOT IN ('Dia', 'Mensual', 'Temporada')
        BEGIN
            THROW 50029, 'La nueva categoría de pase no es válida (Dia, Mensual, Temporada).', 1;
        END

        IF @newMontoTotalActividad IS NOT NULL AND @newMontoTotalActividad <= 0
        BEGIN
            THROW 50030, 'El nuevo monto total de la actividad debe ser un valor positivo.', 1;
        END

        -- Iniciar transacción
        BEGIN TRANSACTION;
        UPDATE reservas.reservaPaseActividad
        SET
            categoriaSocio = ISNULL(@newCategoriaSocio, categoriaSocio),
            categoriaPase = ISNULL(@newCategoriaPase, categoriaPase),
            montoTotalActividad = ISNULL(@newMontoTotalActividad, montoTotalActividad)
        WHERE
            idReservaActividad = @idReservaActividad
            AND idSocio = @idSocioOriginal;

        COMMIT TRANSACTION;
        PRINT 'Reserva de Pase de Actividad modificada con éxito.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTO: eliminarReservaPaseActividad
-- ------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reservas.eliminarReservaPaseActividad
    @idReservaActividad INT,
    @idSocio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la reserva de pase de actividad a borrar existe y está activa
        IF NOT EXISTS (SELECT 1 FROM reservas.reservaPaseActividad WHERE idReservaActividad = @idReservaActividad AND idSocio = @idSocio AND estadoPase = 'Activo')
        BEGIN
            THROW 50031, 'La reserva de pase de actividad especificada no existe o ya está inactiva.', 1;
        END

        -- Iniciar transacción
        BEGIN TRANSACTION;
        UPDATE reservas.reservaPaseActividad
        SET estadoPase = 'Inactivo'
        WHERE idReservaActividad = @idReservaActividad
              AND idSocio = @idSocio;
        COMMIT TRANSACTION;
        PRINT 'Reserva de Pase de Actividad marcada como inactiva (borrado lógico) con éxito.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO