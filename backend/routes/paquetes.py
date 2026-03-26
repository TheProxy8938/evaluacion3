from fastapi import APIRouter, HTTPException, status, Header
from models import PaqueteResponse, EntregaRequest, PaqueteUpdate, AsignarPaqueteRequest
from database import fetch_one, fetch_all, insert_update_delete, DatabaseConnection
from utils.security import get_current_user, SecurityUtils
from utils.foto_handler import FotoHandler
import os
from datetime import datetime
import base64
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

router = APIRouter(tags=["Paquetes"])

@router.get("/paquetes", response_model=list)
async def get_paquetes(authorization: Optional[str] = Header(None), agente_id: int = None):
    """
    Obtener lista de paquetes
    
    Parámetros opcionales:
    - agente_id: filtrar por agente (si no se proporciona, obtiene sin asignar)
    """
    token = extract_token(authorization)
    
    user_data = get_current_user(token)
    if not user_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido"
        )
    
    if agente_id:
        query = """
            SELECT id, direccion_destino, entregado, latitud, longitud, agente_id 
            FROM paquetes 
            WHERE agente_id = %s
        """
        paquetes = fetch_all(query, (agente_id,))
    else:
        query = """
            SELECT id, direccion_destino, entregado, latitud, longitud, agente_id 
            FROM paquetes 
            WHERE agente_id IS NULL AND entregado = FALSE
        """
        paquetes = fetch_all(query)
    
    if not paquetes:
        return []
    
    return paquetes

@router.get("/paquetes/{paquete_id}", response_model=dict)
async def get_paquete(paquete_id: int, authorization: Optional[str] = Header(None)):
    """
    Obtener detalles de un paquete específico (incluye foto en base64 si está disponible)
    """
    token = extract_token(authorization)
    
    user_data = get_current_user(token)
    if not user_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido"
        )
    
    query = """
        SELECT id, direccion_destino, entregado, latitud, longitud, agente_id, foto_evidencia
        FROM paquetes 
        WHERE id = %s
    """
    paquete = fetch_one(query, (paquete_id,))
    
    if not paquete:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paquete no encontrado"
        )
    
    # Si hay foto, convertirla a base64
    if paquete.get('foto_evidencia'):
        foto_bytes = paquete['foto_evidencia']
        if isinstance(foto_bytes, bytes):
            paquete['foto_evidencia'] = base64.b64encode(foto_bytes).decode('utf-8')
    
    return paquete

@router.post("/paquetes/{paquete_id}/entregar")
async def entregar_paquete(paquete_id: int, entrega: EntregaRequest, authorization: Optional[str] = Header(None)):
    """
    Registrar entrega de un paquete
    
    - paquete_id: ID del paquete
    - foto_base64: Foto de evidencia en base64
    - latitud: Coordenada GPS latitud
    - longitud: Coordenada GPS longitud
    """
    token = extract_token(authorization)
    
    user_data = get_current_user(token)
    if not user_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido"
        )
    
    agente_id = user_data.get('sub')
    
    # Verificar que el paquete existe y le pertenece al agente
    query = "SELECT id FROM paquetes WHERE id = %s AND agente_id = %s"
    paquete = fetch_one(query, (paquete_id, agente_id))
    
    if not paquete:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paquete no encontrado o no asignado a este agente"
        )
    
    # Usar FotoHandler para guardar la entrega completa
    success, mensaje = FotoHandler.guardar_entrega_completa(
        paquete_id=paquete_id,
        foto_base64=entrega.foto_base64,
        latitud=entrega.latitud,
        longitud=entrega.longitud
    )
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=mensaje
        )
    
    return {
        "mensaje": "Paquete entregado exitosamente",
        "paquete_id": paquete_id,
        "latitud": entrega.latitud,
        "longitud": entrega.longitud,
        "detalles": mensaje
    }

@router.post("/paquetes/{paquete_id}/asignar")
async def asignar_paquete(paquete_id: int, asignacion: AsignarPaqueteRequest, authorization: Optional[str] = Header(None)):
    """
    Asignar un paquete a un agente
    """
    token = extract_token(authorization)
    
    user_data = get_current_user(token)
    if not user_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido"
        )
    
    # Verificar que el paquete existe
    query = "SELECT id FROM paquetes WHERE id = %s"
    paquete = fetch_one(query, (paquete_id,))
    
    if not paquete:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paquete no encontrado"
        )
    
    # Asignar paquete
    update_query = "UPDATE paquetes SET agente_id = %s WHERE id = %s"
    insert_update_delete(update_query, (asignacion.agente_id, paquete_id))
    
    return {
        "mensaje": "Paquete asignado exitosamente",
        "paquete_id": paquete_id,
        "agente_id": asignacion.agente_id
    }
