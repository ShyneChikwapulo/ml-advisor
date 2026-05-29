# ML Advisor

**Machine Learning Model Selection Assistant for Software Bug Prediction**

ML Advisor helps software engineering students and developers choose the right machine learning models for bug prediction. Browse 8 pre-trained models, compare performance metrics, get personalized recommendations, and access research-backed guidance.

---

## 📱 Features

- **Authentication** - Login/Register with role-based access (Student, Developer, Admin)
- **Model Library** - Browse 8 ML models with search and filter
- **Model Details** - View accuracy, F1-score, precision, recall, strengths, weaknesses
- **Compare Models** - Side-by-side comparison with table and bar charts
- **Recommendations** - Answer 3 questions and get the best model for your context
- **Favorites** - Save models you like for quick access
- **Research Papers** - Read summaries of key papers (Albattah & Alzahrani 2024, etc.)
- **Glossary** - Look up technical terms like F1-score, class imbalance, SMOTE
- **AI Chat** - Ask questions powered by Ollama + RAG (26 research papers)
- **Admin Dashboard** - Manage models, papers, and glossary terms

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter (Dart) |
| Backend | Python + FastAPI |
| Database | Firebase Firestore |
| Authentication | Firebase Auth |
| AI/LLM | Ollama + Llama 3.2 |
| Charts | fl_chart |

---

## 💻 Installation Guide (For Non-Technical Users)

### What You Need Before Starting

| Tool | Why You Need It | Where to Get It |
|------|-----------------|-----------------|
| **Flutter** | To run the mobile app | [flutter.dev](https://flutter.dev) |
| **Android Studio** | To run a phone emulator | [developer.android.com/studio](https://developer.android.com/studio) |
| **Visual Studio Code** | To edit code | [code.visualstudio.com](https://code.visualstudio.com) |
| **Python** | To run the backend | [python.org](https://python.org) |
| **Git** | To download the code | [git-scm.com](https://git-scm.com) |
| **Ollama** | To run the AI chat | [ollama.ai](https://ollama.ai) |

---

## Step-by-Step Setup

### Step 1: Install Flutter

**What it does:** Flutter lets you run the mobile app on your computer.

**Instructions:**

1. Go to https://flutter.dev
2. Click "Get Started" → "Install"
3. Choose your operating system (Windows/Mac/Linux)
4. Download the installer
5. Run the installer (just click Next, Next, Finish)
6. Open a terminal/command prompt and type: `flutter doctor`
7. If you see a green checkmark, Flutter is installed

**Common problem:** If `flutter doctor` says "Android license status unknown", run:
```bash
flutter doctor --android-licenses
```

Press "y" and Enter for each prompt.
---

### Step 2: Install Android Studio (For Emulator)

**What it does:** Creates a fake phone on your computer so you can see the app.

**Instructions:**

1. Go to https://developer.android.com/studio
2. Download Android Studio for your computer
3. Install it (just click Next, Next, Finish - takes 10-15 minutes)
4. Open Android Studio
5. Click "More Actions" → "Virtual Device Manager"
6. Click "Create device"
7. Choose "Pixel 4" → Next
8. Download "API 33" → Next
9. Name it "Pixel_4_API_33" → Finish
10. Click the green play button next to your emulator
11. A phone window will pop up - this is your emulator
12. Close Android Studio (keep the phone window open)

**Alternative (Use Your Real Phone):**

- Android: Enable Developer Options → USB Debugging → Plug in your phone
- iPhone: You need a Mac and Xcode (more complicated)

---
### Step 3: Install Visual Studio Code

**What it does:** Visual Studio Code (VS Code) is where you will edit and manage the project code.

#### Instructions

1. Go to https://code.visualstudio.com
2. Download the version for your operating system (Windows, Mac, or Linux)
3. Run the installer and follow the setup steps:
   - Click **Next**
   - Click **Next**
   - Click **Finish**
4. Open **Visual Studio Code**
5. On the left sidebar, click the **Extensions** icon  
   *(it looks like four small squares)*
6. In the search bar, search for and install the following extensions:
   - **Flutter** (by Google)
   - **Dart** (by Google)

#### How to Install Extensions

1. Click on an extension name
2. Press the **Install** button
3. Wait for the installation to finish
4. Repeat for the second extension

#### Why These Extensions Matter

- **Flutter Extension** → Helps you run and debug the Flutter app
- **Dart Extension** → Adds support for the Dart programming language used by Flutter

---
### Step 4: Install Python

**What it does:** Python is used to run the backend API for the application.

#### Instructions

1. Go to https://python.org
2. Click **Downloads** and choose your operating system
3. Download the installer
4. Run the installer

> **Important:** Make sure to check the box that says **"Add Python to PATH"**

5. Click **Install Now**
6. Wait for the installation to finish

#### Verify Python Installation

1. Open a terminal or command prompt
2. Type the following command:

```bash
python --version
```

You should see something like

```bash
Python 3.12.x
```
---
### Step 5: Extract the Project Folder

**What it does:** This gives you access to the ML Advisor project files that were provided.

#### Instructions

1. Locate the project ZIP file you received
2. Right-click the ZIP file
3. Select **Extract All...** (Windows) or **Open With → Archive Utility** (Mac)
4. Choose a location where you want to save the project folder
5. Click **Extract**
6. Wait for the extraction process to finish

After extracting, you should see a folder named something like:
ML-Advisor

### Step 6: Install Ollama (For AI Chat)

**What it does:** Ollama runs the AI model locally on your computer for the AI Chat feature.

#### Instructions

1. Go to https://ollama.ai
2. Click **Download**
3. Choose your operating system
4. Run the installer
5. Follow the setup steps:
   - Click **Next**
   - Click **Next**
   - Click **Finish**

#### Start Ollama

1. Open a **new terminal** or command prompt  
   *(keep your other terminal open if needed)*
2. Run the following command:

```bash
ollama serve
```
3. Leave this terminal running
- Do not close it while using the AI Chat feature

**Download the AI Model**

1. Open another terminal window
2. Run the following command:
```bash
ollama pull llama3.2
```

This downloads the AI model used by the application.

Important Notes
- The download may take 5–10 minutes
- The model size is approximately 4 GB
- Make sure you have a stable internet connection