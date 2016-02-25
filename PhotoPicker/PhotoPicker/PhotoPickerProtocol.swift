//
//  PhotoPickerProtocol.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/25.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import Photos

public protocol PhotoPickerDelegate: class {
    func photoPickerController(controller: PhotoPickerController, didFinishPickingAssets: [PHAsset])
    func photoPickerControllerDidCancel(controller: PhotoPickerController)
    func photoPickerController(controller: PhotoPickerController, shouldSelectAsset: PHAsset) -> Bool
    func photoPickerController(controller: PhotoPickerController, didSelectAsset: PHAsset)
    func photoPickerController(controller: PhotoPickerController, didDeselectAsset: PHAsset)
}

public extension PhotoPickerDelegate {
    func photoPickerController(controller: PhotoPickerController, didFinishPickingAssets: [PHAsset]) {
        return
    }
    
    func photoPickerControllerDidCancel(controller: PhotoPickerController) {
        return
    }
    
    func photoPickerController(controller: PhotoPickerController, shouldSelectAsset: PHAsset) -> Bool {
        return true
    }
    
    
    func photoPickerController(controller: PhotoPickerController, didSelectAsset: PHAsset) {
        return
    }
    
    func photoPickerController(controller: PhotoPickerController, didDeselectAsset: PHAsset) {
        return
    }
}
