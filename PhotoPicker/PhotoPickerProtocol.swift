//
//  PhotoPickerProtocol.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/25.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import Photos

public protocol PhotoPickerDelegate: class {
    func photoPickerController(_ controller: PhotoPickerController, didFinishPickingAssets assets: [PHAsset], needHighQualityImage: Bool)
    func photoPickerControllerDidCancel(_ controller: PhotoPickerController)
    func photoPickerController(_ controller: PhotoPickerController, shouldSelectAsset asset: PHAsset) -> Bool
    func photoPickerController(_ controller: PhotoPickerController, didSelectAsset asset: PHAsset)
    func photoPickerController(_ controller: PhotoPickerController, didDeselectAsset asset: PHAsset)
}

public extension PhotoPickerDelegate {
    func photoPickerController(_ controller: PhotoPickerController, didFinishPickingAssets assets: [PHAsset], needHighQualityImage: Bool) {
        return
    }
    
    func photoPickerControllerDidCancel(_ controller: PhotoPickerController) {
        return
    }
    
    func photoPickerController(_ controller: PhotoPickerController, shouldSelectAsset asset: PHAsset) -> Bool {
        return true
    }
    
    func photoPickerController(_ controller: PhotoPickerController, didSelectAsset asset: PHAsset) {
        return
    }
    
    func photoPickerController(_ controller: PhotoPickerController, didDeselectAsset asset: PHAsset) {
        return
    }
}
