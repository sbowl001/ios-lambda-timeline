//
//  UIImage+Scaling.swift
//  LambdaTimeline
//
//  Created by Stephanie Bowles on 9/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

extension UIImage {
    func imageByScaling(toSize size: CGSize) -> UIImage? {
        guard let data = pngData(),
            let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {return nil}
        
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height) / 2.0,  kCGImageSourceCreateThumbnailFromImageAlways: true]
        
        return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary).flatMap { UIImage(cgImage: $0)}
    }
}
