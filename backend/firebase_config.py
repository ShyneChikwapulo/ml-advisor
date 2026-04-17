import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()       

def get_db():  
    return db      #"Whenever I ask for the database, give me this same connection" 
