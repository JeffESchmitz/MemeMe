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
		NSStrokeColorAttributeName : UIColor.black,
		NSForegroundColorAttributeName : UIColor.white,
		NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
		NSStrokeWidthAttributeName : -3.0
	] as [String : Any]
    
    var memes: [Meme]!
    var meme: Meme!
    var editedMemeIndex: Int?
	let appDelegate = (UIApplication.shared.delegate as! AppDelegate)

	// MARK: UIViewController delegate methods
	override func viewDidLoad() {
		super.viewDidLoad()

        setTextFieldProperties(topText, displayText: "TOP")
        setTextFieldProperties(bottomText, displayText: "BOTTOM")
        
        if meme != nil {
            imagePickerView.image = meme.image
            topText.text = meme.topText
            bottomText.text = meme.bottomText
        }
        
        memes = appDelegate.memes
    }

    func setTextFieldProperties(_ textField: UITextField!, displayText: String?) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.text = displayText
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)


        shareButton.isEnabled = imagePickerView.image != nil
        cancelButton.isEnabled = imagePickerView.image != nil
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
		subscribeToKeyboardNotifications()
		UIApplication.shared.isStatusBarHidden = true
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		unsubscribeFromKeyboardNotifications()
	}
    
	@IBAction func pickImageFromAlbum(_ sender: AnyObject) {
        pickImage(UIImagePickerControllerSourceType.photoLibrary)
	}

	@IBAction func pickImageFromCamera(_ sender: AnyObject) {
		pickImage(UIImagePickerControllerSourceType.camera)
	}

	func pickImage(_ sourceType: UIImagePickerControllerSourceType) {
		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self
		imagePickerController.sourceType = sourceType
		present(imagePickerController, animated: true, completion: nil)
	}

	@IBAction func shareMeme(_ sender: AnyObject) {
		let memeImage = generateMemedImage()

		let activityController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)

		activityController.completionWithItemsHandler = {
//			(activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) -> Void in
      (activityType, completed, returnedItems, activityError) in
			if completed {
				self.save(memeImage)
				self.dismiss(animated: true, completion: nil)
			}
		}
  
		present(activityController, animated: true, completion: nil)
	}

    @IBAction func cancelMeme(_ sender: AnyObject) {
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        imagePickerView.image = nil
        cancelButton.isEnabled = false
        shareButton.isEnabled = false

        dismiss(animated: true, completion: nil)
    }
    
    
	// MARK: UIImagePickerControllerDelegate methods
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		// Conditionally unwrapping the info dictionary
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			imagePickerView.image = image
			dismiss(animated: true, completion: nil)
		}
	}

	func imagePickerControllerDidCancel(_ picker : UIImagePickerController) {
		dismiss(animated: true, completion : nil)
	}

    
	// MARK: UITextFieldDelegate methods
	func textFieldDidBeginEditing(_ textField: UITextField) {
		switch textField.text! {
		case "TOP", "BOTTOM":
			textField.text = ""
		default:
			break
		}
	}
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		var newText: NSString = textField.text! as NSString
		newText = newText.replacingCharacters(in: range, with: string) as NSString
		return true
	}

    // subscribe (wire-up) this viewcontroller to keyboard notifications.
	func subscribeToKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}

    // unsubscribes from notifications so when view disappears, notifications are no longer subscribed to this viewcontroller.
	func unsubscribeFromKeyboardNotifications() {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}

	func keyboardWillShow(_ notification: Notification) {
		if bottomText.isFirstResponder {
            toolBar.isHidden = true
            let keyboardHeight = (getKeyboardHeight(notification) - 40) * -1
            view.frame.origin.y = keyboardHeight
		}
	}

    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.cgRectValue.height
	}
	
    func keyboardWillHide(_ notification: Notification) {
		if bottomText.isFirstResponder {
            toolBar.isHidden = false
			view.frame.origin.y = 0
		}
	}

	func save(_ memedImage: UIImage) {
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
		view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
		let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()

        toggleNavigationBarsVisibility(false)

		return memedImage
	}

	func toggleNavigationBarsVisibility(_ visible: Bool) {
		navigationController?.setNavigationBarHidden(visible, animated: true)
        toolBar.isHidden = visible;
        
	}
    
    // MARK: ChooseFontViewProtocol delegate method
    func selectedFont(_ font: String) {
        topText.font = UIFont(name: font, size: 40)
        bottomText.font = UIFont(name: font, size: 40)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chooseFontController = segue.destination as! ChooseFontViewController
        chooseFontController.chooseFontViewDelegate = self
    }
}
