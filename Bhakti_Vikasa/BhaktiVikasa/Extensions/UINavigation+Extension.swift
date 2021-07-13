//
//  UINavigation+Extension.swift
//  Bhakti_Vikasa
//
//  Created by gagandeepmishra on 16/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import Foundation
import UIKit
extension UINavigationController {

   func backToViewController(vc: Any) {
      // iterate to find the type of vc
      for element in viewControllers as Array {
        if "\(type(of: element)).Type" == "\(type(of: vc))" {
            self.popToViewController(element, animated: true)
            break
         }
      }
   }
    func getViweController(vc: Any) -> UIViewController?{
       // iterate to find the type of vc
       for element in viewControllers as Array {
        if "\(type(of: element)).Type" == "\(type(of: vc))" {
            return element
          }
       }
        return nil
    }

}
