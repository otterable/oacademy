# app.py

from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_login import LoginManager, UserMixin
from google.oauth2 import id_token
from google.auth.transport import requests
import os
import logging

# Initialize Flask app
app = Flask(__name__)
CORS(app)
app.secret_key = "secure_secret_key_here"
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///app.db'
app.config['UPLOAD_FOLDER'] = 'uploads'

# Initialize database
db = SQLAlchemy(app)

# Initialize login manager
login_manager = LoginManager(app)

# Logging setup
logging.basicConfig(level=logging.DEBUG)

# Google OAuth Client Config
GOOGLE_CLIENT_ID = "695509729214-orede17jk35rvnou5ttbk4d6oi7oph2i.apps.googleusercontent.com"

# Import models
from models import User, Presentation

# Console Debug: Flask initialized
logging.debug("Flask app initialized and configured with SQLite database.")

# Import views (routes)
import views

# Create all tables within app context
with app.app_context():
    if not os.path.exists(app.config['UPLOAD_FOLDER']):
        os.makedirs(app.config['UPLOAD_FOLDER'])
    db.create_all()
    logging.debug("Database tables created for User and Presentation.")

# Run the Flask app
if __name__ == "__main__":
    app.run(port=5656)
