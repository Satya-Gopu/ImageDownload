//
//  Utility.swift
//  SpinCar
//
//  Created by Satya on 7/9/18.
//  Copyright © 2018 Satya. All rights reserved.
//

import UIKit

// MARK: - Utility object

class Utility: NSObject {
    
    // MARK: Properties
    
    // singleton utility instance
    static let shared = Utility()
    
    // MARK: LifeCycle
    
    // override init to make it private
    
    private override init() {
        
    }
    
    // MARK: Methods
    
    // presents an Alert on the received view controller
    
    func showAlert(on vc: UIViewController, title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        weak var weakAlert = alertController
        let defaultAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            weakAlert?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(defaultAction)
        vc.present(alertController, animated: true, completion: nil)
    }
    
    // presents an Error Alert on the received view controller
    
    func showErrorAlert(on vc: UIViewController, message: String?) {
        showAlert(on: vc, title: "Error", message: message)
    }
    
}
