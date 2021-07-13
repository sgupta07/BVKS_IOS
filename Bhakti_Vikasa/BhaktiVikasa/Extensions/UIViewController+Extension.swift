//
//  UIViewController.swift
//  whatsthewait
//
//  Created by Harsh Rajput on 20/07/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func popupAlert(title: String?, message: String?, style:UIAlertController.Style = .alert, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func openShareActivityControler(userContent:[Any]){
       
        DispatchQueue.main.async{
            let activityViewController = UIActivityViewController(activityItems: userContent as [Any], applicationActivities: nil)
            
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                // It's an iPhone
                break
            case .pad:
                // It's an iPad (or macOS Catalyst)
              //  alert.popoverPresentationController?.sourceView = VC.view
                if let popoverPresentationController = activityViewController.popoverPresentationController {
                      popoverPresentationController.sourceView = self.view
                      popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                      popoverPresentationController.permittedArrowDirections = []
                    }
                break
                
            @unknown default:
                // Uh, oh! What could it be?
                break
            }
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    func setUIInterfaceOrientation(_ value: UIInterfaceOrientation) {
        UIDevice.current.setValue(value.rawValue, forKey: "orientation")
    }
    
    func reloadViewFromNib() {
        let parent = view.superview
        view.removeFromSuperview()
        view = nil
        parent?.addSubview(view) // This line causes the view to be reloaded
    }
    
        func hideKeyboardWhenTappedAround() {
            let tapGesture = UITapGestureRecognizer(target: self,
                             action: #selector(hideKeyboard))
            view.addGestureRecognizer(tapGesture)
        }

        @objc func hideKeyboard() {
            view.endEditing(true)
        }
}

