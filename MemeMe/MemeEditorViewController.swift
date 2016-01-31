//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Jeff Schmitz on 1/28/16.
//  Copyright © 2016 Jeff Schmitz. All rights reserved.
//

import UIKit
import Foundation

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

	@IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : 3.0
    ]

    // MARK: UIViewController delegate methods
	override func viewDidLoad() {
		super.viewDidLoad()
        
        topText.delegate = self
        topText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = .Center
        topText.text = "TOP"
        
        bottomText.textAlignment = .Center
        bottomText.text = "BOTTOM"
        bottomText.delegate = self 
        bottomText.defaultTextAttributes = memeTextAttributes
	}
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
	@IBAction func pickImageFromAlbum(sender: AnyObject) {
		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self
		imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		self.presentViewController(imagePickerController, animated: true, completion: nil)
	}

	@IBAction func pickImageFromCamera(sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePickerController, animated: true, completion: nil)
	}

	// MARK: UIImagePickerControllerDelegate methods
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        // Conditionally unwrapping the info dictionary
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
        }
	}

    // MARK: UITextFieldDelegate methods
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
	func imagePickerControllerDidCancel(picker : UIImagePickerController) {

		self.dismissViewControllerAnimated(true, completion : nil)
	}
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter
            .defaultCenter()
            .removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}



