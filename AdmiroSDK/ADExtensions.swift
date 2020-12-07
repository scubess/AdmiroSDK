//
//  ADExtensions.swift
//  Admiro
//
//  Created by Lshiva on 07/12/2020.
//

import UIKit

extension UIImage{

    static func flipImage(from data: Data) -> CIImage {
        let image = UIImage(data: data)!
        let ciImage: CIImage = CIImage(cgImage: image.cgImage!).oriented(forExifOrientation: 6)
        let flippedImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
        return flippedImage
    }
    
    static func convert(from ciImage: CIImage) -> UIImage{
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}

extension CIImage {
    static func flipImageFromCIImage(from image: CIImage) -> CIImage {
        let flippedImage = image.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
        return flippedImage
    }
}

extension CGImage {
    static func flipImageFromCGIImage(from image: CGImage) -> CIImage {
        let ciimage = CIImage(cgImage: image)
        let flippedImage = ciimage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
        return flippedImage
    }
}

