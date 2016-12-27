//
//  AssetsViewController.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/26.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit
import Photos
import PhotoBrowser

class AssetsViewController: UICollectionViewController {
    
    //MARK: - public property
    weak var photoPickerController: PhotoPickerController!
    var selectedAssets: [PHAsset] = [] {
        didSet {
            updateHighQualityImageSize()
        }
    }
    
    var assetCollection: PHAssetCollection! {
        didSet {
            self.updateFetchRequest()
        }
    }
    
    //MARK: - private property
    fileprivate let imageManager: PHCachingImageManager = PHCachingImageManager()
    fileprivate var previousPreheatRect: CGRect = CGRect.zero
    fileprivate var assetsFetchResults: PHFetchResult<PHAsset>!
    fileprivate var lastSelectItemIndexPath: IndexPath?
    fileprivate var toolbarNumberView: ToolBarNumberView!
    fileprivate var toolbarHighQualityButton: ToolBarHighQualityButton!
    fileprivate var sendBarItem: UIBarButtonItem!
    fileprivate var selectedIndexPaths: [IndexPath] = []
    fileprivate var isFirstLoading: Bool = true
    fileprivate weak var photoBrowserHighQualityButton: ToolBarHighQualityButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.layoutIfNeeded()
        view.layoutIfNeeded()
        setupCancelButton()
        setupToolBar()
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = assetCollection.localizedTitle
        navigationItem.prompt = photoPickerController.prompt
        
        collectionView?.allowsMultipleSelection = photoPickerController.allowMultipleSelection
        collectionView?.reloadData()

        if assetsFetchResults.count > 0 && isMovingToParentViewController {
            let indexPath = IndexPath(item: assetsFetchResults.count - 1, section: 0)
            collectionView?.layoutIfNeeded()
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCachedAssets()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let collectionView = collectionView else { return }
        collectionViewLayout.invalidateLayout()
        if let indexPath = collectionView.indexPathsForVisibleItems.last {
            coordinator.animate(alongsideTransition: nil, completion: { (context) -> Void in
               collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
            })
        }
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
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsFetchResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AssetCell = collectionView.dequeueReusableCell(withReuseIdentifier: assetCellIdentifier, for: indexPath) as! AssetCell
        fillCell(cell, forIndexPath: indexPath)
        cell.addCheckHandler { [weak self](checked) -> Bool in
            guard let weakSelf = self , weakSelf.shouldSelectItemAtIndexPath(indexPath, checked: checked) else { return false }
            if !checked {
                weakSelf.selectItemAtIndexPath(indexPath)
            } else {
                weakSelf.deselectItemAtIndexPath(indexPath, uncheckCell: false)
            }
            return true
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let footerView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: assetFooterViewIdentifier, for: indexPath)
            let numberOfPhotos = assetsFetchResults.countOfAssets(with: .image)
            let numberOfVideos = assetsFetchResults.countOfAssets(with: .video)
            
            if let label = footerView.viewWithTag(100) as? UILabel {
                label.text = "\(numberOfPhotos) \(localizedString["PhotoPicker.Photos"]!) , \(numberOfVideos) \(localizedString["PhotoPicker.Videos"]!)"
            }
            return footerView
        }
        return UICollectionReusableView()
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if photoPickerController.allowMultipleSelection {
            let photoBrowser = PhotoBrowser()
            photoBrowser.currentIndex = indexPath.item
            // set isFrom PhotoPicker
            photoBrowser.isFromPhotoPicker = true
            photoBrowser.selectedIndex = selectedIndexPaths.map { return $0.item }
            // action
            let highQualityButton = ToolBarHighQualityButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 21.0)))
            highQualityButton.assetsViewController = self
            highQualityButton.checked = self.toolbarHighQualityButton.checked
            if highQualityButton.checked {
                highQualityButton.highqualityImageSize = self.getImageSize(at: photoBrowser.currentIndex)
            }
            highQualityButton.action = { (checked) in
                self.toolbarHighQualityButton.checked = checked
                if checked {
                    highQualityButton.highqualityImageSize = self.getImageSize(at: photoBrowser.currentIndex)
                }
            }
            photoBrowserHighQualityButton = highQualityButton
            let barItem = UIBarButtonItem(customView: highQualityButton)
            let actionItem = PBActionBarItem(barButtonItem: barItem)
            let middleEmptyItem = PBActionBarItem(title: "", style: .plain)
            let rightEmptyItem = PBActionBarItem(title: "", style: .plain)
            photoBrowser.actionItems = [actionItem, middleEmptyItem, rightEmptyItem]

            // configuration
            let indexSet = IndexSet(integersIn: 0..<assetsFetchResults.count)
            let assets = assetsFetchResults.objects(at: indexSet)
            photoBrowser.assets = assets
            photoBrowser.setCurrentIndex(to: indexPath.item)
            photoBrowser.photoBrowserDelegate = self
            self.present(photoBrowser, animated: true, completion: nil)
        } else {
            let asset = assetsFetchResults[indexPath.item]
            photoPickerController.delegate?.photoPickerController(photoPickerController, didFinishPickingAssets: [asset], needHighQualityImage: true)
        }
    }
}

//MARK: - response method
extension AssetsViewController {
    func sendButtonTapped() {
        guard selectedAssets.count > 0 else { return }
        photoPickerController.delegate?.photoPickerController(photoPickerController, didFinishPickingAssets: selectedAssets, needHighQualityImage: toolbarHighQualityButton.checked)
    }
    
    func cancelButtonTapped(_ sender: UIBarButtonItem) {
        photoPickerController.delegate?.photoPickerControllerDidCancel(photoPickerController)
    }

    func photoBrowserOriginButtonTapped() {
        print("wtf")
    }
}

//MARK: - UI help method
extension AssetsViewController {
    func setupCancelButton() {
        let cancel = UIBarButtonItem(title: localizedString["PhotoPicker.Cancel"], style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = cancel
    }

    func setupToolBar() {
        guard photoPickerController.allowMultipleSelection else { return }
        toolbarNumberView = ToolBarNumberView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 21.0, height: 21.0)))
        toolbarHighQualityButton = ToolBarHighQualityButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 21.0)))
        toolbarHighQualityButton.assetsViewController = self
        
        sendBarItem = UIBarButtonItem(title: localizedString["PhotoPicker.Send"], style: .plain, target: self, action: #selector(AssetsViewController.sendButtonTapped))
        sendBarItem.isEnabled = false
        let highqualityBarItem = UIBarButtonItem(customView: toolbarHighQualityButton)
        let numberBarItem = UIBarButtonItem(customView: toolbarNumberView)
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [highqualityBarItem, leftSpace, numberBarItem, sendBarItem]
        
        navigationController?.toolbar.tintColor = toolBarTintColor
        navigationController?.setToolbarHidden(false, animated: true)
    }

    func toggleHighQualityButtonHidden(_ hidden: Bool) {
        toolbarHighQualityButton.isHidden = hidden
    }
    
    func updateToolBar() {
        guard photoPickerController.allowMultipleSelection else { return }
        sendBarItem.isEnabled = (selectedAssets.count != 0)
        toolbarNumberView.number = selectedAssets.count
    }
    
    func updateHighQualityImageSize() {
        guard toolbarHighQualityButton.checked else { return }
        var size: Int = 0
        selectedAssets.forEach { (asset) -> () in
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { (imageData, dataUTI, orientation, info) -> Void in
                if let data = imageData {
                    size += data.count
                }
            })
        }
        self.toolbarHighQualityButton.highqualityImageSize = size
    }

    func getImageSize(at index: Int) -> Int {
        var size: Int = 0
        let asset = assetsFetchResults[index]
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { (imageData, dataUTI, orientation, info) -> Void in
            if let data = imageData {
                size += data.count
            }
        })
        return size
    }

    func isVideoAsset(_ indexPath: IndexPath?) -> Bool {
        guard let `indexPath` = indexPath else { return false }
        return assetsFetchResults[indexPath.item].mediaType == .video
    }

    func showVideoSelectAlert() {
        guard !photoPickerController.hasShowVideoAlert else { return }
        let alertController = UIAlertController(title: nil, message: localizedString["PhotoPicker.VideoSelect.Alert"] ?? "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: localizedString["PhotoPicker.OK"], style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        photoPickerController.hasShowVideoAlert = true
    }
}

//MARK: - collection view help method
extension AssetsViewController {
    func fillCell(_ cell: AssetCell, forIndexPath indexPath: IndexPath) {
        cell.tag = indexPath.item
        
        let asset = assetsFetchResults[indexPath.item]
        let itemSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        let targetSize = itemSize.scale(traitCollection.displayScale)
        cell.overlayView.isHidden = !photoPickerController.allowMultipleSelection
        
        imageManager.requestImage(for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: nil) { (image, info) -> Void in
                guard let image = image , cell.tag == indexPath.item else { return }
                cell.imageView.image = image
        }
        
        if asset.mediaType == .video {
            cell.videoIndicatorView.isHidden = false
            
            let minutes = Int(asset.duration / 60.0)
            let seconds = Int(ceil(asset.duration - 60.0 * Double(minutes)))
            cell.videoIndicatorView.timeLabel.text = String(format: "%02ld:%02ld", minutes, seconds)
            
            if asset.mediaSubtypes == .videoHighFrameRate {
                cell.showSlomoIcon()
            } else {
                cell.showVideoIcon()
            }
        } else {
            cell.videoIndicatorView.isHidden = true
        }
        cell.setChecked(selectedIndexPaths.contains(indexPath), animation: false)
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
        let alertController = UIAlertController(title: nil, message: String(format: localizedString["PhotoPicker.MaximumNumberOfSelection.Alert"]!, maximumNumberOfSelection), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: localizedString["PhotoPicker.Cancel"], style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        if let presentedViewController = navigationController?.presentedViewController {
            presentedViewController.present(alertController, animated: true, completion: nil)
        } else {
            navigationController?.present(alertController, animated: true, completion: nil)
        }
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
        case .image:
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        case .video:
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        default:
            break
        }
        
        assetsFetchResults = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
    }
    
    func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }
    
    func updateCachedAssets() {
        guard isViewLoaded, let _ = view.window, let collectionView = self.collectionView else { return }
        
        // The preheat window is twice the height of the visible rect.
        var preheatRect = collectionView.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
        
        /*
        Check if the collection view is showing an area that is significantly
        different to the last preheated area.
        */
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        
        if delta > (collectionView.bounds.height / 3.0) {
            var addedIndexPaths: [IndexPath] = []
            var removedIndexPaths: [IndexPath] = []
            
            computeDifferenceBetweenRect(previousPreheatRect, andRect: preheatRect,
                removedHandler: { (removedRect) -> Void in
                    guard let indexPaths = collectionView.pp_indexPathsForElementsInRect(removedRect) else { return }
                    removedIndexPaths.append(contentsOf: indexPaths)
                }, addedHandler: { (addedRect) -> Void in
                    guard let indexPaths = collectionView.pp_indexPathsForElementsInRect(addedRect) else { return }
                    addedIndexPaths.append(contentsOf: indexPaths)
            })
            
            let itemSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
            let targetSize = itemSize.scale(traitCollection.displayScale)
            
            if let assetsToStartCaching = assetsAtIndexPaths(addedIndexPaths) {
                imageManager.startCachingImages(for: assetsToStartCaching,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: nil)
            }
            
            if let assetsToStopCaching = assetsAtIndexPaths(removedIndexPaths) {
                imageManager.stopCachingImages(for: assetsToStopCaching,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: nil)
            }
            
            previousPreheatRect = preheatRect
        }
        
    }
    
    func computeDifferenceBetweenRect(_ oldRect: CGRect, andRect newRect: CGRect, removedHandler: (_ removedRect: CGRect) -> Void, addedHandler: (_ addedRect: CGRect) -> Void) {
        if oldRect.intersects(newRect) {
            let oldMaxY = oldRect.maxY
            let oldMinY = oldRect.minY
            let newMaxY = newRect.maxY
            let newMinY = newRect.minY
            
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
            
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height: (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height: (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset]? {
        guard indexPaths.count > 0 else { return nil }
        
        var assets: [PHAsset] = []
        for indexPath in indexPaths {
            guard indexPath.item < assetsFetchResults.count else { break }
            let asset: PHAsset = assetsFetchResults[indexPath.item]
            assets.append(asset)
        }
        
        return assets
    }
}

extension AssetsViewController {
    func clearSelectedCell(at indexPath: IndexPath) {
        selectedIndexPaths.forEach({ (selectIndexPath) in
            if selectIndexPath != indexPath {
                deselectItemAtIndexPath(selectIndexPath, uncheckCell: true)
            }
        })
        selectedIndexPaths.removeAll()
    }

    func selectItemAtIndexPath(_ indexPath: IndexPath) {
        
        let asset = assetsFetchResults[indexPath.item]
        
        if photoPickerController.allowMultipleSelection {
            if isAutoDeselectEnable() && selectedAssets.count > 0 {
                if let lastSelectItemIndexPath = lastSelectItemIndexPath {
                    deselectItemAtIndexPath(lastSelectItemIndexPath, uncheckCell: true)
                }
            }
            
            if asset.mediaType == .video {
                clearSelectedCell(at: indexPath)
                toggleHighQualityButtonHidden(true)
                showVideoSelectAlert()
            } else if isVideoAsset(lastSelectItemIndexPath) {
                clearSelectedCell(at: indexPath)
                toggleHighQualityButtonHidden(false)
            } else {
                toggleHighQualityButtonHidden(false)
            }
            
            selectedAssets.append(asset)
            selectedIndexPaths.append(indexPath)
            lastSelectItemIndexPath = indexPath
            updateToolBar()
        } else {
            photoPickerController.delegate?.photoPickerController(photoPickerController, didFinishPickingAssets: [asset], needHighQualityImage: true)
        }
        
        photoPickerController.delegate?.photoPickerController(photoPickerController, didSelectAsset: asset)
    }

    func deselectItemAtIndexPath(_ indexPath: IndexPath, uncheckCell: Bool) {
        guard photoPickerController.allowMultipleSelection else { return }
        let asset = assetsFetchResults[indexPath.item]
        if let index = selectedAssets.index(of: asset) {
            selectedAssets.remove(at: index)
            selectedIndexPaths.remove(at: index)
            lastSelectItemIndexPath = nil
            
            updateToolBar()
            photoPickerController.delegate?.photoPickerController(photoPickerController, didDeselectAsset: asset)
            if let cell = collectionView?.cellForItem(at: indexPath) as? AssetCell , uncheckCell {
                cell.setChecked(false, animation: true)
            }
        }
    }
    
    func shouldSelectItemAtIndexPath(_ indexPath: IndexPath, checked: Bool) -> Bool {
        if checked {
            return true
        }
        let asset = assetsFetchResults[indexPath.item]
        if let shouldSelectAsset = photoPickerController.delegate?.photoPickerController(photoPickerController, shouldSelectAsset: asset) {
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
}

//MARK: - UICollectionViewDelegateFlowLayout
extension AssetsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var numberOfColumns: Int = 0
        switch (currentDevice, currentOrientation) {
        case (.phone, .landscape):
            numberOfColumns = AssetsNumberOfColumns.LandscapePhone
        case (.phone, .portrait):
            numberOfColumns = AssetsNumberOfColumns.PortraitPhone
        case (.pad, .landscape):
            numberOfColumns = AssetsNumberOfColumns.LandscapePad
        case (.pad, .portrait):
            numberOfColumns = AssetsNumberOfColumns.PortraitPad
        default:
            numberOfColumns = AssetsNumberOfColumns.LandscapePhone
        }

        let containerViewWidth = photoPickerController.view.frame.width
        let width: CGFloat = floor((containerViewWidth - 2.0 * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns))
        return CGSize(width: width, height: width)
    }
}

extension AssetsViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let collectionChanges = changeInstance.changeDetails(for: self.assetsFetchResults as! PHFetchResult<PHObject>) else { return }
        
        DispatchQueue.main.async { [weak self]() -> Void in
            guard let strongSelf = self else { return }
            strongSelf.assetsFetchResults = collectionChanges.fetchResultAfterChanges as! PHFetchResult<PHAsset>
            
            if collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                strongSelf.collectionView?.reloadData()
            } else {
                strongSelf.collectionView?.performBatchUpdates({ () -> Void in
                    if let removedIndexes = collectionChanges.removedIndexes , removedIndexes.count > 0 {
                        strongSelf.collectionView?.deleteItems(at: removedIndexes.pp_indexPathsFromIndexesInSection(0))
                    }
                    
                    if let insertedIndexes = collectionChanges.insertedIndexes , insertedIndexes.count > 0 {
                        strongSelf.collectionView?.insertItems(at: insertedIndexes.pp_indexPathsFromIndexesInSection(0))
                    }
                    
                    if let changedIndexes = collectionChanges.changedIndexes , changedIndexes.count > 0 {
                        strongSelf.collectionView?.reloadItems(at: changedIndexes.pp_indexPathsFromIndexesInSection(0))
                    }
                    }, completion: nil)
            }
            
            strongSelf.resetCachedAssets()
        }
    }
}

extension AssetsViewController: PhotoBrowserDelegate {
    func photoBrowser(_ browser: PhotoBrowser, canSelectPhotoAtIndex index: Int) -> Bool {
        let indexPath = IndexPath(item: index, section: 0)
        let checked = selectedIndexPaths.contains(indexPath)
        return shouldSelectItemAtIndexPath(indexPath, checked: checked)
    }

    func photoBrowser(_ browser: PhotoBrowser, didSelectPhotoAtIndex index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        let checked = selectedIndexPaths.contains(indexPath)
        if !checked {
            selectItemAtIndexPath(indexPath)
        } else {
            deselectItemAtIndexPath(indexPath, uncheckCell: true)
        }
    }

    func photoBrowser(_ browser: PhotoBrowser, didShowPhotoAtIndex index: Int) {
        if let button = photoBrowserHighQualityButton, button.checked {
            button.highqualityImageSize = getImageSize(at: index)
        }
    }
}
