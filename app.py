from flask import Flask, redirect, url_for
from config import Config
app = Flask(__name__)
app.config.from_object(Config)
app.secret_key = Config.SECRET_KEY

from routes.auth import auth_bp
from routes.profile import profile_bp
from routes.notes import notes_bp
from routes.contact import contact_bp
from routes.filiere import filiere_bp
from routes.absence import absence_bp
from routes.emploi import emploi_bp
from routes.calendrier import calendrier_bp
app.register_blueprint(auth_bp)
app.register_blueprint(profile_bp)
app.register_blueprint(notes_bp)
app.register_blueprint(contact_bp)
app.register_blueprint(filiere_bp)
app.register_blueprint(absence_bp)
app.register_blueprint(emploi_bp)
app.register_blueprint(calendrier_bp)
@app.route('/')
def index():
    return redirect(url_for('auth.login'))
if __name__ == '__main__':
    print("="*70)
    print(" ELEVEPLATFORM - APPLICATION DÉMARRÉE".center(70))
    print("="*70)
    print(" URL: http://localhost:5000")
    print(" Email test: test@ensa.ma")
    print(" Mot de passe: tEST123")
    print("="*70)
    app.run(debug=True, port=5000, host='0.0.0.0')

