"""
Manejador de fotos para almacenamiento en base de datos
"""

import base64
import io
from typing import Optional, Tuple
import mysql.connector
from mysql.connector import Error
import sys
import os

# Agregar ruta del proyecto al path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import DatabaseConnection


class FotoHandler:
    """Maneja el almacenamiento y recuperación de fotos en BLOB"""
    
    @staticmethod
    def decodificar_base64(foto_base64: str) -> Optional[bytes]:
        """
        Decodifica una foto en base64 a bytes
        
        Args:
            foto_base64: String en base64 (puede incluir data URI prefix)
            
        Returns:
            bytes: Foto decodificada, o None si hay error
        """
        try:
            if not foto_base64:
                return None
            
            # Limpiar el string
            foto_base64 = foto_base64.strip()
            
            # Eliminar el prefijo data:image/...;base64, si existe
            if ',' in foto_base64:
                foto_base64 = foto_base64.split(',', 1)[1]
            
            # Decodificar
            foto_bytes = base64.b64decode(foto_base64)
            
            return foto_bytes
            
        except Exception as e:
            print(f"❌ Error decodificando base64: {e}")
            return None
    
    @staticmethod
    def guardar_foto_en_db(paquete_id: int, foto_bytes: bytes) -> bool:
        """
        Guarda foto como BLOB en la base de datos
        
        Args:
            paquete_id: ID del paquete
            foto_bytes: Bytes de la foto
            
        Returns:
            bool: True si se guardó correctamente, False si no
        """
        if not foto_bytes or len(foto_bytes) == 0:
            print(f"⚠️  Foto vacía para paquete {paquete_id}")
            return False
        
        try:
            conn = DatabaseConnection.get_connection()
            cursor = conn.cursor()
            
            # Usar LOAD_FILE equivalente con INSERT/UPDATE
            update_query = """
                UPDATE paquetes 
                SET foto_evidencia = %s 
                WHERE id = %s
            """
            
            # Pasar los bytes directamente (mysql.connector los maneja)
            cursor.execute(update_query, (foto_bytes, paquete_id))
            
            conn.commit()
            print(f"✓ Foto guardada en DB para paquete {paquete_id} ({len(foto_bytes)} bytes)")
            cursor.close()
            
            return True
            
        except Error as e:
            print(f"❌ Error guardando foto en DB: {e}")
            return False
    
    @staticmethod
    def guardar_entrega_completa(paquete_id: int, foto_base64: Optional[str], 
                                 latitud: float, longitud: float) -> Tuple[bool, str]:
        """
        Guarda una entrega completa (foto + GPS)
        
        Args:
            paquete_id: ID del paquete
            foto_base64: Foto en base64
            latitud: Coordenada GPS
            longitud: Coordenada GPS
            
        Returns:
            Tuple[bool, str]: (éxito, mensaje)
        """
        try:
            # Decodificar foto
            foto_bytes = None
            if foto_base64:
                foto_bytes = FotoHandler.decodificar_base64(foto_base64)
                if not foto_bytes:
                    return False, "Error al procesar la foto"
            
            # Actualizar DB
            conn = DatabaseConnection.get_connection()
            cursor = conn.cursor()
            
            update_query = """
                UPDATE paquetes 
                SET entregado = TRUE, 
                    foto_evidencia = %s, 
                    latitud = %s, 
                    longitud = %s,
                    updated_at = NOW()
                WHERE id = %s
            """
            
            cursor.execute(update_query, (foto_bytes, latitud, longitud, paquete_id))
            conn.commit()
            
            cursor.close()
            
            tamaño_foto = len(foto_bytes) if foto_bytes else 0
            mensaje = f"Entrega registrada: GPS ({latitud}, {longitud}), Foto ({tamaño_foto} bytes)"
            print(f"✓ {mensaje}")
            
            return True, mensaje
            
        except Error as e:
            print(f"❌ Error guardando entrega: {e}")
            return False, f"Error en base de datos: {str(e)}"
        except Exception as e:
            print(f"❌ Error inesperado: {e}")
            return False, f"Error: {str(e)}"
    
    @staticmethod
    def recuperar_foto(paquete_id: int) -> Optional[bytes]:
        """
        Recupera una foto de la base de datos
        
        Args:
            paquete_id: ID del paquete
            
        Returns:
            bytes: Foto, o None si no existe
        """
        try:
            conn = DatabaseConnection.get_connection()
            cursor = conn.cursor()
            
            query = "SELECT foto_evidencia FROM paquetes WHERE id = %s"
            cursor.execute(query, (paquete_id,))
            
            result = cursor.fetchone()
            cursor.close()
            
            if result and result['foto_evidencia']:
                return result['foto_evidencia']
            
            return None
            
        except Error as e:
            print(f"❌ Error recuperando foto: {e}")
            return None
    
    @staticmethod
    def foto_a_base64(foto_bytes: bytes) -> str:
        """
        Convierte bytes a base64 string
        
        Args:
            foto_bytes: Bytes de la foto
            
        Returns:
            str: Foto en base64
        """
        return base64.b64encode(foto_bytes).decode('utf-8')
    
    @staticmethod
    def verificar_sensibilidad_blob():
        """Verifica que la BD pueda almacenar BLOBs grandes"""
        try:
            conn = DatabaseConnection.get_connection()
            cursor = conn.cursor()
            
            # Verificar max_allowed_packet
            cursor.execute("SHOW VARIABLES LIKE 'max_allowed_packet'")
            result = cursor.fetchone()
            
            if result:
                max_size = int(result['Value'])
                max_mb = max_size / (1024 * 1024)
                print(f"✓ max_allowed_packet: {max_mb:.2f} MB")
                
                if max_size < (20 * 1024 * 1024):  # Menos de 20MB
                    print(f"⚠️  Advertencia: max_allowed_packet es bajo para fotos grandes")
            
            cursor.close()
            
        except Error as e:
            print(f"❌ Error verificando configuración: {e}")
