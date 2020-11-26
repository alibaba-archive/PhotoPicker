//
//  PhotoPickerController.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/25.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit
import Photos

open class PhotoPickerController: UIViewController {
    
    //MARK: - public property
    open weak var delegate: PhotoPickerDelegate?
    open var assetCollectionSubtypes: [PHAssetCollectionSubtype]?
    open var allowMultipleSelection: Bool = true
    open var minimumNumberOfSelection: Int = 1
    open var maximumNumberOfSelection: Int = 9
    open var mediaType: PhotoPickerMediaType = .any
    open var prompt: String?
    
    //MARK: - private property
    fileprivate var albumsNavigationController: UINavigationController!
    
    public init(localizedStrings: [String: String], highQualityImageByDefault: Bool = false) {
        super.init(nibName:nil, bundle:nil)
        
        self.assetCollectionSubtypes = [.smartAlbumUserLibrary,
                                        .smartAlbumFavorites,
                                        .albumMyPhotoStream,
                                        .albumCloudShared,
                                        .albumRegular]

        if let color = PhotoPickerThemeManager.shared.themeColor {
            themeToolBarTintColor = color
            themeTextColor = color
        }
        setupAlbumsViewController()
        localizedString = localizedStrings
        
        let albumsViewController = albumsNavigationController.topViewController as! AlbumsViewController
        albumsViewController.photoPickerController = self
        albumsViewController.highQualityImageByDefault = highQualityImageByDefault
    }
    
    func setupAlbumsViewController() {
        let storyboard = UIStoryboard(name: "PhotoPicker", bundle: currentBundle)
        let navigationController: UINavigationController = storyboard.instantiateViewController(withIdentifier: "AlbumsNavigationController") as! UINavigationController
        
        addChild(navigationController)
        navigationController.view.frame = view.bounds
        view.addSubview(navigationController.view)
        navigationController.didMove(toParent: self)
        
        albumsNavigationController = navigationController
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func updatePhotoPickerTheme(themeColor: UIColor) {
        PhotoPickerThemeManager.shared.themeColor = themeColor
    }
}
