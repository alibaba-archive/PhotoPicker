//
//  ViewController.swift
//  PhotoPickerDemo
//
//  Created by DangGu on 16/2/25.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit
import PhotoPicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let photoPickerController = PhotoPickerController()
        photoPickerController.delegate = self
        photoPickerController.maximumNumberOfSelection = 1
        self.presentViewController(photoPickerController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: PhotoPickerDelegate {
    
}

