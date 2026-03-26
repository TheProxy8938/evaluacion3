# 🔐 Seguridad y Configuración de Permisos

## Configuración de Permisos en Android

### 1. Archivo `android/app/build.gradle`

Verificar que el `targetSdkVersion` sea al menos 33:

```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        targetSdkVersion 34
    }
}
```

### 2. Archivo `android/app/src/main/AndroidManifest.xml`

Agregar estos permisos:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 3. Archivo `android/app/src/main/AndroidManifest.xml` (dentro de `<application>`)

```xml
<activity
    android:name=".MainActivity"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">
</activity>
```

---

## Configuración de Permisos en iOS

### 1. Archivo `ios/Runner/Info.plist`

Agregar estas claves:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>PaquExpress necesita acceso a tu ubicación para registrar entregas</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>PaquExpress necesita acceso a tu ubicación para registrar entregas</string>

<key>NSCameraUsageDescription</key>
<string>PaquExpress necesita acceso a la cámara para tomar fotos de evidencia</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>PaquExpress necesita acceso a tus fotos para cargar evidencia</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>PaquExpress necesita guardar fotos en tu biblioteca</string>
```

### 2. Archivo `ios/Podfile`

Asegurar que está descomenntado:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
        'PERMISSION_PHOTOS=1',
        'PERMISSION_LOCATION=1',
      ]
    end
  end
end
```

---

## Estrategia de Seguridad de Contraseñas

### Hash utilizado: BCrypt

```python
# Las contraseñas se hashean con:
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
hashed = pwd_context.hash(password)
```

### Proceso de Verificación:

1. Usuario ingresa contraseña
2. Sistema calcula hash de la entrada
3. Compara con hash almacenado en BD
4. Si coincide → autenticación exitosa

### Ejemplo de hash almacenado:
```
$2b$12$EixZaYVK1fsbw1ZfbX3OzeP68d8UD6ZvwJ1RV6VgSvEFcgV51ClFm
```

---

## Tokens JWT

### Estructura:
```
header.payload.signature
```

### Payload contiene:
```json
{
  "sub": "1",           // ID del usuario
  "username": "agente1",
  "exp": 1234567890     // Timestamp de expiración
}
```

### Validez:
- **Duración**: 30 minutos (configurable)
- **Algoritmo**: HS256
- **Clave**: Variable `SECRET_KEY`

### Envío en requests:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIS...
```

---

## Encriptación de Imágenes

### Proceso de Almacenamiento:

1. **Capturar foto** en app
2. **Codificar a Base64** para transmisión
3. **Enviar vía HTTPS** en body del request
4. **Decodificar Base64** en backend
5. **Guardar archivo** en `/fotos_entregas/`
6. **Guardar ruta** en BD (LONGBLOB alternativo)

### Ejemplo de tamaño:
- Foto JPEG 2MB → ≈ 2.6MB en Base64
- Transmisión: ~30-60 segundos en 4G

---

## HTTPS en Producción

### Cambios necesarios:

```python
# En main.py
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://tudominio.com"],  # No "*"
    allow_credentials=True,
)
```

### Certificado SSL:
```bash
# Usar Let's Encrypt
sudo certbot certonly --standalone -d api.tudominio.com
```

---

## Rate Limiting (Recomendado)

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.post("/auth/login")
@limiter.limit("5/minute")
async def login(request: Request, creds):
    pass
```

---

## Monitoreo y Logs

### Ver logs de acceso:
```sql
SELECT * FROM mysql.general_log 
WHERE argument LIKE '%auth%' 
ORDER BY event_time DESC;
```

### Patrones sospechosos:
- Múltiples intentos fallidos de login
- Requests con tokens expirados
- Acceso a recursos sin autorizar

---

## Checklist de Seguridad

- [ ] Cambiar `SECRET_KEY` en producción
- [ ] Usar HTTPS en lugar de HTTP
- [ ] Configurar CORS correctamente
- [ ] Habilitar rate limiting
- [ ] Respaldar BD regularmente
- [ ] Revisar logs de errores
- [ ] Actualizar dependencias
- [ ] Limpiar datos sensibles en logs

---

**Proyecto seguro ✓**
