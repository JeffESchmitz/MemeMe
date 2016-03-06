//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Jeff Schmitz on 1/28/16.
//  Copyright © 2016 Jeff Schmitz. All rights reserved.
//

import UIKit
import Foundation

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, ChooseFontViewProtocol
{
	@IBOutlet weak var imagePickerView: UIImageView!
	@IBOutlet weak var albumButton: UIBarButtonItem!
	@IBOutlet weak var cameraButton: UIBarButtonItem!
	@IBOutlet weak var topText: UITextField!
	@IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
	let memeTextAttributes = [
		NSStrokeColorAttributeName : UIColor.blackColor(),
		NSForegroundColorAttributeName : UIColor.whiteColor(),
		NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
		NSStrokeWidthAttributeName : -3.0
	]
    
    var memes: [Meme]!
    var meme: Meme!
    var editedMemeIndex: Int?
	let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)

	// MARK: UIViewController delegate methods
	override func viewDidLoad() {
		super.viewDidLoad()

        setTextFieldProperties(topText, displayText: "TOP")
        setTextFieldProperties(bottomText, displayText: "BOTTOM")
        
        memes = appDelegate.memes
    }

    func setTextFieldProperties(textField: UITextField!, displayText: String?) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
        textField.text = displayText
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

        if meme != nil {
            imagePickerView.image = meme.image
            topText.text = meme.topText
            bottomText.text = meme.bottomText
        }

        shareButton.enabled = imagePickerView.image != nil
        cancelButton.enabled = imagePickerView.image != nil
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
		subscribeToKeyboardNotifications()
		UIApplication.sharedApplication().statusBarHidden = true
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		unsubscribeFromKeyboardNotifications()
	}
    
	@IBAction func pickImageFromAlbum(sender: AnyObject) {
        pickImage(UIImagePickerControllerSourceType.PhotoLibrary)
	}

	@IBAction func pickImageFromCamera(sender: AnyObject) {
		pickImage(UIImagePickerControllerSourceType.Camera)
	}

	func pickImage(sourceType: UIImagePickerControllerSourceType) {
		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self
		imagePickerController.sourceType = sourceType
		presentViewController(imagePickerController, animated: true, completion: nil)
	}

	@IBAction func shareMeme(sender: AnyObject) {
		let memeImage = generateMemedImage()

		let activityController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)

		activityController.completionWithItemsHandler = {
			(activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) -> Void in
			if completed {
				self.save(memeImage)
				self.dismissViewControllerAnimated(true, completion: nil)
			}
		}

		presentViewController(activityController, animated: true, completion: nil)
	}

    @IBAction func cancelMeme(sender: AnyObject) {
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        imagePickerView.image = nil
        cancelButton.enabled = false
        shareButton.enabled = false

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
	// MARK: UIImagePickerControllerDelegate methods
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		// Conditionally unwrapping the info dictionary
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			imagePickerView.image = image
			dismissViewControllerAnimated(true, completion: nil)
		}
	}

	func imagePickerControllerDidCancel(picker : UIImagePickerController) {
		dismissViewControllerAnimated(true, completion : nil)
	}

    
	// MARK: UITextFieldDelegate methods
	func textFieldDidBeginEditing(textField: UITextField) {
		switch textField.text! {
		case "TOP", "BOTTOM":
			textField.text = ""
		default:
			break
		}
	}
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            switch textField.tag {
            case 1:
                textField.text = "TOP"
                break
            case 2:
                textField.text = "BOTTOM"
                break
            default:
                break
            }
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

    // subscribe (wire-up) this viewcontroller to keyboard notifications.
	func subscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}

    // unsubscribes from notifications so when view disappears, notifications are no longer subscribed to this viewcontroller.
	func unsubscribeFromKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}

	func keyboardWillShow(notification: NSNotification) {
		if bottomText.isFirstResponder() {
            toolBar.hidden = true
            let keyboardHeight = (getKeyboardHeight(notification) - 40) * -1
            view.frame.origin.y = keyboardHeight
		}
	}

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.CGRectValue().height
	}
	
    func keyboardWillHide(notification: NSNotification) {
		if bottomText.isFirstResponder() {
            toolBar.hidden = false
			view.frame.origin.y = 0
		}
	}

	func save(memedImage: UIImage) {
		guard let pickerImage = imagePickerView.image else {
			print("No picker image selected. Picker image view needs an image to save.")
			return
		}

		let meme = Meme(topText: topText.text, bottomText: bottomText.text, image: pickerImage, memedImage: memedImage)

		// Add or edit existing meme to the memes array in the Application Delegate
		if editedMemeIndex != nil {
            appDelegate.memes[editedMemeIndex!] = meme
        } else {
            appDelegate.memes.append(meme)
        }
	}

	func generateMemedImage() -> UIImage {
        toggleNavigationBarsVisibility(true)

		// Take a snapshot of the screen's memedImage
		UIGraphicsBeginImageContext(view.frame.size)
		view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
		let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

        toggleNavigationBarsVisibility(false)

		return memedImage
	}

	func toggleNavigationBarsVisibility(visible: Bool) {
		navigationController?.setNavigationBarHidden(visible, animated: true)
        toolBar.hidden = visible;
        
	}
    
    // MARK: ChooseFontViewProtocol delegate method
    func selectedFont(font: String) {
        topText.font = UIFont(name: font, size: 40)
        bottomText.font = UIFont(name: font, size: 40)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let chooseFontController = segue.destinationViewController as! ChooseFontViewController
        chooseFontController.chooseFontViewDelegate = self
    }
}
