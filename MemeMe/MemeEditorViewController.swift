//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Jeff Schmitz on 1/28/16.
//  Copyright © 2016 Jeff Schmitz. All rights reserved.
//

import UIKit
import Foundation

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate
{

	@IBOutlet weak var imagePickerView: UIImageView!
	@IBOutlet weak var albumButton: UIBarButtonItem!
	@IBOutlet weak var cameraButton: UIBarButtonItem!
	@IBOutlet weak var topText: UITextField!
	@IBOutlet weak var bottomText: UITextField!

	let memeTextAttributes = [
		NSStrokeColorAttributeName : UIColor.blackColor(),
		NSForegroundColorAttributeName : UIColor.whiteColor(),
		NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
		NSStrokeWidthAttributeName : -3.0
	]

	// MARK: UIViewController delegate methods
	override func viewDidLoad() {
		super.viewDidLoad()

		topText.delegate = self
		topText.defaultTextAttributes = memeTextAttributes
		topText.textAlignment = .Center
		topText.text = "TOP"

		bottomText.delegate = self
		bottomText.defaultTextAttributes = memeTextAttributes
		bottomText.textAlignment = .Center
		bottomText.text = "BOTTOM"
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

    @IBAction func shareMeme(sender: AnyObject) {

        let memeImage = generateMemedImage()

        let activityController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)

        activityController.completionWithItemsHandler = {
            (activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError:NSError?) -> Void in
            if completed {
                self.save(memeImage)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }

        self.presentViewController(activityController, animated: true, completion: nil)
    }

	// MARK: UIImagePickerControllerDelegate methods
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

		// Conditionally unwrapping the info dictionary
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			imagePickerView.image = image
			self.dismissViewControllerAnimated(true, completion: nil)
		}
	}

    func imagePickerControllerDidCancel(picker : UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion : nil)
    }


	// MARK: UITextFieldDelegate methods
	func textFieldDidBeginEditing(textField: UITextField) {
		switch textField.text! {
		case "TOP", "BOTTOM":
			textField.text = ""
		default:
			break;
		}
	}

	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newText: NSString = textField.text!
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        return true
    }


	func subscribeToKeyboardNotifications() {
		NSNotificationCenter
			.defaultCenter()
			.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)

		NSNotificationCenter
			.defaultCenter()
			.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}

	func unsubscribeFromKeyboardNotifications() {
		NSNotificationCenter
			.defaultCenter()
			.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)

		NSNotificationCenter
			.defaultCenter()
			.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}

    func keyboardWillShow(notification: NSNotification) {
        if bottomText.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
	}

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.CGRectValue().height
	}

    func keyboardWillHide(notification: NSNotification) {
        if bottomText.isFirstResponder() {
            self.view.frame.origin.y = 0
        }
	}

	func save(memedImage: UIImage) {
        
        guard let pickerImage = imagePickerView.image else {
            print("No picker image selected. Picker image view needs an image to save.")
            return
        }
        
		let meme = Meme(topText: topText.text, bottomText: bottomText.text, image: pickerImage, memedImage: memedImage)

		// Add it to the memes array in the Application Delegate
		(UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
	}

	func generateMemedImage() -> UIImage {

		hideNavigationBars()

		// Take a snapshot of the screen's memedImage
		UIGraphicsBeginImageContext(self.view.frame.size)
		self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
		let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		showNavigationBars()

		return memedImage
	}

	func showNavigationBars() {
		toggleNavigationBarsVisibility(false)
	}

	func hideNavigationBars() {
		toggleNavigationBarsVisibility(true)
	}

	private func toggleNavigationBarsVisibility(visible: Bool) {
		navigationController?.setNavigationBarHidden(visible, animated: true)
		navigationController?.setToolbarHidden(visible, animated: true)
	}
}
