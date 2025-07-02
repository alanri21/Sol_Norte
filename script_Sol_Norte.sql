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