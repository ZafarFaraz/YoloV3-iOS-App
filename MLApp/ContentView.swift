import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @State private var isShowingLiveCaptureView = false
    @State private var isShowingPhotoCaptureView = false
    @State private var capturedImage: UIImage?
    @State private var predictions: [VNRecognizedObjectObservation] = []

    var body: some View {
        VStack {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotationEffect(.degrees(-90))
                    .overlay(
                        BoundingBoxesView(predictions: predictions, imageSize: image.size)
                    )
            } else {
                Text("No image captured")
                    .padding()
            }

            Button("Start Live Capture") {
                isShowingLiveCaptureView = true
            }
            .padding()

            Button("Snap a Picture") {
                isShowingPhotoCaptureView = true
            }
            .padding()
        }
        .fullScreenCover(isPresented: $isShowingLiveCaptureView) {
            LiveCaptureView(capturedImage: $capturedImage, predictions: $predictions)
                .onAppear {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }
        }
        .fullScreenCover(isPresented: $isShowingPhotoCaptureView) {
            PhotoCaptureView(capturedImage: $capturedImage, predictions: $predictions)
                .onAppear {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }
        }
    }
}

struct BoundingBoxesView: View {
    let predictions: [VNRecognizedObjectObservation]
    let imageSize: CGSize

    var body: some View {
        GeometryReader { geometry in
            ForEach(predictions, id: \.uuid) { prediction in
                let boundingBox = prediction.boundingBox
                let width = boundingBox.width * geometry.size.width
                let height = boundingBox.height * geometry.size.height
                let x = boundingBox.minX * geometry.size.width
                let y = (1 - boundingBox.maxY) * geometry.size.height

                Rectangle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: width, height: height)
                    .position(x: x + width / 2, y: y + height / 2)

                Text(prediction.labels.first?.identifier ?? "Unknown")
                    .foregroundColor(.white)
                    .background(Color.red)
                    .position(x: x + width / 2, y: y)
            }
        }
    }
}
