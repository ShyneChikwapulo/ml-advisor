import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase (only once)
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

# Add document
db.collection("models").add({
    "name": "Random Forest",
    "accuracy": 0.84,
    "f1Score": 0.58,
    "precision": 0.62,
    "recall": 0.55,
    "description": "Ensemble method that builds multiple decision trees",
    "category": "Ensemble",
    "handlesImbalance": True,
    "interpretable": False,
    "strengths": ["Handles overfitting well", "Feature importance scores"],
    "weaknesses": ["Memory intensive", "Slow for real-time prediction"],
    "bestUseCases": ["Large datasets", "When accuracy is priority"]
})

print("Data added to Firestore")