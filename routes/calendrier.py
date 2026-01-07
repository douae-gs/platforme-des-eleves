from flask import Blueprint, render_template

calendrier_bp = Blueprint('calendrier', __name__)

@calendrier_bp.route('/calendrier')
def calendrier_academique():
   
        return render_template('calendrier/calendrier.html')
