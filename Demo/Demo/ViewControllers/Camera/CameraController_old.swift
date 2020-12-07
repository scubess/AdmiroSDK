//
//  ViewController.swift
//  Demo
//
//  Created by Lshiva on 04/12/2020.
//

import UIKit
import UIKit
import AVFoundation
import CoreMedia
import SnapKit
import Admiro

class CameraController: CameraViewController {

    //---------------------//
    //--- VARS AND LETS ---//
    //---------------------//

    let imagePicker = UIImagePickerController() // select image from albums
    
    internal lazy var cameraView : UIView = {
        let view = CameraView()
        view.cameraViewDelegate = self
        return view
    }()
    
    internal lazy var faceDetection : FaceDetectionView = {
        let view = FaceDetectionView()
        view.frame = self.view.frame
        view.backgroundColor = UIColor.clear.cgColor
        return view
    }()
    
    var version = ADVersion()
    
    let selfieDetection = FaceDetection()
    
    //-------------------------//
    //--- LIFECYCLE METHODS ---//
    //-------------------------//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SETUP CAMERA VIEW
        self.cameraView.frame = self.view.frame
        self.view.addSubview(self.cameraView)
        
        //SETUP PHOTOALBUM
        self.imagePicker.delegate = self
        
        //SETUP SELFIE DELEGATE
        self.selfieDetection.faceDetectionDelegate = self
        
        self.cameraViewSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.faceDetectionSetup()
    }
    
    //-------------------------//
    //--- CAMERA METHODS ------//
    //-------------------------//
    func cameraViewSetup(){
        cameraDelegate = self
        tapToFocus = true
        lowLightBoost = false
        cameraPosition = .front
        flashMode = .off
        preset = .hd4K3840x2160 // TODO: set up image quality in settings to choose = low | medium | high
    }
}

    //-----------------------------------------//
    //--- EXTENSION METHOD 1: PHOTO CAPTURE ---//
    //-----------------------------------------//
extension CameraController : CameraViewDelegate {
    
    func didCapturePressed() {
        //self.takePhoto()
    }
    
    func didGalleryPressed() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func didSettingsPressed() {
        
    }
    
    func didFlashPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.toggleFlash()
    }
    
    func didSwitchCameraPressed(_ sender: UIButton) {
        if self.cameraPosition == .back {
            self.cameraPosition = .front
        } else {
            self.cameraPosition = .back
        }
    }
    
    func faceDetectionSetup() {
        self.faceDetection.setup()
        self.previewLayer!.addSublayer(faceDetection)
        self.faceDetection.frame = self.previewLayer!.frame
    }
    
    func showFilterController(image: UIImage) {
        let filterController =  FilterController()
        filterController.modalPresentationStyle = .fullScreen
        filterController.sourceImage = image
        filterController.modalPresentationStyle = .custom
        filterController.modalTransitionStyle = .crossDissolve
        filterController.onBack = { [unowned self] in
            self.dimissed()
        }
        self.present(filterController, animated: true) {
            DLog("completed")
        }
    }
    
    func dimissed() {
        //set the selfiedetection to false
        self.selfieDetection.isFaceDetected = false
    }
}

    //-----------------------------------------//
    //--- EXTENSION METHOD 2: CAMERA DELEGATE--//
    //-----------------------------------------//
extension CameraController: CameraViewControllerDelegate {

    func cameraViewController(didFocus point: CGPoint) {
        DLog("focused point: \(point)")
    }
    
    func cameraViewController(update status: AVAuthorizationStatus) {
        DLog("status changed")
    }
    
    func cameraViewController(captured image: UIImage) {
        DLog("captured image ")
        self.showFilterController(image: image)
    }
    
    func cameraViewController(sampleBuffer: CMSampleBuffer) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            self.faceDetection.detectFace(in: pixelBuffer, previewLayer: self.previewLayer!)
            if selfieDetection.isFaceDetected == false {
                self.selfieDetection.detectFace(in: pixelBuffer)
            }
        }
    }
}
    //---------------------------------------------//
    //--- EXTENSION METHOD 3: IMG PICKER DELEGATE--//
    //---------------------------------------------//
extension CameraController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        _ = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        //self.didCapturePhoto?(image)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
     }
}
    //---------------------------------------------//
    //--- EXTENSION METHOD 4: SELFIE DELEGATE--//
    //---------------------------------------------//

extension CameraController : FaceDetectionDelegate {
    func FaceDetected() {
        //self.takePhoto()
    }
}


extension CameraController {

    func drawRect(rect: CGRect) {
        let ovalPath = UIBezierPath(ovalIn: rect)
        UIColor.gray.setFill()
        ovalPath.fill()
    }
}

