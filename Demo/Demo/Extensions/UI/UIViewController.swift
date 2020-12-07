//
//  UIViewController.swift
//  Demo
//
//  Created by Lshiva on 05/12/2020.
//

import UIKit
import MBProgressHUD

extension UIViewController {
    
    // MARK: - Public methods
    
    // MARK: Loader
    func showHUD(progressLabel:String){
        DispatchQueue.main.async{
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHUD.label.text = progressLabel
            progressHUD.mode = .customView
            //progressHUD.bezelView.color = Config.Font.Color.background
            progressHUD.bezelView.style = .solidColor
            progressHUD.contentColor = UIColor.white
            progressHUD.hide(animated: true, afterDelay: 2.0)
        }
    }

    func dismissHUD(isAnimated:Bool) {
        DispatchQueue.main.async{
            MBProgressHUD.hide(for: self.view, animated: isAnimated)
        }
    }

    func shouldHideLoader(isHidden: Bool) {
        if isHidden {
            MBProgressHUD.hide(for: self.view, animated: true)
        } else {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    
    // MARK: Alerts
    func showAlertWith(message: AlertMessage , style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: message.title, message: message.body, preferredStyle: style)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}

