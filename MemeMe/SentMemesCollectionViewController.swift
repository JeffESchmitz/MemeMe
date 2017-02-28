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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space: CGFloat = 2.0
        let width = (view.frame.size.width - (2 * space)) / 3.0
        let height = (view.frame.size.height - (2 * space)) / 5.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: width, height: height)
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationController?.setToolbarHidden(true, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView!.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SentMemeCollectionViewCell
        
        // Configure the cell
        let meme = appDelegate.memes[indexPath.row]
        
        cell.memeImageView.contentMode = .scaleAspectFit
        cell.memeImageView.clipsToBounds = true
        cell.memeImageView.image = meme.memedImage
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            highlightCell(indexPath, flag: true)
        } else {
            let detailController = storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
            detailController.editedMemeIndex = indexPath.row
            navigationController?.pushViewController(detailController, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        highlightCell(indexPath, flag: false)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        collectionView?.allowsMultipleSelection = editing
        navigationController?.setToolbarHidden(!editing, animated: true)
    }
    
    func highlightCell(_ indexPath: IndexPath, flag: Bool) {
        let cell = collectionView?.cellForItem(at: indexPath)
        
        if flag {
            cell?.contentView.backgroundColor = UIColor.red
        } else {
            cell?.contentView.backgroundColor = UIColor.clear
        }
    }
    
    // MARK: Collection group delete functionality taken from Ravi Shankar's blog - UICollectionViewDemo in Swift - http://rshankar.com/uicollectionview-demo-in-swift/
    @IBAction func deleteCells(_ sender: AnyObject) {
        if let indexpaths = collectionView?.indexPathsForSelectedItems {
            var memesToDeleteIndexes:[Int] = []
            for item in indexpaths {
                collectionView?.deselectItem(at: item, animated: true)
                memesToDeleteIndexes.append(item.item)
            }
            
            memesToDeleteIndexes.sort(by: >)

            for index in memesToDeleteIndexes {
               appDelegate.memes.remove(at: index)
            }
            
            collectionView?.deleteItems(at: indexpaths)
        }
    }
}
