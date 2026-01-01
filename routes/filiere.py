from flask import Blueprint, render_template
import mysql.connector
from config import Config

filiere_bp = Blueprint('filiere', __name__)

def get_db_connection():
    return mysql.connector.connect(**Config.get_db_config())

@filiere_bp.route('/filieres')
def filieres():
    from flask import session, redirect, url_for, flash
    
    if 'user_id' not in session:
        flash('Veuillez vous connecter', 'error')
        return redirect(url_for('auth.login'))
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Récupérer la filière de l'utilisateur connecté
        cursor.execute("SELECT filiere FROM etudiants WHERE id = %s", (session['user_id'],))
        user = cursor.fetchone()
        
        if not user or not user.get('filiere'):
            flash('Filière non trouvée pour votre compte', 'error')
            cursor.close()
            conn.close()
            return redirect(url_for('profile.profile'))
        
        user_filiere = user['filiere']
        
        # Mapping des filières utilisateur vers les codes de la base de données
        # La base utilise: PREPA, ITIRC, GI, GE, etc.
        filiere_code_mapping = {
            'CP1': 'PREPA',
            'CP2': 'PREPA',
            'ITIRC': 'ITIRC',
            'GE': 'GE',
            'GINFO': 'GI',
            'Génie Info': 'GI',
            'Génie Électrique': 'GE',
            'Cycle d\'ingénieurs': 'ITIRC'
        }
        
        # Obtenir le code de la filière dans la base
        filiere_code = filiere_code_mapping.get(user_filiere, user_filiere)
        
        # Chercher la filière par code d'abord (plus fiable)
        cursor.execute("SELECT * FROM filieres WHERE code = %s", (filiere_code,))
        filiere_data = cursor.fetchone()
        
        # Si pas trouvé par code, chercher par nom
        if not filiere_data:
            filiere_mapping = {
                'CP1': 'Cycle Préparatoire Intégré',
                'CP2': 'Cycle Préparatoire Intégré',
                'ITIRC': 'Informatique et Technologies des Réseaux',
                'GE': 'Génie Électrique',
                'GINFO': 'Génie Informatique'
            }
            filiere_nom = filiere_mapping.get(user_filiere, user_filiere)
            cursor.execute("SELECT * FROM filieres WHERE nom LIKE %s", (f'%{filiere_nom}%',))
            filiere_data = cursor.fetchone()
        
        # Si toujours pas trouvé, chercher par nom exact de l'utilisateur
        if not filiere_data:
            cursor.execute("SELECT * FROM filieres WHERE code = %s OR nom = %s", (user_filiere, user_filiere))
            filiere_data = cursor.fetchone()
        
        if filiere_data:
            # Récupérer les modules de cette filière
            cursor.execute("""
                SELECT code, nom, volume_horaire, professeur_responsable 
                FROM modules 
                WHERE filiere_id = %s 
                ORDER BY code
            """, (filiere_data['id'],))
            modules = cursor.fetchall()
            filiere_data['modules'] = modules
        else:
            # Si aucune filière trouvée, créer un objet avec les infos de l'utilisateur
            filiere_data = {
                'nom': user_filiere,
                'code': user_filiere,
                'type': None,
                'duree': None,
                'description': None,
                'modules': []
            }
        
        cursor.close()
        conn.close()
        
        return render_template('filière/filieres.html', filieres=[filiere_data])
    except Exception as e:
        import traceback
        print(f"Erreur filieres: {e}")
        traceback.print_exc()
        flash(f'Erreur lors du chargement des filières: {str(e)}', 'error')
        return render_template('filière/filieres.html', filieres=[])
