//
//  FilterView.swift
//  Demo
//
//  Created by Lshiva on 05/12/2020.
//

import UIKit
import SnapKit

public protocol FilterViewDelegate : class  {
    func didBackPressed()
}

class FilterView: UIView {

    //---------------------//
    //--- VARS AND LETS ---//
    //---------------------//
    public weak var filterViewDelegate: FilterViewDelegate?

    internal lazy var imageView : UIImageView  = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.backgroundColor = .blue
        return imageview
    }()

    // back button
    internal lazy var backBtn : UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "Back Button"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        return button
    }()
    
    //----------------------//
    //--- CUSTOM METHODS ---//
    //----------------------//
    func setup() {
        // IMAGE VIEW
        self.imageView.frame = self.frame
        self.addSubview(self.imageView)
        
        //BACK BUTTON
        self.addSubview(self.backBtn)
        self.backBtn.addTarget(self, action: #selector(self.backPressed), for: .touchUpInside)
        self.backBtn.snp.makeConstraints { (make) in
            make.width.equalTo(54)
            make.height.equalTo(50)
            make.bottom.equalTo(self).offset(-55)
            make.left.equalTo(20)
        }
    }
    
    //-------------------------//
    //--- LIFECYCLE METHODS ---//
    //-------------------------//
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
}

extension FilterView {
    @objc func backPressed(_ sender: UIButton) {
        filterViewDelegate?.didBackPressed()
    }

}
