//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Jeff Schmitz on 3/1/16.
//  Copyright © 2016 Jeff Schmitz. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeCollectionViewCell"

class SentMemesCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space: CGFloat = 2.0
        let width = (view.frame.size.width - (2 * space)) / 3.0
        let height = (view.frame.size.height - (2 * space)) / 5.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(width, height)
        
        navigationItem.leftBarButtonItem = editButtonItem()
        navigationController?.setToolbarHidden(true, animated: true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView!.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SentMemeCollectionViewCell
        
        // Configure the cell
        let meme = appDelegate.memes[indexPath.row]
        
        cell.memeImageView.contentMode = .ScaleAspectFit
        cell.memeImageView.clipsToBounds = true
        cell.memeImageView.image = meme.memedImage
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if editing {
            highlightCell(indexPath, flag: true)
        } else {
            let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
            detailController.meme = appDelegate.memes[indexPath.row]
            detailController.editedMemeIndex = indexPath.row
            navigationController?.pushViewController(detailController, animated: true)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        highlightCell(indexPath, flag: false)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView?.allowsMultipleSelection = editing
        navigationController?.setToolbarHidden(!editing, animated: true)
    }
    
    func highlightCell(indexPath: NSIndexPath, flag: Bool) {
        let cell = collectionView?.cellForItemAtIndexPath(indexPath)
        
        if flag {
            cell?.contentView.backgroundColor = UIColor.redColor()
        } else {
            cell?.contentView.backgroundColor = UIColor.clearColor()
        }
    }
    
    // MARK: Collection group delete functionality taken from Ravi Shankar's blog - UICollectionViewDemo in Swift - http://rshankar.com/uicollectionview-demo-in-swift/
    @IBAction func deleteCells(sender: AnyObject) {
        if let indexpaths = collectionView?.indexPathsForSelectedItems() {
            for item in indexpaths {
                collectionView?.deselectItemAtIndexPath(item, animated: true)
                appDelegate.memes.removeAtIndex(item.row)
            }
            collectionView?.deleteItemsAtIndexPaths(indexpaths)
        }
    }
    
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
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
