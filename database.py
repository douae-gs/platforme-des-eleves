import mysql.connector
from config import Config
def get_db_connection():
    """Connexion MySQL"""
    try:
        return mysql.connector.connect(**Config.get_db_config())
    except Exception as e:
        print(f"Erreur de connexion à la base de données: {e}")
        return None

def execute_query(query, params=None, fetch=False):
    """Exécuter une requête SQL"""
    conn = get_db_connection()
    if not conn:
        return [] if fetch else None
    
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute(query, params or ())
        
        if fetch:
            result = cursor.fetchall()
            cursor.close()
            conn.close()
            return result
        else:
            conn.commit()
            lastrowid = cursor.lastrowid
            cursor.close()
            conn.close()
            return lastrowid
            
    except Exception as e:
        print(f"Erreur SQL: {e}")
        cursor.close()
        conn.close()
        return [] if fetch else None
