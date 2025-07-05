/*****************************************
** Grupo 2
** Fecha de entrega: xx/xx/xxxx
** Nombre de la materia: Base de datos aplicada
** Ingrantes:
** 40896369		Riquelme Alan Adriel
** 41173099		Eduardo Abel Hidalgo
** 43406784		Lucas Rodrigo Grance Zenteno
******************************************/

----------------------------------------------------
-- CREACION DE BASE DE DATOS 
----------------------------------------------------

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'Sol_Norte')
BEGIN
    CREATE DATABASE Sol_Norte;
END;
GO

USE Sol_Norte;
GO

----------------------------------------------------
-- CREACION DE ESQUEMAS DE BASE DE DATOS
----------------------------------------------------

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'tesoreria')
BEGIN
    EXEC('CREATE SCHEMA tesoreria'); --Con el exec evito el error de sintaxis, ejecutando de manera independiente la creacion del esquema.
END;
GO

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'socios')
BEGIN
    EXEC('CREATE SCHEMA socios'); --Con el exec evito el error de sintaxis, ejecutando de manera independiente la creacion del esquema.
END;
GO

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'actividades')
BEGIN
    EXEC('CREATE SCHEMA actividades'); --Con el exec evito el error de sintaxis, ejecutando de manera independiente la creacion del esquema.
END;
GO

----------------------------------------------------
-- CREACION DE TABLAS
----------------------------------------------------


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'categoria_socio')
	CREATE TABLE socios.categoria_socio (
	categoria_socio_id INT IDENTITY(1,1),
	nombre_categoria VARCHAR(20) UNIQUE NOT NULL,
	costo_membresia DECIMAL(18,2) NOT NULL,
	CONSTRAINT PK_categoria_socio PRIMARY KEY (categoria_socio_id),
	CONSTRAINT CHK_categoria_costo CHECK (costo_membresia >= 0)
	) ;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'socio')
	CREATE TABLE socios.socio (
	nro_socio INT IDENTITY(1,1),
	categoria_socio_id INT NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	edad TINYINT NOT NULL,
	fec_inscripcion DATE NOT NULL,
	dni CHAR(8) UNIQUE NOT NULL,
	email VARCHAR(50),
	fec_nacimiento DATE NOT NULL,
	tel_contacto VARCHAR(20),
	tel_contacto_emergencia VARCHAR(20),
	nombre_prepaga VARCHAR(30),
	nro_socio_prepaga VARCHAR(20),
	tel_prepaga_emergencia VARCHAR(20),
	responsable_pago INT,
	parentezco  VARCHAR(15),
	CONSTRAINT PK_socio PRIMARY KEY (nro_socio),
	CONSTRAINT FK_categoria_socio FOREIGN KEY (categoria_socio_id) 
	REFERENCES socios.categoria_socio(categoria_socio_id)
	ON UPDATE CASCADE,
	CONSTRAINT CHK_socio_responsable_pago
    CHECK (
        edad >= 13
        OR responsable_pago IS NOT NULL
    )
	) ;
	GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'cuenta_credito')
    CREATE TABLE socios.cuenta_credito (
        cuenta_credito_id   INT           IDENTITY(1,1) NOT NULL,
        nro_socio           INT           NOT NULL,
        saldo_a_favor       DECIMAL(18,2) NOT NULL,
        fec_actualizacion   DATE          NOT NULL DEFAULT (CAST(GETDATE() AS date)),

        CONSTRAINT PK_cuenta_credito PRIMARY KEY (cuenta_credito_id),
        CONSTRAINT FK_cc_socio FOREIGN KEY (nro_socio)
            REFERENCES socios.socio(nro_socio)
            ON DELETE CASCADE,
		CONSTRAINT CHK_cuenta_cred_saldo CHECK (saldo_a_favor >= 0),
		
    );
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'profesor')
BEGIN
    CREATE TABLE actividades.profesor (
        profesor_id INT           IDENTITY(1,1) UNIQUE NOT NULL,
        nombre      VARCHAR(50)   NOT NULL,
        apellido    VARCHAR(50)   NOT NULL,
        dni         CHAR(8)       NOT NULL
        CONSTRAINT PK_profesor PRIMARY KEY (profesor_id),
        CONSTRAINT CHK_profesor_dni CHECK (LEN(dni) = 8)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'deporte')
BEGIN
    CREATE TABLE actividades.deporte (
        deporte_id      INT           IDENTITY(1,1) NOT NULL,
        nombre_deporte  VARCHAR(50)   UNIQUE NOT NULL,
        costo_deporte   DECIMAL(18,2) NOT NULL,
        dia_semana      TINYINT       NOT NULL,
        hora_inicio     TIME(0)       NOT NULL,
        hora_fin        TIME(0)       NOT NULL,
		CONSTRAINT PK_deporte PRIMARY KEY (deporte_id),
		CONSTRAINT CHK_deporte_costo CHECK (costo_deporte >= 0),
		CONSTRAINT CHK_deporte_dia_semana CHECK (dia_semana BETWEEN 1 AND 7),
		CONSTRAINT CHK_deporte_horario CHECK (hora_fin > hora_inicio)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'asistencia')
BEGIN
    CREATE TABLE actividades.asistencia (
        asistencia_id     INT           IDENTITY(1,1) NOT NULL,
        nro_socio         INT           NOT NULL,
        profesor_id       INT           NOT NULL,
        deporte_id        INT           NOT NULL,
        fec_asistencia    DATE          NOT NULL,
        estado_asistencia CHAR(1)       NOT NULL,
		CONSTRAINT PK_asistencia PRIMARY KEY (asistencia_id),
        CONSTRAINT FK_asist_socio FOREIGN KEY (nro_socio)
            REFERENCES socios.socio(nro_socio),
        CONSTRAINT FK_asist_profesor FOREIGN KEY (profesor_id)
            REFERENCES actividades.profesor(profesor_id),
        CONSTRAINT FK_asist_deporte FOREIGN KEY (deporte_id)
            REFERENCES actividades.deporte(deporte_id),
		CONSTRAINT CHK_asistencia_estado CHECK (estado_asistencia IN ('J','A','P'))

    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'inscripcion_act')
BEGIN
    CREATE TABLE actividades.inscripcion_act (
        inscripcion_id INT           IDENTITY(1,1) NOT NULL,
        socio_id       INT           NOT NULL,
        deporte_id     INT           NOT NULL,
        fec_inicio     DATE          NOT NULL,
        fec_fin        DATE          NOT NULL,
        estado         VARCHAR(20)   NOT NULL,
        costo_base     DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_inscripcion_act PRIMARY KEY (inscripcion_id),
        CONSTRAINT FK_insc_act_socio FOREIGN KEY (socio_id)
            REFERENCES socios.socio(nro_socio),
        CONSTRAINT FK_insc_act_deporte FOREIGN KEY (deporte_id)
            REFERENCES actividades.deporte(deporte_id),
        CONSTRAINT CHK_insc_act_fechas CHECK (fec_fin >= fec_inicio),
		CONSTRAINT CHK_insc_act_estado CHECK (estado IN ('pendiente','pagada','vencida')),
		CONSTRAINT CHK_insc_act_costo CHECK (costo_base >= 0)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'reserva_sum')
BEGIN
    CREATE TABLE actividades.reserva_sum (
        reserva_sum_id INT           IDENTITY(1,1) NOT NULL,
        fec_reserva    DATE          NOT NULL,
        estado         VARCHAR(20)   NOT NULL,
        CONSTRAINT PK_reserva_sum PRIMARY KEY (reserva_sum_id),
		CONSTRAINT CHK_reserva_sum_estado CHECK (estado IN ('pendiente','confirmada','cancelada'))
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tarifa_pileta')
BEGIN
    CREATE TABLE actividades.tarifa_pileta (
        tarifa_pileta_id INT           IDENTITY(1,1) NOT NULL,
        vigencia         DATE          NOT NULL,  -- fecha de inicio de vigencia
        costo_vigencia   DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_tarifa_pileta PRIMARY KEY (tarifa_pileta_id),
		CONSTRAINT CHK_tarifa_pileta_costo CHECK (costo_vigencia >= 0)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'jornada_pileta')
BEGIN
    CREATE TABLE actividades.jornada_pileta (
        jornada_id         INT    IDENTITY(1,1) NOT NULL,
        fecha              DATE   NOT NULL,
        reintegrable_flag  BIT    NOT NULL,
        CONSTRAINT PK_jornada_pileta PRIMARY KEY (jornada_id)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'colonia_verano')
BEGIN
    CREATE TABLE actividades.colonia_verano (
        colonia_verano_id      INT           IDENTITY(1,1) NOT NULL,
        costo_colonia_mensual  DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_colonia_verano PRIMARY KEY (colonia_verano_id),
		CONSTRAINT CHK_colonia_verano_costo CHECK (costo_colonia_mensual >= 0)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'alquiler_sum')
BEGIN
    CREATE TABLE actividades.alquiler_sum (
        alquiler_sum_id     INT           IDENTITY(1,1) NOT NULL,
        costo_alquiler_sum  DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_alquiler_sum PRIMARY KEY (alquiler_sum_id),
		CONSTRAINT CHK_alquiler_sum_costo CHECK (costo_alquiler_sum >= 0)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'pase_pileta')
BEGIN
    CREATE TABLE actividades.pase_pileta (
        pase_pileta_id    INT NOT NULL IDENTITY(1,1),
        tarifa_pileta_id  INT NOT NULL,
        jornada_id        INT NOT NULL,
        CONSTRAINT PK_pase_pileta PRIMARY KEY (pase_pileta_id),
        CONSTRAINT FK_pase_tarifa FOREIGN KEY (tarifa_pileta_id)
            REFERENCES actividades.tarifa_pileta(tarifa_pileta_id),
        CONSTRAINT FK_pase_jornada FOREIGN KEY (jornada_id)
            REFERENCES actividades.jornada_pileta(jornada_id)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'inscripcion_act_extra')
BEGIN
    CREATE TABLE actividades.inscripcion_act_extra (
        inscripcion_extra_id  INT           IDENTITY(1,1) NOT NULL,
        socio_id              INT           NOT NULL,
        colonia_verano_id     INT           NOT NULL,
        alquiler_sum_id       INT           NOT NULL,
        pase_pileta_id        INT           NOT NULL,
        fec_inicio            DATE          NOT NULL,
        fec_fin               DATE          NOT NULL,
        costo_base            DECIMAL(18,2) NOT NULL,

        CONSTRAINT PK_inscripcion_act_extra PRIMARY KEY (inscripcion_extra_id),
        CONSTRAINT FK_insc_extra_socio FOREIGN KEY (socio_id)
            REFERENCES socios.socio(nro_socio),
        CONSTRAINT FK_insc_extra_colonia FOREIGN KEY (colonia_verano_id)
            REFERENCES actividades.colonia_verano(colonia_verano_id),
        CONSTRAINT FK_insc_extra_alquiler FOREIGN KEY (alquiler_sum_id)
            REFERENCES actividades.alquiler_sum(alquiler_sum_id),
        CONSTRAINT FK_insc_extra_pase FOREIGN KEY (pase_pileta_id)
            REFERENCES actividades.pase_pileta(pase_pileta_id),
        CONSTRAINT CHK_insc_extra_fechas CHECK (fec_fin >= fec_inicio),
		CONSTRAINT CHK_insc_extra_costo CHECK (costo_base >= 0)
    );
END;
GO

----------------------------------------------------
-- CREACION DE STORED PROCEDURE
----------------------------------------------------

--TABLA socios.categoria_socio
--INSERT
CREATE OR ALTER PROCEDURE socios.insert_categoria_socio
	@par_nombreCategoria VARCHAR(20),
    @par_costoMembresia  DECIMAL(18,2)
AS
BEGIN
-- validaciones

IF @par_nombreCategoria IS NULL OR TRIM(@par_nombreCategoria) = ''
    BEGIN
        RAISERROR('Debe especificar un nombre de categoría válido.', 16, 1);
        RETURN;
    END

    INSERT INTO socios.categoria_socio (nombre_categoria, costo_membresia)
    VALUES (@par_nombreCategoria, @par_costoMembresia);
END;
GO

--UPDATE

CREATE OR ALTER PROCEDURE socios.update_categoria_socio
	@par_categoriaSocioID INT,
    @par_nombreCategoria  VARCHAR(20),
    @par_costoMembresia   DECIMAL(18,2)
AS
BEGIN
-- validacion
IF @par_nombreCategoria IS NULL OR TRIM(@par_nombreCategoria) = ''
    BEGIN
        RAISERROR('Debe especificar un nombre de categoría válido.', 16, 1);
        RETURN;
    END
UPDATE socios.categoria_socio
SET nombre_categoria = @par_nombreCategoria,
    costo_membresia  = @par_costoMembresia
WHERE categoria_socio_id = @par_categoriaSocioID;

END;
GO

--DELETE
CREATE OR ALTER PROCEDURE  socios.delete_CategoriaSocio
    @par_categoriaSocioID INT
AS
BEGIN

DELETE FROM socios.categoria_socio
WHERE categoria_socio_id = @par_categoriaSocioID;

END;
GO

-- TABLA socios.socio
-- INSERT
CREATE OR ALTER PROCEDURE socios.insert_socio
    @par_categoriaSocioID     INT,
    @par_nombre               VARCHAR(50),
    @par_apellido             VARCHAR(50),
    @par_edad                 TINYINT,
    @par_fec_inscripcion      DATE,
    @par_dni                  CHAR(8),
    @par_email                VARCHAR(50),
    @par_fec_nacimiento       DATE,
    @par_tel_contacto         VARCHAR(20),
    @par_tel_contacto_emergencia VARCHAR(20),
    @par_nombre_prepaga       VARCHAR(30),
    @par_nro_socio_prepaga    VARCHAR(20),
    @par_tel_prepaga_emergencia VARCHAR(20),
    @par_responsable_pago     INT,
    @par_parentezco           VARCHAR(15)
AS
BEGIN

-- validaciones

    IF @par_edad < 0 OR @par_edad > 120
    BEGIN
        RAISERROR('La edad debe estar entre 0 y 120.', 16, 1);
        RETURN;
    END

    IF TRIM(@par_dni) IS NULL 
       OR LEN(@par_dni) <> 8
    BEGIN
        RAISERROR('El DNI debe ser un número de 8 dígitos.', 16, 1);
        RETURN;
    END

	IF @par_fec_inscripcion > GETDATE()
    BEGIN
        RAISERROR('La fecha de inscripción no puede ser futura.', 16, 1);
        RETURN;
    END

	IF @par_fec_nacimiento > @par_fec_inscripcion
    BEGIN
        RAISERROR('La fecha de nacimiento no puede ser posterior a la inscripción.', 16, 1);
        RETURN;
    END

	IF @par_responsable_pago IS NOT NULL
       AND NOT EXISTS (
           SELECT 1 FROM socios.socio WHERE nro_socio = @par_responsable_pago
       )
    BEGIN
        RAISERROR('El responsable de pago con nro_socio = %d no existe.',16, 1, @par_responsable_pago);
        RETURN;
    END

-- realizo el insert luego de las validaciones
    INSERT INTO socios.socio (
        categoria_socio_id,
		nombre,
		apellido,
		edad,
        fec_inscripcion,
		dni,
		email,
		fec_nacimiento,
        tel_contacto,
		tel_contacto_emergencia,
        nombre_prepaga,
		nro_socio_prepaga,
		tel_prepaga_emergencia,
        responsable_pago,
		parentezco
    )
    VALUES (
        @par_categoriaSocioID,
		@par_nombre,
		@par_apellido,
		@par_edad,
        @par_fec_inscripcion,
		@par_dni,
		@par_email,
		@par_fec_nacimiento,
        @par_tel_contacto,
		@par_tel_contacto_emergencia,
        @par_nombre_prepaga,
		@par_nro_socio_prepaga,
		@par_tel_prepaga_emergencia,
        @par_responsable_pago,
		@par_parentezco
    );
END;
GO

-- UPDATE
CREATE OR ALTER PROCEDURE socios.update_socio
    @par_nro_socio             INT,
    @par_categoriaSocioID      INT,
    @par_nombre               VARCHAR(50),
    @par_apellido             VARCHAR(50),
    @par_edad                 TINYINT,
    @par_fec_inscripcion      DATE,
    @par_dni                  CHAR(8),
    @par_email                VARCHAR(50),
    @par_fec_nacimiento       DATE,
    @par_tel_contacto         VARCHAR(20),
    @par_tel_contacto_emergencia VARCHAR(20),
    @par_nombre_prepaga       VARCHAR(30),
    @par_nro_socio_prepaga    VARCHAR(20),
    @par_tel_prepaga_emergencia VARCHAR(20),
    @par_responsable_pago     INT,
    @par_parentezco           VARCHAR(15)
AS
BEGIN

-- validaciones

    IF @par_edad < 0 OR @par_edad > 120
    BEGIN
        RAISERROR('La edad debe estar entre 0 y 120.', 16, 1);
        RETURN;
    END

    IF TRIM(@par_dni) IS NULL 
       OR LEN(@par_dni) <> 8
    BEGIN
        RAISERROR('El DNI debe ser un número de 8 dígitos.', 16, 1);
        RETURN;
    END

	IF @par_fec_inscripcion > GETDATE()
    BEGIN
        RAISERROR('La fecha de inscripción no puede ser futura.', 16, 1);
        RETURN;
    END

	IF @par_fec_nacimiento > @par_fec_inscripcion
    BEGIN
        RAISERROR('La fecha de nacimiento no puede ser posterior a la inscripción.', 16, 1);
        RETURN;
    END

	IF @par_responsable_pago IS NOT NULL
       AND NOT EXISTS (
           SELECT 1 FROM socios.socio WHERE nro_socio = @par_responsable_pago
       )
    BEGIN
        RAISERROR('El responsable de pago con nro_socio = %d no existe.',16, 1, @par_responsable_pago);
        RETURN;
    END
	
    UPDATE socios.socio
    SET 
        categoria_socio_id         = @par_categoriaSocioID,
        nombre                     = @par_nombre,
        apellido                   = @par_apellido,
        edad                       = @par_edad,
        fec_inscripcion            = @par_fec_inscripcion,
        dni                        = @par_dni,
        email                      = @par_email,
        fec_nacimiento             = @par_fec_nacimiento,
        tel_contacto               = @par_tel_contacto,
        tel_contacto_emergencia    = @par_tel_contacto_emergencia,
        nombre_prepaga             = @par_nombre_prepaga,
        nro_socio_prepaga          = @par_nro_socio_prepaga,
        tel_prepaga_emergencia     = @par_tel_prepaga_emergencia,
        responsable_pago           = @par_responsable_pago,
        parentezco                 = @par_parentezco
    WHERE nro_socio = @par_nro_socio;
END;
GO

-- DELETE
CREATE OR ALTER PROCEDURE socios.delete_socio
    @par_nro_socio INT
AS
BEGIN
	

	IF EXISTS (SELECT 1 FROM socios.socio WHERE responsable_pago = @par_nro_socio)
    BEGIN
        RAISERROR('No se puede eliminar: el socio %d está asignado como responsable de pago.',16, 1, @par_nro_socio);
        RETURN;
    END
    DELETE FROM socios.socio
    WHERE nro_socio = @par_nro_socio;
END;
GO

