import SwiftUI
import AVFoundation
import Vision

struct PhotoCaptureView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var predictions: [VNRecognizedObjectObservation]

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = CaptureViewController(isLiveCapture: false, capturedImage: $capturedImage, predictions: $predictions)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
