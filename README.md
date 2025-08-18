# 🌾 Krishi-Sadaiv

**Krishi-Sadaiv** is a Flutter-based mobile application designed as a **comprehensive agricultural assistant for farmers**.  
It integrates **machine learning**, **real-time weather forecasting**, and **agricultural databases** to provide farmers with actionable insights.  
The application is **bilingual** (English and Hindi) for accessibility and usability in rural communities.  

---

## 🚀 Features

### 1. Crop Disease Detection
- Upload an image of a crop using **camera or gallery**.  
- A **PyTorch Mobile (Lite) Vision Transformer model** classifies the crop image and detects possible diseases.  
- Provides **disease category**, **description about the disease and related symptoms**, and **preventive measures**.  

### 2. Fertilizer Information
- Detailed database of **chemical and bio-fertilizers**.  
- Includes **active components**, **primary functions**, **suitable crops**, and **application timing**.   

### 3. MSP (Minimum Support Price) Information
- Provides up-to-date **MSP data** for multiple crops saved.  
- Search by crop name and view detailed MSP values.  
- Integrated **voice search** using `speech_to_text`.  

### 4. Weather Forecast
- Real-time **current weather** using device GPS location.  
- **7-day weather forecast** with temperature, rainfall, and humidity insights.
- In-case of **no internet connectivity**, the last fetched data saved using `shared_preferences` is displayed.
- Personalized agricultural recommendations such as **irrigation planning** and **crop health suggestions**.  

### 5. General FAQs
- In-app **FAQs** covering both **application usage** and **general agricultural practices**.  

### 6. Bilingual Support
- **English + Hindi** supported.  
- Achieved through **`intl` package** and JSON-based localization.  

---

## 🧠 Machine Learning Model Utilized for Crop Disease Detection

This app integrates a **Fine-tuned Vision Transformer (ViT)** model for crop disease detection. This pre-trained image classification model runs directly on the user's device. This allows for fast, offline-capable analysis of crop images.  

### Model Format and Engine
- **Format**: The model is saved in the PyTorch Lite (.ptl) format. This is a lightweight version of a standard PyTorch model, optimized for deployment on mobile and edge devices.
- **Inference Engine**: The app uses the `pytorch_lite` Flutter package. This package acts as a bridge, allowing the Flutter application (written in Dart) to execute the underlying PyTorch Lite model (which is typically written in C++).

### Disease Classification Labels

```plaintext
| Crop             |    Disease / Condition    |
|------------------|---------------------------|
| **Corn (Maize)** |    Common Rust            |
|                  |    Gray Leaf Spot         |
|                  |    Healthy                |
| **Potato**       |    Early Blight           |
|                  |    Late Blight            |
|                  |    Healthy                |
| **Rice**         |    Brown Spot             |
|                  |    Leaf Blast             |
|                  |    Healthy                |
| **Wheat**        |    Brown Rust             |
|                  |    Yellow Rust            |
|                  |    Healthy                |
| **Other crop**   |    Invalid                |
| (Invalid Image)  |                           |
```

### Integration and Workflow in App
- 1. **Model Loading**: When the app starts, the `_loadModel()` function is called. It uses `PytorchLite.loadClassificationModel()` to load the `model.ptl` file and its corresponding `labels.txt` from the app's assets into memory.
- 2. **Image Selection**: User selects an image using the `image_picker package`, either from their camera or gallery.
- 3. **Classification**: The `_analyzeImage()` function is triggered. The selected image is read as a byte array. The  `_model!.getImagePrediction() ` method is called. This method handles all the necessary preprocessing (resizing to 224x224 and normalization) and runs the on-device inference. The model returns the name of the class with the highest probability score (e.g., "Potato___Early_Blight").

### Displaying Results
- **Output**: The model outputs a single prediction corresponding to one of the 13 classes it was trained on.
- The predicted class name is then used as a key to look up detailed information in the `assets/diseases.json` file.
- This JSON file contains user-friendly descriptions and actionable preventive measures for each disease, available in both English and Hindi.

---

## 🏗️ Project Structure

```plaintext
krishi-sadaiv/
│── flutterproject
│   │── lib/
│   │   ├── main.dart                # App entry point
│   │   ├── fertilizer_screen.dart   # Fertilizer information UI
│   │   ├── general_faqs_screen.dart # FAQ section
│   │   ├── msp_screen.dart          # MSP data section
│   │   ├── weather_screen.dart      # Weather forecast UI
│   │   ├── disease_classifier.dart  # Crop disease detection logic
│   │   └── widgets/                 # Reusable UI widgets
│   │
│   │── assets/
│   │   ├── models/                  # ML model for crop disease detection
│   │   │   ├── model.ptl
│   │   │   ├── labels.txt
│   │   ├── diseases.json
│   │   ├── fertilizers.json
│   │   ├── faqs.json
│   │   └── msp.json
│   │
│   │── pubspec.yaml                 # Dependencies & assets configuration
│── README.md                        # Project documentation
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8        # iOS-style icons
  image_picker: ^1.0.7           # Capture/select images for disease detection
  http: ^1.1.2                   # API calls for weather/MSP data
  geolocator: ^12.0.0            # Fetch device location (GPS)
  shared_preferences: ^2.2.3     # Local storage for weather/MSP caching
  intl: ^0.19.0                  # Internationalization (English/Hindi)
  connectivity_plus: ^6.0.3      # Network connectivity checks
  speech_to_text: ^7.3.0         # Voice search in MSP section
  pytorch_lite: ^4.3.2           # ML model inference for disease detection
  image: ^4.5.4                  # Image preprocessing for ML

dev_dependencies:
  flutter_lints: ^5.0.0          # Recommended linting rules
```
---

## 📲 Installation & Setup  

Follow these steps to set up the app locally:  

### 🔹 Prerequisites  
- Flutter SDK  
- Dart SDK  
- Android Studio / VS Code with Flutter extension  
- Emulator or a physical Android device  

### 🔹 Clone the Repository  
```bash
git clone https://github.com/cpiyush04/krishisadaiv.git
cd krishisadaiv
```

### 🔹 Install Dependencies 
```bash
flutter pub get
```

### 🔹 Run the App
```bash
flutter run
```

---

## 📚 References  

- Kinyua, W. (2024). *Smart Farming Disease Detection Transformer*. Hugging Face.  
  [https://huggingface.co/wambugu1738/crop_leaf_diseases_vit](https://huggingface.co/wambugu1738/crop_leaf_diseases_vit)  






