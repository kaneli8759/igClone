//
//  CameraViewController.swift
//  igClone
//
//  Created by 李宗政 on 10/11/19.
//  Copyright © 2019 LiTusngCheng. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var removeButoon: UIBarButtonItem!
    var selectedImage: UIImage?
    var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    func handlePost() {
        if selectedImage != nil {
            self.shareButton.isEnabled = true
            self.removeButoon.isEnabled = true
            self.shareButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            self.shareButton.isEnabled = false
            self.removeButoon.isEnabled = false
            self.shareButton.backgroundColor = .lightGray
        }
    }
    
    
    @objc func handleSelectPhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image", "public.movie"]
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        if let profileImg = self.selectedImage, let imageData = profileImg.jpegData(compressionQuality: 0.1) {
            let ratio = profileImg.size.width / profileImg.size.height
            HelpService.uploadDataToServer(data: imageData, videoUrl: self.videoUrl, ratio:ratio, caption: captionTextView.text!, onSuccess: {
                self.clean()
                self.tabBarController?.selectedIndex = 0
            })
        } else {
            print("Profile Image can't be empty")
        }
    }
    
    @IBAction func remove_TouchUpInside(_ sender: Any) {
        clean()
        handlePost()
    }
    
    func clean() {
        self.captionTextView.text = ""
        self.photo.image = UIImage(named: "placeholder-photo")
        self.selectedImage = nil
        self.videoUrl = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filter_segue" {
            let filterVC = segue.destination as! FilterViewController
            filterVC.selectedImage = self.selectedImage
            filterVC.delegate = self
        }
    }
    
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("did finish picking media")
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            if let thumbnailImage = self.thumbnailImageForFileUrl(videoUrl) {
                do {
                    if #available(iOS 13, *) {
                        let urlString = videoUrl.relativeString
                        let urlSlice = urlString.split(separator: ".")
                        
                        let tempDiretoryUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                        let targetUrl = tempDiretoryUrl.appendingPathComponent(String(urlSlice[1])).appendingPathExtension(String(urlSlice[2]))
                        
                        try FileManager.default.copyItem(at: videoUrl, to: targetUrl)
                        
                        // if iOS 13 -> viedoUrl = targetUrl
                        selectedImage =  thumbnailImage
                        photo.image = thumbnailImage
                        self.videoUrl = targetUrl
                        handlePost()
                    } else {
                        // if iOS 12 -> viedoUrl = viedoUrl
                        selectedImage =  thumbnailImage
                        photo.image = thumbnailImage
                        self.videoUrl = videoUrl
                        handlePost()
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            dismiss(animated: true, completion: nil)
        }
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
            photo.image = image
            dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "filter_segue", sender: nil)
            })
            handlePost()
        }
    }
    
    func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 2, timescale: 1), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        
        return nil
    }
}

extension CameraViewController: FilterViewControllerDelegate {
    func updatePhoto(image: UIImage) {
        self.photo.image = image
        self.selectedImage = image
    }
}
