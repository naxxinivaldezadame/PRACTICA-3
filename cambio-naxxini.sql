-- Archivo: cambio-naxxini.sql
-- Propuesta individual (Naxxini Giovani Valdez Adame): 
-- Historial y calificación de desempeño de contratistas mediante IA

CREATE TABLE calificacion_contratista (
    id_calificacion SERIAL PRIMARY KEY,
    id_constructora INT NOT NULL,
    id_obra INT NOT NULL,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    puntaje_calidad NUMERIC(5, 2) NOT NULL CHECK (puntaje_calidad BETWEEN 0 AND 10),
    puntaje_puntualidad NUMERIC(5, 2) NOT NULL CHECK (puntaje_puntualidad BETWEEN 0 AND 10),
    -- Campos requeridos por el requisito extra de IA:
    version_modelo VARCHAR(50) NOT NULL, -- Versión del modelo de IA que evaluó
    marca_tiempo TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Cuándo se generó la predicción/calificación
    comentarios TEXT,
    CONSTRAINT fk_calificacion_constructora FOREIGN KEY (id_constructora)
        REFERENCES constructora (id_constructora)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_calificacion_obra FOREIGN KEY (id_obra)
        REFERENCES obra (id_obra)
        ON DELETE CASCADE ON UPDATE CASCADE
);