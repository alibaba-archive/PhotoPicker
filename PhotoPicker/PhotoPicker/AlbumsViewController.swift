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
    var photoPickerController: PhotoPickerController!
    
    //MARK: - private property
    private var fetchedResults: [PHFetchResult] = []
    private var assetCollections: [PHAssetCollection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 86.0
        loadAlbums()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Photo"
        navigationItem.prompt = photoPickerController.prompt
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetCollections.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(albumCellIdentifier, forIndexPath: indexPath) as! AlbumCell
        fillCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let assetsViewController = segue.destinationViewController as? AssetsViewController {
            assetsViewController.photoPickerController = photoPickerController
            assetsViewController.assetCollection = assetCollections[tableView.indexPathForSelectedRow!.row]
        }
    }
}

//MARK: - help method
extension AlbumsViewController {
    func loadAlbums() {
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .Any, options: nil)
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil)
        fetchedResults = [smartAlbums, userAlbums]
        
        processAlbums()
    }
    
    func processAlbums() {
        assetCollections.removeAll()
        
        guard let assetCollectionsSubTypes = self.photoPickerController.assetCollectionSubtypes else { return }
        
        let smartAlbums = fetchedResults[0]
        let userAlbums = fetchedResults[1]
        
        smartAlbums.enumerateObjectsUsingBlock { [unowned self](assetCollection, index, stop) -> Void in
            guard let assetCollection = assetCollection as? PHAssetCollection else { return }
            if assetCollectionsSubTypes.contains(assetCollection.assetCollectionSubtype) {
                self.assetCollections.append(assetCollection)
            }
        }
        
        userAlbums.enumerateObjectsUsingBlock { (assetCollection, index, stop) -> Void in
            guard let assetCollection = assetCollection as? PHAssetCollection else { return }
            if assetCollectionsSubTypes.contains(assetCollection.assetCollectionSubtype) {
                self.assetCollections.append(assetCollection)
            }
        }
    }
    
    func fillCell(cell: AlbumCell, forIndexPath indexPath: NSIndexPath) {
        cell.tag = indexPath.row
        cell.borderWidth = 1.0 / traitCollection.displayScale
        
        let assetCollection = assetCollections[indexPath.row]
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        switch photoPickerController.mediaType {
        case .Image:
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.Image.rawValue)
        case .Video:
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.Video.rawValue)
        default:
            break
        }
        
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: fetchOptions)
        let imageManager = PHImageManager.defaultManager()
        
        if fetchResult.count >= 3 {
            cell.albumCover3.hidden = false
            imageManager.requestImageForAsset(fetchResult[fetchResult.count - 3] as! PHAsset,
                targetSize: cell.albumCover3.frame.size.scale(traitCollection.displayScale),
                contentMode: .AspectFill,
                options: nil,
                resultHandler: { (image, info) -> Void in
                    guard let image = image where cell.tag == indexPath.row else { return }
                    cell.albumCover3.image = image
            })
        } else {
            cell.albumCover3.hidden = true
        }
        
        if fetchResult.count >= 2 {
            cell.albumCover2.hidden = false
            imageManager.requestImageForAsset(fetchResult[fetchResult.count - 2] as! PHAsset,
                targetSize: cell.albumCover2.frame.size.scale(traitCollection.displayScale),
                contentMode: .AspectFill,
                options: nil,
                resultHandler: { (image, info) -> Void in
                    guard let image = image where cell.tag == indexPath.row else { return }
                    cell.albumCover2.image = image
            })
        } else {
            cell.albumCover2.hidden = true
        }
        
        if fetchResult.count >= 1 {
            imageManager.requestImageForAsset(fetchResult[fetchResult.count - 1] as! PHAsset,
                targetSize: cell.albumCover1.frame.size.scale(traitCollection.displayScale),
                contentMode: .AspectFill,
                options: nil,
                resultHandler: { (image, info) -> Void in
                    guard let image = image where cell.tag == indexPath.row else { return }
                    cell.albumCover1.image = image
            })
        }
        
        if fetchResult.count == 0 {
            cell.albumCover3.hidden = false
            cell.albumCover2.hidden = false
            
            let placeholderImage = UIImage(named: "EmptyPlaceholder", inBundle: currentBundle, compatibleWithTraitCollection: nil)
            cell.albumCover1.image = placeholderImage
            cell.albumCover2.image = placeholderImage
            cell.albumCover3.image = placeholderImage
        }
        
        cell.titleLabel.text = assetCollection.localizedTitle
        cell.countLabel.text = "\(fetchResult.count)"
    }
}
