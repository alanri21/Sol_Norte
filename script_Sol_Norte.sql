/*****************************************
** Grupo 2
** Fecha de entrega: xx/xx/xxxx
** Nombre de la materia: Base de datos aplicada
** Ingrantes:
** 40896369		Riquelme Alan Adriel
** 41173099		Eduardo Abel Hidalgo
** --------		--------------------
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

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'autoridades')
BEGIN
    EXEC('CREATE SCHEMA autoridades'); --Con el exec evito el error de sintaxis, ejecutando de manera independiente la creacion del esquema.
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
	create table socios.socio (
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

----------------------------------------------------
-- CREACION DE STORED PROCEDURE
----------------------------------------------------

--TABLA socios.categoria_socio
--INSERT
CREATE OR ALTER PROCEDURE insert_categoria_socio
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

CREATE OR ALTER PROCEDURE update_categoria_socio
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
CREATE OR ALTER PROCEDURE  delete_CategoriaSocio
    @par_categoriaSocioID INT
AS
BEGIN

DELETE FROM socios.categoria_socio
WHERE categoria_socio_id = @par_categoriaSocioID;

END;
GO

-- TABLA socios.socio
-- INSERT
CREATE OR ALTER PROCEDURE insert_socio
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
CREATE OR ALTER PROCEDURE update_socio
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
CREATE OR ALTER PROCEDURE delete_socio
    @par_nro_socio INT
AS
BEGIN
    DELETE FROM socios.socio
    WHERE nro_socio = @par_nro_socio;
END;
GO

