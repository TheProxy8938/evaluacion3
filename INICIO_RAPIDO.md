# ⚡ Inicio Rápido - PaquExpress

## 1️⃣ Iniciar en 5 minutos

### Backend (Terminal 1)
```bash
cd backend
pip install -r requirements.txt
python main.py
```
✅ API disponible en: **http://localhost:8000**

### Frontend (Terminal 2)
```bash
flutter pub get
flutter run
```
✅ App corriendo en emulador/dispositivo

---

## 2️⃣ Crear Datos de Prueba

Ejecutar en MySQL:

```sql
-- Usuario de prueba
INSERT INTO agentes (username, password_hash) VALUES 
('agente1', '$2b$12$EixZaYVK1fsbw1ZfbX3OzeP68d8UD6ZvwJ1RV6VgSvEFcgV51ClFm');
-- Contraseña: 123456

-- Paquetes de ejemplo
INSERT INTO paquetes (id, direccion_destino) VALUES
(1, 'Calle Principal 123, Apto 4B'),
(2, 'Avenida Central 456, Piso 2'),
(3, 'Calle Secundaria 789');
```

---

## 3️⃣ Probar en la App

1. **Login**:
   - Usuario: `agente1`
   - Contraseña: `123456`

2. **Seleccionar Paquete**:
   - Ve a "Disponibles"
   - Toca "Asignarme" en un paquete

3. **Entregar**:
   - Ve a "Asignados"
   - Toca el paquete
   - Captura foto + GPS
   - Toca "Paquete Entregado"

---

## 4️⃣ URLs Importantes

| Servicio | URL |
|----------|-----|
| API Base | http://localhost:8000 |
| Swagger Docs | http://localhost:8000/docs |
| API Health | http://localhost:8000/health |
| DB Admin | localhost:3306 |

---

## 5️⃣ Archivos Clave

```
backend/
├── main.py          ← Inicia aquí
├── .env             ← Variables de entorno
└── routes/
    ├── auth.py      ← Login/Register
    └── paquetes.py  ← CRUD de entregas

lib/
├── main.dart        ← Punto de entrada
├── screens/         ← Pantallas UI
├── services/        ← API calls
└── models/          ← Modelos de datos
```

---

## 6️⃣ Cambiar URL de API (Si es necesario)

**Emulador Android**: Cambiar en `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

**Dispositivo Físico**: Cambiar a tu IP local:
```dart
static const String baseUrl = 'http://192.168.1.100:8000';
```

---

## 7️⃣ Troubleshooting

| Error | Solución |
|-------|----------|
| `Connection refused` | Iniciar backend: `python main.py` |
| `Database error` | Crear BD: ejecutar script SQL |
| `Permission denied (GPS)` | Aceptar permisos en app |
| `Port 8000 in use` | Cambiar en `.env`: `API_PORT=8001` |

---

## 8️⃣ Próximos Pasos (Opcional)

- [ ] Agregar mapa interactivo (google_maps_flutter)
- [ ] Historial de entregas
- [ ] Reportes por agente
- [ ] Notificaciones push
- [ ] Sincronización offline

---

**¡Listo para empezar! 🚀**
