//
//  UtilityFunctions.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 09/08/1444 AH.
//

import Foundation
import UIKit

class UtilityFunctions : NSObject{
    
    func simpleAlert(vc : UIViewController, title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        vc.present(alert, animated: true)
    }
    func simpleAlertII(vc : UIViewController, title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { alertAction in
            vc.dismiss(animated: true)
        }
        alert.addAction(okAction)
        vc.present(alert, animated: true)
    }
}
