import SwiftUI
import AVFoundation
import Vision

struct LiveCaptureView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var predictions: [VNRecognizedObjectObservation]

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = CaptureViewController(isLiveCapture: true, capturedImage: $capturedImage, predictions: $predictions)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
