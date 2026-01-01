from flask import Blueprint, render_template
import mysql.connector
from config import Config

contact_bp = Blueprint('contact', __name__)

def get_db_connection():
    return mysql.connector.connect(**Config.get_db_config())

@contact_bp.route('/contact')
def contact():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        query = """
            SELECT * FROM contact 
            WHERE service IN ('Scolarité', 'Direction')
            ORDER BY service
        """
        cursor.execute(query)
        contacts = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return render_template('contact/contact.html', contacts=contacts)
        
    except Exception as e:
        import traceback
        print(f"Erreur contact: {e}")
        traceback.print_exc()
        return render_template('contact/contact.html', contacts=[])