//
//  NameViewController.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit
import LogWrapperKit

class NameViewController: UIViewController {
	
	@IBOutlet weak var fieldsVerticalSpacingConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var logoImageView: UIImageView!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var nextButton: UIButton!
	@IBOutlet weak var welcomeLabel: UILabel!
	
	var firstLoad: Bool = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		logoImageView.image = BluyChat.imageOfBluyChat()
		self.navigationController?.viewControllers = [self]
		navigationItem.setHidesBackButton(true, animated: false)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		dismissKeyboardOnTap = true
//		displaceOnKeyboard = true
		
		guard firstLoad else {
			return
		}
		log(debug: "view.frame.height = \(view.frame.height)")
		welcomeLabel.alpha = 0.0
		fieldsVerticalSpacingConstraint.constant = view.frame.height
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		dismissKeyboardOnTap = false
		displaceOnKeyboard = false
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		guard firstLoad else {
			return
		}
		firstLoad = false
		DispatchQueue.main.async {
			UIView.animate(withDuration: 1.0, animations: {
				self.welcomeLabel.alpha = 1.0
			}, completion: { (completed) in
				self.fieldsVerticalSpacingConstraint.constant = 8
				UIView.animate(withDuration: 0.3) {
					self.view.layoutIfNeeded()
				}
			})
		}
	}
	
	@IBAction func editingDidChange(_ sender: Any) {
		guard let text = nameTextField.text else {
			nextButton.isEnabled = false
			return
		}
		nextButton.isEnabled = !text.trimmed.isEmpty
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard segue.identifier == "Segue.Avator" else {
			return
		}
		guard let destination = segue.destination as? AvatarCollectionViewController else {
			return
		}
		destination.userName = nameTextField.text?.trimmed
	}
}
