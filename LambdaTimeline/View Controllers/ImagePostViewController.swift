//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {
    
    @IBOutlet weak var monochromeSlider: UISlider!
    
    private let context = CIContext(options: nil)
    private let filter = CIFilter(name: "CIColorMonochrome")!
    var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
//        imageView.image = image
        
        var scaledSize = imageView.bounds.size
      
        
        let scale = UIScreen.main.scale
        
        scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height  * scale )
        scaledImage = image.imageByScaling(toSize: scaledSize)
        
        imageView.image = scaledImage
        
        chooseImageButton.setTitle("", for: [])
    }
    
    @IBAction func changeMonochrome(_ sender: Any) {
        self.updateImage()
    }
    private func monochromeImage(byFiltering image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else {return image}
        
        let ciImage = CIImage(cgImage: cgImage)
       
        filter.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
        filter.setValue(ciImage, forKey: "inputImage")
        filter.setValue(monochromeSlider.value, forKey: "inputIntensity")
        
        guard let outputCIImage = filter.outputImage else {return image}
        
        guard let outputCGIImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {return image}
        
        return UIImage(cgImage: outputCGIImage)
    }
    
    private func updateImage(){
        if let scaledImage = self.scaledImage {
            imageView.image = self.monochromeImage(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
//            updateViews()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
                
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
//        updateViews()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
//        imageView.image = image
        
        setImageViewHeight(with: image.ratio)
        var scaledSize = imageView.bounds.size
        
        
        let scale = UIScreen.main.scale
        
        scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height  * scale )
        scaledImage = image.imageByScaling(toSize: scaledSize)
        
        imageView.image = scaledImage
       
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
