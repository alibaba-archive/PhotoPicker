//
//  PhotoPickerController.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/25.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit
import Photos

public class PhotoPickerController: UIViewController {
    
    //MARK: - public property
    public weak var delegate: PhotoPickerDelegate?
    public var assetCollectionSubtypes: [PHAssetCollectionSubtype]?
    public var allowMultipleSelection: Bool = true
    public var minimumNumberOfSelection: Int = 1
    public var maximumNumberOfSelection: Int = 9
    public var mediaType: PhotoPickerMediaType = .Any
    public var prompt: String?
    var hasShowVideoAlert: Bool = false
    
    //MARK: - private property
    private var albumsNavigationController: UINavigationController!
    
    public init(localizedStrings: [String: String]) {
        super.init(nibName:nil, bundle:nil)
        
        self.assetCollectionSubtypes = [.SmartAlbumUserLibrary,
                                        .SmartAlbumFavorites,
                                        .AlbumMyPhotoStream,
                                        .AlbumCloudShared,
                                        .AlbumRegular]
        
        setupAlbumsViewController()
        localizedString = localizedStrings
        
        let albumsViewController = albumsNavigationController.topViewController as! AlbumsViewController
        albumsViewController.photoPickerController = self
    }
    
    func setupAlbumsViewController() {
        let storyboard = UIStoryboard(name: "PhotoPicker", bundle: currentBundle)
        let navigationController: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("AlbumsNavigationController") as! UINavigationController
        
        addChildViewController(navigationController)
        navigationController.view.frame = view.bounds
        view.addSubview(navigationController.view)
        navigationController.didMoveToParentViewController(self)
        
        albumsNavigationController = navigationController
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
