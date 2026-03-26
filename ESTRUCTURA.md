# 📂 Estructura Completa del Proyecto

```
evaluacion_u3/
│
├── backend/                              # ⚙️ API REST en FastAPI
│   ├── main.py                          # 🚀 Aplicación principal
│   ├── config.py                        # ⚙️ Configuración centralizada
│   ├── models.py                        # 📊 Modelos Pydantic (validación)
│   ├── database.py                      # 🗄️ Conexión y queries MySQL
│   ├── requirements.txt                 # 📦 Dependencias Python
│   ├── .env                             # 🔐 Variables de entorno
│   ├── SETUP.md                         # 📖 Guía de setup del backend
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── auth.py                      # 🔐 Endpoints: /auth/login, /auth/register
│   │   └── paquetes.py                  # 📦 Endpoints: /paquetes, /entregar
│   └── utils/
│       ├── __init__.py
│       └── security.py                  # 🔒 Encriptación, JWT, Base64
│
├── lib/                                  # 📱 Código Flutter
│   ├── main.dart                        # 🎯 Punto de entrada
│   ├── models/
│   │   ├── agente.dart                  # 👤 Modelo: Agente/Token
│   │   └── paquete.dart                 # 📦 Modelo: Paquete
│   ├── services/
│   │   └── api_service.dart             # 🌐 Cliente HTTP (todos los endpoints)
│   ├── screens/
│   │   ├── login_screen.dart            # 🔓 Pantalla: Login/Register
│   │   ├── paquetes_list_screen.dart    # 📋 Pantalla: Lista de paquetes
│   │   └── entrega_screen.dart          # 📸 Pantalla: Captura (foto + GPS)
│   └── utils/
│       └── (vacío, listo para extensión)
│
├── android/                              # 🤖 Configuración Android
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/main/AndroidManifest.xml # 🔐 Permisos de la app
│   └── ...
│
├── ios/                                  # 🍎 Configuración iOS
│   ├── Runner/
│   │   └── Info.plist                   # 🔐 Permisos de la app
│   └── ...
│
├── pubspec.yaml                          # 📦 Dependencias Flutter
├── README.md                             # 📖 Documentación principal
├── INICIO_RAPIDO.md                      # ⚡ Guía rápida (5 minutos)
├── SEGURIDAD.md                          # 🔒 Configuración de seguridad
├── database_setup.sql                    # 🗄️ Script de BD + datos ejemplo
└── analysis_options.yaml                 # 📋 Configuración Dart Lint
```

---

## 📊 Estadísticas del Proyecto

| Componente | Cantidad | Lenguaje |
|-----------|----------|----------|
| **Backend** | | |
| Archivos Python | 7 | Python |
| Endpoints API | 8 | - |
| Modelos | 8 | Pydantic |
| **Frontend** | | |
| Archivos Dart | 7 | Dart |
| Pantallas (Screens) | 3 | Flutter |
| Servicios | 1 | Dart |
| Modelos | 2 | Dart |
| **BD** | | |
| Tablas | 2 | SQL |
| Relaciones | 1 | FK |
| Vistas | 3 | SQL |
| **Documentación** | | |
| Archivos MD | 4 | Markdown |

---

## 🔗 Relaciones Principales

```
AGENTE (1) ←─────→ (N) PAQUETE
├─ id (PK)
├─ username         
└─ password_hash
                    
                    PAQUETE
                    ├─ id (PK)
                    ├─ direccion_destino
                    ├─ entregado
                    ├─ foto_evidencia
                    ├─ latitud
                    ├─ longitud
                    └─ agente_id (FK)
```

---

## 📡 Flujo de Datos

```
┌─────────────────────────────────────────────────────┐
│                    FLUTTER APP                       │
│  (screens/ + services/ + models/)                    │
└─────────────────┬───────────────────────────────────┘
                  │
                  │ HTTP (JSON)
                  │
        ┌─────────▼───────────┐
        │   FASTAPI (Python)  │
        │  routes/ + models/  │
        │  database.py        │
        └─────────┬───────────┘
                  │
                  │ SQL Queries
                  │
        ┌─────────▼─────────────┐
        │   MySQL Database      │
        │  (paquetes_db)        │
        │  ├─ agentes           │
        │  └─ paquetes          │
        └──────────────────────┘
```

---

## 🔐 Stack de Seguridad

```
┌─────────────────────────────────────────┐
│  Nivel de Seguridad                     │
├─────────────────────────────────────────┤
│  1. HTTPS/TLS (en producción)           │
│  2. JWT Token (Bearer Auth)             │
│  3. BCrypt Password Hashing             │
│  4. Base64 Image Encoding               │
│  5. SQL Injection Prevention (prepared) │
│  6. CORS (Cross-Origin Resource Sharing)│
└─────────────────────────────────────────┘
```

---

## 🎯 Rutas de API Implementadas

### Autenticación (5 endpoints)
```
POST   /auth/login           → Login y obtener token
POST   /auth/register        → Registrarse como nuevo agente
GET    /auth/me              → Obtener info del usuario actual
```

### Paquetes (5 endpoints)
```
GET    /paquetes             → Lista de paquetes sin asignar
GET    /paquetes/{id}        → Detalles de un paquete
POST   /paquetes/{id}/entregar   → Registrar entrega (foto + GPS)
POST   /paquetes/{id}/asignar    → Asignar paquete a agente
GET    /health               → Verificar estado de API
```

---

## 📲 Pantallas Flutter

### 1. LoginScreen
- **Ruta**: `/login`
- **Funciones**:
  - Login de usuario existente
  - Registro de nuevo usuario
  - Toggle mostrar/ocultar contraseña
  - Manejo de errores

### 2. PaquetesListScreen
- **Ruta**: `/paquetes`
- **Funciones**:
  - Filtro: Asignados / Disponibles
  - Lista scrolleable de paquetes
  - Botones: Entregarar / Asignarse
  - Endpoint hit de paquete

### 3. EntregaScreen
- **Ruta**: `/entrega` (con argumentos)
- **Funciones**:
  - Captura foto desde cámara
  - Selecciona foto desde galería
  - Obtiene GPS automático
  - Actualiza ubicación manual
  - Envía entrega con evidencia

---

## ⚡ Rendimiento y Optimizaciones

| Aspecto | Optimización |
|--------|--------------|
| Base de datos | Índices en agente_id, entregado |
| Imágenes | Compresión (quality: 85) en Flutter |
| API | Timeout de 10-30 segundos |
| Token | Expiración automática (30 min) |
| Conexión | Singleton para DB |

---

## 🚀 Deployment Ready

### Cambios para Producción:

1. **Backend**:
   ```
   Cambiar SECRET_KEY en .env
   Usar HTTPS en lugar de HTTP
   Configurar CORS correctamente
   Habilitar Rate Limiting
   ```

2. **Frontend**:
   ```
   Cambiar URL de API a dominio real
   Habilitar ProGuard (Android)
   Crear release build
   Firmar APK/IPA
   ```

3. **Base de Datos**:
   ```
   Configurar backups automáticos
   Habilitar SSL en conexión MySQL
   Crear usuarios con permisos limitados
   ```

---

## 📚 Dependencias Principales

### Python (Backend)
- FastAPI 0.104.1 - Framework web
- MySQL Connector 8.2.0 - Conector BD
- BCrypt 4.1.1 - Encriptación
- Python-Jose 3.3.0 - JWT

### Dart (Frontend)
- http 1.1.0 - Cliente HTTP
- image_picker 1.0.4 - Cámara y galería
- geolocator 9.0.2 - GPS
- google_maps_flutter 2.5.0 - Mapas (opcional)
- shared_preferences 2.2.0 - Persistencia local

---

## ✅ Checklist de Completitud

### Backend
- ✅ Estructura modular (config, models, database, routes)
- ✅ Autenticación (login, register, JWT)
- ✅ Encriptación (BCrypt, Base64)
- ✅ CRUD de paquetes (crear, leer, actualizar)
- ✅ Manejo de errores
- ✅ CORS habilitado
- ✅ Documentación (SETUP.md)

### Frontend
- ✅ 3 pantallas principales
- ✅ Modelo de datos (Agente, Paquete)
- ✅ Servicio HTTP centralizado
- ✅ Captura de fotos (cámara + galería)
- ✅ GPS en tiempo real
- ✅ Persistencia de token
- ✅ Validación de permisos

### Documentación
- ✅ README.md completo
- ✅ INICIO_RAPIDO.md (5 min setup)
- ✅ SEGURIDAD.md (permisos + encriptación)
- ✅ database_setup.sql (BD lista)
- ✅ backend/SETUP.md (backend detallado)

---

**Proyecto completo y listo para usar 🎉**
