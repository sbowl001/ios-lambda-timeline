//
//  CameraPreviewView.swift
//  LambdaTimeline
//
//  Created by Stephanie Bowles on 9/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
