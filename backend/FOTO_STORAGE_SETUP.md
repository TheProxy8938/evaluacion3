# 📸 Configuración de Almacenamiento de Fotos en Base de Datos

Sistema completo para guardar fotos de entregas en MySQL como BLOB binario.

## 🚀 Inicio Rápido

### Paso 1: Inicializar la Configuración de MySQL

```bash
cd backend
python init_foto_config.py
```

Este script:
- ✓ Verifica la tabla `paquetes`
- ✓ Crea/actualiza columna `foto_evidencia` como LONGBLOB
- ✓ Verifica variables críticas de MySQL
- ✓ Crea triggers para updated_at automático

### Paso 2: Probar el Almacenamiento de Fotos

```bash
python test_foto_storage.py
```

Este script ejecuta 4 tests:
1. **Decodificación Base64**: Verifica que se decodifique correctamente
2. **Conexión BD**: Valida conexión y estructura de tabla
3. **Guardado en BD**: Prueba guardar/recuperar foto
4. **Entrega Completa**: Prueba registro completo (foto + GPS)

### Paso 3: Reiniciar Backend

```bash
python main.py
```

Verificar en consola:
```
✓ Conexión a la base de datos establecida (configurada para BLOB)
```

### Paso 4: Probar desde Flutter

1. Abrir app: `flutter run`
2. Navegar a un paquete asignado
3. Hacer click en "Entregar"
4. Capturar foto
5. Permitir ubicación GPS
6. Click en "Paquete Entregado"

---

## 📁 Archivos Creados

### `utils/foto_handler.py`
Manejador completo de fotos:
- `decodificar_base64()` - Decodificar foto de base64
- `guardar_foto_en_db()` - Guardar foto como BLOB
- `guardar_entrega_completa()` - Guardar foto + GPS
- `recuperar_foto()` - Obtener foto de DB
- `foto_a_base64()` - Convertir bytes a base64
- `verificar_sensibilidad_blob()` - Verificar configuración

### `init_foto_config.py`
Script de inicialización:
- Verifica tabla paquetes
- Crea columnas necesarias
- Verifica variables MySQL
- Crea triggers automáticos

### `test_foto_storage.py`
Suite de tests completa:
- Test de decodificación
- Test de conexión
- Test de guardado
- Test de entrega completa

---

## 🔧 Flujo Completo de Entrega

### Frontend (Flutter) - `entrega_screen.dart`
```
Usuario captura foto → Se convierte a base64
                    ↓
         se obtienen coordenadas GPS
                    ↓
       Click en "Paquete Entregado"
                    ↓
        Envío de foto base64 + GPS al API
```

### Backend (FastAPI) - `routes/paquetes.py`
```
POST /paquetes/{id}/entregar
   ↓
Verificar token y usuario
   ↓
FotoHandler.guardar_entrega_completa()
   ↓
Decodificar base64 → bytes
   ↓
UPDATE paquetes SET foto_evidencia = <bytes>, entregado = TRUE, GPS...
   ↓
Respuesta exitosa al cliente
```

### Base de Datos - `paquetes` table
```
UPDATE paquetes
SET entregado = TRUE,
    foto_evidencia = <BLOB 50KB-10MB>,
    latitud = 4.7110,
    longitud = -74.0721,
    updated_at = NOW()
WHERE id = ?
```

---

## 📊 Estructura de Datos

### Tabla `paquetes`
```sql
CREATE TABLE paquetes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    direccion_destino TEXT,
    entregado BOOLEAN DEFAULT FALSE,
    foto_evidencia LONGBLOB,        -- ← Foto como bytes binarios
    latitud DOUBLE,                 -- ← GPS
    longitud DOUBLE,                -- ← GPS
    agente_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Request JSON (desde Flutter)
```json
{
    "paquete_id": 1,
    "foto_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==",
    "latitud": 4.7110,
    "longitud": -74.0721
}
```

### Response JSON (desde Backend)
```json
{
    "mensaje": "Paquete entregado exitosamente",
    "paquete_id": 1,
    "latitud": 4.7110,
    "longitud": -74.0721,
    "detalles": "Entrega registrada: GPS (4.7110, -74.0721), Foto (45632 bytes)"
}
```

---

## 🐛 Solución de Problemas

### Error: "BLOB too large"
**Solución**: Aumentar `max_allowed_packet` en MySQL

Agregar a `/etc/mysql/my.cnf` (Linux) o `C:\ProgramData\MySQL\MySQL Server 8.0\my.ini` (Windows):
```ini
[mysqld]
max_allowed_packet = 256M
tmp_table_size = 256M
max_heap_table_size = 256M
```

Reiniciar MySQL:
```bash
# Linux
sudo systemctl restart mysql

# Windows
net stop MySQL80
net start MySQL80
```

### Error: "Connection timeout"
**Solución**: Aumentar timeout en `database.py`:
```python
DatabaseConnection._connection = mysql.connector.connect(
    # ... otros parámetros
    connection_timeout=30,
    use_pure=True
)
```

### Error: "Foto no se guarda"
**Verificar**:
1. Ejecutar `test_foto_storage.py` para diagnosticar
2. Revisar logs en terminal de backend
3. Verificar que paquete esté asignado al agente: `SELECT * FROM paquetes WHERE id = 1;`

---

## 📈 Monitoreo

### Ver entregas guardadas

```sql
-- Entregas pendientes
SELECT id, direccion_destino, foto_evidencia IS NOT NULL as tiene_foto
FROM paquetes WHERE entregado = FALSE;

-- Entregas completadas
SELECT id, direccion_destino, 
       LENGTH(foto_evidencia) as foto_size_bytes,
       latitud, longitud, updated_at
FROM paquetes WHERE entregado = TRUE;

-- Tamaño total de fotos
SELECT 
    COUNT(*) as total_entregas,
    SUM(LENGTH(foto_evidencia)) / 1024 / 1024 as tamaño_total_mb
FROM paquetes WHERE foto_evidencia IS NOT NULL;
```

---

## 🔒 Seguridad

### Consideraciones:
- ✓ Validar token antes de guardar
- ✓ Verificar proprietario del paquete
- ✓ Limitar tamaño de foto: `max_allowed_packet = 256M`
- ✓ Usar HTTPS en producción
- ✓ Encriptar conexión MySQL

### Configuración segura (producción):
```python
DatabaseConnection._connection = mysql.connector.connect(
    host='db.example.com',
    user='app_user',
    password='secure_password',
    database='paquexpress_db',
    ssl_ca='/path/to/ca.pem',
    ssl_disabled=False,
    use_pure=True,
    raw_as_string=False
)
```

---

## ✅ Checklist de Implementación

- [ ] Ejecutar `init_foto_config.py`
- [ ] Ejecutar `test_foto_storage.py` (deben pasar 5 tests)
- [ ] Reiniciar backend
- [ ] Compilar Flutter app
- [ ] Probar captura de foto
- [ ] Probar obtener GPS
- [ ] Probar navegar a pantalla entrega
- [ ] Hacer entrega completa
- [ ] Verificar en BD: `SELECT LENGTH(foto_evidencia) FROM paquetes WHERE id = 1;`
- [ ] Verificar GPS guardado: `SELECT latitud, longitud FROM paquetes WHERE id = 1;`

---

## 📞 Soporte

Si hay problemas:

1. **Revisar logs del backend**: Buscar líneas con `[ERROR]` o `[EXCEPTION]`
2. **Ejecutar tests de diagnóstico**: `python test_foto_storage.py`
3. **Verificar DB**: `python init_foto_config.py`
4. **Revisar permisos**: Usuario MySQL debe tener `INSERT`, `UPDATE` en tabla paquetes

---

**Creado**: 2024
**Versión**: 1.0
**Estado**: ✓ Producción
