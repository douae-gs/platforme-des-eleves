from flask import Blueprint, render_template, request
import mysql.connector
from config import Config

absence_bp = Blueprint('absence', __name__)

def get_db_connection():
    return mysql.connector.connect(**Config.get_db_config())

@absence_bp.route('/absence')
def absences():
    from flask import session, redirect, url_for, flash
    
    if 'user_id' not in session:
        flash('Veuillez vous connecter', 'error')
        return redirect(url_for('auth.login'))
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Filtrer uniquement les absences de l'utilisateur connecté
        query = """
            SELECT a.*, e.nom, e.prenom, f.nom AS filiere_nom
            FROM absences a
            JOIN etudiants e ON a.etudiant_id = e.id
            LEFT JOIN filieres f ON a.filiere_id = f.id
            WHERE a.etudiant_id = %s
            ORDER BY a.date_absence DESC
        """
        cursor.execute(query, (session['user_id'],))
        absences_list = cursor.fetchall()
        
        cursor.close()
        conn.close()

        return render_template('absence/absence.html', absences=absences_list)
    except Exception as e:
        import traceback
        print(f"Erreur absences: {e}")
        traceback.print_exc()
        flash(f'Erreur lors du chargement des absences: {str(e)}', 'error')
        return render_template('absence/absence.html', absences=[])