//
//  MessageViewController.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit
import LogWrapperKit

class MessageViewController: UIViewController {
	
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var messageTextField: UITextField!
	@IBOutlet weak var sendButton: UIButton!
	
	var keyboardHelper: KeyboardHelper = KeyboardHelper()
	
	var currentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	
	var delegate: MessageDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		dismissKeyboardOnTap = false
		keyboardHelper.delegate = self
		keyboardHelper.isInstalled = true
		bottomConstraint.constant = currentInsets.bottom + 8
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		keyboardHelper.isInstalled = false
		keyboardHelper.delegate = nil
	}

	@IBAction func sendMessage(_ sender: Any) {
		log(debug: "")
		guard let text = messageTextField.text, !text.trimmed.isEmpty else {
			return
		}
		messageTextField.text = nil
		delegate?.send(message: text)
	}
}

extension MessageViewController: KeyboardHelperDelegate {

	func changeBottomConstraintTo(_ constant: CGFloat, with event: KeyboardEvent) {
		guard let duration = event.duration, let curve = event.curve else {
			bottomConstraint.constant = constant
			return
		}
		self.bottomConstraint.constant = constant
		UIView.animate(withDuration: duration, delay: 0, options: [curve], animations: {
			self.view.layoutIfNeeded()
		}) { (completed) in
		}
	}
	
	func keyboardWillShow(with event: KeyboardEvent) {
		changeBottomConstraintTo(8, with: event)
	}
	
	func keyboardWillHide(with event: KeyboardEvent) {
		changeBottomConstraintTo(currentInsets.bottom + 8, with: event)
	}
	
}
