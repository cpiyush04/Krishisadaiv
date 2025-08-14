# Crop Disease Diagnosis App

A Flutter application that uses machine learning to diagnose crop leaf diseases. The app allows users to take pictures or select images from their gallery and get instant disease diagnosis using a Hugging Face model.

## Features

- 📸 Take pictures using the device camera
- 🖼️ Select images from the device gallery
- 🤖 AI-powered disease diagnosis using Hugging Face model
- 📱 Modern, clean UI with Material Design 3
- ⚡ Real-time image analysis
- 🛡️ Error handling and user feedback

## Setup Instructions

### Prerequisites

- Flutter SDK (version 3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone or download the project**
   ```bash
   git clone <repository-url>
   cd flutterproject
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Hugging Face API Token**
   
   You need to get a Hugging Face API token to use the model:
   
   - Go to [Hugging Face](https://huggingface.co/settings/tokens)
   - Create a new token
   - Replace `YOUR_HUGGING_FACE_API_TOKEN` in `lib/main.dart` with your actual token
   
   ```dart
   static const String _apiToken = 'your_actual_token_here';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Usage

1. **Launch the app** - You'll see the main screen with two buttons
2. **Select an image**:
   - Tap "Pick from Gallery" to choose an existing image
   - Tap "Take Picture" to capture a new photo
3. **Wait for analysis** - The app will show a loading indicator while processing
4. **View results** - The diagnosis will appear with the disease name and confidence percentage

## Technical Details

### Dependencies

- `image_picker: ^1.0.7` - For camera and gallery access
- `http: ^1.1.2` - For API calls to Hugging Face
- `flutter` - Core Flutter framework

### Model Information

The app uses the [crop_leaf_diseases_vit](https://huggingface.co/wambugu71/crop_leaf_diseases_vit) model from Hugging Face, which is a Vision Transformer (ViT) model trained to classify crop leaf diseases.

### API Endpoint

```
https://api-inference.huggingface.co/models/wambugu71/crop_leaf_diseases_vit
```

### Permissions

The app requires the following Android permissions:
- `CAMERA` - To take pictures
- `READ_EXTERNAL_STORAGE` - To access gallery images
- `WRITE_EXTERNAL_STORAGE` - To save captured images
- `INTERNET` - To communicate with the Hugging Face API

## Error Handling

The app includes comprehensive error handling for:
- Image selection failures
- Camera access issues
- Network connectivity problems
- API response errors
- Model processing failures

## UI Components

- **AppBar**: Clean header with app title
- **Image Selection Buttons**: Two prominent buttons for gallery and camera
- **Image Display**: Centered image container with rounded corners
- **Loading Indicator**: Circular progress indicator with status text
- **Result Display**: Styled container showing diagnosis results
- **Error Display**: Red-themed error messages

## Customization

You can easily customize the app by:
- Changing the theme colors in `ThemeData`
- Modifying the UI layout in the `build` method
- Adjusting image quality settings in the picker options
- Adding more disease information or treatment suggestions

## Troubleshooting

### Common Issues

1. **API Token Error**: Make sure you've replaced the placeholder token with your actual Hugging Face API token
2. **Camera Permission**: Grant camera permissions when prompted
3. **Network Issues**: Ensure you have a stable internet connection for API calls
4. **Image Loading**: Check that the selected image is in a supported format

### Debug Mode

Run the app in debug mode to see detailed error messages:
```bash
flutter run --debug
```

## Contributing

Feel free to contribute to this project by:
- Reporting bugs
- Suggesting new features
- Improving the UI/UX
- Adding support for more disease types

## License

This project is open source and available under the MIT License.

## Support

For support or questions, please open an issue in the project repository.
