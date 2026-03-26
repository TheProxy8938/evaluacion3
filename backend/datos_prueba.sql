-- Script para insertar datos de prueba en PaquExpress

SET FOREIGN_KEY_CHECKS = 0;

-- Limpiar tabla paquetes (sin restricciones)
DELETE FROM paquetes;

SET FOREIGN_KEY_CHECKS = 1;

-- Insertar paquetes disponibles (sin asignar) - dejar que MySQL genere los IDs
INSERT INTO paquetes (direccion_destino, entregado, latitud, longitud, agente_id) VALUES
('Calle Principal 123, Apartado 4B, Centro Comercial', 0, 10.3910, -75.4794, NULL),
('Carrera 5 No. 45-67, Barrio El Hueco, Piso 2', 0, 10.4037, -75.5147, NULL),
('Avenida Bolívar 89, Edificio Torres del Centro, Apto 501', 0, 10.3869, -75.5136, NULL),
('Calle 50 No. 32-15, Zona Rosa, Casa 7', 0, 10.3989, -75.5087, NULL),
('Diagonal 20 No. 120-30, Residencial Campestre', 0, 10.3654, -75.4892, NULL),
('Calle 80 No. 25-40, Barrio Esteban', 0, 10.4258, -75.5210, NULL),
('Carrera 13 No. 55-12, Centro Histórico, Suite 3', 0, 10.4043, -75.5150, NULL),
('Avenida 68 No. 95-44, Zona Industrial', 0, 10.3450, -75.5500, NULL),
('Calle 15 No. 8-50, Parque Principal, Piso 4', 0, 10.3920, -75.4850, NULL),
('Cra 7 No. 35-90, Barrio La Candelaria, Casa 12', 0, 10.3790, -75.4980, NULL),
('Calle 72 No. 10-25, Centro Administrativo, Oficina 208', 0, 10.4156, -75.5098, NULL),
('Avenida Colombia No. 58-47, Residencial Suites', 0, 10.3612, -75.5045, NULL);

SELECT 'Datos insertados exitosamente' as resultado;
SELECT COUNT(*) as total_paquetes FROM paquetes;
