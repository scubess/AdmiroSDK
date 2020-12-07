//
//  ADFaceDetection.swift
//  AdmiroSDK
//
//  Created by Lshiva on 05/12/2020.
//

import AVFoundation
import UIKit
import Vision
import CoreImage

enum Detectiondeeback  : String {
    case EyePosition        = "Please position you eyes correctly"
    case EyesClosed         = "Please stright up your head"
    case MouthPosition      = "Please keep your face inside the marked region"
    case HeadAnglePosition  = "Please keep your head stright"
}

internal protocol ADDetectionDelegate: class {
    func faceDetection(captured face: UIImage, rect: CGRect)
    func faceDetectFeedback(With message: String?)
}

internal class ADFaceDetection: NSObject {
    
    //---------------------//
    //--- VARS AND LETS ---//
    //---------------------//
    
    let ciContext = CIContext()

    public weak var adDetectionDelegate: ADDetectionDelegate?
    
    var isFaceDetected : Bool?
    
    private let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    //-------------------------//
    //--- LIFECYCLE METHODS ---//
    //-------------------------//
    
    override init() {
        self.isFaceDetected = false
        super.init()
    }
    
    
    
    //----------------------//
    //--- CUSTOM METHODS ---//
    //----------------------//
    public func handleFaceFeatures(faceImage: CIImage, previewLayer: AVCaptureVideoPreviewLayer, overlay: ADOverlayView) {

        let options = [CIDetectorImageOrientation: orientation(orientation: UIDevice.current.orientation),
                       CIDetectorSmile: true,
                       CIDetectorEyeBlink: true] as [String: Any]
        
        guard let features = faceDetector?.features(in: faceImage, options: options) else {
            return
        }

        guard let faceFeatures = features as? [CIFaceFeature] else {
            return
        }
        
        // no face detected
        if features.isEmpty {
            return
        }
        
        // more than one faces
        if features.count > 1 {
            return
        }
        
        // For converting the Core Image Coordinates to UIView Coordinates
        // useful to move into helper
        for face in faceFeatures {
            let ciImageSize = faceImage.extent.size
            let scale = previewLayer.frame.size.height / ciImageSize.height
            let offset = faceImage.extent.size.width * scale - previewLayer.frame.size.width
            let actualMarginWidth = -offset
            let imageToScreenConversionTransform = CGAffineTransform(scaleX: -scale, y: -scale).translatedBy(x: -ciImageSize.width - actualMarginWidth, y: -ciImageSize.height)
            let faceViewBounds = face.bounds.applying(imageToScreenConversionTransform)

            if overlay.overlayFrame.contains(faceViewBounds)  {
                self.isFaceDetected = true
                let _ = self.validateDetection(faceFeature: face)
                let flippedCIImage = CIImage.flipImageFromCIImage(from:faceImage)
                let cgImage = self.ciContext.createCGImage(flippedCIImage, from: flippedCIImage.extent)
                self.adDetectionDelegate?.faceDetection(captured: UIImage(cgImage: cgImage!), rect: faceViewBounds)
            } else {
                self.adDetectionDelegate?.faceDetectFeedback(With: "Please position you eyes correctly")
            }
        }
    }
    
    fileprivate func validateDetection(faceFeature: CIFaceFeature) -> Bool{
    
        if !faceFeature.hasRightEyePosition || !faceFeature.hasLeftEyePosition {
            self.adDetectionDelegate?.faceDetectFeedback(With: "Please position you eyes correctly")
            return false
        }
        
        if faceFeature.leftEyeClosed || faceFeature.rightEyeClosed {
            self.adDetectionDelegate?.faceDetectFeedback(With: "Please stright up your head")
            return false
        }
        
        if !faceFeature.hasMouthPosition {
            self.adDetectionDelegate?.faceDetectFeedback(With: "Please keep your face inside the marked region")
            return false
        }
        
        if faceFeature.faceAngle < 80 || faceFeature.faceAngle > 120 {
            self.adDetectionDelegate?.faceDetectFeedback(With: "Please keep your head stright")
            return false
        }
        return true
    }
    
    internal func orientation(orientation: UIDeviceOrientation) -> Int {
        switch orientation {
        case .portraitUpsideDown:
            return 8
        case .landscapeLeft:
            return 3
        case .landscapeRight:
            return 1
        case .portrait:
            return 6
        default:
            return 6
        }
    }
}

