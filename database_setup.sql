-- ============================================
-- Script de Creación de Base de Datos
-- PaquExpress - Sistema de Entregas
-- ============================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS paquexpress_db;
USE paquexpress_db;

-- ============================================
-- Tabla: AGENTES
-- ============================================
CREATE TABLE IF NOT EXISTS agentes (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID único del agente',
    username VARCHAR(50) UNIQUE NOT NULL COMMENT 'Nombre de usuario único',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Hash de contraseña (BCrypt)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Última actualización'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tabla de agentes de entrega';

-- ============================================
-- Tabla: PAQUETES
-- ============================================
CREATE TABLE IF NOT EXISTS paquetes (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID único del paquete',
    direccion_destino TEXT NOT NULL COMMENT 'Dirección de entrega',
    entregado BOOLEAN DEFAULT FALSE COMMENT 'Estado: entregado o no',
    foto_evidencia LONGBLOB COMMENT 'Foto de evidencia en BLOB',
    latitud DOUBLE COMMENT 'Coordenada GPS: Latitud',
    longitud DOUBLE COMMENT 'Coordenada GPS: Longitud',
    agente_id INT COMMENT 'ID del agente asignado',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Última actualización',
    FOREIGN KEY (agente_id) REFERENCES agentes(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tabla de paquetes para entrega';

-- ============================================
-- Índices para optimización
-- ============================================
CREATE INDEX idx_paquetes_agente_id ON paquetes(agente_id);
CREATE INDEX idx_paquetes_entregado ON paquetes(entregado);
CREATE INDEX idx_agentes_username ON agentes(username);

-- ============================================
-- DATOS DE EJEMPLO
-- ============================================

-- Agentes de prueba
-- Usuario: agente1 | Contraseña: 123456
-- (Hash BCrypt)
INSERT INTO agentes (username, password_hash) VALUES 
('agente1', '$2b$12$EixZaYVK1fsbw1ZfbX3OzeP68d8UD6ZvwJ1RV6VgSvEFcgV51ClFm'),
('agente2', '$2b$12$EixZaYVK1fsbw1ZfbX3OzeP68d8UD6ZvwJ1RV6VgSvEFcgV51ClFm'),
('agente3', '$2b$12$EixZaYVK1fsbw1ZfbX3OzeP68d8UD6ZvwJ1RV6VgSvEFcgV51ClFm');

-- Paquetes de ejemplo
INSERT INTO paquetes (id, direccion_destino, entregado, agente_id) VALUES
(1, 'Calle Principal 123, Apartamento 4B', FALSE, NULL),
(2, 'Avenida Central 456, Piso 2', FALSE, NULL),
(3, 'Calle Secundaria 789, Casa 10', FALSE, NULL),
(4, 'Boulevard Este 321, Oficina 5', FALSE, NULL),
(5, 'Calle Oeste 654, Garaje B', FALSE, NULL),
(6, 'Carrera Norte 987, Penthouse', FALSE, NULL),
(7, 'Avenida Sur 234, Local 1A', FALSE, NULL),
(8, 'Calle Central 567, Casilla de Correos', FALSE, NULL),
(9, 'Paseo Este 890, Despacho 3', FALSE, NULL),
(10, 'Plaza Oeste 432, Centro Comercial', FALSE, NULL);

-- ============================================
-- VISTAS ÚTILES (Opcional)
-- ============================================

-- Vista de entregas pendientes
CREATE OR REPLACE VIEW entregas_pendientes AS
SELECT 
    p.id,
    p.direccion_destino,
    a.username as agente,
    p.created_at as fecha_creacion,
    DATEDIFF(NOW(), p.created_at) as dias_pendiente
FROM paquetes p
LEFT JOIN agentes a ON p.agente_id = a.id
WHERE p.entregado = FALSE
ORDER BY p.created_at ASC;

-- Vista de entregas completadas
CREATE OR REPLACE VIEW entregas_completadas AS
SELECT 
    p.id,
    p.direccion_destino,
    a.username as agente,
    p.latitud,
    p.longitud,
    p.updated_at as fecha_entrega
FROM paquetes p
LEFT JOIN agentes a ON p.agente_id = a.id
WHERE p.entregado = TRUE
ORDER BY p.updated_at DESC;

-- Vista de resumen por agente
CREATE OR REPLACE VIEW resumen_agentes AS
SELECT 
    a.id,
    a.username,
    COUNT(CASE WHEN p.entregado = TRUE THEN 1 END) as entregas_completadas,
    COUNT(CASE WHEN p.entregado = FALSE THEN 1 END) as entregas_pendientes,
    COUNT(p.id) as total_asignadas
FROM agentes a
LEFT JOIN paquetes p ON a.id = p.agente_id
GROUP BY a.id, a.username;

-- ============================================
-- Verificación final
-- ============================================
SELECT 'Base de datos creada exitosamente' as status;
SELECT COUNT(*) as total_agentes FROM agentes;
SELECT COUNT(*) as total_paquetes FROM paquetes;
SELECT COUNT(*) as paquetes_pendientes FROM paquetes WHERE entregado = FALSE;

-- ============================================
-- Consultas útiles para pruebas
-- ============================================
/*

-- Ver todos los paquetes sin asignar:
SELECT * FROM paquetes WHERE agente_id IS NULL AND entregado = FALSE;

-- Ver entregas de un agente:
SELECT p.* FROM paquetes p 
WHERE p.agente_id = 1 ORDER BY p.created_at DESC;

-- Ver entregas completadas:
SELECT * FROM entregas_completadas;

-- Ver resumen por agente:
SELECT * FROM resumen_agentes;

-- Asignar paquete a agente:
UPDATE paquetes SET agente_id = 1 WHERE id = 1;

-- Marcar como entregado:
UPDATE paquetes 
SET entregado = TRUE, latitud = 14.6349, longitud = -90.5069 
WHERE id = 1;

-- Ver movimientos de BD (logs):
SELECT * FROM mysql.general_log ORDER BY event_time DESC LIMIT 10;

*/
