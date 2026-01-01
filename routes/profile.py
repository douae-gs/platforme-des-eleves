from flask import Blueprint, render_template, session, redirect, url_for, flash
import mysql.connector
from config import Config

profile_bp = Blueprint('profile', __name__)

def get_db_connection():
    return mysql.connector.connect(**Config.get_db_config())

@profile_bp.route('/profile')
def profile():
    """Afficher le profil complet de l'étudiant"""
    if 'user_id' not in session:
        flash('Veuillez vous connecter', 'error')
        return redirect(url_for('auth.login'))
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # RécupérATION les info de l'étudiant
        query = "SELECT * FROM etudiants WHERE id = %s"
        cursor.execute(query, (session['user_id'],))
        user = cursor.fetchone()
        
        if not user:
            flash('Utilisateur introuvable', 'error')
            return redirect(url_for('auth.login'))
        
        # Calculer des statistiques
        # Nombre de notes
        cursor.execute("SELECT COUNT(*) as total FROM notes WHERE etudiant_id = %s", (session['user_id'],))
        stats_notes = cursor.fetchone()
        
        # Nombre d'absences
        cursor.execute("SELECT COUNT(*) as total FROM absences WHERE etudiant_id = %s", (session['user_id'],))
        stats_absences = cursor.fetchone()
        
        # Moyenne générale 
        cursor.execute("""
            SELECT AVG(note_generale) as moyenne 
            FROM notes 
            WHERE etudiant_id = %s AND note_generale IS NOT NULL
        """, (session['user_id'],))
        stats_moyenne = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        return render_template(
            'profile/profile.html',
            user=user,
            total_notes=stats_notes['total'] if stats_notes else 0,
            total_absences=stats_absences['total'] if stats_absences else 0,
            moyenne_generale=round(stats_moyenne['moyenne'], 2) if stats_moyenne and stats_moyenne['moyenne'] else 0
        )
        
    except Exception as e:
        import traceback
        print(f"Erreur profile: {e}")
        traceback.print_exc()
        flash(f'Erreur lors du chargement du profil: {str(e)}', 'error')
        return redirect(url_for('auth.login'))