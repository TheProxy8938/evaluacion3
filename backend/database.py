import mysql.connector
from mysql.connector import Error
from config import DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, DB_PORT

class DatabaseConnection:
    _connection = None
    
    @staticmethod
    def get_connection():
        """Obtiene o crea una conexión a la base de datos"""
        try:
            if DatabaseConnection._connection is None or not DatabaseConnection._connection.is_connected():
                DatabaseConnection._connection = mysql.connector.connect(
                    host=DB_HOST,
                    user=DB_USER,
                    password=DB_PASSWORD,
                    database=DB_NAME,
                    port=DB_PORT,
                    autocommit=True,
                    use_pure=True  # Usar implementación pura de Python
                )
                print("Conexion a la base de datos establecida")
            return DatabaseConnection._connection
        except Error as e:
            print(f"Error al conectar a la base de datos: {e}")
            raise
    
    @staticmethod
    def close_connection():
        """Cierra la conexión a la base de datos"""
        if DatabaseConnection._connection and DatabaseConnection._connection.is_connected():
            DatabaseConnection._connection.close()
            print("Conexión a la base de datos cerrada.")

def get_db_cursor():
    """Obtiene un cursor para ejecutar queries"""
    conn = DatabaseConnection.get_connection()
    return conn.cursor(dictionary=True)

def execute_query(query, params=None):
    """Ejecuta una query y retorna el resultado"""
    try:
        cursor = get_db_cursor()
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        return cursor
    except Error as e:
        print(f"Error ejecutando query: {e}")
        raise

def fetch_one(query, params=None):
    """Obtiene un registro"""
    cursor = execute_query(query, params)
    return cursor.fetchone()

def fetch_all(query, params=None):
    """Obtiene todos los registros"""
    cursor = execute_query(query, params)
    return cursor.fetchall()

def insert_update_delete(query, params=None):
    """Ejecuta INSERT, UPDATE o DELETE"""
    try:
        cursor = execute_query(query, params)
        return cursor.rowcount
    except Error as e:
        print(f"Error executando operación: {e}")
        raise
