//
//  UIImage+Extension.swift
//  Bhakti_Vikasa
//
//  Created by gagandeepmishra on 21/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import UIKit

import Kingfisher

import AVKit
extension UIImage{

    #if swift(>=4.2)

    var png:                  Data      { return self.pngData()!        }

    var highestJPEG:          Data      { return self.jpegData(compressionQuality: 1.0)!  }

    var highJPEG:             Data      { return self.jpegData(compressionQuality: 0.75)! }

    var mediumJPEG:           Data      { return self.jpegData(compressionQuality: 0.5)!  }

    var lowQualityJPEG:       Data      { return self.jpegData(compressionQuality: 0.25)! }

    var lowestQualityJPEG:    Data      { return self.jpegData(compressionQuality: 0.0)!  }

    #else

    var png:                  Data      { return UIImagePNGRepresentation(self)!          }

    var highestJPEG:          Data      { return UIImageJPEGRepresentation(self,1.0)!     }

    var highJPEG:             Data      { return UIImageJPEGRepresentation(self,0.75)!    }

    var mediumJPEG:           Data      { return UIImageJPEGRepresentation(self,0.5)!     }

    var lowQualityJPEG:       Data      { return UIImageJPEGRepresentation(self,0.25)!    }

    var lowestQualityJPEG:    Data      { return UIImageJPEGRepresentation(self, 0.25 )!  }

    #endif

    

    

    

     @discardableResult

    func scaleImage(to size: CGSize) -> KFCrossPlatformImage {

        guard let cgImage    = self.cgImage else {return self}

        let wRatio           = size.width/CGFloat(cgImage.width)

        let hRatio           = size.height/CGFloat(cgImage.height)

        let width            = size.width

        var height           = size.width

        if wRatio < hRatio { height =  CGFloat(cgImage.height) * CGFloat(wRatio)}

        return self.resize(to: .init(width: width, height: height))

        

    }

    // MARK: Round Corner

    /// Creates a round corner image from on `UIImage` image.

    ///

    /// - Parameters:

    ///   - radius: The round corner radius of creating image.

    ///   - size: The target size of creating image.

    ///   - corners: The target corners which will be applied rounding.

    ///   - backgroundColor: The background color for the output image

    /// - Returns: An image with round corner of `self`.

    ///

    /// - Note: This method only works for CG-based image. The current image scale is kept.

    ///         For any non-CG-based image, `UIImage` itself is returned.

     @discardableResult

    func image(withRoundRadius radius: CGFloat,

               fit size: CGSize,

               roundingCorners corners: RectCorner = .all,

               backgroundColor: KFCrossPlatformColor? = nil) -> KFCrossPlatformImage

    {

        guard let _ = cgImage else {

            assertionFailure("Round corner image only works for CG-based image.")

            return self

        }

        let wrapp = KingfisherWrapper(self)

        return wrapp.image(withRoundRadius: radius, fit: size, roundingCorners: corners, backgroundColor: backgroundColor)

        

        

    }

    

    // MARK: Resizing

    /// Resizes `UIImage` image to an image with new size.

    ///

    /// - Parameter size: The target size in point.

    /// - Returns: An image with new size.

    /// - Note: This method only works for CG-based image. The current image scale is kept.

    ///         For any non-CG-based image, `UIImage` itself is returned.

     @discardableResult

    func resize(to size: CGSize) -> KFCrossPlatformImage {

        let wrapp = KingfisherWrapper(self)

        return wrapp.resize(to: size)

    }

    

    // MARK: tintColor

    /// Creates an image from `UIImage` image with a color tint.

    ///

    /// - Parameter color: The color should be used to tint `UIImage`

    /// - Parameter renderingMode: The rendering mode to assign to the returned image. available(iOS 13, *)

    /// - Returns: An image with a color tint applied.

    @discardableResult

    func tintColor(_ color: UIColor,renderingMode: UIImage.RenderingMode? = nil) -> UIImage {

        if #available(iOS 13, *) {

            if let renderingMode = renderingMode {

               return self.withTintColor(color, renderingMode: renderingMode)

            }else{

               return self.withTintColor(color)

            }

            

        }else{

            UIGraphicsBeginImageContextWithOptions(size, false, scale)

            defer { UIGraphicsEndImageContext() }

            color.set()

            withRenderingMode(renderingMode ?? .alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))

            return UIGraphicsGetImageFromCurrentImageContext() ?? self

        }

        

        

        

    }

    /**

     Calculates the best height of the image for available width.

     */

     @discardableResult

     func height(forWidth width: CGFloat) -> CGFloat {

        let boundingRect = CGRect(

            x: 0,

            y: 0,

            width: width,

            height: CGFloat(MAXFLOAT)

        )

        let rect = AVMakeRect(

            aspectRatio: size,

            insideRect: boundingRect

        )

        return rect.size.height

    }

    

    

}
