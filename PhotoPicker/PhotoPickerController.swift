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
    var hasShowVideoAlert: Bool = false
    
    //MARK: - private property
    fileprivate var albumsNavigationController: UINavigationController!
    
    public init(localizedStrings: [String: String]) {
        super.init(nibName:nil, bundle:nil)
        
        self.assetCollectionSubtypes = [.smartAlbumUserLibrary,
                                        .smartAlbumFavorites,
                                        .albumMyPhotoStream,
                                        .albumCloudShared,
                                        .albumRegular]
        
        setupAlbumsViewController()
        localizedString = localizedStrings
        
        let albumsViewController = albumsNavigationController.topViewController as! AlbumsViewController
        albumsViewController.photoPickerController = self
    }
    
    func setupAlbumsViewController() {
        let storyboard = UIStoryboard(name: "PhotoPicker", bundle: currentBundle)
        let navigationController: UINavigationController = storyboard.instantiateViewController(withIdentifier: "AlbumsNavigationController") as! UINavigationController
        
        addChildViewController(navigationController)
        navigationController.view.frame = view.bounds
        view.addSubview(navigationController.view)
        navigationController.didMove(toParentViewController: self)
        
        albumsNavigationController = navigationController
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
