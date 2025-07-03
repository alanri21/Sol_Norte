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
-- Descripción: Inserta categoría 'Bronce' con costo 150.00
-- Resultado esperado: Se inserta la fila sin errores
--------------------------------------------------------------------------------
EXEC insert_categoria_socio
    @par_nombreCategoria = 'Bronce',
    @par_costoMembresia  = 150.00;
GO

SELECT * 
  FROM socios.categoria_socio 
 WHERE nombre_categoria = 'Bronce';
-- Debe retornar 1 fila con nombre_categoria='Bronce', costo_membresia=150.00
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