//
//  AssetsViewController.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/26.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit
import Photos

class AssetsViewController: UICollectionViewController {
    
    //MARK: - public property
    var photoPickerController: PhotoPickerController!
    var selectedAssets: [PHAsset] = []
    
    var assetCollection: PHAssetCollection! {
        didSet {
            self.updateFetchRequest()
        }
    }
    
    //MARK: - private property
    private let imageManager: PHCachingImageManager = PHCachingImageManager()
    private var previousPreheatRect: CGRect = CGRectZero
    private var assetsFetchResults: PHFetchResult!
    private var lastSelectItemIndexPath: NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedAssets()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = assetCollection.localizedTitle
        navigationItem.prompt = photoPickerController.prompt
        
        collectionView?.allowsMultipleSelection = photoPickerController.allowMultipleSelection
        
        collectionView?.reloadData()
        
        if assetsFetchResults.count > 0 && isMovingToParentViewController() {
            let indexPath = NSIndexPath(forItem: assetsFetchResults.count - 1, inSection: 0)
            collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCachedAssets()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsFetchResults.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: AssetCell = collectionView.dequeueReusableCellWithReuseIdentifier(assetCellIdentifier, forIndexPath: indexPath) as! AssetCell
        fillCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let footerView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: assetFooterViewIdentifier, forIndexPath: indexPath)
            let numberOfPhotos = assetsFetchResults.countOfAssetsWithMediaType(.Image)
            
            if let label = footerView.viewWithTag(100) as? UILabel {
                if numberOfPhotos == 1 {
                    label.text = "1 Photo"
                } else {
                    label.text = "\(numberOfPhotos) Photos"
                }
            }
            return footerView
        }
        return UICollectionReusableView()
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let asset = assetsFetchResults[indexPath.item] as? PHAsset else { return }
        
        if photoPickerController.allowMultipleSelection {
            if isAutoDeselectEnable() && selectedAssets.count > 0 {
                selectedAssets.removeAtIndex(0)
                if let lastSelectItemIndexPath = lastSelectItemIndexPath {
                    collectionView.deselectItemAtIndexPath(lastSelectItemIndexPath, animated: false)
                }
            }
            
            selectedAssets.append(asset)
            lastSelectItemIndexPath = indexPath
        } else {
            photoPickerController.delegate?.photoPickerController(photoPickerController, didFinishPickingAssets: selectedAssets)
        }
        
        photoPickerController.delegate?.photoPickerController(photoPickerController, didSelectAsset: asset)
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        guard photoPickerController.allowMultipleSelection, let asset = assetsFetchResults[indexPath.item] as? PHAsset else { return }
        
        if let index = selectedAssets.indexOf(asset) {
            selectedAssets.removeAtIndex(index)
            lastSelectItemIndexPath = nil
            
            photoPickerController.delegate?.photoPickerController(photoPickerController, didDeselectAsset: asset)
        }
    }

    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if let asset = assetsFetchResults[indexPath.item] as? PHAsset, let shouldSelectAsset = photoPickerController.delegate?.photoPickerController(photoPickerController, shouldSelectAsset: asset) {
            guard shouldSelectAsset else { return false }
            if isAutoDeselectEnable() {
                return true
            }
            
            if isMaximumSelectionReached() {
                showMaximumSelectionReachedAlert()
                return false
            }
            return true
        } else {
            return false
        }
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}

//MARK: - collection view help method
extension AssetsViewController {
    func fillCell(cell: AssetCell, forIndexPath indexPath: NSIndexPath) {
        cell.tag = indexPath.item
        
        let asset = assetsFetchResults[indexPath.item] as! PHAsset
        let itemSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        let targetSize = itemSize.scale(traitCollection.displayScale)
        
        imageManager.requestImageForAsset(asset,
            targetSize: targetSize,
            contentMode: .AspectFill,
            options: nil) { (image, info) -> Void in
                guard let image = image where cell.tag == indexPath.item else { return }
                cell.imageView.image = image
        }
    }
    
    func isMaximumSelectionReached() -> Bool {
        let minimumNumberOfSelection = max(1, photoPickerController.minimumNumberOfSelection)
        
        if minimumNumberOfSelection <= photoPickerController.maximumNumberOfSelection {
            return photoPickerController.maximumNumberOfSelection <= selectedAssets.count
        } else {
            return false
        }
    }
    
    func isMinimumSelectionFullfilled() -> Bool {
        return photoPickerController.minimumNumberOfSelection <= selectedAssets.count
    }
    
    func isAutoDeselectEnable() -> Bool {
        return photoPickerController.maximumNumberOfSelection == 1 && photoPickerController.maximumNumberOfSelection >= photoPickerController.minimumNumberOfSelection
    }
    
    func showMaximumSelectionReachedAlert() {
        let maximumNumberOfSelection = photoPickerController.maximumNumberOfSelection
        let alertController = UIAlertController(title: nil, message: "最多选择\(maximumNumberOfSelection)张照片", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        navigationController?.presentViewController(alertController, animated: true, completion: nil)
    }
}

//MARK: - asset help method
extension AssetsViewController {
    
    func updateFetchRequest() {
        guard let assetCollection = assetCollection else {
            assetsFetchResults = nil
            return
        }
        
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
        
        assetsFetchResults = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: fetchOptions)
    }
    
    func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRectZero
    }
    
    func updateCachedAssets() {
        guard isViewLoaded(), let _ = view.window, let collectionView = self.collectionView else { return }
        
        // The preheat window is twice the height of the visible rect.
        var preheatRect = collectionView.bounds
        preheatRect = CGRectInset(preheatRect, 0.0, -0.5 * CGRectGetHeight(preheatRect))
        
        /*
        Check if the collection view is showing an area that is significantly
        different to the last preheated area.
        */
        let delta = abs(CGRectGetMidY(preheatRect) - CGRectGetMidY(previousPreheatRect))
        
        if delta > (CGRectGetHeight(collectionView.bounds) / 3.0) {
            var addedIndexPaths: [NSIndexPath] = []
            var removedIndexPaths: [NSIndexPath] = []
            
            computeDifferenceBetweenRect(previousPreheatRect, andRect: preheatRect,
                removedHandler: { (removedRect) -> Void in
                    guard let indexPaths = collectionView.pp_indexPathsForElementsInRect(removedRect) else { return }
                    removedIndexPaths.appendContentsOf(indexPaths)
                }, addedHandler: { (addedRect) -> Void in
                    guard let indexPaths = collectionView.pp_indexPathsForElementsInRect(addedRect) else { return }
                    addedIndexPaths.appendContentsOf(indexPaths)
            })
            
            let itemSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
            let targetSize = itemSize.scale(traitCollection.displayScale)
            
            if let assetsToStartCaching = assetsAtIndexPaths(addedIndexPaths) {
                imageManager.startCachingImagesForAssets(assetsToStartCaching,
                    targetSize: targetSize,
                    contentMode: .AspectFill,
                    options: nil)
            }
            
            if let assetsToStopCaching = assetsAtIndexPaths(removedIndexPaths) {
                imageManager.stopCachingImagesForAssets(assetsToStopCaching,
                    targetSize: targetSize,
                    contentMode: .AspectFill,
                    options: nil)
            }
            
            previousPreheatRect = preheatRect
        }
        
    }
    
    func computeDifferenceBetweenRect(oldRect: CGRect, andRect newRect: CGRect, removedHandler: (removedRect: CGRect) -> Void, addedHandler: (addedRect: CGRect) -> Void) {
        if CGRectIntersectsRect(oldRect, newRect) {
            let oldMaxY = CGRectGetMaxY(oldRect)
            let oldMinY = CGRectGetMinY(oldRect)
            let newMaxY = CGRectGetMaxY(newRect)
            let newMinY = CGRectGetMinY(newRect)
            
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                addedHandler(addedRect: rectToAdd)
            }
            
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                addedHandler(addedRect: rectToAdd)
            }
            
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height: (oldMaxY - newMaxY))
                removedHandler(removedRect: rectToRemove)
            }
            
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height: (newMinY - oldMinY))
                removedHandler(removedRect: rectToRemove)
            }
        } else {
            addedHandler(addedRect: newRect)
            removedHandler(removedRect: oldRect)
        }
    }
    
    func assetsAtIndexPaths(indexPaths: [NSIndexPath]) -> [PHAsset]? {
        guard indexPaths.count > 0 else { return nil }
        
        var assets: [PHAsset] = []
        for indexPath in indexPaths {
            guard indexPath.item < assetsFetchResults.count else { break }
            let asset: PHAsset = assetsFetchResults[indexPath.item] as! PHAsset
            assets.append(asset)
        }
        
        return assets
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension AssetsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var numberOfColumns: Int = 0
        switch (currentDevice, currentOrientation) {
        case (.Phone, .Landscape):
            numberOfColumns = AssetsNumberOfColumns.LandscapePhone
        case (.Phone, .Portrait):
            numberOfColumns = AssetsNumberOfColumns.PortraitPhone
        case (.Pad, .Landscape):
            numberOfColumns = AssetsNumberOfColumns.LandscapePad
        case (.Pad, .Portrait):
            numberOfColumns = AssetsNumberOfColumns.PortraitPad
        default:
            numberOfColumns = AssetsNumberOfColumns.LandscapePhone
        }
        
        let width: CGFloat = (CGRectGetWidth(view.frame) - 2.0 * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns)
        
        return CGSize(width: width, height: width)
    }
}
