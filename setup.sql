/* Script de inicializacion para syacapp */
USE syacapp;

-- 1. Crear la tabla de alumnos
CREATE TABLE IF NOT EXISTS alumnos (
    rut_id VARCHAR(15) PRIMARY KEY,
    nombre_completo VARCHAR(150) NOT NULL,
    carrera VARCHAR(100) NOT NULL
);

-- 2. Crear la tabla de la malla
CREATE TABLE IF NOT EXISTS malla_curricular (
    id INT AUTO_INCREMENT PRIMARY KEY,
    carrera VARCHAR(100) NOT NULL,
    codigo_asignatura VARCHAR(20) NOT NULL,
    nombre_asignatura VARCHAR(100) NOT NULL,
    semestre_recomendado INT NOT NULL,
    creditos INT NOT NULL,
    prerrequisitos VARCHAR(255),
    UNIQUE KEY (carrera, codigo_asignatura)
);

-- 3. Limpiar tablas para pruebas
TRUNCATE TABLE alumnos;
TRUNCATE TABLE malla_curricular;

-- 4. Insertar alumnos de prueba
INSERT INTO alumnos (rut_id, nombre_completo, carrera)
VALUES
('19.876.543-2', 'Francisca Rojas', 'Ingeniería Informática'),
('20.123.456-K', 'Bastián González', 'Ingeniería Informática')
ON DUPLICATE KEY UPDATE 
    nombre_completo=VALUES(nombre_completo),
    carrera=VALUES(carrera);

-- 5. Insertar malla de Ingeniería Informática
INSERT INTO malla_curricular (carrera, codigo_asignatura, nombre_asignatura, semestre_recomendado, creditos, prerrequisitos)
VALUES
('Ingeniería Informática', 'MAT-100', 'Álgebra', 1, 5, NULL),
('Ingeniería Informática', 'INF-100', 'Introducción a la Programación', 1, 6, NULL),
('Ingeniería Informática', 'FYQ-100', 'Física General', 1, 5, NULL),
('Ingeniería Informática', 'CAD-100', 'Comunicación y Redacción', 1, 4, NULL),
('Ingeniería Informática', 'MAT-200', 'Cálculo I', 2, 5, 'MAT-100'),
('Ingeniería Informática', 'INF-200', 'Programación Avanzada', 2, 6, 'INF-100'),
('Ingeniería Informática', 'MAT-201', 'Álgebra Lineal', 2, 5, 'MAT-100'),
('Ingeniería Informática', 'FYQ-200', 'Mecánica', 2, 5, 'FYQ-100,MAT-100'),
('Ingeniería Informática', 'MAT-300', 'Cálculo II', 3, 5, 'MAT-200'),
('Ingeniería Informática', 'INF-300', 'Estructuras de Datos', 3, 6, 'INF-200'),
('Ingeniería Informática', 'INF-301', 'Bases de Datos', 3, 6, 'INF-200'),
('Ingeniería Informática', 'EST-300', 'Probabilidad y Estadística', 3, 5, 'MAT-200'),
('Ingeniería Informática', 'INF-400', 'Sistemas Operativos', 4, 6, 'INF-300'),
('Ingeniería Informática', 'INF-401', 'Algoritmos y Complejidad', 4, 6, 'INF-300'),
('Ingeniería Informática', 'INF-402', 'Ingeniería de Software I', 4, 5, 'INF-301');