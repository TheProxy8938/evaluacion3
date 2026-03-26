#!/usr/bin/env python3
"""
Script de inicialización de MySQL para almacenamiento de fotos
Ejecutar desde: python init_foto_config.py
"""

import sys
import os
import mysql.connector
from mysql.connector import Error

# Cargar configuración
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from config import DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, DB_PORT


def conectar_mysql(con_db=True):
    """Conectar a MySQL"""
    try:
        config = {
            'host': DB_HOST,
            'user': DB_USER,
            'password': DB_PASSWORD,
            'port': DB_PORT,
        }
        
        if con_db:
            config['database'] = DB_NAME
        
        conn = mysql.connector.connect(**config)
        return conn
    except Error as e:
        print(f"❌ Error conectando a MySQL: {e}")
        return None


def verificar_tabla_paquetes():
    """Verificar y actualizar tabla paquetes si es necesario"""
    print("\n" + "="*60)
    print("VERIFICACIÓN DE TABLA 'paquetes'")
    print("="*60)
    
    conn = conectar_mysql(con_db=True)
    if not conn:
        return False
    
    try:
        cursor = conn.cursor()
        
        # Verificar que la columna foto_evidencia existe y es LONGBLOB
        cursor.execute("""
            SELECT COLUMN_NAME, COLUMN_TYPE 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME = 'paquetes' AND COLUMN_NAME = 'foto_evidencia'
        """)
        
        resultado = cursor.fetchone()
        
        if not resultado:
            print("❌ Columna 'foto_evidencia' no encontrada")
            print("Creando columna...")
            
            alter_query = """
                ALTER TABLE paquetes 
                ADD COLUMN foto_evidencia LONGBLOB COMMENT 'Foto de evidencia en BLOB'
            """
            cursor.execute(alter_query)
            conn.commit()
            print("✓ Columna foto_evidencia creada como LONGBLOB")
            
        else:
            columna, tipo = resultado
            print(f"✓ Columna encontrada: {columna}")
            print(f"  Tipo: {tipo}")
            
            if 'LONGBLOB' not in tipo.upper():
                print(f"⚠️  ADVERTENCIA: La columna no es LONGBLOB, es {tipo}")
                print("Intentando actualizar...")
                
                alter_query = """
                    ALTER TABLE paquetes 
                    MODIFY COLUMN foto_evidencia LONGBLOB COMMENT 'Foto de evidencia en BLOB'
                """
                cursor.execute(alter_query)
                conn.commit()
                print("✓ Columna actualizada a LONGBLOB")
        
        cursor.close()
        conn.close()
        return True
        
    except Error as e:
        print(f"❌ Error: {e}")
        if cursor:
            cursor.close()
        if conn:
            conn.close()
        return False


def verificar_variables_mysql():
    """Verificar variables críticas de MySQL"""
    print("\n" + "="*60)
    print("VERIFICACIÓN DE VARIABLES MYSQL")
    print("="*60)
    
    conn = conectar_mysql(con_db=True)
    if not conn:
        return False
    
    try:
        cursor = conn.cursor()
        
        # Variables importante para BLOB
        variables = [
            'max_allowed_packet',
            'tmp_table_size',
            'max_heap_table_size',
            'innodb_log_file_size'
        ]
        
        for var in variables:
            cursor.execute(f"SHOW VARIABLES LIKE '{var}'")
            result = cursor.fetchone()
            
            if result:
                var_name, var_value = result
                try:
                    valor_bytes = int(var_value)
                    valor_mb = valor_bytes / (1024 * 1024)
                    print(f"✓ {var_name:30} = {valor_mb:10.2f} MB")
                    
                    # Alertas
                    if var_name == 'max_allowed_packet' and valor_mb < 16:
                        print(f"  ⚠️  ALERTA: max_allowed_packet muy bajo para fotos grandes")
                except:
                    print(f"✓ {var_name:30} = {var_value}")
        
        cursor.close()
        conn.close()
        return True
        
    except Error as e:
        print(f"❌ Error: {e}")
        if cursor:
            cursor.close()
        if conn:
            conn.close()
        return False


def aumentar_max_allowed_packet():
    """Intenta aumentar max_allowed_packet"""
    print("\n" + "="*60)
    print("AJUSTE DE max_allowed_packet")
    print("="*60)
    
    conn = conectar_mysql(con_db=False)
    if not conn:
        return False
    
    try:
        cursor = conn.cursor()
        
        # Verificar valor actual
        cursor.execute("SHOW VARIABLES LIKE 'max_allowed_packet'")
        result = cursor.fetchone()
        
        if result:
            var_name, var_value = result
            valor_mb = int(var_value) / (1024 * 1024)
            print(f"Valor actual: {valor_mb:.2f} MB")
            
            if valor_mb < 256:
                print(f"Aumentando a 256 MB...")
                print("\n⚠️  NOTA: Para cambios permanentes, agregar a my.cnf:")
                print("   [mysqld]")
                print("   max_allowed_packet = 256M")
                print("\n   Luego reiniciar MySQL")
        
        cursor.close()
        conn.close()
        return True
        
    except Error as e:
        print(f"⚠️  No se pudo ajustar: {e}")
        return False


def crear_trigger_timestamp():
    """Crear trigger para updated_at automático"""
    print("\n" + "="*60)
    print("SETUP DE TIMESTAMP AUTOMÁTICO")
    print("="*60)
    
    conn = conectar_mysql(con_db=True)
    if not conn:
        return False
    
    try:
        cursor = conn.cursor()
        
        # Verificar que la columna updated_at existe
        cursor.execute("""
            SELECT COLUMN_NAME 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME = 'paquetes' AND COLUMN_NAME = 'updated_at'
        """)
        
        if not cursor.fetchone():
            print("Agregando columna updated_at...")
            cursor.execute("""
                ALTER TABLE paquetes 
                ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
                ON UPDATE CURRENT_TIMESTAMP
            """)
            conn.commit()
            print("✓ Columna updated_at agregada")
        else:
            print("✓ Columna updated_at ya existe")
        
        cursor.close()
        conn.close()
        return True
        
    except Error as e:
        print(f"❌ Error: {e}")
        if cursor:
            cursor.close()
        if conn:
            conn.close()
        return False


def main():
    """Ejecutar todas las verificaciones"""
    print("\n")
    print("╔" + "="*58 + "╗")
    print("║" + " " * 58 + "║")
    print("║" + "  INICIALIZACIÓN DE MYSQL PARA ALMACENAMIENTO DE FOTOS".center(58) + "║")
    print("║" + " " * 58 + "║")
    print("╚" + "="*58 + "╝")
    
    print(f"\nBaseDatos: {DB_NAME}")
    print(f"Host: {DB_HOST}:{DB_PORT}")
    print(f"Usuario: {DB_USER}")
    
    resultados = []
    
    # Ejecutar verificaciones
    resultados.append(("Tabla paquetes", verificar_tabla_paquetes()))
    resultados.append(("Variables MySQL", verificar_variables_mysql()))
    resultados.append(("Timestamp automático", crear_trigger_timestamp()))
    
    # Sugerencia para optimización
    aumentar_max_allowed_packet()
    
    # Resumen
    print("\n" + "="*60)
    print("RESUMEN")
    print("="*60)
    
    for nombre, resultado in resultados:
        estado = "✓" if resultado else "❌"
        print(f"{estado} {nombre}")
    
    print("\n" + "="*60)
    print("PRÓXIMOS PASOS:")
    print("="*60)
    print("1. Ejecutar test_foto_storage.py para verificar funcionamiento")
    print("2. Reiniciar el servidor backend: python main.py")
    print("3. Probar desde la app Flutter")
    print("\nSi hay problemas con fotos grandes, agregar a MySQL config:")
    print("  max_allowed_packet = 256M")
    print("  tmp_table_size = 256M")
    print("  max_heap_table_size = 256M")


if __name__ == "__main__":
    main()
