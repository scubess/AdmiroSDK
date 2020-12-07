//
//  ADExtensions.swift
//  Admiro
//
//  Created by Lshiva on 07/12/2020.
//

import UIKit

extension UIImage{

    // front facing camera
    static func flipImage(from data: Data) -> CIImage {
        let image = UIImage(data: data)!
        let ciImage: CIImage = CIImage(cgImage: image.cgImage!).oriented(forExifOrientation: 6)
        let flippedImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
        return flippedImage
    }
    
    // CIImage to UIImage
    static func convert(from ciImage: CIImage) -> UIImage{
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}

extension CIImage {
    // flip to UIImage: Render issue on live
    static func flipImageFromCIImage(from image: CIImage) -> CIImage {
        let flippedImage = image.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
        return flippedImage
    }
}

extension CGImage {
    // flip to CGImage: Render issue on live
    static func flipImageFromCGIImage(from image: CGImage) -> CIImage {
        let ciimage = CIImage(cgImage: image)
        let flippedImage = ciimage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
        return flippedImage
    }
}
