//
//  FaceDetection.swift
//  Demo
//
//  Created by Lshiva on 05/12/2020.
//

import UIKit
import Vision
import AVFoundation

public protocol FaceDetectionDelegate : class {
    func FaceDetected()
}

class FaceDetection: NSObject {
    //---------------------//
    //--- VARS AND LETS ---//
    //---------------------//
    public weak var faceDetectionDelegate: FaceDetectionDelegate?

    var isFaceDetected = false
    
    //-------------------------//
    //--- LIFECYCLE METHODS ---//
    //-------------------------//
    override init() {
        super.init()
    }

    //-------------------------//
    //--- CUSTOM METHODS ------//
    //-------------------------//
    public func detectFace(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation] {
                    guard results.count > 0 else {
                        return
                    }
                    self.isFaceDetected = true
                    self.faceDetected()
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
}

extension FaceDetection {
    @objc func faceDetected() {
        self.faceDetectionDelegate?.FaceDetected()
    }
}
