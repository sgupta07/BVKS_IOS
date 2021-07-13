//
//  UISlider+Ex.swift
//  Bhakti_Vikasa
//
//  Created by gagandeepmishra on 21/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import Foundation
import UIKit
extension UISlider{
    @IBInspectable
    var thumbImage:UIImage? {
        set{self[thumImage: .normal] = newValue}get{self[thumImage: .normal]}
    }
    @IBInspectable
    var sthumbImage:UIImage? {
        set{self[thumImage: .selected] = newValue}get{self[thumImage: .selected]}
    }
    subscript(thumImage state: UIControl.State)->UIImage?{
        set{setThumbImage(newValue, for: state)}get{thumbImage(for: state)}
    }
    subscript(maximumTrackImage state: UIControl.State)->UIImage?{
        set{setMaximumTrackImage(newValue, for: state)} get{maximumTrackImage(for: state)}
        
    }
    subscript(minimumTrackImage state: UIControl.State)->UIImage?{
        set{setMinimumTrackImage(newValue, for: state)} get{minimumTrackImage(for: state)}
        
    }
    
}
