//
//  AlertMessage.swift
//  Demo
//
//  Created by Lshiva on 05/12/2020.
//

import Foundation

class AlertMessage: Error {
    //---------------------//
    //--- VARS AND LETS ---//
    //---------------------//
    
    var title = ""
    var body = ""
    
    // MARK: - Intialization
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
    }
    
}

