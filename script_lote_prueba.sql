/*****************************************
** Lotes de prueba - Grupo 2
** Fecha de entrega: xx/xx/xxxx
** Nombre de la materia: Base de datos aplicada
** Ingrantes:
** 40896369		Riquelme Alan Adriel
** 41173099		Eduardo Abel Hidalgo
** --------		--------------------
******************************************/

USE Sol_Norte;
GO

--------------------------------------------------------------------------------
-- Tabla socios.categoria_socio
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Prueba 1: INSERT válido
-- Descripción: Inserta varias categorias
-- Resultado esperado: Se inserta la fila sin errores
--------------------------------------------------------------------------------
EXEC insert_categoria_socio
    @par_nombreCategoria = 'Bronce',
    @par_costoMembresia  = 150.00;
GO

EXEC insert_categoria_socio
    @par_nombreCategoria = 'Plata',
    @par_costoMembresia  = 300.00;
GO

EXEC insert_categoria_socio
    @par_nombreCategoria = 'Oro',
    @par_costoMembresia  = 500.00;
GO

SELECT * 
  FROM socios.categoria_socio;
-- Debe retornar 3 filas
GO

--------------------------------------------------------------------------------
-- Prueba 2: INSERT inválido – costo negativo
-- Descripción: intenta insertar categoría 'Plata' con costo -20.00
-- Resultado esperado: Error 'El costo de membresía debe ser >= 0.'
--------------------------------------------------------------------------------
EXEC insert_categoria_socio
    @par_nombreCategoria = 'Plata',
    @par_costoMembresia  = -20.00;
GO

SELECT * 
  FROM socios.categoria_socio;
GO
--------------------------------------------------------------------------------
-- Prueba 3: UPDATE válido
-- Descripción: modifica la categoría 'Bronce' a 'Bronce Plus', costo 175.00
-- Resultado esperado: Se actualiza la fila sin errores
--------------------------------------------------------------------------------

-- Identificamos el ID de 'Bronce'
DECLARE @idBronce INT;
SELECT @idBronce = categoria_socio_id
  FROM socios.categoria_socio
 WHERE nombre_categoria = 'Bronce';

EXEC update_categoria_socio
    @par_categoriaSocioID = @idBronce,
    @par_nombreCategoria  = 'Bronce Plus',
    @par_costoMembresia   = 175.00;

SELECT * 
  FROM socios.categoria_socio 
 WHERE categoria_socio_id = @idBronce;
-- Debe retornar nombre_categoria='Bronce Plus', costo_membresia=175.00
GO

--------------------------------------------------------------------------------
-- Prueba 4: UPDATE inválido – nombre vacío
-- Descripción: intenta dejar nombre en ''
-- Resultado esperado: Error 'Debe especificar un nombre de categoría válido.'
--------------------------------------------------------------------------------
-- Identificamos el ID de 'Bronce Plus'
DECLARE @idBroncePlus INT;
SELECT @idBroncePlus = categoria_socio_id
  FROM socios.categoria_socio
 WHERE nombre_categoria = 'Bronce Plus';

EXEC update_categoria_socio
    @par_categoriaSocioID = @idBroncePlus,
    @par_nombreCategoria  = '',
    @par_costoMembresia   = 175.00;
GO

--------------------------------------------------------------------------------
-- Prueba 5: DELETE válido
-- Descripción: elimina la categoría recién creada (ID = @idBronce)
-- Resultado esperado: La fila se borra sin errores
--------------------------------------------------------------------------------
-- Identificamos el ID de 'Bronce Plus'
DECLARE @idBroncePlus INT;
SELECT @idBroncePlus = categoria_socio_id
  FROM socios.categoria_socio
 WHERE nombre_categoria = 'Bronce Plus';

EXEC delete_CategoriaSocio
    @par_categoriaSocioID = @idBroncePlus;

SELECT * 
  FROM socios.categoria_socio 
 WHERE categoria_socio_id = @idBroncePlus;
-- No debe retornar filas
GO

--------------------------------------------------------------------------------
-- Tabla socios.categoria_socio
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Caso 1: INSERT VÁLIDO
-- Descripción: socio con datos correctos
-- Resultado esperado: se inserta sin errores
--------------------------------------------------------------------------------
DECLARE @cat INT;
DECLARE @fec_actual DATE;
DECLARE @nro_socio INT;

SELECT @cat = categoria_socio_id
FROM socios.categoria_socio
WHERE nombre_categoria = 'Oro';

SELECT @fec_actual = cast(GETDATE() as date);

EXEC insert_socio
    @par_categoriaSocioID         = @cat,
    @par_nombre                   = 'Juan',
    @par_apellido                 = 'Pérez',
    @par_edad                     = 30,
    @par_fec_inscripcion          = @fec_actual,
    @par_dni                      = '12345678',
    @par_email                    = 'juan.perez@example.com',
    @par_fec_nacimiento           = '1995-04-15',
    @par_tel_contacto             = '1122334455',
    @par_tel_contacto_emergencia  = '1199887766',
    @par_nombre_prepaga           = 'Medife',
    @par_nro_socio_prepaga        = 'MP1234',
    @par_tel_prepaga_emergencia   = '1144556677',
    @par_responsable_pago         = NULL,
    @par_parentezco               = NULL;

EXEC insert_socio
    @par_categoriaSocioID         = @cat,
    @par_nombre                   = 'Alan',
    @par_apellido                 = 'Riquelme',
    @par_edad                     = 20,
    @par_fec_inscripcion          = @fec_actual,
    @par_dni                      = '40896369',
    @par_email                    = 'alriquelme@example.com',
    @par_fec_nacimiento           = '1998-04-15',
    @par_tel_contacto             = '1122334455',
    @par_tel_contacto_emergencia  = '1199887766',
    @par_nombre_prepaga           = 'Medife',
    @par_nro_socio_prepaga        = 'MP1234',
    @par_tel_prepaga_emergencia   = '1144556677',
    @par_responsable_pago         = NULL,
    @par_parentezco               = NULL;

SELECT @nro_socio = nro_socio FROM socios.socio where dni = 40896369;
EXEC insert_socio
    @par_categoriaSocioID         = @cat,
    @par_nombre                   = 'Camila',
    @par_apellido                 = 'Manuli',
    @par_edad                     = 10,
    @par_fec_inscripcion          = @fec_actual,
    @par_dni                      = '59875234',
    @par_email                    = 'camila.manuli@example.com',
    @par_fec_nacimiento           = '2015-05-15',
    @par_tel_contacto             = '1122334455',
    @par_tel_contacto_emergencia  = '1199887766',
    @par_nombre_prepaga           = 'Medife',
    @par_nro_socio_prepaga        = 'MP1234',
    @par_tel_prepaga_emergencia   = '1144556677',
    @par_responsable_pago         = @nro_socio,
    @par_parentezco               = 'hermana';

-- Verificación
SELECT * FROM socios.socio;
-- Debe aparecer el socio 'Juan Pérez' y 'Alan Riquelme'
GO
--------------------------------------------------------------------------------
-- Caso 2: INSERT INVALIDO
-- Descripción: socio menor, sin un socio responsable
-- Resultado esperado: se espera que no inserte ningun resultado
--------------------------------------------------------------------------------
DECLARE @cat INT;
DECLARE @fec_actual DATE;

SELECT @cat = categoria_socio_id
FROM socios.categoria_socio
WHERE nombre_categoria = 'Oro';

SELECT @fec_actual = cast(GETDATE() as date);

EXEC insert_socio
    @par_categoriaSocioID         = @cat,
    @par_nombre                   = 'Renzo',
    @par_apellido                 = 'Vattino',
    @par_edad                     = 10,
    @par_fec_inscripcion          = @fec_actual,
    @par_dni                      = '25498768',
    @par_email                    = 'renzo.vattino@example.com',
    @par_fec_nacimiento           = '2015-05-15',
    @par_tel_contacto             = '1122334455',
    @par_tel_contacto_emergencia  = '1199887766',
    @par_nombre_prepaga           = 'Medife',
    @par_nro_socio_prepaga        = 'MP1234',
    @par_tel_prepaga_emergencia   = '1144556677',
    @par_responsable_pago         = NULL,
    @par_parentezco               = NULL;

-- Verificación
SELECT * FROM socios.socio;
GO

--------------------------------------------------------------------------------
-- Caso 3: UPDATE VALIDO
-- Descripción: modifico al socio camila
-- Resultado esperado: se espera que modifique varias campos del registro
--------------------------------------------------------------------------------
declare @nro_socio_camila int;

select @nro_socio_camila = nro_socio 
from socios.socio 
where dni = 59875234;


EXEC update_socio
    @par_nro_socio               = @nro_socio_camila,
    @par_categoriaSocioID        = 25,
    @par_nombre                  = 'Camila',
    @par_apellido                = 'Manuli',
    @par_edad                    = 11,
    @par_fec_inscripcion         = '2025-06-03',
    @par_dni                     = '59875234', 
    @par_email                   = 'camila.m@example.com',
    @par_fec_nacimiento          = '2015-05-15',
    @par_tel_contacto            = '1122334455',
    @par_tel_contacto_emergencia = '1199887766',
    @par_nombre_prepaga          = 'Medife',
    @par_nro_socio_prepaga       = 'MP1234',
    @par_tel_prepaga_emergencia  = '1144556677',
    @par_responsable_pago        = 9,
    @par_parentezco              = 'hermana';
GO

-- Verificación
SELECT * FROM socios.socio;
GO

--------------------------------------------------------------------------------
-- Caso 4: UPDATE INVALIDO
-- Descripción: modifico al socio camila
-- Resultado esperado: se espera que arroje un error, ya que se esta colocando una categoria de socio que no existe
--------------------------------------------------------------------------------
declare @nro_socio_camila int;

select @nro_socio_camila = nro_socio 
from socios.socio 
where dni = 59875234;


EXEC update_socio
    @par_nro_socio               = @nro_socio_camila,
    @par_categoriaSocioID        = 1000, -- no existe
    @par_nombre                  = 'Camila',
    @par_apellido                = 'Manuli',
    @par_edad                    = 11,
    @par_fec_inscripcion         = '2025-06-03',
    @par_dni                     = '59875234', 
    @par_email                   = 'camila.m@example.com',
    @par_fec_nacimiento          = '2015-05-15',
    @par_tel_contacto            = '1122334455',
    @par_tel_contacto_emergencia = '1199887766',
    @par_nombre_prepaga          = 'Medife',
    @par_nro_socio_prepaga       = 'MP1234',
    @par_tel_prepaga_emergencia  = '1144556677',
    @par_responsable_pago        = 9,
    @par_parentezco              = 'hermana';
GO

-- Verificación
SELECT * FROM socios.socio;
GO
--------------------------------------------------------------------------------
-- Caso 5: DELETE INVALIDO
-- Descripción: intento eliminar al socio Alan (responsable de otro)
-- Resultado esperado: Erro, ya que Alan esta como RP 
--------------------------------------------------------------------------------
DECLARE @idAlan INT;
SELECT @idAlan = nro_socio
FROM socios.socio
WHERE dni = '40896369';

EXEC delete_socio
    @par_nro_socio = @idAlan;
GO

SELECT *
  FROM socios.socio
 WHERE nro_socio = @idAlan;
-- Esperado: registro de Alan todavía existe
GO
--------------------------------------------------------------------------------
-- Caso 6: DELETE VÁLIDO
-- Descripción: elimino al socio Camila (menor con responsable)
-- Resultado esperado: se elimina sin error. La fila no aparece en la tabla
--------------------------------------------------------------------------------
DECLARE @idCamila INT;
SELECT @idCamila = nro_socio
  FROM socios.socio
 WHERE dni = '59875234';

EXEC delete_socio
    @par_nro_socio = @idCamila;

SELECT *
  FROM socios.socio
 WHERE nro_socio = @idCamila;
-- Esperado: ningún registro
GO


