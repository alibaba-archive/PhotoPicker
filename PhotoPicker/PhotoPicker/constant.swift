//
//  constant.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/25.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

let AlbumCoverBorderColor: CGColorRef = UIColor.whiteColor().CGColor
let currentBundle: NSBundle = NSBundle(forClass: PhotoPickerController.self)

public enum PhotoPickerMediaType {
    case Any
    case Image
    case Video
}