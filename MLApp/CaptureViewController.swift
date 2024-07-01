import UIKit
import AVFoundation
import Vision
import SwiftUI

class CaptureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var requests = [VNRequest]()
    private var isLiveCapture: Bool
    @Binding var capturedImage: UIImage?
    @Binding var predictions: [VNRecognizedObjectObservation]

    init(isLiveCapture: Bool, capturedImage: Binding<UIImage?>, predictions: Binding<[VNRecognizedObjectObservation]>) {
        self.isLiveCapture = isLiveCapture
        self._capturedImage = capturedImage
        self._predictions = predictions
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupVision()

        if !isLiveCapture {
            let captureButton = UIButton(frame: CGRect(x: self.view.frame.width - 120, y: 40, width: 100, height: 50))
            captureButton.setTitle("Snap", for: .normal)
            captureButton.backgroundColor = .red
            captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
            view.addSubview(captureButton)
        }
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .landscapeRight
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    private func setupVision() {
        guard let model = try? VNCoreMLModel(for: YOLOv3().model) else { return }
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
            self?.processObservations(results)
        }
        self.requests = [request]
    }

    private func processObservations(_ observations: [VNRecognizedObjectObservation]) {
        DispatchQueue.main.async {
            self.view.layer.sublayers?.removeSubrange(1...)
            for observation in observations {
                self.addBoundingBox(observation: observation)
            }
        }
    }

    private func addBoundingBox(observation: VNRecognizedObjectObservation) {
        let boundingBox = observation.boundingBox
        let size = CGSize(width: boundingBox.width * view.frame.width, height: boundingBox.height * view.frame.height)
        let origin = CGPoint(x: boundingBox.minX * view.frame.width, y: (1 - boundingBox.maxY) * view.frame.height)

        let boundingBoxView = UIView(frame: CGRect(origin: origin, size: size))
        boundingBoxView.layer.borderColor = UIColor.red.cgColor
        boundingBoxView.layer.borderWidth = 2

        let label = UILabel(frame: CGRect(x: origin.x, y: origin.y - 20, width: size.width, height: 20))
        label.backgroundColor = UIColor.red
        label.textColor = UIColor.white
        label.text = observation.labels.first?.identifier ?? "Unknown"
        label.font = UIFont.systemFont(ofSize: 12)

        view.addSubview(boundingBoxView)
        view.addSubview(label)
    }

    private func rotateImage(image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let rotatedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
        return rotatedImage
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isLiveCapture else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try requestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        let rotatedImage = rotateImage(image: image)
        self.capturedImage = rotatedImage

        guard let ciImage = CIImage(image: rotatedImage) else { return }
        let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try requestHandler.perform(self.requests)
            if let results = requests.first?.results as? [VNRecognizedObjectObservation] {
                self.predictions = results
            }
        } catch {
            print(error)
        }

        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}
