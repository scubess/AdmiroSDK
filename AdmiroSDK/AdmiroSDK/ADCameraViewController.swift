//
//  ADCameraViewController.swift
//  AdmiroSDK
//
//  Created by Lshiva on 05/12/2020.
//

import AVFoundation
import Foundation
import UIKit

public protocol ADCameraViewControllerDelegate: class {
    func cameraViewController(didFocus point: CGPoint)
    func cameraViewController(update status: AVAuthorizationStatus)
    func cameraViewController(captured image: UIImage)
}

@available(iOS 11.0, *)
open class ADCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    //---------------------//
    //--- VARS AND LETS ---//
    //---------------------//
    internal lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.blue
        label.textAlignment = .center
        return label
    }()
    //---------------------//
    //---      CAMERA   ---//
    //---------------------//
    private let context = CIContext()
    public var preset: AVCaptureSession.Preset = .high
    public var videoGravity: AVLayerVideoGravity = .resizeAspectFill
    public var lowLightBoost: Bool = false
    public var tapToFocus: Bool = false
    public var flashMode: AVCaptureDevice.FlashMode = .off
    private var queue = DispatchQueue(label: "com.scube.camera")
    private(set) var session: AVCaptureSession = AVCaptureSession()
    public var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureDevice: AVCaptureDevice?
    private var captureDeviceInput: AVCaptureDeviceInput?
    private var capturePhotoOutput: AVCapturePhotoOutput?
    private var captureVideoOutput: AVCaptureVideoDataOutput?
    public weak var ADcameraDelegate: ADCameraViewControllerDelegate?
    
    public var cameraPosition: AVCaptureDevice.Position = .front {
        didSet {
            reconfigureSession()
        }
    }

    //---------------------//
    //--- CUSTOMVIEWS   ---//
    //---------------------//

    private let adOverlayView = ADOverlayView()
    private let selfieDetection = ADFaceDetection()

    //-------------------------//
    //--- LIFECYCLE METHODS ---//
    //-------------------------//

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(warningLabel)
        
        // Set its constraint to display it on screen
        warningLabel.widthAnchor.constraint(equalToConstant:self.view.frame.width).isActive = true
        warningLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = videoGravity
        previewLayer.connection?.videoOrientation = .portrait
        self.view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
        self.previewLayer?.frame = view.bounds
        self.view.addSubview(adOverlayView)
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            configureSession()
            ADcameraDelegate?.cameraViewController(update: status)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
                let newStatus = AVCaptureDevice.authorizationStatus(for: .video)
                if granted {
                    self.configureSession()
                }
                self.ADcameraDelegate?.cameraViewController(update: newStatus)
            }
        default:
            ADcameraDelegate?.cameraViewController(update: status)
        }
        
        //SETUP SELFIE DELEGATE
        self.selfieDetection.adDetectionDelegate = self
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopSession()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        self.session.startRunning()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        self.stopSession()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session.startRunning()
        previewLayer?.frame = view.bounds
        previewLayer?.videoGravity = videoGravity
        previewLayer?.connection?.videoOrientation = .portrait
        
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.startSession()
        previewLayer?.frame = view.bounds
        previewLayer?.videoGravity = videoGravity
        previewLayer?.connection?.videoOrientation = .portrait
    }
    //-------------------------//
    //--- CUSTOM METHODS ------//
    //-------------------------//
    
    internal func startSession() {
        queue.async {
            guard !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }
    
    internal func stopSession() {
        queue.async {
            guard self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }
    
    
    public func toggleFlash() {
        if let device = AVCaptureDevice.default(for: AVMediaType.video){
                if (device.hasTorch) {
                    do {
                        try device.lockForConfiguration()
                        if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                            device.torchMode = AVCaptureDevice.TorchMode.off
                        } else {
                        do {
                            try device.setTorchModeOn(level: 1.0)
                        } catch {
                           //Error
                        }
                    }
                    device.unlockForConfiguration()
                } catch {
                    //Error
                }
            }
        }
    }

    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        if selfieDetection.isFaceDetected == false {
            guard let (faceCIImage, faceUIImage) = createFaceImages(sampleBuffer: sampleBuffer) as? (CIImage, UIImage) else {
                print("TakeASelfie: creating face images returns nil")
                return
            }
            
            DispatchQueue.main.async { [self] in
                self.warningLabel.text = ""
                self.selfieDetection.handleFaceFeatures(faceImage: faceCIImage, previewLayer: self.previewLayer!, overlay: adOverlayView)
            }
        }
    }
    
    internal func createFaceImages(sampleBuffer: CMSampleBuffer) -> (CIImage?, UIImage?) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return (nil, nil)
        }
        let faceCIImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let faceImage = context.createCGImage(faceCIImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))) else {
            return (nil, nil)
        }
        
        let faceUIImage = UIImage(cgImage: faceImage, scale: 0.0, orientation: UIImage.Orientation.right)
        return (faceCIImage, faceUIImage)
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    }
}

    //----------------------------//
    //--- SESSION & VIDEO   ------//
    //----------------------------//
@available(iOS 11.0, *)
extension ADCameraViewController {

    private func reconfigureSession() {
        queue.async {
            let inputs = self.session.inputs
            inputs.forEach { self.session.removeInput($0) }

            self.captureDevice = nil
            self.captureDeviceInput = nil

            self.configureCaptureDevice()
            self.configureCaptureDeviceInput()
        }
    }

    private func configureSession() {
        self.session.beginConfiguration()

        if self.session.canSetSessionPreset(self.preset) {
            self.session.sessionPreset = self.preset
        } else {
            self.session.sessionPreset = .high
        }

        self.configureCaptureDevice()
        self.configureCaptureDeviceInput()
        self.configureCapturePhotoOutput()
        self.configureCaptureVideoOutput()

        
        self.session.commitConfiguration()
        self.session.startRunning()
    }

    private func configureCaptureDevice() {
        let device = captureDevice(for: cameraPosition)
        guard let captureDevice = device else { return }

        do {
            try captureDevice.lockForConfiguration()

            if captureDevice.isFocusModeSupported(.continuousAutoFocus) {
                captureDevice.focusMode = .continuousAutoFocus
            }

            if captureDevice.isSmoothAutoFocusSupported {
                captureDevice.isSmoothAutoFocusEnabled = true
            }

            if captureDevice.isExposureModeSupported(.continuousAutoExposure) {
                captureDevice.exposureMode = .continuousAutoExposure
            }

            if captureDevice.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                captureDevice.whiteBalanceMode = .continuousAutoWhiteBalance
            }

            if captureDevice.isLowLightBoostSupported && lowLightBoost {
                captureDevice.automaticallyEnablesLowLightBoostWhenAvailable = true
            }

            captureDevice.unlockForConfiguration()
        } catch {
            //Error
        }

        self.captureDevice = captureDevice
    }

    private func configureCaptureDeviceInput() {
        do {
            guard let captureDevice = captureDevice else { return }
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)

            if session.canAddInput(captureDeviceInput) {
                session.addInput(captureDeviceInput)
            }

            self.captureDeviceInput = captureDeviceInput
        } catch {
            //Error
        }
    }

    private func configureCapturePhotoOutput() {
        let capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput.isHighResolutionCaptureEnabled = true

        if capturePhotoOutput.isDualCameraDualPhotoDeliverySupported {
            capturePhotoOutput.isDualCameraDualPhotoDeliveryEnabled = true
        }

        if session.canAddOutput(capturePhotoOutput) {
            session.addOutput(capturePhotoOutput)
        }

        self.capturePhotoOutput = capturePhotoOutput
    }

    private func configureCaptureVideoOutput() {
        let captureVideoOutput = AVCaptureVideoDataOutput()
        captureVideoOutput.alwaysDiscardsLateVideoFrames = true
        captureVideoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "CameraViewControllerQueue"))

        if session.canAddOutput(captureVideoOutput) {
            session.addOutput(captureVideoOutput)
        }

        self.captureVideoOutput = captureVideoOutput
    }

    private func captureDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: position)
        let devices = session.devices
        let wideAngle = devices.first { $0.position == position }
        return wideAngle
    }
    
    public func dimissed() {
        self.selfieDetection.isFaceDetected = false //set the selfiedetection to false
    }
}

@available(iOS 11.0, *)
extension ADCameraViewController : ADDetectionDelegate {
    func faceDetection(captured face: UIImage, rect: CGRect) {
        if self.cameraPosition == .front {
                self.ADcameraDelegate?.cameraViewController(captured: face)
            } else {
                self.ADcameraDelegate?.cameraViewController(captured: face)
        }
    }
    
    func faceDetectFeedback(With message: String?) {
        self.warningLabel.text = message
    }
}
