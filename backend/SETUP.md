# 🔧 Guía de Ejecución - Backend FastAPI

## Requisitos Previos

```
Python 3.10+
MySQL Server (corriendo)
Base de datos 'paquexpress_db' creada
```

## Paso 1: Instalar Dependencias

```bash
pip install -r requirements.txt
```

**Paquetes instalados:**
- fastapi==0.104.1 - Framework web
- uvicorn==0.24.0 - Servidor ASGI
- mysql-connector-python==8.2.0 - Conector MySQL
- pydantic==2.5.0 - Validación de datos
- python-jose==3.3.0 - JWT
- passlib==1.7.4 - Hashing de contraseñas
- bcrypt==4.1.1 - Encriptación
- python-dotenv==1.0.0 - Manejo de variables de entorno

## Paso 2: Configurar Variables de Entorno

El archivo `.env` ya está configurado con valores por defecto:

```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=paquexpress_db
DB_PORT=3306
```

**Cambiar si es necesario** según tu configuración de MySQL.

## Paso 3: Crear la Base de Datos

Ejecutar en MySQL:

```sql
CREATE DATABASE paquexpress_db;
USE paquexpress_db;

CREATE TABLE agentes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE paquetes (
    id INT PRIMARY KEY,
    direccion_destino TEXT NOT NULL,
    entregado BOOLEAN DEFAULT FALSE,
    foto_evidencia LONGBLOB, 
    latitud DOUBLE,
    longitud DOUBLE,
    agente_id INT,
    FOREIGN KEY (agente_id) REFERENCES agentes(id)
);
```

## Paso 4: Ejecutar el Servidor

```bash
python main.py
```

**Salida esperada:**
```
==================================================
Iniciando PaquExpress API
==================================================
✓ Conexión a base de datos exitosa
✓ API lista para recibir solicitudes
✓ Disponible en: http://0.0.0.0:8000
```

## Acceso a la API

- **URL Base**: http://localhost:8000
- **Documentación (Swagger)**: http://localhost:8000/docs
- **Alternativa (ReDoc)**: http://localhost:8000/redoc

## Endpoints Principales

### Autenticación
```
POST /auth/login
  {
    "username": "agente1",
    "password": "123456"
  }

POST /auth/register
  {
    "username": "agente2",
    "password": "password123"
  }

GET /auth/me
  (Requiere: Authorization: Bearer {token})
```

### Paquetes
```
GET /paquetes
  (Lista paquetes sin asignar)

GET /paquetes?agente_id=1
  (Lista paquetes de un agente)

GET /paquetes/{id}
  (Detalles de un paquete)

POST /paquetes/{id}/entregar
  {
    "foto_base64": "...",
    "latitud": 14.6349,
    "longitud": -90.5069
  }

POST /paquetes/{id}/asignar
  {
    "agente_id": 1
  }
```

## Crear Datos de Prueba

### Insertar paquetes de ejemplo:
```sql
INSERT INTO paquetes (id, direccion_destino, entregado, agente_id) VALUES
(1, 'Calle Principal 123, Apartamento 4B', FALSE, NULL),
(2, 'Avenida Central 456, Piso 2', FALSE, NULL),
(3, 'Calle Secundaria 789, Casa 10', FALSE, NULL),
(4, 'Boulevard Este 321, Oficina 5', FALSE, NULL),
(5, 'Calle Oeste 654, Garaje B', FALSE, NULL);
```

## Solución de Problemas

### Error: "Access denied for user 'root'@'localhost'"
- Verificar contraseña de MySQL en `.env`
- Asegurar que el usuario existe

### Error: "Unknown database 'paquexpress_db'"
- Crear la base de datos ejecutando el script SQL

### Error: "Address already in use"
- El puerto 8000 está en uso
- Cambiar en `.env`: API_PORT=8001

### ConnectionError
- Verificar que MySQL está corriendo
- Confirmar con: `mysql -u root -p`

## Variables de Entorno Avanzadas

```
# Seguridad
SECRET_KEY=tu-clave-super-segura          # Cambiar en producción!
ALGORITHM=HS256                            # Algoritmo JWT
ACCESS_TOKEN_EXPIRE_MINUTES=30             # Expiración de token

# Base de datos
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=paquexpress_db
DB_PORT=3306

# API
API_PORT=8000
API_HOST=0.0.0.0                          # 0.0.0.0 = Acceso externo
```

## Estructura de Respuestas

### Respuesta exitosa:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "usuario_id": 1
}
```

### Respuesta de error:
```json
{
  "detail": "Usuario o contraseña incorrectos"
}
```

## Desarrollo y Depuración

### Habilitar modo DEBUG:
En `main.py`, modificar al iniciar Uvicorn:
```python
uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
```

### Ver logs MySQL:
```bash
SELECT * FROM mysql.general_log;
```

### Probar endpoint con cURL:
```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"agente1","password":"123456"}'
```

## Despliegue en Producción

Cambiar en `.env`:
```
SECRET_KEY=<generar-clave-aleatoria-fuerte>
API_HOST=0.0.0.0
ALGORITHM=HS256
```

Ejecutar con Gunicorn:
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:8000 main:app
```

---

**¡API lista para usar! 🚀**
