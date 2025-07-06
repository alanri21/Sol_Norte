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

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'cuota')
BEGIN
    CREATE TABLE socios.cuota (
        cuota_id        INT           IDENTITY(1,1) NOT NULL,
        nro_socio       INT           NOT NULL,
        inscripcion_id  INT           NOT NULL,
        monto           DECIMAL(18,2) NOT NULL,
        fec_vencimiento DATE          NOT NULL,
        estado          VARCHAR(10)   NOT NULL,
        CONSTRAINT PK_cuota PRIMARY KEY (cuota_id),
        CONSTRAINT FK_cuota_socio FOREIGN KEY (nro_socio)
            REFERENCES socios.socio(nro_socio),
        CONSTRAINT FK_cuota_inscripcion FOREIGN KEY (inscripcion_id)
            REFERENCES actividades.inscripcion_act(inscripcion_id),
		CONSTRAINT CHK_cuota_monto CHECK (monto >= 0),
		CONSTRAINT CHK_cuota_estado CHECK (estado IN ('pendiente','pagada','vencida'))
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'invitado')
BEGIN
    CREATE TABLE socios.invitado (
        invitado_id      INT           IDENTITY(1,1) NOT NULL,
        tarifa_invitado  DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_invitado PRIMARY KEY (invitado_id),
		CONSTRAINT CHK_invitado_tarifa CHECK (tarifa_invitado >= 0)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'factura')
BEGIN
    CREATE TABLE tesoreria.factura (
        nro_factura               INT           IDENTITY(1,1) NOT NULL,
        nro_socio                 INT           NOT NULL,
        cuota_id                  INT           NULL,
        invitado_id               INT           NULL,
        fec_emision               DATE          NOT NULL,
        fec_primer_vto            DATE          NOT NULL,
        estado                    VARCHAR(10)   NOT NULL,
        fec_segundo_vto           DATE          NULL,
        importe_total_primer_venc DECIMAL(18,2) NOT NULL,
        importe_total_segundo_venc DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_factura PRIMARY KEY (nro_factura),
        CONSTRAINT FK_factura_socio FOREIGN KEY (nro_socio)
            REFERENCES socios.socio(nro_socio),
        CONSTRAINT FK_factura_cuota FOREIGN KEY (cuota_id)
            REFERENCES socios.cuota(cuota_id),
        CONSTRAINT FK_factura_invitado FOREIGN KEY (invitado_id)
            REFERENCES socios.invitado(invitado_id),
		CONSTRAINT CHK_factura_estado CHECK (estado IN ('emitida','anulada')),
		CONSTRAINT CHK_factura_imp2 CHECK (importe_total_segundo_venc >= 0),
		CONSTRAINT CHK_factura_imp1 CHECK (importe_total_primer_venc >= 0)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'nota_credito')
BEGIN
    CREATE TABLE tesoreria.nota_credito (
        nro_nota_credito   INT           IDENTITY(1,1) NOT NULL,
        nro_factura        INT           NOT NULL,
        fec_emision_nc     DATE          NOT NULL,
        importe_anulado    DECIMAL(18,2) NOT NULL,
        cae_nc             VARCHAR(50)   NULL,
        vto_cae_nc         DATE          NULL,
        CONSTRAINT PK_nota_credito PRIMARY KEY (nro_nota_credito),
        CONSTRAINT FK_nota_credito_factura FOREIGN KEY (nro_factura)
            REFERENCES tesoreria.factura(nro_factura),
        CONSTRAINT CHK_notacredito_importe CHECK (importe_anulado >= 0)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'descuento')
BEGIN
    CREATE TABLE tesoreria.descuento (
        descuento_id         INT           IDENTITY(1,1) NOT NULL,
        descripcion          VARCHAR(100)  NOT NULL,
        porcentaje_descuento DECIMAL(5,2)  NOT NULL,
        CONSTRAINT PK_descuento PRIMARY KEY (descuento_id),
		CONSTRAINT CHK_descuento_porcentaje CHECK (porcentaje_descuento BETWEEN 0 AND 100)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'detalle_factura')
BEGIN
    CREATE TABLE tesoreria.detalle_factura (
        detalle_factura_id   INT           IDENTITY(1,1) NOT NULL,
        categoria_socio_id   INT           NULL,
        nro_factura          INT           NOT NULL,
        cuota_id             INT           NULL,
        inscripcion_id_act   INT           NULL,
        inscripcion_id_ex    INT           NULL,
        descuento_id         INT           NULL,
        detalle_concepto     VARCHAR(200)  NOT NULL,
        cantidad             INT           NOT NULL,
        precio_unitario      DECIMAL(18,2) NOT NULL,
        subtotal             DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_detalle_factura PRIMARY KEY (detalle_factura_id),
        CONSTRAINT FK_detfac_factura FOREIGN KEY (nro_factura)
            REFERENCES tesoreria.factura(nro_factura),
        CONSTRAINT FK_detfac_socioCat FOREIGN KEY (categoria_socio_id)
            REFERENCES socios.categoria_socio(categoria_socio_id),
        CONSTRAINT FK_detfac_cuota FOREIGN KEY (cuota_id)
            REFERENCES socios.cuota(cuota_id),
        CONSTRAINT FK_detfac_inscAct FOREIGN KEY (inscripcion_id_act)
            REFERENCES actividades.inscripcion_act(inscripcion_id),
        CONSTRAINT FK_detfac_inscEx FOREIGN KEY (inscripcion_id_ex)
            REFERENCES actividades.inscripcion_act_extra(inscripcion_extra_id),
        CONSTRAINT FK_detfac_descuento FOREIGN KEY (descuento_id)
            REFERENCES tesoreria.descuento(descuento_id),
		CONSTRAINT CHK_detalle_cantidad CHECK (cantidad > 0),
		CONSTRAINT CHK_detalle_precio CHECK (precio_unitario >= 0)
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'morosidad')
BEGIN
    CREATE TABLE tesoreria.morosidad (
        morosidad_id       INT           IDENTITY(1,1) NOT NULL,
        nro_factura        INT           NOT NULL,
        fec_inicio_mora    DATE          NOT NULL,
        estado_mora        VARCHAR(12)   NOT NULL,
        fec_regularizacion DATE         NULL,
        CONSTRAINT PK_morosidad PRIMARY KEY (morosidad_id),
        CONSTRAINT FK_morosidad_factura FOREIGN KEY (nro_factura)
            REFERENCES tesoreria.factura(nro_factura),
		CONSTRAINT CHK_morosidad_estado CHECK (estado_mora IN ('Activa','Regularizada'))
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'medio_pago')
BEGIN
    CREATE TABLE tesoreria.medio_pago (
        medio_pago_id           INT           IDENTITY(1,1) NOT NULL,
        nombre_medio            VARCHAR(30)   NOT NULL,
        debito_automatico_flag  BIT           NOT NULL,
        CONSTRAINT PK_medio_pago PRIMARY KEY (medio_pago_id),
		CONSTRAINT CHK_mediopago_nombre CHECK ( nombre_medio IN (
                                      'Visa',
                                      'MasterCard',
                                      'Tarjeta Naranja',
                                      'Pago Fácil',
                                      'Rapipago',
                                      'Transferencia Mercado Pago'))
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'pago')
BEGIN
    CREATE TABLE tesoreria.pago (
        pago_id                  INT           IDENTITY(1,1) NOT NULL,
        factura_id               INT           NOT NULL,
        medio_pago_id            INT           NOT NULL,
        modalidad_pago           VARCHAR(20)   NOT NULL,
        fecha_pago               DATE          NOT NULL,
        monto_pagado             DECIMAL(18,2) NOT NULL,
        estado_transaccion       VARCHAR(12)   NOT NULL,
        codigo_aprobacion_banco  VARCHAR(50)   NULL,
        CONSTRAINT PK_pago PRIMARY KEY (pago_id),
        CONSTRAINT FK_pago_factura FOREIGN KEY (factura_id)
            REFERENCES tesoreria.factura(nro_factura),
        CONSTRAINT FK_pago_mediopago FOREIGN KEY (medio_pago_id)
            REFERENCES tesoreria.medio_pago(medio_pago_id),
		CONSTRAINT CHK_pago_modalidad CHECK (modalidad_pago IN ('Manual','Debito automatico')),
		CONSTRAINT CHK_pago_monto CHECK (monto_pagado >= 0),
		CONSTRAINT CHK_pago_estado CHECK (estado_transaccion IN ('Pendiente','Confirmado','Rechazado'))
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ajuste_pago')
BEGIN
    CREATE TABLE tesoreria.ajuste_pago (
        ajuste_pago_id INT           IDENTITY(1,1) NOT NULL,
        pago_id        INT           NOT NULL,
        tipo_ajuste    VARCHAR(20)   NOT NULL,
        monto_ajuste   DECIMAL(18,2) NOT NULL,
        fec_ajuste     DATE          NOT NULL,
        descripcion    VARCHAR(200)  NULL,
        CONSTRAINT PK_ajuste_pago PRIMARY KEY (ajuste_pago_id),
        CONSTRAINT FK_ajuste_pago_pago FOREIGN KEY (pago_id)
            REFERENCES tesoreria.pago(pago_id),
		CONSTRAINT CHK_ajuste_pago_tipo CHECK (tipo_ajuste IN ('Reembolso','Pago_a_Cuenta')),
		CONSTRAINT CHK_ajuste_pago_monto CHECK (monto_ajuste >= 0)
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
--------------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------
-- TABLA actividades.profesor 
-- INSERT

CREATE OR ALTER PROCEDURE actividades.insert_profesor      
        @par_nombre      VARCHAR(50),
        @par_apellido    VARCHAR(50),
        @par_dni         CHAR(8)   
AS
BEGIN
--validaciones

    IF TRIM(@par_dni) IS NULL 
       OR LEN(@par_dni) <> 8
    BEGIN
        RAISERROR('El DNI debe ser un número de 8 dígitos.', 16, 1);
        RETURN;
    END

-- realizo el insert luego de las validaciones

INSERT INTO actividades.profesor(
		nombre,
		apellido,
		dni
	)
	VALUES(
		@par_nombre,
		@par_apellido,
		@par_dni
		);
END;
GO

--UPDATES

CREATE OR ALTER PROCEDURE actividades.update_profesor
	    @par_profesor_id INT
		@par_nombre      VARCHAR(50),
        @par_apellido    VARCHAR(50),
        @par_dni         CHAR(8)   
AS
BEGIN
--validaciones

    IF TRIM(@par_dni) IS NULL 
       OR LEN(@par_dni) <> 8
    BEGIN
        RAISERROR('El DNI debe ser un número de 8 dígitos.', 16, 1);
        RETURN;
    END

	UPDATE actividades.profesor
		SET
		nombre =@par_nombre ,
		apellido=@par_apellido ,
		dni=@par_dni
		where profesor_id= @profesor_id;
END; 
GO

--DELETE
CREATE OR ALTER PROCEDURE actividades.delete_profesor
    @par_profesor_id INT
AS
BEGIN
    DELETE FROM socios.socio
    WHERE profesor_id = @par_profesor_id;
END;
GO
---------------------------------------------------------------------------------------------------
-- TABLA actividades.insert_deporte
-- INSERT
CREATE OR ALTER PROCEDURE actividades.insert_deporte
        @par_nombre_deporte  VARCHAR(50),
        @par_costo_deporte   DECIMAL(18,2),
        @par_dia_semana      TINYINT,
        @par_hora_inicio     TIME(0),
        @par_hora_fin        TIME(0)

AS
BEGIN

--Validaciones 
	IF NOT(@PAR_dia_semana BETWEEN 1 AND 7)
		BEGIN
			RAISERROR('El dia debe estar entre 1 y 7', 16, 1);
			RETURN;
		END
	IF @par_costo_deporte < 0
	BEGIN
			RAISERROR('El costo del deporte debe ser mayor a 0', 16, 1);
			RETURN;
	END 
	IF @par_hora_fin<@par_hora_inicio	
		BEGIN
			RAISERROR('La hora de fin debe ser mayor a la de hora de inicio',16,1)
			RETURN;
		END
-- realizo el insert luego de las validaciones
	INSERT INTO actividades.deporte(
        nombre_deporte,
        costo_deporte,
        dia_semana,
        hora_inicio,
        hora_fin
		)
		VALUES(
			@par_nombre_deporte,
			@par_costo_deporte,
			@par_dia_semana,
			@par_hora_inicio,
			@par_hora_fin
		);
END;
GO

--UPDATE
CREATE OR ALTER PROCEDURE actividades.update_deporte
        @par_deporte_id      INT,
		@par_nombre_deporte  VARCHAR(50),
        @par_costo_deporte   DECIMAL(18,2),
        @par_dia_semana      TINYINT,
        @par_hora_inicio     TIME(0),
        @par_hora_fin        TIME(0)
AS
BEGIN
--Validaciones 
	IF @par_dia_semana<1 OR @par_dia_semana>31
		BEGIN
			RAISERROR('El dia debe estar entre 1 y 31', 16, 1);
			RETURN;
		END

	IF @par_hora_fin<@par_hora_inicio	
		BEGIN
			RAISERROR('La hora de fin debe ser mayor a la de hora de inicio',16,1)
			RETURN;
		END

	UPDATE actividades.deporte
	SET
		nombre_deporte=@par_nombre_deporte,
        costo_deporte=@par_costo_deporte,
        dia_semana=@par_dia_semana,
        hora_inicio=@par_hora_inicio,
        hora_fin=@par_hora_fin
		where deporte_id=@par_deporte_id;

END;
GO

--DELETE
CREATE OR ALTER PROCEDURE actividades.delete_deporte
	@par_deporte_id INT
AS
BEGIN
	DELETE FROM  actividades.deporte
    WHERE deporte_id = @par_deporte_id;
END;
GO
---------------------------------------------------------------------------------------------------
-- TABLA actividades.insert_asistencia
-- INSERT
    CREATE OR ALTER PROCEDURE actividades.insert_asistencia
        @par_nro_socio         INT,
        @par_profesor_id       INT,
        @par_deporte_id        INT,
        @par_fec_asistencia    DATE,
        @par_estado_asistencia CHAR(1)
AS
BEGIN
--validaciones

	IF @par_fec_asistencia>GETDATE()
	BEGIN
		RAISERROR('La fecha de asistencia debe ser menor o igual a la fecha actual',16,1)
		RETURN;
	END

	IF NOT (@par_estado_asistencia IN('J','A','P'))
	BEGIN
		RAISERROR('El estado de la asistencia debe tener de valor J, A o P',16,1)
		RETURN;
	END

-- realizo el insert luego de las validaciones
	INSERT INTO actividades.asistencia(
        nro_socio,
        profesor_id,
        deporte_id,
        fec_asistencia,
        estado_asistencia	
	)
	VALUES(
	    @par_nro_socio,
        @par_profesor_id,
        @par_deporte_id,
        @par_fec_asistencia,
        @par_estado_asistencia
	);
END;
GO

--UPDATE

CREATE OR ALTER PROCEDURE actividades.update_asistencia
        @par_asistencia_id	   INT,
		@par_nro_socio         INT,
        @par_profesor_id       INT,
        @par_deporte_id        INT,
        @par_fec_asistencia    DATE,
        @par_estado_asistencia CHAR(1)
AS
BEGIN
--validaciones 
	IF @par_fec_asistencia>GETDATE()
	BEGIN
		RAISERROR('La fecha de asistencia debe ser menor o igual a la fecha actual',16,1)
		RETURN;
	END

	IF NOT (@par_estado_asistencia IN('J','A','P'))
	BEGIN
		RAISERROR('El estado de la asistencia debe tener de valor J, A o P',16,1)
		RETURN;
	END

	UPDATE actividades.asitencia
	SET
		nro_socio=@par_nro_socio,
        profesor_id=@par_profesor_id,
        deporte_id=@par_deporte_id,
        @par_fec_asistencia,
        @par_estado_asistencia
		where asistencia_id=@par_asistencia_id
END;
GO

--DELETE
CREATE OR ALTER PROCEDURE actividades.delete_asistencia
		@par_asistencia_id INT
AS
BEGIN
	DELETE FROM actividades.asistencia
	WHERE @par_asistencia_id = asistencia_id;
END;
GO
---------------------------------------------------------------------------------------------------
-- TABLA actividades.inscripcion_act
-- INSERT
CREATE OR ALTER PROCEDURE actividades.insert_inscripcion_act
        @par_socio_id       INT,
        @par_deporte_id     INT,
        @par_fec_inicio     DATE,
        @par_fec_fin        DATE,
        @par_estado         VARCHAR(20), 
        @par_costo_base     DECIMAL(18,2)
AS
BEGIN
--validaciones
       IF @par_fec_fin < @par_fec_inicio
	   BEGIN
			RAISERROR('La fecha de fin debe ser menor a la fecha de inicio', 16, 1);
			RETURN;
	   END
		IF NOT(@par_estado IN ('pendiente','pagada','vencida'))
		BEGIN
			RAISERROR('El valor de estado debe ser pendiente, pagada o vencida', 16, 1);
			RETURN;
		END
		IF @par_costo_base < 0
		BEGIN
			RAISERROR('El costo base no debe ser menor a 0', 16, 1);
			RETURN;
		END

	INSERT INTO actividades.inscripcion_act(
        socio_id,
        deporte_id,
        fec_inicio,
        fec_fin,
        estado,
        costo_base
	)
	VALUES(
        @par_socio_id,
        @par_deporte_id,
        @par_fec_inicio,
        @par_fec_fin,
        @par_estado, 
        @par_costo_base
	);
END;
GO
--UPDATE
CREATE OR ALTER actividades.update_inscripcion
	    @par_inscripcion_id INT,
        @par_socio_id       INT,
        @par_deporte_id     INT,
        @par_fec_inicio     DATE,
        @par_fec_fin        DATE,
        @par_estado         VARCHAR(20),
        @par_costo_base     DECIMAL(18,2)
AS
BEGIN
--validaciones
       IF @par_fec_fin < @par_fec_inicio
	   BEGIN
			RAISERROR('La fecha de fin debe ser menor a la fecha de inicio', 16, 1);
			RETURN;
	   END
		IF NOT(@par_estado IN ('pendiente','pagada','vencida'))
		BEGIN
			RAISERROR('El valor de estado debe ser pendiente, pagada o vencida', 16, 1);
			RETURN;
		END
		IF @par_costo_base < 0
		BEGIN
			RAISERROR('El costo base no debe ser menor a 0', 16, 1);
			RETURN;
		END

		UPDATE actividades.inscripcion_act
		SET
			socio_id=@par_socio_id,
			deporte_id=@par_deporte_id,
			fec_inicio=@par_fec_inicio,
			fec_fin=@par_fec_fin,
			estado=@par_estado,
			costo_base=@par_costo_base
			WHERE inscripcion_id=@par_inscripcion_id;
END;
GO

--DELETE 

CREATE OR ALTER PROCEDURE actividades.delete_inscripcion_act
		@par_incripcion_id INT
AS
BEGIN
	DELETE FROM actividades.inscripcion_act
	WHERE @par_incripcion_id=inscripcion_id;
END;
GO
---------------------------------------------------------------------------------------------------
-- TABLA actividades.reserva_sum
-- INSERT
CREATE OR ALTER actividades.insert_reserva_sum
        @par_costo_alquiler_sum  DECIMAL(18,2)
AS
BEGIN

--validaciones
	IF @par_costo_alquiler_sum <0
	BEGIN
			RAISERROR('El costo de alquiler no debe ser menor a 0', 16, 1);
			RETURN;
	END
-- realizo el insert luego de las validaciones
	INSERT INTO actividades.reserva_sum(
		costo_alquiler_sum
	)
	VALUES(
	@par_costo_alquiler_sum
	);
END;
GO

--UPDATE
CREATE OR ALTER PROCEDURE actividades.update_reserva_sum
		@par_alquiler_sum_id INT,
        @par_costo_alquiler_sum DECIMAL(18,2)
AS
BEGIN
--validaciones 
	IF @par_costo_alquiler_sum <0
	BEGIN
			RAISERROR('El costo de alquiler no debe ser menor a 0', 16, 1);
			RETURN;
	END
	
	UPDATE actividades.reserva_sum
	SET
		costo_alquiler_sum=@par_costo_alquiler_sum
	WHERE alquiler_sum_id=@par_alquiler_sum_id
END;
GO

--DELETE
CREATE OR ALTER actividades.delete_reserva_sum
		@par_alquiler_sum_id INT
AS
BEGIN
		DELETE FROM actividades.reserva_sum
		WHERE alquiler_sum_id= @par_alquiler_sum_id
END;
GO
---------------------------------------------------------------------------------------------------
-- TABLA actividades.pase_pileta
-- INSERT

CREATE OR ALTER actividades.insert_pase_pileta 
        @par_tarifa_pileta_id  INT,
        @par_jornada_id        INT
AS
BEGIN
	INSERT INTO actividades.pase_pileta (
        tarifa_pileta_id,
        jornada_id,
	)
	VALUES(
        @par_tarifa_pileta_id,
        @par_jornada_id
	);
END;
GO

--UPDATE
CREATE OR ALTER actividades.update_pase_pileta
		@par_pase_pileta_id    INT ,
        @par_tarifa_pileta_id  INT,
        @par_jornada_id        INT
AS
BEGIN
	UPDATE actividades.pase_pileta
	SET
        tarifa_pileta_id=@par_tarifa_pileta_id,
        jornada_id=@par_jornada_id
		WHERE pase_pileta_id=@par_pase_pileta_id

END;
GO

--DELETE
CREATE OR ALTER PROCEDURE actividades.delete_pase_pileta
		@par_pase_pileta_id INT
AS
BEGIN
		DELETE FROM actividades.pase_pileta
		WHERE @par_pase_pileta_id= pase_pileta_id
END;
GO
---------------------------------------------------------------------------------------------------
-- TABLA actividades.inscripcion_act_extra
-- INSERT
CREATE OR ALTER PROCEDURE actividades.inscripcion_act_extra
        @par_socio_id              INT,
        @par_colonia_verano_id     INT,
        @par_alquiler_sum_id       INT,
        @par_pase_pileta_id        INT,
        @par_fec_inicio            DATE,
        @par_fec_fin               DATE,
        @par_costo_base            DECIMAL(18,2)
AS
BEGIN
--validaciones
		IF @par_fec_fin < @par_fec_inicio
		BEGIN
			RAISERROR('La fecha de fin no debe ser menor a la fecha de inicio',16,1)
			RETURN;
		END

		IF @par_costo_base<0
		BEGIN
			RAISERROR('El costo base no debe ser menor a 0',16,1)
			RETURN;
		END

-- realizo el insert luego de las validaciones
	INSERT INTO actividades.inscripcion_act_extra(
        socio_id ,
        colonia_verano_id,
        alquiler_sum_id,
        pase_pileta_id,
        fec_inicio,
        fec_fin,
        costo_base
	)
	VALUES(
		@par_socio_id ,
        @par_colonia_verano_id,
        @par_alquiler_sum_id,
        @par_pase_pileta_id,
        @par_fec_inicio,
        @par_fec_fin,
        @par_costo_base
		);
END;
GO

--UPDATE
CREATE OR ALTER PROCEDURE actividades.update_inscripcion_act_extra
        @par_inscripcion_extra_id  INT,
        @par_socio_id              INT,
        @par_colonia_verano_id     INT,
        @par_alquiler_sum_id       INT,
        @par_pase_pileta_id        INT,
        @par_fec_inicio            DATE,
        @par_fec_fin               DATE,
        @par_costo_base            DECIMAL(18,2) 
AS
BEGIN
--validaciones
		IF @par_fec_fin < @par_fec_inicio
		BEGIN
			RAISERROR('La fecha de fin no debe ser menor a la fecha de inicio',16,1)
			RETURN;
		END

		IF @par_costo_base<0
		BEGIN
			RAISERROR('El costo base no debe ser menor a 0',16,1)
			RETURN;
		END

		UPDATE actividades.inscripciones_act_extra
		SET
		socio_id=@par_socio_id ,
        colonia_verano_id=@par_colonia_verano_id,
        alquiler_sum_id=@par_alquiler_sum_id,
        pase_pileta_id=@par_pase_pileta_id,
        fec_inicio=@par_fec_inicio,
        fec_fin=@par_fec_fin,
        costo_base=@par_costo_base
		WHERE @par_inscripcion_extra_id=inscripcion_extra_id
END;
GO

--DELETE
CREATE OR ALTER PROCEDURE actividades.delete_inscripcion_act_extra
		@par_inscripcion_extra_id INT
AS
BEGIN
	DELETE FROM actividades.inscripcion_act_extra
	WHERE @par_inscripcion_extra_id = inscripcion_extra_id;
END;
GO