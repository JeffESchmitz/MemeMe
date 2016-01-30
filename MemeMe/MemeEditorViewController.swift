//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Jeff Schmitz on 1/28/16.
//  Copyright © 2016 Jeff Schmitz. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	@IBOutlet weak var imagePickerView: UIImageView!

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	@IBAction func pickImageFromAlbum(sender: AnyObject) {
		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self
		imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		self.presentViewController(imagePickerController, animated: true, completion: nil)
	}

	@IBAction func pickImageFromCamera(sender: AnyObject) {
	}

	// MARK: UIImagePickerControllerDelegate methods
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

		imagePickerView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	func imagePickerControllerDidCancel(picker : UIImagePickerController) {

		self.dismissViewControllerAnimated(true, completion : nil)
	}
}