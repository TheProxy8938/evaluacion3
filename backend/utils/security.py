from passlib.context import CryptContext
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from config import SECRET_KEY, ALGORITHM
import base64

# Configurar contexto de encriptación
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class SecurityUtils:
    
    @staticmethod
    def hash_password(password: str) -> str:
        """Encripta una contraseña usando bcrypt"""
        return pwd_context.hash(password)
    
    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """Verifica una contraseña contra su hash"""
        return pwd_context.verify(plain_password, hashed_password)
    
    @staticmethod
    def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
        """Crea un JWT token"""
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(hours=24)
        
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
        return encoded_jwt
    
    @staticmethod
    def decode_token(token: str) -> Optional[dict]:
        """Decodifica y valida un JWT token"""
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            return payload
        except JWTError:
            return None
    
    @staticmethod
    def encode_image_to_base64(image_path: str) -> str:
        """Convierte una imagen a base64"""
        try:
            with open(image_path, "rb") as image_file:
                return base64.b64encode(image_file.read()).decode('utf-8')
        except Exception as e:
            print(f"Error encoding image: {e}")
            return None
    
    @staticmethod
    def decode_base64_to_image(base64_string: str, output_path: str) -> bool:
        """Convierte base64 a imagen"""
        try:
            image_data = base64.b64decode(base64_string)
            with open(output_path, "wb") as image_file:
                image_file.write(image_data)
            return True
        except Exception as e:
            print(f"Error decoding image: {e}")
            return False

def get_current_user(token: str) -> Optional[dict]:
    """Obtiene el usuario actual del token"""
    return SecurityUtils.decode_token(token)
