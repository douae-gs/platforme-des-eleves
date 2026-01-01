from flask import Blueprint, render_template

calendrier_bp = Blueprint('calendrier', __name__)

@calendrier_bp.route('/calendrier')
def calendrier_academique():
    try:
        return render_template('calendrier/calendrier.html')
    except Exception as e:
        import traceback
        print(f"Erreur calendrier: {e}")
        traceback.print_exc()
        return f"<h1>Erreur</h1><p>{e}</p>"