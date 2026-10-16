-- =====================================================
-- Base de datos: Sistema de Gestion Academica (MySQL 8+)
-- =====================================================
DROP DATABASE IF EXISTS gestion_academica;
CREATE DATABASE gestion_academica CHARACTER SET utf8mb4;
USE gestion_academica;

-- =====================================================
-- TABLAS
-- =====================================================
CREATE TABLE grado (
    id_grado INT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE asignatura (
    id_asignatura INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE periodo (
    id_periodo INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE estudiante (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    id_grado      INT NOT NULL,
    UNIQUE (nombre, id_grado),   -- mismo nombre en otro grado = otro registro
    FOREIGN KEY (id_grado) REFERENCES grado(id_grado)
);

CREATE TABLE nota (
    id_nota       INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_asignatura INT NOT NULL,
    id_periodo    INT NOT NULL,
    valor         DECIMAL(3,2) NOT NULL,
    CHECK (valor >= 0 AND valor <= 5),
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante),
    FOREIGN KEY (id_asignatura) REFERENCES asignatura(id_asignatura),
    FOREIGN KEY (id_periodo)    REFERENCES periodo(id_periodo)
);

-- =====================================================
-- DATOS DE PRUEBA
-- =====================================================
INSERT INTO grado (nombre)      VALUES ('Grado 1'), ('Grado 2'), ('Grado 3');
INSERT INTO asignatura (nombre) VALUES ('Matematicas'), ('Ciencias'), ('Ingles'), ('Tecnologia');
INSERT INTO periodo (nombre)    VALUES ('Periodo 1'), ('Periodo 2'), ('Periodo 3');

INSERT INTO estudiante (nombre, id_grado) VALUES
    ('Cesar Reguillo', 1),
    ('Luis Gonzales',  2),
    ('Edgar Rolon',    1),
    ('Darwin Garcia',  3),
    ('Jorley Toloza',  3);

-- (id_estudiante, id_asignatura, id_periodo, valor)
INSERT INTO nota (id_estudiante, id_asignatura, id_periodo, valor) VALUES
    (1, 1, 1, 4.5), (1, 1, 2, 4.0), (1, 3, 1, 3.8),
    (2, 1, 1, 2.5), (2, 2, 1, 2.9), (2, 4, 2, 2.2),
    (3, 2, 1, 3.2), (3, 2, 2, 4.8), (3, 4, 3, 5.0),
    (4, 4, 1, 5.0), (4, 4, 2, 4.0), (4, 4, 3, 4.4),
    (5, 4, 1, 4.0), (5, 4, 2, 4.0), (5, 4, 3, 4.0);

-- =====================================================
-- PROCEDIMIENTOS
-- =====================================================
DELIMITER $$

-- 1) Mostrar estudiantes por grado
--    Uso: CALL sp_estudiantes_por_grado('Grado 1');
CREATE PROCEDURE sp_estudiantes_por_grado(IN p_grado VARCHAR(30))
BEGIN
    SELECT e.nombre AS Estudiante, g.nombre AS Grado
    FROM estudiante e
    JOIN grado g ON g.id_grado = e.id_grado
    WHERE g.nombre = p_grado
    ORDER BY e.nombre;
END$$

-- 2) Mostrar notas de un estudiante por asignatura y periodo
--    Uso: CALL sp_notas_por_asignatura_periodo('Cesar Reguillo', 'Matematicas', 'Periodo 1');
CREATE PROCEDURE sp_notas_por_asignatura_periodo(
    IN p_estudiante VARCHAR(100),
    IN p_asignatura VARCHAR(50),
    IN p_periodo    VARCHAR(30)
)
BEGIN
    SELECT e.nombre AS Estudiante,
           g.nombre AS Grado,
           a.nombre AS Asignatura,
           p.nombre AS Periodo,
           n.valor  AS Nota
    FROM nota n
    JOIN estudiante e ON e.id_estudiante = n.id_estudiante
    JOIN grado g      ON g.id_grado      = e.id_grado
    JOIN asignatura a ON a.id_asignatura = n.id_asignatura
    JOIN periodo p    ON p.id_periodo    = n.id_periodo
    WHERE e.nombre = p_estudiante
      AND a.nombre = p_asignatura
      AND p.nombre = p_periodo;
END$$

-- 3) Promedio de cada estudiante y si aprobo o no
--    Uso: CALL sp_promedio_estudiantes(3.0);
CREATE PROCEDURE sp_promedio_estudiantes(IN p_nota_minima DECIMAL(3,2))
BEGIN
    SELECT e.nombre AS Estudiante,
           g.nombre AS Grado,
           ROUND(IFNULL(AVG(n.valor), 0), 2) AS Promedio,
           IF(IFNULL(AVG(n.valor), 0) >= p_nota_minima, 'Aprobó', 'Reprobó') AS Estado
    FROM estudiante e
    JOIN grado g ON g.id_grado = e.id_grado
    LEFT JOIN nota n ON n.id_estudiante = e.id_estudiante
    GROUP BY e.id_estudiante;
END$$

-- 4) Estudiantes con promedio por debajo de un limite
--    Uso: CALL sp_bajo_rendimiento(3.0);
CREATE PROCEDURE sp_bajo_rendimiento(IN p_limite DECIMAL(3,2))
BEGIN
    SELECT e.nombre AS Estudiante,
           g.nombre AS Grado,
           ROUND(AVG(n.valor), 2) AS Promedio
    FROM estudiante e
    JOIN grado g ON g.id_grado = e.id_grado
    JOIN nota n  ON n.id_estudiante = e.id_estudiante
    GROUP BY e.id_estudiante
    HAVING AVG(n.valor) < p_limite;
END$$

-- 5) Registrar un estudiante (si ya existe en ese grado, no hace nada)
--    Uso: CALL sp_registrar_estudiante('Laura', 'Grado 2');
CREATE PROCEDURE sp_registrar_estudiante(
    IN p_nombre VARCHAR(100),
    IN p_grado  VARCHAR(30)
)
BEGIN
    INSERT IGNORE INTO estudiante (nombre, id_grado)
    SELECT p_nombre, id_grado FROM grado WHERE nombre = p_grado;
END$$

-- 6) Registrar una nota
--    Uso: CALL sp_registrar_nota('Cesar Reguillo', 'Grado 1', 'Ciencias', 'Periodo 3', 4.5);
CREATE PROCEDURE sp_registrar_nota(
    IN p_estudiante VARCHAR(100),
    IN p_grado      VARCHAR(30),
    IN p_asignatura VARCHAR(50),
    IN p_periodo    VARCHAR(30),
    IN p_valor      DECIMAL(3,2)
)
BEGIN
    INSERT INTO nota (id_estudiante, id_asignatura, id_periodo, valor)
    SELECT e.id_estudiante, a.id_asignatura, p.id_periodo, p_valor
    FROM estudiante e
    JOIN grado g ON g.id_grado = e.id_grado
    JOIN asignatura a ON a.nombre = p_asignatura
    JOIN periodo p    ON p.nombre = p_periodo
    WHERE e.nombre = p_estudiante
      AND g.nombre = p_grado;
END$$

-- 7) Listar asignaturas (para llenar los combos)
--    Uso: CALL sp_listar_asignaturas();
CREATE PROCEDURE sp_listar_asignaturas()
BEGIN
    SELECT nombre FROM asignatura ORDER BY id_asignatura;
END$$

-- 8) Listar estudiantes (para llenar el combo de Calificaciones)
--    Uso: CALL sp_listar_estudiantes();
CREATE PROCEDURE sp_listar_estudiantes()
BEGIN
    SELECT DISTINCT nombre FROM estudiante ORDER BY nombre;
END$$

-- 9) Mostrar todo (solo para pruebas): estudiantes con sus notas
--    Uso: CALL sp_mostrar_todo();
CREATE PROCEDURE sp_mostrar_todo()
BEGIN
    SELECT e.id_estudiante AS Id,
           e.nombre        AS Estudiante,
           g.nombre        AS Grado,
           a.nombre        AS Asignatura,
           p.nombre        AS Periodo,
           n.valor         AS Nota
    FROM estudiante e
    JOIN grado g ON g.id_grado = e.id_grado
    LEFT JOIN nota n       ON n.id_estudiante = e.id_estudiante
    LEFT JOIN asignatura a ON a.id_asignatura = n.id_asignatura
    LEFT JOIN periodo p    ON p.id_periodo    = n.id_periodo
    ORDER BY e.id_estudiante, n.id_nota;
END$$

DELIMITER ;
call sp_mostrar_todo();