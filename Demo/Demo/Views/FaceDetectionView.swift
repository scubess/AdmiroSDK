//
//  ScanArea.swift
//  Demo
//
//  Created by Lshiva on 04/12/2020.
//
import UIKit
import Vision
import AVFoundation

class FaceDetectionView : CAShapeLayer {
    var drawings: [CAShapeLayer] = []
    
    override init() {
        super.init()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.fillColor = UIColor.clear.cgColor
        self.lineWidth = 2.5
        self.isHidden = true
    }

    func show(_ observedFaces: [VNFaceObservation], previewLayer: AVCaptureVideoPreviewLayer) {
        self.isHidden = false
        self.clearDrawings()
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.flatMap({ (observedFace: VNFaceObservation) -> [CAShapeLayer] in
            let faceBoundingBoxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            let faceBoundingBoxShape = CAShapeLayer()
            faceBoundingBoxShape.path = self.CornerView(frame: faceBoundingBoxOnScreen)
            faceBoundingBoxShape.lineWidth = 3
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            faceBoundingBoxShape.strokeColor = UIColor.white.cgColor
            var newDrawings = [CAShapeLayer]()
            newDrawings.append(faceBoundingBoxShape)
            return newDrawings
        })
        
        facesBoundingBoxes.forEach({ faceBoundingBox in self.addSublayer(faceBoundingBox) })
        self.drawings = facesBoundingBoxes
    }
    
    func hide() {
        self.isHidden = true
        self.clearDrawings()
    }
}

extension FaceDetectionView {
    
    public func detectFace(in image: CVPixelBuffer, previewLayer: AVCaptureVideoPreviewLayer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation] {
                    self.show(results, previewLayer: previewLayer)
                } else {
                    self.hide()
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    private func clearDrawings() {
        self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
}


extension FaceDetectionView {

    func CornerView(frame: CGRect) -> CGMutablePath {
        
        let cornerLengthToShow = frame.size.height * 0.05

        let topLeftCorner = UIBezierPath()
        topLeftCorner.move(to: CGPoint(x: frame.minX, y: frame.minY + cornerLengthToShow))
        topLeftCorner.addLine(to: CGPoint(x: frame.minX, y: frame.minY))
        topLeftCorner.addLine(to: CGPoint(x: frame.minX + cornerLengthToShow, y: frame.minY))

        let topRightCorner = UIBezierPath()
        topRightCorner.move(to: CGPoint(x: frame.maxX - cornerLengthToShow, y: frame.minY))
        topRightCorner.addLine(to: CGPoint(x: frame.maxX, y: frame.minY))
        topRightCorner.addLine(to: CGPoint(x: frame.maxX, y: frame.minY + cornerLengthToShow))

        let bottomRightCorner = UIBezierPath()
        bottomRightCorner.move(to: CGPoint(x: frame.maxX, y: frame.maxY - cornerLengthToShow))
        bottomRightCorner.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
        bottomRightCorner.addLine(to: CGPoint(x: frame.maxX - cornerLengthToShow, y: frame.maxY ))

        let bottomLeftCorner = UIBezierPath()
        bottomLeftCorner.move(to: CGPoint(x: frame.minX, y: frame.maxY - cornerLengthToShow))
        bottomLeftCorner.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
        bottomLeftCorner.addLine(to: CGPoint(x: frame.minX + cornerLengthToShow, y: frame.maxY))

        let combinedPath = CGMutablePath()
        combinedPath.addPath(topLeftCorner.cgPath)
        combinedPath.addPath(topRightCorner.cgPath)
        combinedPath.addPath(bottomRightCorner.cgPath)
        combinedPath.addPath(bottomLeftCorner.cgPath)
        
        return combinedPath
    }
}
