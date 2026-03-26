from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# ==================== MODELOS DE AUTENTICACIÓN ====================

class AgenteLogin(BaseModel):
    """Modelo para login de agentes"""
    username: str
    password: str

class AgenteRegister(BaseModel):
    """Modelo para registro de agentes"""
    username: str
    password: str

class TokenResponse(BaseModel):
    """Modelo para respuesta de token"""
    access_token: str
    token_type: str
    usuario_id: int

class AgenteResponse(BaseModel):
    """Modelo para respuesta de agente"""
    id: int
    username: str

# ==================== MODELOS DE PAQUETES ====================

class PaqueteBase(BaseModel):
    """Modelo base de paquete"""
    id: int
    direccion_destino: str

class PaqueteCreate(BaseModel):
    """Modelo para crear/actualizar paquete"""
    id: int
    direccion_destino: str
    foto_evidencia: Optional[str] = None
    latitud: Optional[float] = None
    longitud: Optional[float] = None
    agente_id: Optional[int] = None

class PaqueteUpdate(BaseModel):
    """Modelo para actualizar estado de paquete"""
    entregado: bool = False
    foto_evidencia: Optional[str] = None
    latitud: Optional[float] = None
    longitud: Optional[float] = None

class PaqueteResponse(BaseModel):
    """Modelo para respuesta de paquete"""
    id: int
    direccion_destino: str
    entregado: bool
    foto_evidencia: Optional[str] = None
    latitud: Optional[float] = None
    longitud: Optional[float] = None
    agente_id: Optional[int] = None

class EntregaRequest(BaseModel):
    """Modelo para solicitud de entrega"""
    paquete_id: int
    foto_base64: Optional[str] = None
    latitud: float
    longitud: float

class AsignarPaqueteRequest(BaseModel):
    """Modelo para solicitud de asignación de paquete"""
    agente_id: int

# ==================== MODELOS DE RESPUESTA ====================

class ErrorResponse(BaseModel):
    """Modelo para respuesta de error"""
    error: str
    mensaje: str

class SuccessResponse(BaseModel):
    """Modelo para respuesta exitosa"""
    mensaje: str
    data: Optional[dict] = None
