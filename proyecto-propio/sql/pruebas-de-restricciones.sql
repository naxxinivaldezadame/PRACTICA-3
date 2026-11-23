-- ============================================================================
-- PRUEBAS DE RESTRICCIONES - GESTIÓN DE UNA FARMACIA
-- ============================================================================

-- A) DATOS BASE VÁLIDOS PARA PROBAR INTEGRIDAD REFERENCIAL
INSERT INTO persona (id_persona, nombre_pila, ap_paterno, ap_materno, telefono) VALUES
(1, 'Carlos', 'Méndez', 'Soto', '5511223344'),
(2, 'Ana', 'López', 'Díaz', '5522334455'),
(3, 'Luis', 'Pérez', 'Cruz', '5533445566');

INSERT INTO doctor (id_persona, cedula_prof, especialidad)
VALUES (1, 'CED-987654', 'Medicina General');

INSERT INTO paciente (id_persona, fecha_nac)
VALUES (2, '1999-08-20');

INSERT INTO sucursal (id_sucursal, nombre, calle, numero, colonia)
VALUES (1, 'Sucursal Lindavista', 'Av. Instituto Politécnico Nacional', '2580', 'Lindavista');

INSERT INTO empleado (id_persona, id_sucursal, contrasena, puesto, fecha_contratacion)
VALUES (3, 1, 'hash_emp_03', 'Farmacéutico', '2026-02-01');

INSERT INTO medicamento (id_medicamento, nombre, marca, caducidad, tipo_venta, costo)
VALUES (1, 'Amoxicilina 500mg', 'Genfar', '2027-11-30', 'Receta', 135.00);

INSERT INTO almacena (id_sucursal, id_medicamento, cantidad, stock_minimo)
VALUES (1, 1, 40, 10);

INSERT INTO venta (id_venta, fecha, id_empleado)
VALUES (1, '2026-10-12 11:15:00', 3);

INSERT INTO detalle_venta (id_venta, no_linea, id_medicamento, cantidad, precio_unitario)
VALUES (1, 1, 1, 2, 135.00);

INSERT INTO receta (folio, id_venta, id_doctor, id_paciente, fecha_emision)
VALUES ('REC-2026-001', 1, 1, 2, '2026-10-12');

-- ============================================================================
-- B) INSTRUCCIONES INVÁLIDAS (DEBEN SER RECHAZADAS POR POSTGRESQL)
-- ============================================================================

-- PRUEBA 1: Violación de CHECK (tipo_venta fuera de dominio 'Libre'/'Receta')
-- Error esperado: new row for relation "medicamento" violates check constraint "ck_medicamento_tipo_venta"
INSERT INTO medicamento (id_medicamento, nombre, marca, caducidad, tipo_venta, costo)
VALUES (2, 'Clonazepam 2mg', 'Roche', '2027-05-01', 'Controlado', 280.00);

-- PRUEBA 2: Violación de FOREIGN KEY (empleado inexistente al registrar venta)
-- Error esperado: insert or update on table "venta" violates foreign key constraint "fk_venta_empleado"
INSERT INTO venta (id_venta, fecha, id_empleado)
VALUES (2, '2026-10-12 12:00:00', 999);

-- PRUEBA 3: Violación de UNIQUE en relación 1:1 (dos recetas apuntando a la misma venta)
-- Error esperado: duplicate key value violates unique constraint "uq_receta_venta"
INSERT INTO receta (folio, id_venta, id_doctor, id_paciente, fecha_emision)
VALUES ('REC-2026-002', 1, 1, 2, '2026-10-12');

-- PRUEBA 4: Violación de CHECK (inventario negativo en sucursal)
-- Error esperado: new row for relation "almacena" violates check constraint "ck_almacena_cantidad"
INSERT INTO almacena (id_sucursal, id_medicamento, cantidad, stock_minimo)
VALUES (1, 1, -10, 5);

-- PRUEBA 5: Violación de CHECK (cantidad vendida igual a cero en detalle_venta)
-- Error esperado: new row for relation "detalle_venta" violates check constraint "ck_detalle_cantidad"
INSERT INTO detalle_venta (id_venta, no_linea, id_medicamento, cantidad, precio_unitario)
VALUES (1, 2, 1, 0, 135.00);