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
        let localizedString: [String: String] = [
            "PhotoPicker.Cancel": "取消",
            "PhotoPicker.OK": "确定",
            "PhotoPicker.Send": "发送",
            "PhotoPicker.Origin": "原图",
            "PhotoPicker.MaximumNumberOfSelection.Alert": "最多选择 %ld 张照片",
            "PhotoPicker.Photos": "张照片",
            "PhotoPicker.Videos": "个视频",
            "PhotoPicker.Title" : "照片",
            "PhotoPicker.VideoSelect.Alert": "当你选择视频时，只能选择一个视频哦!"
        ]
        let photoPickerController = PhotoPickerController(localizedStrings: localizedString)
        photoPickerController.delegate = self
        photoPickerController.allowMultipleSelection = true
        photoPickerController.maximumNumberOfSelection = 3
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

