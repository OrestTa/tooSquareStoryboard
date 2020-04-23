//
//  ViewController.swift
//  tooSquare
//
//  Created by Orest Tarasiuk on 21/4/20.
//  Copyright © 2020 orest. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var aspectControl: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var saveButton: UIButton!
    
    var pickedImage: UIImage?
    
    func drawRectangle(width: CGFloat, height: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: width, height: height)
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
        }
        return img
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        activityIndicator.stopAnimating()
    }
    
    @IBAction func logoButtonPressed(_ sender: UIButton) {
        actionClickOnGallery(sender)
    }
    
    @IBAction func aspectControlChanged(_ sender: Any) {
        if let image = pickedImage {
            activityIndicator.startAnimating()
            addStripes(toImage: image)
            activityIndicator.stopAnimating()
        }
    }
    
    //MARK: - Action for fetch image from Camera
    @IBAction func actionClickOnCamera(_ sender: UIButton) {
        //This condition is used for check availability of camera
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false;
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Alert", message: "You don't have a camera for this device", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Action for fetch image from Gallery
    @IBAction func actionClickOnGallery(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false;
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        activityIndicator.startAnimating()
        self.dismiss(animated: true, completion: {
            self.imagePicked(info: info)
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePicked(info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            pickedImage = image
            addStripes(toImage: image)
        }
        else
        {
            let ac = UIAlertController(title: "Image read error", message: "No UIImage found", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        activityIndicator.stopAnimating()
    }
    
    func addStripes(toImage image: UIImage) {
        let aspectRatio = aspectControl.selectedSegmentIndex == 0 ? CGFloat(1/1.0) : CGFloat(4/5.0)
        var width = image.size.width
        var height = image.size.height
        let originalAspectRatio = width/height
        if originalAspectRatio > aspectRatio {
            // we need to extend the height
            height = width / aspectRatio
        } else {
            // we need to extend the width
            width = height * aspectRatio
        }
        
        let whiteImage = drawRectangle(width: width, height: height)
        imageView.image = UIImage.imageByCombiningImage(firstImage: whiteImage, withImage: image)
        logoButton.isHidden = true
        saveButton.isEnabled = true
    }
    
    @IBAction func saveButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
            imageView.image = nil
            logoButton.isHidden = false
            saveButton.isEnabled = false
        }
    }
}

extension UIImage {
    
    class func imageByCombiningImage(firstImage: UIImage, withImage secondImage: UIImage) -> UIImage {
        
        let newImageWidth  = max(firstImage.size.width,  secondImage.size.width )
        let newImageHeight = max(firstImage.size.height, secondImage.size.height)
        let newImageSize = CGSize(width : newImageWidth, height: newImageHeight)
        
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, 1)
        
        let firstImageDrawX  = round((newImageSize.width  - firstImage.size.width  ) / 2)
        let firstImageDrawY  = round((newImageSize.height - firstImage.size.height ) / 2)
        
        let secondImageDrawX = round((newImageSize.width  - secondImage.size.width ) / 2)
        let secondImageDrawY = round((newImageSize.height - secondImage.size.height) / 2)
        
        firstImage .draw(at: CGPoint(x: firstImageDrawX,  y: firstImageDrawY))
        secondImage.draw(at: CGPoint(x: secondImageDrawX, y: secondImageDrawY))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        
        return image!
    }
}
