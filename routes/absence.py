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

    conn = None
    cursor = None

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # 1️⃣ Récupérer les absences de l'étudiant connecté
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

        # 2️⃣ Vérifier dépassement de 3 absences PAR MODULE
        warning_query = """
            SELECT module, COUNT(*) AS total_absences
            FROM absences
            WHERE etudiant_id = %s
            GROUP BY module
            HAVING COUNT(*) > 3
        """
        cursor.execute(warning_query, (session['user_id'],))
        warnings = cursor.fetchall()

        # 3️⃣ Messages d’avertissement
        for w in warnings:
            flash(
                f"⚠️ Attention : vous avez dépassé 3 absences dans le module vous devez apporter une justification a l'administration "
                f"« {w['module']} » ({w['total_absences']} absences).",
                "warning"
            )

        return render_template(
            'absence/absence.html',
            absences=absences_list
        )

    except Exception as e:
        import traceback
        print("Erreur absences :", e)
        traceback.print_exc()
        flash("Erreur lors du chargement des absences", "error")
        return render_template('absence/absence.html', absences=[])

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
