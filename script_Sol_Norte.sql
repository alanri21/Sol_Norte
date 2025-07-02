/*****************************************
** Grupo 2
** Fecha de entrega: xx/xx/xxxx
** Nombre de la materia: Base de datos aplicada
** Ingrantes:
** 40896369		Riquelme Alan Adriel
** --------		--------------------
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
	nombre_categoria VARCHAR(20) NOT NULL,
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

	


