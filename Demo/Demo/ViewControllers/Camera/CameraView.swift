//
//  CameraView.swift
//  Demo
//
//  Created by Lshiva on 04/12/2020.
//

import UIKit
import SnapKit
import Photos

public protocol CameraViewDelegate: class {
    func didCapturePressed()
    func didFlashPressed(_ sender: UIButton)
    func didSwitchCameraPressed(_ sender: UIButton)
}

class CameraView: UIView {
    //---------------------//
    //--- VARS AND LETS ---//
    //---------------------//
    public weak var cameraViewDelegate: CameraViewDelegate?
            
    // capture button
    internal lazy var captureBtn : UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 30
        button.layer.borderColor = UIColor.white.cgColor
        button.setBackgroundImage(UIImage(named: "Circle"), for: .normal)
        button.clipsToBounds = true
        return button
    }()
    
    // flash button
    internal lazy var flashbtn : UIButton = {
        let button = UIButton(type: .custom)
        button.layer.borderColor = UIColor.clear.cgColor
        button.setImage(UIImage(named: "flash_off"), for: .normal)
        button.setImage(UIImage(named: "flash_on"), for: .selected)
        button.layer.borderWidth = 1.5
        return button
    }()
    
    // switch camera button
    internal lazy var switchCamerabtn : UIButton = {
        let button = UIButton(type: .custom)
        button.layer.borderColor = UIColor.clear.cgColor
        button.setImage(UIImage(named: "switch_camera"), for: .normal)
        button.layer.borderWidth = 1.5
        return button
    }()

    //-------------------------//
    //--- CUSTOM METHODS ------//
    //-------------------------//
     func setup() {
             
        // CAPTURE BUTTON
        self.addSubview(self.captureBtn)
        self.captureBtn.addTarget(self, action: #selector(self.capturePhoto), for: .touchUpInside)
        self.captureBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-50)
            make.centerX.equalTo(self)
            make.width.height.equalTo(60)
        }
                
        // FLASH BUTTON
        self.addSubview(self.flashbtn)
        self.flashbtn.addTarget(self, action: #selector(self.flashPressed), for: .touchUpInside)
        self.flashbtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(50)
        }
        
        // SWITCH CAMERA BUTTON
        self.addSubview(self.switchCamerabtn)
        self.switchCamerabtn.addTarget(self, action: #selector(self.switchCameraPressed), for: .touchUpInside)
        self.switchCamerabtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(34)
            make.centerY.equalTo(self.captureBtn.snp.centerY)
            make.right.equalTo(self).offset(-30)
        }
    }
    
    //-------------------------//
    //--- LIFECYCLE METHODS ---//
    //-------------------------//
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}

    //-----------------------------------------//
    //--- EXTENSION     1: CAMERAVIEWDELEGATE--//
    //-----------------------------------------//
extension CameraView {
    @objc func capturePhoto() {
        self.cameraViewDelegate?.didCapturePressed()
    }
    
    @objc func flashPressed(_ sender: UIButton) {
        self.cameraViewDelegate?.didFlashPressed(sender)
    }
    
    @objc func switchCameraPressed(_ sender: UIButton) {
        self.cameraViewDelegate?.didSwitchCameraPressed(sender)
    }

}
