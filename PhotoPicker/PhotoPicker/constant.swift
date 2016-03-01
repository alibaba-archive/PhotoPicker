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
let AlbumCoverBorderColor: CGColorRef = UIColor.whiteColor().CGColor
let currentBundle: NSBundle = NSBundle(forClass: PhotoPickerController.self)
let selectedCheckMarkImageName = "checkmark_selected"
let unselectedCheckMarkImageName = "checkmark_unselected"
let toolbarNumberViewBackgroundImageName = "toolbar_numberview_background"
let toolbarHighQualityImageCheckedImageName = "toolbar_highquality_checked"
let toolbarHighQualityImageUnCheckedImageName = "toolbar_highquality_unchecked"

let assetCellIdentifier = "AssetCell"
let albumCellIdentifier = "AlbumCell"
let assetFooterViewIdentifier = "AssetFooterView"

public enum PhotoPickerMediaType {
    case Any
    case Image
    case Video
}

enum PhotoPickerOrientation {
    case Landscape
    case Portrait
}

struct AssetsNumberOfColumns {
    static let PortraitPhone: Int = 4
    static let PortraitPad: Int = 7
    static let LandscapePhone: Int = 7
    static let LandscapePad: Int = 12
}

var currentOrientation: PhotoPickerOrientation {
    get {
        var orientation: PhotoPickerOrientation = .Portrait
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            orientation = .Portrait
        case .LandscapeLeft, .LandscapeRight:
            orientation = .Landscape
        }
        return orientation
    }
}

var currentDevice: UIUserInterfaceIdiom {
    get {
        return UIDevice.currentDevice().userInterfaceIdiom
    }
}