//
//  CameraViewController.swift
//  Admiro
//
//  Created by selva on 09/08/2020.
//  Copyright © 2020 Scube Software Ltd. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

public protocol CameraViewControllerDelegate: class {

    func cameraViewController(didFocus point: CGPoint)
    func cameraViewController(update status: AVAuthorizationStatus)
    func cameraViewController(captured image: UIImage)
    func cameraViewController(sampleBuffer: CMSampleBuffer)
}

open class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    private let ovalOverlayView = OvalOverlayView()

    public var preset: AVCaptureSession.Preset = .high
    public var videoGravity: AVLayerVideoGravity = .resizeAspectFill
    public var lowLightBoost: Bool = false

    public var tapToFocus: Bool = false
    public var flashMode: AVCaptureDevice.FlashMode = .off

    public var cameraPosition: AVCaptureDevice.Position = .front {
        didSet {
            reconfigureSession()
        }
    }

    private var queue = DispatchQueue(label: "com.scube.camera")

    private(set) var session: AVCaptureSession = AVCaptureSession()
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?

    private var captureDevice: AVCaptureDevice?
    private var captureDeviceInput: AVCaptureDeviceInput?
    private var capturePhotoOutput: AVCapturePhotoOutput?
    private var captureVideoOutput: AVCaptureVideoDataOutput?

    public weak var cameraDelegate: CameraViewControllerDelegate?

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = videoGravity
        previewLayer.connection?.videoOrientation = .portrait
        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
        self.previewLayer?.frame = view.bounds
        self.view.addSubview(ovalOverlayView)
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            configureSession()
            cameraDelegate?.cameraViewController(update: status)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
                let newStatus = AVCaptureDevice.authorizationStatus(for: .video)
                if granted {
                    self.configureSession()
                }
                self.cameraDelegate?.cameraViewController(update: newStatus)
            }
        default:
            cameraDelegate?.cameraViewController(update: status)
        }
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopSession()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        session.startRunning()

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
    
    func startSession() {
        queue.async {
            guard !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        queue.async {
            guard self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }
    
    public func takePhoto() {
        guard let output = capturePhotoOutput, session.isRunning else { return }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        settings.isHighResolutionPhotoEnabled = true
        settings.isAutoStillImageStabilizationEnabled = true

        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first ?? 0
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]

        settings.previewPhotoFormat = previewFormat

        output.capturePhoto(with: settings, delegate: self)
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard tapToFocus, let touch = touches.first else { return }

        let location = touch.preciseLocation(in: view)
        let size = view.bounds.size
        let focusPoint = CGPoint(x: location.x / size.height, y: 1 - location.x / size.width)

        guard let captureDevice = captureDevice else { return }
        do {
            try captureDevice.lockForConfiguration()
            if captureDevice.isFocusPointOfInterestSupported {
                captureDevice.focusPointOfInterest = focusPoint
                captureDevice.focusMode = .autoFocus
            }
            if captureDevice.isExposurePointOfInterestSupported {
                captureDevice.exposurePointOfInterest = focusPoint
                captureDevice.exposureMode = .continuousAutoExposure
            }
            captureDevice.unlockForConfiguration()
            cameraDelegate?.cameraViewController(didFocus: location)
        } catch {
            DLog(error)
        }
    }
    
    func toggleFlash() {
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
                            DLog(error)
                        }
                    }
                    device.unlockForConfiguration()
                } catch {
                    DLog(error)
                }
            }
        }
    }

    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        self.cameraDelegate?.cameraViewController(sampleBuffer: sampleBuffer)
    }

    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    }
}

extension CameraViewController {

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
        queue.async {
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
            DLog(error)
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
            DLog(error)
        }
    }

    private func configureCapturePhotoOutput() {
        let capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput.isHighResolutionCaptureEnabled = true

        if #available(iOS 11.0, *) {
            if capturePhotoOutput.isDualCameraDualPhotoDeliverySupported {
                capturePhotoOutput.isDualCameraDualPhotoDeliveryEnabled = true
            }
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
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {

    @available(iOS 11.0, *)
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { [weak self] in
                if let data = photo.fileDataRepresentation() {
                    if self?.cameraPosition == .front {
                        let flippedImage = UIImage.flipImage(from: data)
                        self?.cameraDelegate?.cameraViewController(captured: UIImage.convert(from: flippedImage))
                    } else {
                        self?.cameraDelegate?.cameraViewController(captured: image)
                    }
                    
                }
            }
        }
    }

    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if #available(iOS 11.0, *) { } else {
            DispatchQueue.global(qos: .userInitiated).async {
                guard let sampleBuffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil), let image = UIImage(data: data) else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.cameraDelegate?.cameraViewController(captured: image)
                }
            }
        }
    }

}

extension UIImage{

    static func flipImage(from data: Data) -> CIImage {
        let image = UIImage(data: data)!
        let ciImage: CIImage = CIImage(cgImage: image.cgImage!).oriented(forExifOrientation: 6)
        let flippedImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
        return flippedImage
    }
    
    static func convert(from ciImage: CIImage) -> UIImage{
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}

