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
-- CREACION DE LAS TABLAS
----------------------------------------------------	
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='socios' and TABLE_NAME='Inscripcion_act')
BEGIN
	CREATE TABLE socios.Inscripcion_act(
	inscripcion_id INT identity(1,1) primary key,
	socio_id INT,
	deporte_id INT,
	fec_inicio DATE,
	fec_fin DATE,
	estado CHAR,
	costo_base DECIMAL(10,2),
	FOREIGN KEY(socio_id) REFERENCES socios.Socio(socio_id),
	FOREIGN KEY (deporte_id) REFERENCES socios.Deporte(deporte_id),
	)
	END
	GO
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='socios' and TABLE_NAME='Asistencia')
BEGIN
	CREATE TABLE socios.Asistencia(
	asistencia_id INT identity(1,1) primary key,
	nro_socio INT,
	profesor_id INT,
	deporte_id INT,
	fec_asistencia date,
	estado_asistencia CHAR,	
	 FOREIGN KEY(nro_socio) REFERENCES socios.Socio(nro_socio),
	 FOREIGN KEY(profesor_id) REFERENCES socios.Profesor(profesor_id),
	 FOREIGN KEY(deporte_id) REFERENCES socios.Deporte(deporte_id)
	)
	END
	GO

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='socios' and TABLE_NAME='Profesor')
BEGIN
	CREATE TABLE socios.Profesor(
	profesor_id INT identity(1,1) primary key,
	nombre VARCHAR(50),
	apellido VARCHAR(50),
	DNI INT
	)
	END
	GO


IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='socios' and TABLE_NAME='Deporte')
BEGIN
	CREATE TABLE socios.Deporte(
	deporte_id INT identity(1,1) primary key,
	nombre_deporte VARCHAR(10),
	costo_deporte DECIMAL(10,2),
	dia_semana INT,
	hora_inicio time,
	hora_fin time
	)
	END
	GO

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='socios' and TABLE_NAME='Colonia_verano')
BEGIN
	CREATE TABLE socios.Colonia_verano(
	colonia_verano_id INT identity(1,1) primary key,
	costo_colonia_mensual DECIMAL(10,2)
	)
	END 
	GO

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='socios' and TABLE_NAME='Jornada_pileta')
BEGIN
	CREATE TABLE socios.Jornada_pileta(
	jornada_pileta_id INT identity(1,1) primary key,
	fecha DATE,
	reintegrable_flag BIT
	)
	END
	GO

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='socios' and TABLE_NAME='Reserva_sum')
BEGIN
	CREATE TABLE socios.Reserva_sum(
	reserva_sum_id INT identity(1,1) primary key,
	fecha_reserva DATE,
	estado CHAR
	)
	END
	GO

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='socios' and TABLE_NAME='Tarifa_pileta')
BEGIN
	CREATE TABLE socios.Tarifa_pileta(
	 tarifa_pileta_id INT identity(1,1)  primary key,
	vigencia varchar(10),
	costo_vigencia DECIMAL(10,2)
	)
	END
	GO 

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='socios' and TABLE_NAME='Alquiler_sum')
BEGIN
	CREATE TABLE socios.Alquiler_sum(
	alquiler_sum_id INT identity(1,1) primary key,
	costo_alquiler_sum DECIMAL(10,2)
	)
	END
	GO

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='socios' and TABLE_NAME='Pase_pileta')
BEGIN
	CREATE TABLE socios.Pase_pileta(
	pase_pileta_id INT identity(1,1) primary key,
	tarifa_pileta_id INT,
	jornada_pileta INT,
	FOREIGN KEY (tarifa_pileta_id) REFERENCES socios.Tarifa_pileta(tarifa_pileta_id),
	FOREIGN KEY (jornada_pileta) REFERENCES socios.Jornada_pileta(jornada_pileta_id)
	)
	END
	GO

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='socios' and TABLE_NAME='inscripcion_act_extra')
BEGIN
	CREATE TABLE socios.Inscripcion_act_extra(
	inscripcion_id INT identity(1,1) primary key,
	socio_id INT,
	colonia_verano_id INT,
	pase_pileta_id INT,
	fecha_inicio DATE,
	fecha_fin DATE,
	costo_base DECIMAL(10,2)	
	FOREIGN KEY (socio_id) REFERENCES socios.Socio(socio_id),
	FOREIGN KEY (colonia_verano_id) REFERENCES socios.Colonia_verano(Colonia_verano_id),
	FOREIGN KEY (pase_pileta_id) REFERENCES socios.Pase_pileta(pase_pileta_id),
	)
	END
	GO