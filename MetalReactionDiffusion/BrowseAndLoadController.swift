//
//  BrowseAndLoadController.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 01/11/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import UIKit

class BrowseAndLoadController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    var collectionViewWidget: UICollectionView!
    var selectedEntity: ReactionDiffusionEntity?
    let blurOverlay = UIVisualEffectView(effect: UIBlurEffect())
    let showDeleted = UISwitch(frame: CGRectZero)
    let showDeletedLabel = UILabel(frame: CGRectZero)
    
    var fetchResults:[ReactionDiffusionEntity] = [ReactionDiffusionEntity]()
    {
        didSet
        {
            if let _collectionView = collectionViewWidget
            {
                _collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad()
    {
        selectedEntity = nil
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumLineSpacing = 30
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionViewWidget = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        collectionViewWidget.backgroundColor = UIColor.clearColor()
        
        collectionViewWidget.delegate = self
        collectionViewWidget.dataSource = self
        collectionViewWidget.registerClass(ReactionDiffusionEntityRenderer.self, forCellWithReuseIdentifier: "Cell")
        collectionViewWidget.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        showDeleted.tintColor = UIColor.darkGrayColor()
        showDeletedLabel.text = "Show recently deleted"
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "longPressHandler")
        collectionViewWidget.addGestureRecognizer(longPress)
        
        view.addSubview(collectionViewWidget)
        view.addSubview(blurOverlay)
        view.addSubview(showDeleted)
        view.addSubview(showDeletedLabel)
    }
    
    var longPressTargetCell: UICollectionViewCell?
    
    func longPressHandler()
    {
        println("long press!")
        
        if let _longPressTargetCell = longPressTargetCell
        {
            let contextMenuController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: deleteItem)
            
            contextMenuController.addAction(deleteAction)
            
            if let popoverPresentationController = contextMenuController.popoverPresentationController
            {
                popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.Down
                popoverPresentationController.sourceRect = _longPressTargetCell.frame.rectByOffsetting(dx: collectionViewWidget.frame.origin.x, dy: collectionViewWidget.frame.origin.y - collectionViewWidget.contentOffset.y)
                popoverPresentationController.sourceView = view
                
                presentViewController(contextMenuController, animated: true, completion: nil)
            }
        }
    }
    
    func deleteItem(value: UIAlertAction!) -> Void
    {
        
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath)
    {
        println("touch down at \(indexPath)")
        
        longPressTargetCell = self.collectionView(collectionViewWidget, cellForItemAtIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return fetchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        selectedEntity = fetchResults[indexPath.item]
        
        if let _popoverPresentationController = popoverPresentationController
        {
            if let _delegate = _popoverPresentationController.delegate
            {
               _delegate.popoverPresentationControllerDidDismissPopover!(_popoverPresentationController)
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as ReactionDiffusionEntityRenderer
        
        cell.reactionDiffusionEntity = fetchResults[indexPath.item]
        
        return cell
    }
    
    override func viewDidLayoutSubviews()
    {
        collectionViewWidget.frame = view.bounds.rectByInsetting(dx: 10, dy: 10)
        
        blurOverlay.frame = CGRect(x: 0, y: view.frame.height - 40, width: view.frame.width, height: 40)

        let showDeletedOffset = (40.0 - showDeleted.frame.height) / 2
        showDeleted.frame = blurOverlay.frame.rectByInsetting(dx: showDeletedOffset, dy: showDeletedOffset)
        
        showDeletedLabel.frame = blurOverlay.frame.rectByInsetting(dx: showDeleted.frame.width + showDeletedOffset + 5, dy: 0)
        
        collectionViewWidget.reloadData()
    }
}


class ReactionDiffusionEntityRenderer: UICollectionViewCell
{
    let label = UILabel(frame: CGRectZero)
    let imageView = UIImageView(frame: CGRectZero)
    let blurOverlay = UIVisualEffectView(effect: UIBlurEffect())
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        
        label = UILabel(frame: CGRectZero)
        label.numberOfLines = 0
        label.frame = CGRect(x: 0, y: frame.height - 20, width: frame.width, height: 20)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.Center

        imageView.frame = bounds.rectByInsetting(dx: 0, dy: 0)
        
        blurOverlay.frame = CGRect(x: 0, y: frame.height - 20, width: frame.width, height: 20)
        
        contentView.addSubview(imageView)
        contentView.addSubview(blurOverlay)
        contentView.addSubview(label)
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 1
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var reactionDiffusionEntity: ReactionDiffusionEntity?
    {
        didSet
        {
            if let _reactionDiffusionEntity = reactionDiffusionEntity
            {
                label.text = _reactionDiffusionEntity.model
            
                let thumbnail = UIImage(data: _reactionDiffusionEntity.imageData as NSData)
            
                imageView.image = thumbnail
            }
        }
    }
}