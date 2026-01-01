from flask import Blueprint, render_template, request, redirect, url_for, session, flash
import mysql.connector
from config import Config
import re

auth_bp = Blueprint('auth', __name__)

def get_db_connection():
    return mysql.connector.connect(**Config.get_db_config())

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        nom = request.form.get('nom', '').strip()
        prenom = request.form.get('prenom', '').strip()
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')
        confirm_password = request.form.get('confirm_password', '')
        filiere = request.form.get('filiere', '').strip()
        ecole = request.form.get('ecole', '').strip()
        
        if not all([nom, prenom, email, password, filiere]):
            flash('Tous les champs sont obligatoires', 'error')
            return render_template('auth/register.html')
        
        # Validation email
        email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_regex, email):
            flash('Adresse email invalide', 'error')
            return render_template('auth/register.html')
        
        # Validation mot de passe
        if len(password) < 6:
            flash('Le mot de passe doit contenir au moins 6 caractères', 'error')
            return render_template('auth/register.html')

        if password != confirm_password:
            flash('Les mots de passe ne correspondent pas', 'error')
            return render_template('auth/register.html')
        
        try:
            conn = get_db_connection()
            if not conn:
                flash('Erreur de connexion à la base de données', 'error')
                return render_template('auth/register.html')
            
            cursor = conn.cursor(dictionary=True)
            
            # Vérifier si l'email existe déjà
            cursor.execute("SELECT id FROM etudiants WHERE email = %s", (email,))
            if cursor.fetchone():
                flash('Un compte existe déjà avec cet email', 'error')
                cursor.close()
                conn.close()
                return render_template('auth/register.html')
            
            cycle = 'prepa' if filiere in ['CP1', 'CP2'] else 'ingenieur'
            
            # Insertion du nouvel utilisateur 
            insert_query = """
                INSERT INTO etudiants (nom, prenom, email, mot_de_passe, filiere, ecole, cycle)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(insert_query, (nom, prenom, email, password, filiere, 'ENSAO', cycle))
            
            conn.commit()
            
            # Vérifier que l'insertion a réussi
            user_id = cursor.lastrowid
            if not user_id:
                conn.rollback()
                flash('Erreur lors de l\'enregistrement. Veuillez réessayer.', 'error')
                cursor.close()
                conn.close()
                return render_template('auth/register.html')
            
            # Récupérer les données de l'utilisateur 
            cursor.execute("SELECT * FROM etudiants WHERE id = %s", (user_id,))
            user = cursor.fetchone()
            
            if not user:
                conn.rollback()
                flash('Erreur lors de la récupération des données utilisateur', 'error')
                cursor.close()
                conn.close()
                return render_template('auth/register.html')
            
            cursor.close()
            conn.close()
            
            # Connecter automatiquement l'utilisateur
            session['user_id'] = user['id']
            session['user_name'] = f"{user['prenom']} {user['nom']}"
            session['user_email'] = user['email']
            session['user_filiere'] = user.get('filiere', 'N/A')
            
            flash('Inscription réussie ! Bienvenue !', 'success')
            return redirect(url_for('profile.profile'))
            
        except mysql.connector.Error as db_error:
            if conn:
                conn.rollback()
            print(f"Erreur DB lors de l'inscription: {db_error}")
            flash(f'Erreur de base de données: {str(db_error)}', 'error')
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()
            return render_template('auth/register.html')
        except Exception as e:
            if 'conn' in locals() and conn:
                conn.rollback()
            print(f"Erreur lors de l'inscription: {e}")
            import traceback
            traceback.print_exc()
            flash(f'Erreur lors de l\'inscription: {str(e)}', 'error')
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()
            return render_template('auth/register.html')
    
    return render_template('auth/register.html')

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')
        
        if not email or not password:
            flash('Email et mot de passe requis', 'error')
            return render_template('auth/login.html')
        
        try:
            conn = get_db_connection()
            if not conn:
                flash('Erreur de connexion à la base de données', 'error')
                return render_template('auth/login.html')
            
            cursor = conn.cursor(dictionary=True)
            
            # Vérifier d'abord si l'email existe
            cursor.execute("SELECT * FROM etudiants WHERE email = %s", (email,))
            user = cursor.fetchone()
            
            if not user:
                flash('Email ou mot de passe incorrect', 'error')
                cursor.close()
                conn.close()
                return render_template('auth/login.html')
            
            # Vérifier le mot de passe 
            if user['mot_de_passe'] != password:
                flash('Email ou mot de passe incorrect', 'error')
                cursor.close()
                conn.close()
                return render_template('auth/login.html')
            
            # Connexion réussie
            session['user_id'] = user['id']
            session['user_name'] = f"{user['prenom']} {user['nom']}"
            session['user_email'] = user['email']
            session['user_filiere'] = user.get('filiere', 'N/A')
            
            cursor.close()
            conn.close()
            
            flash('Connexion réussie !', 'success')
            return redirect(url_for('profile.profile'))
                
        except Exception as e:
            flash(f'Erreur de connexion: {str(e)}', 'error')
            return render_template('auth/login.html')
    
    return render_template('auth/login.html')

@auth_bp.route('/logout')
def logout():
    session.clear()
    flash('Déconnexion réussie', 'info')
    return redirect(url_for('auth.login'))


