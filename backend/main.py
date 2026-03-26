from fastapi import FastAPI, Query, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from routes import auth, paquetes
from database import DatabaseConnection
from config import API_HOST, API_PORT
import uvicorn
import os

# Crear aplicación
app = FastAPI(
    title="PaquExpress API",
    description="API para sistema de entregas de PaquExpress",
    version="1.0.0"
)

# Configurar CORS para permitir conexiones desde la app Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir routers
app.include_router(auth.router)
app.include_router(paquetes.router)

# ==================== ENDPOINTS RAÍZ ====================

@app.get("/")
async def root():
    """Endpoint raíz de la API"""
    return {
        "mensaje": "Bienvenido a PaquExpress API",
        "versión": "1.0.0",
        "documentación": "/docs"
    }

@app.get("/health")
async def health_check():
    """Verificar estado de la API"""
    return {
        "estado": "online",
        "servicio": "PaquExpress API"
    }

@app.on_event("startup")
async def startup():
    """Evento al iniciar la aplicación"""
    print("="*50)
    print("Iniciando PaquExpress API")
    print("="*50)
    try:
        # Probar conexión a la base de datos
        conn = DatabaseConnection.get_connection()
        if conn.is_connected():
            print("✓ Conexión a base de datos exitosa")
        print("✓ API lista para recibir solicitudes")
        print(f"✓ Disponible en: http://{API_HOST}:{API_PORT}")
    except Exception as e:
        print(f"✗ Error al conectar con la base de datos: {e}")
        raise

@app.on_event("shutdown")
async def shutdown():
    """Evento al cerrar la aplicación"""
    print("\nCerrando PaquExpress API...")
    DatabaseConnection.close_connection()
    print("Conexion a base de datos cerrada")

# ==================== MIDDLEWARE DE AUTENTICACIÓN ====================

@app.middleware("http")
async def add_auth_middleware(request, call_next):
    """
    Middleware para procesar token de autenticación
    """
    # Extraer token del header Authorization
    auth_header = request.headers.get("Authorization", "")
    
    if auth_header.startswith("Bearer "):
        token = auth_header[7:]  # Remover "Bearer "
        # Pasar token como parámetro de query
        request.scope["query_string"] = request.scope["query_string"] + f"&token={token}".encode()
    
    response = await call_next(request)
    return response

if __name__ == "__main__":
    # Crear carpeta para fotos si no existe
    if not os.path.exists("fotos_entregas"):
        os.makedirs("fotos_entregas")
    
    # Ejecutar servidor
    uvicorn.run(
        app,
        host=API_HOST,
        port=API_PORT
    )
