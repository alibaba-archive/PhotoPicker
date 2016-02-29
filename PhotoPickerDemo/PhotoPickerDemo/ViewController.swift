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
    }

    @IBAction func showButtonTapped(sender: UIButton) {
        let photoPickerController = PhotoPickerController()
        photoPickerController.delegate = self
        self.presentViewController(photoPickerController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: PhotoPickerDelegate {
    func photoPickerControllerDidCancel(controller: PhotoPickerController) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

