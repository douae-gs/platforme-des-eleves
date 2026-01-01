from flask import Blueprint, render_template, request
import mysql.connector
from config import Config

emploi_bp = Blueprint('emploi', __name__)

def get_db_connection():
    return mysql.connector.connect(**Config.get_db_config())

@emploi_bp.route('/emploi')
def emploi_du_temps():
    try:
        filiere_id = request.args.get('filiere', None)
        
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Exclure la filière GTR (Génie des Télécommunications et Réseaux)
        cursor.execute("""
            SELECT * FROM filieres 
            WHERE code != 'GTR' AND nom NOT LIKE '%Télécommunications%'
            ORDER BY nom
        """)
        filieres = cursor.fetchall()
        
        if filiere_id:
            query = """
                SELECT * FROM emploi
                WHERE filiere_id = %s
                ORDER BY FIELD(jour, 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'), heure
            """
            cursor.execute(query, (filiere_id,))
            emploi = cursor.fetchall()
            filiere_selectionnee = int(filiere_id)
        else:
            emploi = []
            filiere_selectionnee = None
        
        cursor.close()
        conn.close()
        
        return render_template('emploi/emploi.html', filieres=filieres, emploi=emploi, filiere_selectionnee=filiere_selectionnee)
    except Exception as e:
        import traceback
        print(f"Erreur emploi: {e}")
        traceback.print_exc()
        return render_template('emploi/emploi.html', filieres=[], emploi=[], filiere_selectionnee=None)