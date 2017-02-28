//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Jeff Schmitz on 2/28/16.
//  Copyright © 2016 Jeff Schmitz. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var detailMemeImageView: UIImageView!
    
    fileprivate var meme : Meme!
    var editedMemeIndex: Int?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        meme = appDelegate.memes[editedMemeIndex!]
        detailMemeImageView!.image = meme.memedImage
    }
    
    @IBAction func editMemeButton(_ sender: AnyObject) {
        let memeEditorViewController = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        memeEditorViewController.meme = meme
        memeEditorViewController.editedMemeIndex = editedMemeIndex
        
        let navigationController = UINavigationController(rootViewController: memeEditorViewController)
        present(navigationController, animated: true, completion: nil)
    }


}
