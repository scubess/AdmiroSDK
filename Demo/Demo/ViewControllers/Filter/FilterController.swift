//
//  FilterController.swift
//  Demo
//
//  Created by Lshiva on 05/12/2020.
//

import UIKit

public protocol FilterControllerprotocol: class {
     var onBack: (() -> Void)? { get set }
}

class FilterController: UIViewController {

    //---------------------//
    //--- VARS AND LETS ---//
    //---------------------//
    var sourceImage : UIImage? {
        didSet {
            self.filterView.imageView.image = self.sourceImage
        }
    }
    
    internal lazy var filterView : FilterView = {
        let view = FilterView()
        view.filterViewDelegate = self
        return view
    }()
    
    var onBack: (() -> Void)?
    
    //-------------------------//
    //--- LIFECYCLE METHODS ---//
    //-------------------------//
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setup()
    }

    //-------------------------//
    //--- CUSTOM METHODS    ---//
    //-------------------------//
    func setup() {
        self.filterView.frame = self.view.frame
        self.filterView.setup()
        self.view.addSubview(self.filterView)
    }
}

extension FilterController : FilterViewDelegate {
    func didBackPressed() {
        self.dismiss(animated: true) {
            self.onBack?()
        }
    }
}
