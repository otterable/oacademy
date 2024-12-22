# views.py

from flask import request, jsonify, send_from_directory
from app import app, db, GOOGLE_CLIENT_ID
from models import User, Presentation
from werkzeug.utils import secure_filename
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
import os
import logging
import requests
from datetime import datetime

ALLOWED_EXTENSIONS = {'pptx', 'pdf'}

def allowed_file(filename):
    ext = filename.rsplit('.', 1)[1].lower()
    return '.' in filename and ext in ALLOWED_EXTENSIONS

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
                token, google_requests.Request(), GOOGLE_CLIENT_ID
            )
            email = idinfo['email']

        # Only your admin email is allowed
        if email != "novahutskl@gmail.com":
            return jsonify({"error": "Unauthorized"}), 403

        user = User.query.filter_by(email=email).first()
        if not user:
            user = User(email=email)
            db.session.add(user)
            db.session.commit()

        logging.debug(f"Admin {email} logged in.")
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

    if not title or category is None:
        return jsonify({"error": "Title and category are required"}), 400

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)

        # Log file size and start timestamp
        file.seek(0, os.SEEK_END)  # Move cursor to end to get size
        size_bytes = file.tell()
        file_size_mb = round(size_bytes / (1024 * 1024), 2)
        file.seek(0)  # Reset to beginning
        start_time = datetime.utcnow().isoformat()

        logging.debug(
            f"Presentation upload starting: {filename}, size={file_size_mb} MB, start={start_time}"
        )

        # Create uploads folder if needed
        if not os.path.exists(app.config['UPLOAD_FOLDER']):
            os.makedirs(app.config['UPLOAD_FOLDER'])

        # Save file
        file.save(file_path)

        # Create DB entry
        presentation = Presentation(
            title=title,
            category=category,  # could be "" if uncategorized
            file_path=file_path
        )
        db.session.add(presentation)
        db.session.commit()

        end_time = datetime.utcnow().isoformat()
        logging.debug(
            f"Presentation upload finished: {filename}, end={end_time}"
        )

        # Return image_url or direct path
        # We'll store in "image_url" but it can also be used for pdf/pptx
        image_url = f"http://localhost:5656/uploads/{filename}"
        return jsonify({"message": "File uploaded", "image_url": image_url}), 200

    return jsonify({"error": "Invalid file type"}), 400

@app.route('/presentations', methods=['GET'])
def get_presentations():
    query = request.args.get('q', "")
    presentations = Presentation.query.filter(
        Presentation.title.contains(query)
    ).all()

    response = []
    for p in presentations:
        # direct link
        file_link = f"http://localhost:5656/uploads/{os.path.basename(p.file_path)}"
        response.append({
            "id": p.id,
            "title": p.title,
            "category": p.category,
            "views": p.views,
            "upload_date": p.upload_date.strftime("%Y-%m-%d"),
            "image_url": file_link  # Using "image_url" but it's a file link
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

@app.route('/categories', methods=['GET'])
def get_categories():
    categories = Presentation.query.with_entities(
        Presentation.category
    ).distinct().all()
    categories = [c[0] for c in categories if c[0] != '']
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

    # Insert placeholder so category is recognized
    placeholder_presentation = Presentation(
        title='(Placeholder)',
        category=category_name,
        file_path='placeholder_path'
    )
    db.session.add(placeholder_presentation)
    db.session.commit()

    logging.debug(f"Category created: {category_name}")
    return jsonify({"message": "Category created"}), 201

@app.route('/categories/<string:category_name>', methods=['DELETE'])
def delete_category(category_name):
    presentations = Presentation.query.filter_by(category=category_name).all()
    if not presentations:
        return jsonify({"error": "Category not found"}), 404
    for p in presentations:
        p.category = ""
    db.session.commit()
    logging.debug(f"Category {category_name} deleted. Presentations unassigned.")
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
    logging.debug(f"Presentation {presentation_id} assigned to {category_name}")
    return jsonify({"message": "Presentation assigned to category"}), 200

@app.route('/presentations/<int:presentation_id>/unassign', methods=['POST'])
def unassign_presentation(presentation_id):
    presentation = Presentation.query.get(presentation_id)
    if not presentation:
        return jsonify({"error": "Presentation not found"}), 404
    presentation.category = ""
    db.session.commit()
    logging.debug(f"Presentation {presentation_id} unassigned from category.")
    return jsonify({"message": "Presentation unassigned from category"}), 200

@app.route('/uploads/<path:filename>', methods=['GET'])
def serve_upload(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# Heartbeat route
@app.route('/heartbeat', methods=['GET'])
def heartbeat():
    logging.debug("Heartbeat route called. Connection is alive.")
    return jsonify({"status": "alive"}), 200
