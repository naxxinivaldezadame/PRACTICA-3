-- ============================================================================
-- PRÁCTICA 3: ESQUEMA RELACIONAL - PROYECTO PROPIO "GESTIÓN DE UNA FARMACIA"
-- ============================================================================

-- Limpieza previa (orden inverso a dependencias)
DROP VIEW IF EXISTS v_venta_total;
DROP TABLE IF EXISTS orden_reposicion CASCADE;
DROP TABLE IF EXISTS suministra CASCADE;
DROP TABLE IF EXISTS telefono_proveedor CASCADE;
DROP TABLE IF EXISTS proveedor CASCADE;
DROP TABLE IF EXISTS almacena CASCADE;
DROP TABLE IF EXISTS detalle_venta CASCADE;
DROP TABLE IF EXISTS sustancia_activa CASCADE;
DROP TABLE IF EXISTS medicamento CASCADE;
DROP TABLE IF EXISTS receta CASCADE;
DROP TABLE IF EXISTS venta CASCADE;
DROP TABLE IF EXISTS empleado CASCADE;
DROP TABLE IF EXISTS sucursal CASCADE;
DROP TABLE IF EXISTS doctor CASCADE;
DROP TABLE IF EXISTS alergia_paciente CASCADE;
DROP TABLE IF EXISTS paciente CASCADE;
DROP TABLE IF EXISTS persona CASCADE;

-- 1. Supertipo PERSONA (Regla 1 y Regla 9 - Estrategia A: tabla por supertipo y subtipo)
CREATE TABLE persona (
    id_persona   INT          NOT NULL,
    nombre_pila  VARCHAR(60)  NOT NULL,
    ap_paterno   VARCHAR(60)  NOT NULL,
    ap_materno   VARCHAR(60)  NULL,
    telefono     VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_persona PRIMARY KEY (id_persona)
);

-- 2. Subtipo PACIENTE (Regla 9 - Estrategia A)
CREATE TABLE paciente (
    id_persona   INT   NOT NULL,
    fecha_nac    DATE  NOT NULL,
    CONSTRAINT pk_paciente PRIMARY KEY (id_persona),
    CONSTRAINT fk_paciente_persona FOREIGN KEY (id_persona)
        REFERENCES persona (id_persona)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 3. Atributo multivaluado ALERGIA_PACIENTE (Regla 3)
CREATE TABLE alergia_paciente (
    id_persona   INT           NOT NULL,
    alergia      VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_alergia_paciente PRIMARY KEY (id_persona, alergia),
    CONSTRAINT fk_alergia_paciente FOREIGN KEY (id_persona)
        REFERENCES paciente (id_persona)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 4. Subtipo DOCTOR (Regla 9 - Estrategia A)
CREATE TABLE doctor (
    id_persona    INT           NOT NULL,
    cedula_prof   VARCHAR(30)   NOT NULL,
    especialidad  VARCHAR(80)   NOT NULL,
    CONSTRAINT pk_doctor PRIMARY KEY (id_persona),
    CONSTRAINT uq_doctor_cedula UNIQUE (cedula_prof),
    CONSTRAINT fk_doctor_persona FOREIGN KEY (id_persona)
        REFERENCES persona (id_persona)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 5. Entidad fuerte SUCURSAL con atributo compuesto dirección descompuesto (Reglas 1 y 2)
CREATE TABLE sucursal (
    id_sucursal  INT           NOT NULL,
    nombre       VARCHAR(80)   NOT NULL,
    calle        VARCHAR(100)  NOT NULL,
    numero       VARCHAR(20)   NOT NULL,
    colonia      VARCHAR(80)   NOT NULL,
    CONSTRAINT pk_sucursal PRIMARY KEY (id_sucursal)
);

-- 6. Subtipo EMPLEADO + Relación 1:N obligatoria con SUCURSAL (Reglas 4 y 9)
CREATE TABLE empleado (
    id_persona          INT          NOT NULL,
    id_sucursal         INT          NOT NULL,
    contrasena          VARCHAR(255) NOT NULL,
    puesto              VARCHAR(50)  NOT NULL,
    fecha_contratacion  DATE         NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT pk_empleado PRIMARY KEY (id_persona),
    CONSTRAINT fk_empleado_persona FOREIGN KEY (id_persona)
        REFERENCES persona (id_persona)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_empleado_sucursal FOREIGN KEY (id_sucursal)
        REFERENCES sucursal (id_sucursal)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 7. Entidad fuerte VENTA + Relación 1:N con EMPLEADO (Reglas 1 y 4)
-- Nota: El atributo derivado "total" se calcula dinámicamente en la vista v_venta_total
CREATE TABLE venta (
    id_venta     INT        NOT NULL,
    fecha        TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_empleado  INT        NOT NULL,
    CONSTRAINT pk_venta PRIMARY KEY (id_venta),
    CONSTRAINT fk_venta_empleado FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_persona)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 8. Entidad RECETA + Relación 1:1 opcional (0,1)-(1,1) con VENTA (Reglas 1, 4 y 6.1)
CREATE TABLE receta (
    folio          VARCHAR(30)  NOT NULL,
    id_venta       INT          NOT NULL,
    id_doctor      INT          NOT NULL,
    id_paciente    INT          NOT NULL,
    fecha_emision  DATE         NOT NULL,
    CONSTRAINT pk_receta PRIMARY KEY (folio),
    CONSTRAINT uq_receta_venta UNIQUE (id_venta),
    CONSTRAINT fk_receta_venta FOREIGN KEY (id_venta)
        REFERENCES venta (id_venta)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_receta_doctor FOREIGN KEY (id_doctor)
        REFERENCES doctor (id_persona)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_receta_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente (id_persona)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 9. Entidad fuerte MEDICAMENTO (Regla 1)
CREATE TABLE medicamento (
    id_medicamento  INT            NOT NULL,
    nombre          VARCHAR(100)   NOT NULL,
    marca           VARCHAR(80)    NOT NULL,
    caducidad       DATE           NOT NULL,
    tipo_venta      VARCHAR(20)    NOT NULL,
    costo           NUMERIC(10,2)  NOT NULL,
    CONSTRAINT pk_medicamento PRIMARY KEY (id_medicamento),
    CONSTRAINT ck_medicamento_tipo_venta CHECK (tipo_venta IN ('Libre', 'Receta')),
    CONSTRAINT ck_medicamento_costo CHECK (costo > 0)
);

-- 10. Atributo multivaluado SUSTANCIA_ACTIVA (Regla 3)
CREATE TABLE sustancia_activa (
    id_medicamento  INT           NOT NULL,
    sustancia       VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_sustancia_activa PRIMARY KEY (id_medicamento, sustancia),
    CONSTRAINT fk_sustancia_medicamento FOREIGN KEY (id_medicamento)
        REFERENCES medicamento (id_medicamento)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 11. Entidad débil DETALLE_VENTA con dependencia de identificación (Regla 8)
CREATE TABLE detalle_venta (
    id_venta         INT            NOT NULL,
    no_linea         INT            NOT NULL,
    id_medicamento   INT            NOT NULL,
    cantidad         INT            NOT NULL,
    precio_unitario  NUMERIC(10,2)  NOT NULL,
    CONSTRAINT pk_detalle_venta PRIMARY KEY (id_venta, no_linea),
    CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT fk_detalle_venta FOREIGN KEY (id_venta)
        REFERENCES venta (id_venta)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_medicamento FOREIGN KEY (id_medicamento)
        REFERENCES medicamento (id_medicamento)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 12. Relación M:N ALMACENA entre SUCURSAL y MEDICAMENTO (Regla 5)
CREATE TABLE almacena (
    id_sucursal     INT  NOT NULL,
    id_medicamento  INT  NOT NULL,
    cantidad        INT  NOT NULL DEFAULT 0,
    stock_minimo    INT  NOT NULL DEFAULT 5,
    CONSTRAINT pk_almacena PRIMARY KEY (id_sucursal, id_medicamento),
    CONSTRAINT ck_almacena_cantidad CHECK (cantidad >= 0),
    CONSTRAINT ck_almacena_stock_min CHECK (stock_minimo >= 0),
    CONSTRAINT fk_almacena_sucursal FOREIGN KEY (id_sucursal)
        REFERENCES sucursal (id_sucursal)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_almacena_medicamento FOREIGN KEY (id_medicamento)
        REFERENCES medicamento (id_medicamento)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 13. Entidad fuerte PROVEEDOR (Regla 1)
CREATE TABLE proveedor (
    id_proveedor  INT           NOT NULL,
    nombre        VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor)
);

-- 14. Atributo multivaluado TELEFONO_PROVEEDOR (Regla 3)
CREATE TABLE telefono_proveedor (
    id_proveedor  INT          NOT NULL,
    telefono      VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_telefono_proveedor PRIMARY KEY (id_proveedor, telefono),
    CONSTRAINT fk_telefono_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES proveedor (id_proveedor)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 15. Relación M:N SUMINISTRA entre PROVEEDOR y MEDICAMENTO (Regla 5)
CREATE TABLE suministra (
    id_proveedor    INT            NOT NULL,
    id_medicamento  INT            NOT NULL,
    precio_compra   NUMERIC(10,2)  NOT NULL,
    CONSTRAINT pk_suministra PRIMARY KEY (id_proveedor, id_medicamento),
    CONSTRAINT ck_suministra_precio CHECK (precio_compra > 0),
    CONSTRAINT fk_suministra_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES proveedor (id_proveedor)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_suministra_medicamento FOREIGN KEY (id_medicamento)
        REFERENCES medicamento (id_medicamento)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 16. Entidad ORDEN_REPOSICION vinculada a la agregación ALMACENA y a PROVEEDOR (Reglas 1 y 4)
CREATE TABLE orden_reposicion (
    id_orden             INT          NOT NULL,
    id_sucursal          INT          NOT NULL,
    id_medicamento       INT          NOT NULL,
    id_proveedor         INT          NOT NULL,
    fecha                DATE         NOT NULL DEFAULT CURRENT_DATE,
    cantidad_solicitada  INT          NOT NULL,
    estado               VARCHAR(20)  NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT pk_orden_reposicion PRIMARY KEY (id_orden),
    CONSTRAINT ck_orden_cantidad CHECK (cantidad_solicitada > 0),
    CONSTRAINT ck_orden_estado CHECK (estado IN ('Pendiente', 'Enviada', 'Recibida', 'Cancelada')),
    CONSTRAINT fk_orden_almacena FOREIGN KEY (id_sucursal, id_medicamento)
        REFERENCES almacena (id_sucursal, id_medicamento)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_orden_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES proveedor (id_proveedor)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Vista para calcular el atributo derivado "total" de VENTA
CREATE VIEW v_venta_total AS
SELECT
    v.id_venta,
    v.fecha,
    v.id_empleado,
    COALESCE(SUM(dv.cantidad * dv.precio_unitario), 0) AS total
FROM venta v
LEFT JOIN detalle_venta dv ON v.id_venta = dv.id_venta
GROUP BY v.id_venta, v.fecha, v.id_empleado;