# 🌾 Krishi-Sadaiv

**Krishi-Sadaiv** is a Flutter-based mobile application designed as a **comprehensive agricultural assistant for farmers**.  
It integrates **machine learning**, **real-time weather forecasting**, and **agricultural databases** to provide farmers with actionable insights.  
The application is **bilingual** (English and Hindi) for accessibility and usability in rural communities.  

---

## 🚀 Features

### 1. Crop Disease Detection
- Upload an image of a crop using **camera or gallery**.  
- A **PyTorch Mobile (Lite) Vision Transformer model** classifies the crop image and detects possible diseases.  
- Provides a **description of the disease**, **symptoms**, and **preventive measures**.  

### 2. Fertilizer Information
- Detailed database of **chemical and bio-fertilizers**.  
- Includes **active components**, **primary functions**, **suitable crops**, and **application timing**.  
- Farmers can easily search for fertilizers by name or crop type.  

### 3. MSP (Minimum Support Price) Information
- Provides up-to-date **MSP data** for multiple crops.  
- Search by crop name and view detailed MSP values.  
- Integrated **voice search** using `speech_to_text`.  

### 4. Weather Forecast
- Real-time **current weather** using device GPS location.  
- **7-day weather forecast** with temperature, rainfall, and humidity insights.  
- Personalized agricultural recommendations such as **irrigation planning** and **crop health suggestions**.  

### 5. General FAQs
- In-app **FAQs** covering both **application usage** and **general agricultural practices**.  

### 6. Bilingual Support
- **English + Hindi** supported.  
- Achieved through **`intl` package** and JSON-based localization.  

---

## 🏗️ Project Structure

krishi-sadaiv/
│── flutterproject
│   │── lib/
│   │   │   ├── main.dart                # App entry point
│   │   ├── fertilizer_screen.dart   # Fertilizer information UI
│   │   ├── general_faqs_screen.dart # FAQ section
│   │   ├── msp_screen.dart          # MSP data section
│   │   ├── weather_screen.dart      # Weather forecast UI
│   │   ├── disease_classifier.dart  # Crop disease detection logic
│   │   └── widgets/                 # Reusable UI widgets
│   │
│   │── assets/
│   │   ├── images/                  # App logos, icons, and illustrations
│   │   ├── models/                  # ML model (.ptl) for crop disease detection
│   │   └── data/                    # JSON files
│   │       ├── diseases.json
│   │       ├── fertilizers.json
│   │       ├── faqs.json
│   │       └── msp.json
│   │
│   │── pubspec.yaml                 # Dependencies & assets configuration
│── README.md                    # Project documentation

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
s

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

### 🔹 Install Dependencies 
```bash
flutter pub get

### 🔹 Run the App
```bash
flutter run





