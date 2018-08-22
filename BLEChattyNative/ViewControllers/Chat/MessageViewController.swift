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
	
	var currentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		bottomConstraint.constant = currentInsets.bottom + 8
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//		if #available(iOS 11, *) {
//			let insets = view.safeAreaInsets
//			log(debug: "inserts = \(insets)")
//			bottomConstraint.constant = insets.bottom + 8
//		}
	}

	@IBAction func sendMessage(_ sender: Any) {
	}
}
