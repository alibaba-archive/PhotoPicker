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

    @IBAction func showButtonTapped(_ sender: UIButton) {
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
        photoPickerController.maximumNumberOfSelection = 9
        photoPickerController.navigationController?.modalPresentationStyle = .formSheet
        let nav = UINavigationController(rootViewController: photoPickerController)
//        nav.modalPresentationStyle = .formSheet
        navigationController?.present(nav, animated: true, completion: nil)
    }
}

extension ViewController: PhotoPickerDelegate {
    func photoPickerControllerDidCancel(_ controller: PhotoPickerController) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func photoPickerController(_ controller: PhotoPickerController, didFinishPickingAssets assets: [PHAsset], needHighQualityImage: Bool) {
        navigationController?.dismiss(animated: true, completion: { () -> Void in
            let alertController = UIAlertController(title: nil, message: "你已经选择了\(assets.count)张照片", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(cancelAction)
            
            self.navigationController?.present(alertController, animated: true, completion: nil)
        })
    }
}

