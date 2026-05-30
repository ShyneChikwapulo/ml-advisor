import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# ── MODELS (from Albattah & Alzahrani 2024) ─────────────────────────────────
models = [
    {
        "name": "LSTM",
        "accuracy": 0.87,
        "f1Score": 0.61,
        "precision": 0.70,
        "recall": 0.55,
        "category": "Deep Learning",
        "interpretable": False,
        "handlesImbalance": False,
        "description": "Long Short-Term Memory network that captures temporal patterns in sequential code metrics. Best overall performer on the Unified Bug Dataset.",
        "strengths": [
            "Highest accuracy (87%)",
            "Captures sequential dependencies",
            "Handles complex patterns"
        ],
        "weaknesses": [
            "Requires large datasets",
            "Computationally expensive",
            "Black box — hard to explain"
        ],
        "bestUseCases": [
            "Large datasets >10,000 samples",
            "Sequential code metric data",
            "When accuracy is the top priority"
        ]
    },
    {
        "name": "XGBoost",
        "accuracy": 0.85,
        "f1Score": 0.47,
        "precision": 0.62,
        "recall": 0.45,
        "category": "Ensemble",
        "interpretable": False,
        "handlesImbalance": True,
        "description": "Extreme Gradient Boosting. Sequential ensemble that corrects errors of previous trees using regularization to prevent overfitting.",
        "strengths": [
            "Built-in regularization",
            "Handles missing values",
            "Fast training"
        ],
        "weaknesses": [
            "Many hyperparameters to tune",
            "Low F1 on imbalanced data"
        ],
        "bestUseCases": [
            "Structured tabular data",
            "When accuracy matters over interpretability"
        ]
    },

    # Add the remaining model dictionaries here exactly as they are...
]

# ── RESEARCH PAPERS (from knowledge_base.py) ────────────────────────────────
papers = [
    {
        "title": "Software Defect Prediction Based on Machine Learning and Deep Learning Techniques: An Empirical Approach",
        "authors": "Albattah & Alzahrani",
        "year": 2024,
        "keyFindings": "LSTM achieved 87% accuracy on the Unified Bug Dataset (47,618 classes, 60 software metrics). XGBoost was runner-up at 85%. Traditional models like SVM and Logistic Regression struggled with high-dimensional imbalanced data, yielding Binary F1-scores of 0.31 and 0.28 respectively.",
        "modelsEvaluated": [
            "LSTM",
            "XGBoost",
            "Random Forest",
            "SVM",
            "ANN",
            "DBN",
            "Autoencoder",
            "Logistic Regression"
        ]
    },

    # Add the remaining paper dictionaries here exactly as they are...
]

# ── GLOSSARY (technical terms used in the app) ───────────────────────────────
glossary = [
    {
        "term": "F1-Score",
        "definition": "The harmonic mean of Precision and Recall. A score of 1.0 is perfect. Used when you need to balance false positives and false negatives — important for imbalanced bug datasets.",
        "category": "Metrics"
    },

    # Add the remaining glossary dictionaries here exactly as they are...
]

# ── SEED ALL COLLECTIONS ────────────────────────────────────────────────────
print("Seeding models...")

for m in models:
    db.collection("models").add(m)
    print(f"  Added: {m['name']}")

print("\nSeeding papers...")

for p in papers:
    db.collection("papers").add(p)
    print(f"  Added: {p['title'][:50]}...")

print("\nSeeding glossary...")

for g in glossary:
    db.collection("glossary").add(g)
    print(f"  Added: {g['term']}")

print("\n✅ Database seeded successfully!")
print(f"  {len(models)} models")
print(f"  {len(papers)} papers")
print(f"  {len(glossary)} glossary terms")