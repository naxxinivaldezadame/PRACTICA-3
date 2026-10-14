-- 1. MUNICIPIO
CREATE TABLE municipio (
    id_municipio SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- 2. COMUNIDAD (Débil o dependiente de Municipio por relación 1 a N)
CREATE TABLE comunidad (
    id_comunidad SERIAL PRIMARY KEY,
    id_municipio INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    CONSTRAINT fk_comunidad_municipio FOREIGN KEY (id_municipio)
        REFERENCES municipio (id_municipio)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. CONSTRUCTORA
CREATE TABLE constructora (
    id_constructora SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL
);

-- 4. FUENTE_FINANCIAMIENTO
CREATE TABLE fuente_financiamiento (
    id_fuente SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL
);

-- 5. PRESUPUESTO
CREATE TABLE presupuesto (
    id_presupuesto SERIAL PRIMARY KEY,
    id_fuente INT NOT NULL,
    monto NUMERIC(12, 2) NOT NULL,
    CONSTRAINT fk_presupuesto_fuente FOREIGN KEY (id_fuente)
        REFERENCES fuente_financiamiento (id_fuente)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 6. OBRA
CREATE TABLE obra (
    id_obra INT PRIMARY KEY, -- id_obra según tu EER
    id_comunidad INT NOT NULL,
    id_constructora INT NOT NULL,
    id_presupuesto INT NOT NULL,
    descripcion TEXT,
    CONSTRAINT fk_obra_comunidad FOREIGN KEY (id_comunidad)
        REFERENCES comunidad (id_comunidad)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_obra_constructora FOREIGN KEY (id_constructora)
        REFERENCES constructora (id_constructora)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_obra_presupuesto FOREIGN KEY (id_presupuesto)
        REFERENCES presupuesto (id_presupuesto)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 7. PERSONAL (Supertipo de la jerarquía disjunta: DIRECTOR, SUPERVISOR, PROYECTISTA, SECRETARIA)
CREATE TABLE personal (
    codigo_personal INT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    tipo_personal VARCHAR(50) NOT NULL CHECK (tipo_personal IN ('DIRECTOR', 'SUPERVISOR', 'PROYECTISTA', 'SECRETARIA'))
);

-- Subtipos o tablas específicas para cada rol del personal (Estrategia de tabla por subtipo o combinada)
CREATE TABLE director (
    codigo_personal INT PRIMARY KEY,
    CONSTRAINT fk_director_personal FOREIGN KEY (codigo_personal)
        REFERENCES personal (codigo_personal) ON DELETE CASCADE
);

CREATE TABLE supervisor (
    codigo_personal INT PRIMARY KEY,
    CONSTRAINT fk_supervisor_personal FOREIGN KEY (codigo_personal)
        REFERENCES personal (codigo_personal) ON DELETE CASCADE
);

CREATE TABLE proyectista (
    codigo_personal INT PRIMARY KEY,
    CONSTRAINT fk_proyectista_personal FOREIGN KEY (codigo_personal)
        REFERENCES personal (codigo_personal) ON DELETE CASCADE
);

CREATE TABLE secretaria (
    codigo_personal INT PRIMARY KEY,
    CONSTRAINT fk_secretaria_personal FOREIGN KEY (codigo_personal)
        REFERENCES personal (codigo_personal) ON DELETE CASCADE
);

-- 8. TIPO_EVENTO y EVENTO_AUDITORIA
CREATE TABLE tipo_evento (
    id_tipo_evento SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE evento_auditoria (
    id_evento SERIAL PRIMARY KEY,
    codigo_personal INT NOT NULL,
    id_obra INT NOT NULL,
    id_tipo_evento INT NOT NULL,
    fecha DATE NOT NULL,
    CONSTRAINT fk_evento_personal FOREIGN KEY (codigo_personal) REFERENCES personal (codigo_personal),
    CONSTRAINT fk_evento_obra FOREIGN KEY (id_obra) REFERENCES obra (id_obra),
    CONSTRAINT fk_evento_tipo FOREIGN KEY (id_tipo_evento) REFERENCES tipo_evento (id_tipo_evento)
);

-- 9. AVANCE_MENSUAL (Entidad débil con clave primaria compuesta: id_obra + mes)
CREATE TABLE avance_mensual (
    id_obra INT,
    mes INT CHECK (mes BETWEEN 1 AND 12),
    porcentaje_avance NUMERIC(5,2) NOT NULL,
    PRIMARY KEY (id_obra, mes),
    CONSTRAINT fk_avance_obra FOREIGN KEY (id_obra)
        REFERENCES obra (id_obra)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 10. EVIDENCIA_FOTOGRAFICA (Entidad débil con clave primaria compuesta: id_obra + numero_foto)
CREATE TABLE evidencia_fotografica (
    id_obra INT,
    numero_foto INT,
    url_foto VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_obra, numero_foto),
    CONSTRAINT fk_evidencia_obra FOREIGN KEY (id_obra)
        REFERENCES obra (id_obra)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 11. POBLADOR, PROPUESTA y VOTO
CREATE TABLE poblador (
    curp VARCHAR(18) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL
);

CREATE TABLE propuesta (
    id_propuesta SERIAL PRIMARY KEY,
    curp VARCHAR(18) NOT NULL,
    id_comunidad INT NOT NULL,
    id_obra INT NULL, -- Relación opcional con obra (0..1)
    CONSTRAINT fk_propuesta_poblador FOREIGN KEY (curp) REFERENCES poblador (curp),
    CONSTRAINT fk_propuesta_comunidad FOREIGN KEY (id_comunidad) REFERENCES comunidad (id_comunidad),
    CONSTRAINT fk_propuesta_obra FOREIGN KEY (id_obra) REFERENCES obra (id_obra)
);

CREATE TABLE voto (
    curp VARCHAR(18),
    id_propuesta INT,
    PRIMARY KEY (curp, id_propuesta),
    CONSTRAINT fk_voto_poblador FOREIGN KEY (curp) REFERENCES poblador (curp),
    CONSTRAINT fk_voto_propuesta FOREIGN KEY (id_propuesta) REFERENCES propuesta (id_propuesta)
);