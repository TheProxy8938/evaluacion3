from fastapi import APIRouter, HTTPException, status, Header
from models import AgenteLogin, AgenteRegister, TokenResponse, AgenteResponse
from database import fetch_one, insert_update_delete
from utils.security import SecurityUtils, get_current_user
from datetime import timedelta
from config import ACCESS_TOKEN_EXPIRE_MINUTES
from typing import Optional

def extract_token(authorization: Optional[str] = Header(None)) -> str:
    """Extrae el token del header Authorization: Bearer <token>"""
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token requerido"
        )
    
    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Formato de token inválido"
        )
    
    return parts[1]

router = APIRouter(tags=["Autenticación"])

@router.post("/auth/login", response_model=TokenResponse)
async def login(credentials: AgenteLogin):
    """
    Login de agentes
    
    Parámetros:
    - username: nombre de usuario del agente
    - password: contraseña del agente
    """
    # Buscar el agente en la base de datos
    query = "SELECT id, username, password_hash FROM agentes WHERE username = %s"
    agente = fetch_one(query, (credentials.username,))
    
    if not agente:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario o contraseña incorrectos"
        )
    
    # Verificar la contraseña
    if not SecurityUtils.verify_password(credentials.password, agente['password_hash']):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario o contraseña incorrectos"
        )
    
    # Crear token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = SecurityUtils.create_access_token(
        data={"sub": str(agente['id']), "username": agente['username']},
        expires_delta=access_token_expires
    )
    
    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        usuario_id=agente['id']
    )

@router.post("/auth/register", response_model=TokenResponse)
async def register(agente: AgenteRegister):
    """
    Registrar nuevo agente (solo para desarrollo/admin)
    
    Parámetros:
    - username: nombre de usuario único
    - password: contraseña (será encriptada)
    """
    # Verificar si el usuario ya existe
    query = "SELECT id FROM agentes WHERE username = %s"
    existing = fetch_one(query, (agente.username,))
    
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El usuario ya existe"
        )
    
    # Encriptar contraseña
    hashed_password = SecurityUtils.hash_password(agente.password)
    
    # Insertar nuevo agente
    insert_query = "INSERT INTO agentes (username, password_hash) VALUES (%s, %s)"
    insert_update_delete(insert_query, (agente.username, hashed_password))
    
    # Obtener el agente recién creado
    new_agente = fetch_one("SELECT id, username FROM agentes WHERE username = %s", (agente.username,))
    
    # Crear token
    access_token = SecurityUtils.create_access_token(
        data={"sub": str(new_agente['id']), "username": new_agente['username']}
    )
    
    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        usuario_id=new_agente['id']
    )

@router.get("/auth/me", response_model=AgenteResponse)
async def get_current_user_info(authorization: Optional[str] = Header(None)):
    """
    Obtener información del usuario actual
    """
    token = extract_token(authorization)
    
    user_data = get_current_user(token)
    if not user_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido o expirado"
        )
    
    # Obtener información del usuario
    query = "SELECT id, username FROM agentes WHERE id = %s"
    agente = fetch_one(query, (user_data['sub'],))
    
    if not agente:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )
    
    return AgenteResponse(id=agente['id'], username=agente['username'])
