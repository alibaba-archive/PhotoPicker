//
//  AlbumsViewController.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/25.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit
import Photos

class AlbumsViewController: UITableViewController {
    
    //MARK: - public property
    weak var photoPickerController: PhotoPickerController!
    
    //MARK: - private property
    fileprivate var fetchedResults: [PHFetchResult<PHAssetCollection>] = []
    fileprivate var assetCollections: [PHAssetCollection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCancelButton()
        tableView.rowHeight = 86.0
        loadAlbums()
        PHPhotoLibrary.shared().register(self)
    
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = localizedString["PhotoPicker.Title"]
        navigationItem.prompt = photoPickerController.prompt
        
        navigationController?.setToolbarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetCollections.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: albumCellIdentifier, for: indexPath) as! AlbumCell
        fillCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let assetsViewController = segue.destination as? AssetsViewController {
            assetsViewController.photoPickerController = photoPickerController
            assetsViewController.assetCollection = assetCollections[tableView.indexPathForSelectedRow!.row]
        }
    }
}

//MARK: - response method
extension AlbumsViewController {
    func cancelButtonTapped(_ sender: UIBarButtonItem) {
        photoPickerController.delegate?.photoPickerControllerDidCancel(photoPickerController)
    }
}

//MARK: - help method
extension AlbumsViewController {

    func setupCancelButton() {
        let cancel = UIBarButtonItem(title: localizedString["PhotoPicker.Cancel"], style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = cancel
    }

    func loadAlbums() {
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        fetchedResults = [smartAlbums, userAlbums]
        
        processAlbums()
    }
    
    func processAlbums() {
        assetCollections.removeAll()
        
        guard let assetCollectionsSubTypes = self.photoPickerController.assetCollectionSubtypes else { return }
        
        let smartAlbums = fetchedResults[0]
        let userAlbums = fetchedResults[1]
        smartAlbums.enumerateObjects(options: .concurrent) { [weak self] (assetCollection, index, stop) in
            if assetCollectionsSubTypes.contains(assetCollection.assetCollectionSubtype) {
                self?.assetCollections.append(assetCollection)
            }
        }

        userAlbums.enumerateObjects(options: .concurrent) {  [weak self] (assetCollection, index, stop) in
            if assetCollectionsSubTypes.contains(assetCollection.assetCollectionSubtype) {
                self?.assetCollections.append(assetCollection)
            }
        }
    }
    
    func fillCell(_ cell: AlbumCell, forIndexPath indexPath: IndexPath) {
        cell.tag = indexPath.row
        cell.borderWidth = 1.0 / traitCollection.displayScale
        
        let assetCollection = assetCollections[indexPath.row]
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        switch photoPickerController.mediaType {
        case .image:
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        case .video:
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        default:
            break
        }
        
        let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        let imageManager = PHImageManager.default()
        
        if fetchResult.count >= 3 {
            cell.albumCover3.isHidden = false
            imageManager.requestImage(for: fetchResult[fetchResult.count - 3],
                targetSize: cell.albumCover3.frame.size.scale(traitCollection.displayScale),
                contentMode: .aspectFill,
                options: nil,
                resultHandler: { (image, info) -> Void in
                    guard let image = image, cell.tag == indexPath.row else { return }
                    cell.albumCover3.image = image
            })
        } else {
            cell.albumCover3.isHidden = true
        }
        
        if fetchResult.count >= 2 {
            cell.albumCover2.isHidden = false
            imageManager.requestImage(for: fetchResult[fetchResult.count - 2],
                targetSize: cell.albumCover2.frame.size.scale(traitCollection.displayScale),
                contentMode: .aspectFill,
                options: nil,
                resultHandler: { (image, info) -> Void in
                    guard let image = image, cell.tag == indexPath.row else { return }
                    cell.albumCover2.image = image
            })
        } else {
            cell.albumCover2.isHidden = true
        }
        
        if fetchResult.count >= 1 {
            imageManager.requestImage(for: fetchResult[fetchResult.count - 1],
                targetSize: cell.albumCover1.frame.size.scale(traitCollection.displayScale),
                contentMode: .aspectFill,
                options: nil,
                resultHandler: { (image, info) -> Void in
                    guard let image = image, cell.tag == indexPath.row else { return }
                    cell.albumCover1.image = image
            })
        }
        
        if fetchResult.count == 0 {
            cell.albumCover3.isHidden = false
            cell.albumCover2.isHidden = false
            
            let placeholderImage = UIImage(named: "EmptyPlaceholder", in: currentBundle, compatibleWith: nil)
            cell.albumCover1.image = placeholderImage
            cell.albumCover2.image = placeholderImage
            cell.albumCover3.image = placeholderImage
        }
        
        cell.titleLabel.text = assetCollection.localizedTitle
        cell.countLabel.text = "\(fetchResult.count)"
    }
}

extension AlbumsViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [unowned self]() -> Void in
            var changedFetchResult = self.fetchedResults
            
            for (index, fetchResult) in self.fetchedResults.enumerated() {
                guard let changeDetails = changeInstance.changeDetails(for: fetchResult) else { continue }
                changedFetchResult[index] = changeDetails.fetchResultAfterChanges
            }
            
            if self.fetchedResults != changedFetchResult {
                self.fetchedResults = changedFetchResult
                
                self.processAlbums()
                self.tableView.reloadData()
            }
        }
    }
}
