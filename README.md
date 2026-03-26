# 📦 PaquExpress - Sistema de Entregas Inteligente

**Aplicación móvil en Flutter** para registro y seguimiento de entregas de paquetes con validación GPS, captura de fotografía y autenticación segura.

---

## 🎯 Características Principales

### Funcionalidades Básicas ✓
- ✅ Seleccionar paquete desde lista de entregas asignadas
- ✅ Capturar fotografía como evidencia de entrega
- ✅ Obtener ubicación GPS del dispositivo
- ✅ Guardar datos en base de datos MySQL

### Funcionalidades Escaladas ✓
- ✅ **Autenticación Segura**: Login/Registro con validación de credenciales
- ✅ **Encriptación**: Contraseñas hasheadas con BCrypt
- ✅ **Gestión de Sesiones**: JWT tokens con expiración configurable
- ✅ **Interfaz Intuitiva**: Navegación fluida entre pantallas
- ✅ **Validación GPS**: Obtención de coordenadas en tiempo real
- ✅ **Captura de Fotos**: Desde cámara o galería del dispositivo

---

## 📋 Requisitos

### Backend (FastAPI)
- **Python 3.10+**
- **pip** (gestor de paquetes Python)
- **MySQL Server** corriendo en localhost:3306
- **Base de datos** `paquexpress_db` (ver script de creación)

### Frontend (Flutter)
- **Flutter SDK 3.10+**
- **Compilador de Dart**
- **Emulador Android/iOS o dispositivo físico**
- **Android SDK** (para Android) o **Xcode** (para iOS)

---

## 🚀 Instalación y Setup

### 1. Preparar Base de Datos MySQL

Ejecutar el script SQL de creación:

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

### 2. Configurar Backend (FastAPI)

```bash
# Navegar a la carpeta del backend
cd backend

# Crear entorno virtual
python -m venv venv

# Activar entorno virtual
# En Windows:
venv\Scripts\activate
# En macOS/Linux:
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar servidor
python main.py
```

**El servidor estará disponible en**: `http://localhost:8000`

### 3. Configurar Frontend (Flutter)

```bash
# Obtener dependencias
flutter pub get

# Ejecutar en emulador o dispositivo
flutter run
```

---

## 📱 Guía de Uso

1. **Login/Registro**: Ingresa credenciales
2. **Seleccionar Paquete**: Escoge de la lista de entregas
3. **Capturar Foto**: Fotografía de evidencia
4. **Obtener GPS**: Ubicación automática
5. **Entregar**: Guarda todo en BD

---

## 🔐 Seguridad

- ✅ JWT Authentication
- ✅ BCrypt Password Hashing
- ✅ Validación de Tokens
- ✅ CORS Enabled

---

## 📊 Estructura

```
evaluacion_u3/
├── backend/
│   ├── main.py
│   ├── config.py
│   ├── models.py
│   ├── database.py
│   ├── requirements.txt
│   ├── routes/
│   └── utils/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── services/
│   └── screens/
└── pubspec.yaml
```
