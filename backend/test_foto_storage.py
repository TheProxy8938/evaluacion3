#!/usr/bin/env python3
"""
Script de prueba y verificación para almacenamiento de fotos en BLOB
Ejecutar desde: python test_foto_storage.py
"""

import sys
import os
import base64
from pathlib import Path

# Agregar ruta del backend al path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from database import DatabaseConnection
from utils.foto_handler import FotoHandler


def crear_foto_test(tamaño_kb=100):
    """
    Crea una foto de prueba (PNG simple)
    
    Args:
        tamaño_kb: Tamaño aproximado en KB
        
    Returns:
        bytes: Foto generada
    """
    # PNG mínimo válido (1x1 pixel, transparente)
    png_header = bytes([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,  # Firma PNG
        0x00, 0x00, 0x00, 0x0D,  # IHDR length
        0x49, 0x48, 0x44, 0x52,  # IHDR
        0x00, 0x00, 0x00, 0x01,  # Ancho: 1
        0x00, 0x00, 0x00, 0x01,  # Alto: 1
        0x08, 0x06, 0x00, 0x00, 0x00,  # Bit depth, color type, etc.
        0x1F, 0x15, 0xC4, 0x89,  # CRC
        0x00, 0x00, 0x00, 0x0A,  # IDAT length
        0x49, 0x44, 0x41, 0x54,  # IDAT
        0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05,  # Datos comprimidos
        0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4,  # CRC
        0x00, 0x00, 0x00, 0x00,  # IEND length
        0x49, 0x45, 0x4E, 0x44,  # IEND
        0xAE, 0x42, 0x60, 0x82  # CRC
    ])
    
    # Rellenar a tamaño deseado
    relleno = os.urandom(max(0, tamaño_kb * 1024 - len(png_header)))
    return png_header + relleno


def test_decodificacion_base64():
    """Test 1: Verificar decodificación de base64"""
    print("\n" + "="*60)
    print("TEST 1: Decodificación de Base64")
    print("="*60)
    
    try:
        # Crear foto de prueba pequeña
        foto_original = crear_foto_test(tamaño_kb=50)
        print(f"✓ Foto de prueba creada: {len(foto_original)} bytes")
        
        # Codificar a base64
        foto_b64 = base64.b64encode(foto_original).decode('utf-8')
        print(f"✓ Codificada en base64: {len(foto_b64)} caracteres")
        
        # Decodificar
        foto_decodificada = FotoHandler.decodificar_base64(foto_b64)
        
        if foto_decodificada and foto_decodificada == foto_original:
            print(f"✓ Decodificación exitosa: {len(foto_decodificada)} bytes")
            return True
        else:
            print("❌ Decodificación fallida: bytes no coinciden")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False


def test_conexion_db():
    """Test 2: Verificar conexión a base de datos"""
    print("\n" + "="*60)
    print("TEST 2: Conexión a Base de Datos")
    print("="*60)
    
    try:
        conn = DatabaseConnection.get_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Verificar tabla paquetes existe
        cursor.execute("""
            SELECT COLUMN_NAME, COLUMN_TYPE 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME = 'paquetes' AND COLUMN_NAME = 'foto_evidencia'
        """)
        result = cursor.fetchone()
        
        if result:
            print(f"✓ Tabla 'paquetes' encontrada")
            print(f"  - Columna: {result['COLUMN_NAME']}")
            print(f"  - Tipo: {result['COLUMN_TYPE']}")
            
            # Verificar que sea LONGBLOB
            if 'LONGBLOB' in result['COLUMN_TYPE'].upper():
                print(f"✓ Campo foto_evidencia es LONGBLOB")
            else:
                print(f"⚠️  Advertencia: Campo no es LONGBLOB, es {result['COLUMN_TYPE']}")
            
            cursor.close()
            return True
        else:
            print("❌ Campo foto_evidencia no encontrado en tabla paquetes")
            cursor.close()
            return False
            
    except Exception as e:
        print(f"❌ Error conectando a BD: {e}")
        return False


def test_guardado_foto():
    """Test 3: Guardar y recuperar foto en DB"""
    print("\n" + "="*60)
    print("TEST 3: Guardado y Recuperación en BD")
    print("="*60)
    
    try:
        # Crear foto de prueba
        foto_original = crear_foto_test(tamaño_kb=50)
        paquete_id_test = 999  # ID de prueba
        
        print(f"Usando paquete ID: {paquete_id_test} (de prueba)")
        print(f"Tamaño de foto: {len(foto_original)} bytes")
        
        # Verificar que el paquete existe
        from database import fetch_one
        paquete = fetch_one(
            "SELECT id FROM paquetes WHERE id = %s",
            (paquete_id_test,)
        )
        
        if not paquete:
            print(f"⚠️  Paquete {paquete_id_test} no existe. Saltando guardado...")
            return True
        
        # Guardar foto
        guardar_ok = FotoHandler.guardar_foto_en_db(paquete_id_test, foto_original)
        
        if not guardar_ok:
            print("❌ Error guardando foto")
            return False
        
        print("✓ Foto guardada en BD")
        
        # Recuperar foto
        foto_recuperada = FotoHandler.recuperar_foto(paquete_id_test)
        
        if foto_recuperada and foto_recuperada == foto_original:
            print(f"✓ Foto recuperada correctamente: {len(foto_recuperada)} bytes")
            return True
        else:
            print("❌ Foto recuperada no coincide con original")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False


def test_entregar_paquete_completo():
    """Test 4: Registrar entrega completa (foto + GPS)"""
    print("\n" + "="*60)
    print("TEST 4: Entrega Completa (Foto + GPS)")
    print("="*60)
    
    try:
        paquete_id_test = 999
        
        # Crear foto
        foto_original = crear_foto_test(tamaño_kb=50)
        foto_b64 = base64.b64encode(foto_original).decode('utf-8')
        
        # Coordenadas GPS de prueba
        latitud = 4.7110  # Bogotá
        longitud = -74.0721
        
        print(f"Paquete ID: {paquete_id_test}")
        print(f"Foto: {len(foto_b64)} caracteres (base64)")
        print(f"GPS: ({latitud}, {longitud})")
        
        # Guardar entrega
        success, mensaje = FotoHandler.guardar_entrega_completa(
            paquete_id=paquete_id_test,
            foto_base64=foto_b64,
            latitud=latitud,
            longitud=longitud
        )
        
        if success:
            print(f"✓ {mensaje}")
            return True
        else:
            print(f"❌ {mensaje}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False


def verificar_configuracion_db():
    """Verificar la configuración de la base de datos"""
    print("\n" + "="*60)
    print("VERIFICACIÓN DE CONFIGURACIÓN BD")
    print("="*60)
    
    try:
        conn = DatabaseConnection.get_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Verificar max_allowed_packet
        cursor.execute("SHOW VARIABLES LIKE 'max_allowed_packet'")
        result = cursor.fetchone()
        
        if result:
            valor = int(result['Value'])
            valor_mb = valor / (1024 * 1024)
            print(f"✓ max_allowed_packet: {valor_mb:.2f} MB")
            
            if valor_mb < 16:
                print(f"⚠️  Advertencia: max_allowed_packet es bajo para fotos grandes")
        
        cursor.close()
        conn.close()
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False


def main():
    """Ejecutar todos los tests"""
    print("\n")
    print("╔" + "="*58 + "╗")
    print("║" + " " * 58 + "║")
    print("║" + "  TESTS DE ALMACENAMIENTO DE FOTOS EN BASE DE DATOS".center(58) + "║")
    print("║" + " " * 58 + "║")
    print("╚" + "="*58 + "╝")
    
    resultados = []
    
    # Ejecutar tests
    resultados.append(("Decodificación Base64", test_decodificacion_base64()))
    resultados.append(("Conexión BD", test_conexion_db()))
    resultados.append(("Guardado en BD", test_guardado_foto()))
    resultados.append(("Entrega Completa", test_entregar_paquete_completo()))
    resultados.append(("Verificación BD", verificar_configuracion_db()))
    
    # Resumen
    print("\n" + "="*60)
    print("RESUMEN DE RESULTADOS")
    print("="*60)
    
    passed = sum(1 for _, resultado in resultados if resultado)
    total = len(resultados)
    
    for nombre, resultado in resultados:
        estado = "✓ PASS" if resultado else "❌ FAIL"
        print(f"{estado:10} {nombre}")
    
    print("="*60)
    print(f"Total: {passed}/{total} tests pasados")
    
    return passed == total


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
