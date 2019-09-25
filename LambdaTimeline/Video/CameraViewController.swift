//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Stephanie Bowles on 9/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {

    @IBOutlet weak var cameraPreviewView: CameraPreviewView!
    
    
    @IBOutlet weak var recordButton: UIButton!
    
    var captureSession: AVCaptureSession!
    var recordOutput: AVCaptureMovieFileOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let captureSession = AVCaptureSession()
        let videoDevice = self.bestCamera()
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            captureSession.canAddInput(videoDeviceInput) else { fatalError()}
        
        captureSession.addInput(videoDeviceInput)
        
        let fileOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError()
        }
        
        captureSession.addOutput(fileOutput)
        self.recordOutput = fileOutput
        
        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration()
        
        self.captureSession = captureSession
        cameraPreviewView.videoPreviewLayer.session = captureSession
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.captureSession.stopRunning()
    }

    @IBAction func recordButtonTapped(_ sender: Any) {
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: self.newRecordingURL(), recordingDelegate: self)
        }
    }
    
    private func bestCamera() -> AVCaptureDevice {
        
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back ) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }  else {
            fatalError("Missing Expected back camera device")
        }
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documents = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true )
        
        return documents.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    private func updateViews() {
        guard isViewLoaded else {return}
        
        let isRecording = recordOutput?.isRecording ?? false
        let recordButtonImageName: String = isRecording ? "Stop" : "Record"
        recordButton.setImage(UIImage(named: recordButtonImageName), for: .normal)
    }}


extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        defer {self.updateViews()}
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if status != .authorized {
                NSLog("Please give Video Recorder access to your photo library")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            })  { (success, error) in
                if let error = error {
                    NSLog("Error saving video to photo library: \(error)")
                }
                
                if success {
                    DispatchQueue.main.async {
                        self.presentSuccessAlert()
                    }
                    
                }
            }
        }
    }
    
    private func presentSuccessAlert() {
        let alert = UIAlertController(title: "Video Saved!", message: "Your video was successfully saved to your photo library", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        
        let photosAction = UIAlertAction(title: "Open Photos", style: .default) { (_) in
            UIApplication.shared.open(URL(string: "photos-redirect://")!, options: [:], completionHandler: nil)
            //probably wont need this
        }
        
        alert.addAction(photosAction)
        self.present(alert, animated: true, completion: nil)
    }
}
