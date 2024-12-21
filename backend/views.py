# views.py

from flask import request, jsonify, send_from_directory
from app import app, db, GOOGLE_CLIENT_ID
from models import User, Presentation
from werkzeug.utils import secure_filename
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
import os
import logging
import requests  # Add this import

ALLOWED_EXTENSIONS = {'pptx'}

GOOGLE_CLIENT_ID = "545461705793-3v0101rqbcp0hqkeiqt0ohca9me9d0b3.apps.googleusercontent.com"

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/admin/login', methods=['POST'])
def admin_login():
    token = request.json.get("token")
    try:
        email = None
        if token.startswith('ya29.'):
            # Token is an access token
            resp = requests.get(
                'https://www.googleapis.com/oauth2/v1/userinfo',
                params={'access_token': token}
            )
            if resp.status_code != 200:
                raise Exception('Failed to fetch user info')
            userinfo = resp.json()
            email = userinfo.get('email')
            if not email:
                raise Exception('No email found in user info')
        else:
            # Token is an idToken
            idinfo = id_token.verify_oauth2_token(
                token, google_requests.Request(), GOOGLE_CLIENT_ID)
            email = idinfo['email']

        if email != "novahutskl@gmail.com":
            return jsonify({"error": "Unauthorized"}), 403
        user = User.query.filter_by(email=email).first()
        if not user:
            user = User(email=email)
            db.session.add(user)
            db.session.commit()
        return jsonify({"message": "Admin logged in", "email": email}), 200
    except Exception as e:
        logging.error(f"Login failed: {e}")
        return jsonify({"error": "Invalid token"}), 400

@app.route('/upload_presentation', methods=['POST'])
def upload_presentation():
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    file = request.files['file']
    title = request.form.get('title')
    category = request.form.get('category')

    if not title or not category:
        return jsonify({"error": "Title and category are required"}), 400

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        if not os.path.exists(app.config['UPLOAD_FOLDER']):
            os.makedirs(app.config['UPLOAD_FOLDER'])
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
        presentation = Presentation(title=title, category=category, file_path=file_path)
        db.session.add(presentation)
        db.session.commit()
        logging.debug(f"File uploaded: {file_path}")
        # Generate image URL (assuming you have logic to generate image previews)
        image_url = f"http://localhost:5656/uploads/{filename}"
        return jsonify({"message": "File uploaded", "image_url": image_url}), 200
    return jsonify({"error": "Invalid file type"}), 400

@app.route('/presentations', methods=['GET'])
def get_presentations():
    query = request.args.get('q', "")
    presentations = Presentation.query.filter(Presentation.title.contains(query)).all()
    response = []
    for p in presentations:
        image_url = f"http://localhost:5656/uploads/{os.path.basename(p.file_path)}"
        response.append({
            "id": p.id,
            "title": p.title,
            "category": p.category,
            "views": p.views,
            "upload_date": p.upload_date.strftime("%Y-%m-%d"),
            "image_url": image_url
        })
    return jsonify(response), 200

@app.route('/view_presentation/<int:presentation_id>', methods=['GET'])
def view_presentation(presentation_id):
    presentation = Presentation.query.get(presentation_id)
    if presentation:
        presentation.views += 1
        db.session.commit()
        logging.debug(f"Incremented views for presentation ID {presentation_id}")
        directory = os.path.dirname(presentation.file_path)
        filename = os.path.basename(presentation.file_path)
        return send_from_directory(directory, filename)
    return jsonify({"error": "Presentation not found"}), 404

# Category Management Endpoints

@app.route('/categories', methods=['GET'])
def get_categories():
    categories = Presentation.query.with_entities(Presentation.category).distinct().all()
    categories = [c[0] for c in categories]
    return jsonify(categories), 200

@app.route('/categories', methods=['POST'])
def create_category():
    data = request.get_json()
    category_name = data.get('name')
    if not category_name:
        return jsonify({"error": "Category name is required"}), 400
    existing = Presentation.query.filter_by(category=category_name).first()
    if existing:
        return jsonify({"error": "Category already exists"}), 400
    # Optionally, handle additional logic like creating a placeholder presentation
    return jsonify({"message": "Category created"}), 201

@app.route('/categories/<string:category_name>', methods=['DELETE'])
def delete_category(category_name):
    presentations = Presentation.query.filter_by(category=category_name).all()
    if not presentations:
        return jsonify({"error": "Category not found"}), 404
    for p in presentations:
        p.category = ""
    db.session.commit()
    return jsonify({"message": "Category deleted and presentations unassigned"}), 200

@app.route('/presentations/<int:presentation_id>/assign', methods=['POST'])
def assign_presentation(presentation_id):
    data = request.get_json()
    category_name = data.get('category')
    if not category_name:
        return jsonify({"error": "Category name is required"}), 400
    presentation = Presentation.query.get(presentation_id)
    if not presentation:
        return jsonify({"error": "Presentation not found"}), 404
    presentation.category = category_name
    db.session.commit()
    return jsonify({"message": "Presentation assigned to category"}), 200

@app.route('/presentations/<int:presentation_id>/unassign', methods=['POST'])
def unassign_presentation(presentation_id):
    presentation = Presentation.query.get(presentation_id)
    if not presentation:
        return jsonify({"error": "Presentation not found"}), 404
    presentation.category = ""
    db.session.commit()
    return jsonify({"message": "Presentation unassigned from category"}), 200

# Serve uploaded files
@app.route('/uploads/<path:filename>', methods=['GET'])
def serve_upload(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)
