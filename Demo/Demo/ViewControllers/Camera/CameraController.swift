//
//  CameraController.swift
//  Demo
//
//  Created by Lshiva on 05/12/2020.
//

import UIKit
import UIKit
import AVFoundation
import CoreMedia
import SnapKit
import Admiro

class CameraController: ADCameraViewController {

    //---------------------//
    //--- VARS AND LETS ---//
    //---------------------//
    internal lazy var cameraView : UIView = {
        let view = CameraView()
        view.cameraViewDelegate = self
        return view
    }()
        
    var version = ADVersion()
        
    //-------------------------//
    //--- LIFECYCLE METHODS ---//
    //-------------------------//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SETUP CAMERA VIEW
        self.cameraView.frame = self.view.frame
        self.view.addSubview(self.cameraView)
        definesPresentationContext = true
        self.cameraViewSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //-------------------------//
    //--- CAMERA METHODS ------//
    //-------------------------//
    func cameraViewSetup(){
        ADcameraDelegate = self
//        tapToFocus = true
//        lowLightBoost = false
//        cameraPosition = .front
//        flashMode = .off
//        preset = .hd4K3840x2160 // TODO: set up image quality in settings to choose = low | medium | high
    }
}

    //-----------------------------------------//
    //--- EXTENSION METHOD 1: PHOTO CAPTURE ---//
    //-----------------------------------------//
extension CameraController : CameraViewDelegate {
    
    func didCapturePressed() {
        //self.takePhoto()
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
    
    func showFilterController(image: UIImage) {
        let filterController =  FilterController()
        filterController.modalPresentationStyle = .fullScreen
        filterController.sourceImage = image
        filterController.modalPresentationStyle = .custom
        filterController.modalTransitionStyle = .crossDissolve
        filterController.onBack = { [unowned self] in
            self.resetFaceDetection()
        }
        self.present(filterController, animated: true) {
            
        }
    }
    
    func resetFaceDetection() {
        self.dimissed()//set the selfiedetection to false
    }
}

    //-----------------------------------------//
    //--- EXTENSION METHOD 2: CAMERA DELEGATE--//
    //-----------------------------------------//
extension CameraController: ADCameraViewControllerDelegate {

    func cameraViewController(didFocus point: CGPoint) {

    }
    
    func cameraViewController(update status: AVAuthorizationStatus) {

    }
    
    func cameraViewController(captured image: UIImage) {
        self.showFilterController(image: image)
    }
    
    func cameraViewController(sampleBuffer: CMSampleBuffer) {
    
    }
}
