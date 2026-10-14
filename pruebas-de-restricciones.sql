-- Archivo: pruebas-de-restricciones.sql
-- Demostración de rechazo de restricciones por el SGBD

-- 1. Violación de Llave Primaria (Duplicada)
INSERT INTO municipio (id_municipio, nombre) VALUES (1, 'Cuauhtémoc');
INSERT INTO municipio (id_municipio, nombre) VALUES (1, 'Miguel Hidalgo'); -- Debe fallar

-- 2. Violación de Restricción CHECK (Mes inválido)
INSERT INTO obra (id_obra, id_comunidad, id_constructora, id_presupuesto) VALUES (100, 1, 1, 1);
INSERT INTO avance_mensual (id_obra, mes, porcentaje_avance) VALUES (100, 15, 50.0); -- Debe fallar

-- 3. Violación de Llave Foránea (Referencia inexistente)
INSERT INTO comunidad (id_comunidad, id_municipio, nombre) VALUES (50, 999, 'Pueblo Fantasma'); -- Debe fallar