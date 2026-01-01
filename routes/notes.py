from flask import Blueprint, render_template, session, redirect, url_for, flash
import mysql.connector
from config import Config

notes_bp = Blueprint('notes', __name__)

def get_db_connection():
    return mysql.connector.connect(**Config.get_db_config())

@notes_bp.route('/notes')
def notes():
    if 'user_id' not in session:
        flash('Veuillez vous connecter', 'error')
        return redirect(url_for('auth.login'))
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        query = "SELECT * FROM notes WHERE etudiant_id = %s ORDER BY nom_module"
        cursor.execute(query, (session['user_id'],))
        notes_list = cursor.fetchall()
        
        # Calculer la note finale 
        notes_processed = []
        for note in notes_list:
            note_ds = float(note.get('note_ds') or 0)
            note_examen = float(note.get('note_examen') or 0)
            
            #  Note finale = DS×0.5 + Examen×0.5
            if note_ds > 0 and note_examen > 0:
                note_finale = round((note_ds * 0.5) + (note_examen * 0.5), 2)
                statut = 'Validé' if note_finale >= 12 else 'Rattrapage'
            else:
                note_finale = note.get('note_generale') or 0
                statut = note.get('statut', 'N/A')
            
            note['note_finale_calculee'] = note_finale
            note['statut_calcule'] = statut
            notes_processed.append(note)
        
        # Calcul de la moyenne générale 
        if notes_processed:
            notes_valides = [n for n in notes_processed if n.get('note_finale_calculee', 0) > 0]
            if notes_valides:
                moyenne = round(sum([float(n['note_finale_calculee']) for n in notes_valides]) / len(notes_valides), 2)
            else:
                moyenne = 0
        else:
            moyenne = 0
        
        cursor.close()
        conn.close()
        
        return render_template('notes/notes.html', notes=notes_processed, moyenne=moyenne)
        
    except Exception as e:
        flash(f'Erreur: {str(e)}', 'error')
        return redirect(url_for('profile.profile'))
