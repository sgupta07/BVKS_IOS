//
//  UITextField+Ex.swift
//  Bhakti_Vikasa
//
//  Created by gagandeepmishra on 23/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import UIKit

private var maxLengths = [UITextField: Int]()

extension UITextField {
    
   @IBInspectable var maxLength: Int {
      get {
        // 4
        guard let length = maxLengths[self] else {
          return Int.max
        }
        return length
      }
      set {
        maxLengths[self] = newValue
        // 5
        addTarget(
            self,
            action: #selector(limitLength),
            for: UIControl.Event.editingChanged
        )
      }
    }
    
    @objc func limitLength(textField: UITextField) {
      // 6
      guard let prospectiveText = textField.text,
                prospectiveText.count > maxLength
      else {
        return
      }
      
      let selection = selectedTextRange
      // 7
      let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
      text = prospectiveText.substring(to: maxCharIndex)
      selectedTextRange = selection
    }
}
