
# YoloV3 iOS App

This iOS application uses the YoloV3 model from Core ML to perform object detection in real-time using the device's camera. It supports both live video capture and still image capture modes, providing bounding boxes and labels for detected objects.

## Features

- **Live Object Detection**: Detect objects in real-time using the device's camera.
- **Image Capture**: Snap a picture and detect objects in the captured image.
- **Bounding Boxes**: Display bounding boxes and labels around detected objects.

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+
- Core ML

## Setup

1. **Clone the repository**:
   ```sh
   git clone https://github.com/ZafarFaraz/YoloV3-iOS-App.git
   ```

2. **Open the project**:
   Open the project in Xcode by double-clicking `YoloV3-iOS-App.xcodeproj`.

3. **Download an ML model**:
   Download the `YoloV3.mlmodel` or any other model from the [Apple Machine Learning models](https://developer.apple.com/machine-learning/models/) repository. Add the model to your Xcode project. Make sure it is added to the target.

4. **Configure Camera Permissions**:
   Add the following key to your `Info.plist` file to request camera access:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>We need access to your camera to detect objects in real-time.</string>
   ```

5. **Run the app on a physical device**:
   Note: The camera is only accessible on a physical device and not in the simulator.

## Usage

### Live Object Detection

1. Tap the "Start Live Capture" button to start the live video feed. (in Progress)
2. The app will detect objects in real-time and display bounding boxes with labels around detected objects.

### Image Capture

1. Tap the "Snap a Picture" button to capture an image.
2. The app will display the captured image with bounding boxes and labels around detected objects.

## Project Structure

- **ContentView.swift**: The main view of the app, handles displaying the live feed and captured images.
- **LiveCaptureView.swift**: Manages the live capture functionality using `AVCaptureSession`.
- **PhotoCaptureView.swift**: Manages the image capture functionality.
- **CaptureViewController.swift**: Handles the camera setup, image processing, and object detection using Core ML and Vision frameworks.
- **BoundingBoxesView.swift**: Custom view to draw bounding boxes and labels for detected objects.

## Screenshots

**Coming soon**

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Core ML](https://developer.apple.com/documentation/coreml)
- [Vision Framework](https://developer.apple.com/documentation/vision)
- [Apple Machine Learning Models](https://developer.apple.com/machine-learning/models/)

## Author

- **Your Name** - [Your GitHub Profile](https://github.com/ZafarFaraz)
