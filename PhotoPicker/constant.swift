//
//  constant.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/25.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

let toolBarTintColor: UIColor = UIColor(red: 3/255.0, green: 169/255.0, blue: 244/255.0, alpha: 1.0)
let greyTextColor: UIColor = UIColor(red: 191/255.0, green: 191/255.0, blue: 191/255.0, alpha: 1.0)
let blueTextColor: UIColor = UIColor(red: 3/255.0, green: 169/255.0, blue: 244/255.0, alpha: 1.0)
let AlbumCoverBorderColor: CGColor = UIColor.white.cgColor
let currentBundle: Bundle = Bundle(for: PhotoPickerController.self)
let selectedCheckMarkImageName = "checkmark_selected"
let unselectedCheckMarkImageName = "checkmark_unselected"
let toolbarNumberViewBackgroundImageName = "toolbar_numberview_background"
let toolbarHighQualityImageCheckedImageName = "toolbar_highquality_checked"
let toolbarHighQualityImageUnCheckedImageName = "toolbar_highquality_unchecked"

let assetCellIdentifier = "AssetCell"
let albumCellIdentifier = "AlbumCell"
let assetFooterViewIdentifier = "AssetFooterView"

public enum PhotoPickerMediaType {
    case any
    case image
    case video
}

enum PhotoPickerOrientation {
    case landscape
    case portrait
}

struct AssetsNumberOfColumns {
    static let PortraitPhone: Int = 4
    static let PortraitPad: Int = 7
    static let LandscapePhone: Int = 7
    static let LandscapePad: Int = 12
}

var currentOrientation: PhotoPickerOrientation {
    get {
        var orientation: PhotoPickerOrientation = .portrait
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .portraitUpsideDown, .unknown:
            orientation = .portrait
        case .landscapeLeft, .landscapeRight:
            orientation = .landscape
        }
        return orientation
    }
}

var currentDevice: UIUserInterfaceIdiom {
    get {
        return UIDevice.current.userInterfaceIdiom
    }
}

var localizedString: [String: String] = [
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
