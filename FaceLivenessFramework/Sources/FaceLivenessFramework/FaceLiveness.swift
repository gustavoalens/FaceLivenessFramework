import AVFoundation
import CoreImage

public final class FaceLiveness: NSObject, FaceLivenessProtocol {
    weak var delegate: FaceLivenessDelegate?
    private let captureSession: AVCaptureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var frontDevice: AVCaptureDevice?
    private var frontInput: AVCaptureInput?
    private var currentDetector: CIDetector?
    
    public func startLiveness(with delegate: FaceLivenessDelegate) async {
        self.delegate = delegate
        guard await isAuthorized() else { return } // TODO: Add error
        prepareSession()
        captureSession.startRunning()
    }
    
    public func stop() {
        captureSession.stopRunning()
    }
    
    private func prepareSession() {
        guard let frontDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first else { return } // TODO: Add error)
        self.frontDevice = frontDevice
        guard let frontInput = try? AVCaptureDeviceInput(device: frontDevice) else { return } // TODO: Add error
        self.frontInput = frontInput
        captureSession.beginConfiguration()
        if captureSession.canAddInput(frontInput) {
            captureSession.addInput(frontInput)
        }
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        captureSession.commitConfiguration()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
    }
    
    private func isAuthorized() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                return await AVCaptureDevice.requestAccess(for: .video)
            case .restricted, .denied:
                return false
            case .authorized:
                return true
            @unknown default:
                return false
        }
    }
    
    private func detect(image: CIImage) -> Bool {
        let blinkOptions: [String : Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorEyeBlink: true
        ]
        
        let allOptions: [String : Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorEyeBlink: true,
            CIDetectorTracking: true
        ]
        guard let detector = currentDetector ?? CIDetector(ofType: CIDetectorTypeFace, context: nil, options: allOptions) else { return false }
        currentDetector = detector
        
        print("features: \(detector.features(in: image))")
        for feature in detector.features(in: image, options: blinkOptions) {
            guard let feature = feature as? CIFaceFeature else { continue }
            print("CIFaceFeature-Tracking(blinkOp): \(feature.faceAngle)")
            print("CIFaceFeature: rightClosed: \(feature.rightEyeClosed)(hasTrack: \(feature.hasRightEyePosition)), leftClosed: \(feature.leftEyeClosed)(hasTrack: \(feature.hasLeftEyePosition))")
            if feature.rightEyeClosed && feature.leftEyeClosed {
                return true
            }
        }
        
        return false
    }
    
    deinit {
        stop()
    }
}

extension FaceLiveness: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        delegate?.didUpdateVideo(currentImage: convert(cmage: ciImage))
        delegate?.didDetect(detected: detect(image: ciImage))
        
    }
    
    private func convert(cmage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(cmage, from: cmage.extent)
    }
}

public protocol FaceLivenessDelegate: AnyObject {
    func didUpdateVideo(currentImage: CGImage?)
    func didDetect(detected: Bool)
}

public protocol FaceLivenessProtocol {
    func startLiveness(with delegate: FaceLivenessDelegate) async
    func stop()
}

enum FaceLivenessError {
    case unauthorized
}

enum LivenessValidations {
    case blink
    case smile
    case verticalMovement
    case horizontalMovement
}
