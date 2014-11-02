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
    var collectionView: UICollectionView!
    var selectedEntity: ReactionDiffusionEntity?
    
    var fetchResults:[ReactionDiffusionEntity] = [ReactionDiffusionEntity]()
    {
        didSet
        {
            if let _collectionView = collectionView
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
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clearColor()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(ReactionDiffusionEntityRenderer.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
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
        collectionView.frame = view.bounds.rectByInsetting(dx: 20, dy: 20)
        
        collectionView.reloadData()
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
            if let _entity = reactionDiffusionEntity
            {
                label.text = _entity.model
            
                let thumbnail = UIImage(data: _entity.imageData as NSData)
            
                imageView.image = thumbnail
            }
        }
    }
}