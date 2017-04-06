//
//  UIHelpers.swift
//  Thiqah ToDo app
//
//  Created by khaledannajar on 4/6/17.
//  Copyright © 2017 mycompany. All rights reserved.
//

import UIKit

class AlertHelper {
    
    class func displayAlert(title: String?, message: String, inViewController controller: UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
        })
        controller.present(alert, animated: true) {}
    }
}
