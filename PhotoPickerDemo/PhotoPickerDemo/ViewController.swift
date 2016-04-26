//
//  ViewController.swift
//  PhotoPickerDemo
//
//  Created by DangGu on 16/2/25.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit
import PhotoPicker
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func showButtonTapped(sender: UIButton) {
        let photoPickerController = PhotoPickerController()
        photoPickerController.delegate = self
        photoPickerController.allowMultipleSelection = false
        self.presentViewController(photoPickerController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController: PhotoPickerDelegate {
    func photoPickerControllerDidCancel(controller: PhotoPickerController) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func photoPickerController(controller: PhotoPickerController, didFinishPickingAssets assets: [PHAsset], needHighQualityImage: Bool) {
        navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            let alertController = UIAlertController(title: nil, message: "你已经选择了\(assets.count)张照片", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            }
            alertController.addAction(cancelAction)
            
            self.navigationController?.presentViewController(alertController, animated: true, completion: nil)
        })
    }
}

