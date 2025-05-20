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