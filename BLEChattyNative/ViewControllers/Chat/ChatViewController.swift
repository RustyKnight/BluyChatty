//
//  ChatViewController.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit
import LogWrapperKit

class ChatViewController: UIViewController {
	
	var messageViewController: MessageViewController!
	var chatTableViewController: ChatTableViewController!

	var currentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		dismissKeyboardOnTap = true
		displaceOnKeyboard = true
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		let bounds = messageViewController.view.bounds
//		let leftOver = bounds.height - currentInsets.bottom
//
//		log(debug: "Left over = \(leftOver)")
//
//		chatTableViewController.tableView.contentInset.top = leftOver + 8
//
//		DispatchQueue.global(qos: .userInitiated).async {
//			Thread.sleep(forTimeInterval: 1.0)
//			DispatchQueue.main.async {
//				self.chatTableViewController.scrollToBottom(animated: true, then: {
//					log(debug: "Done")
//				})
//			}
//		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		dismissKeyboardOnTap = false
		displaceOnKeyboard = false
	}
	
	private var isFirstLayout = true
	private var layoutPass = 0;

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		// 😓 Okay, so, apparently, the "safe" areas aren't populated till
		// the layout pass, but the size of the messaging area doesn't seem
		// to be set (properly) until the second layout pass
		// So we can't use willAppear to offset the table view and viewDidAppear
		// causes a visual change which is not pleasent, so we jump through some
		// hoops to make this work
		guard isFirstLayout else {
			return
		}
		layoutPass += 1
		guard layoutPass > 1 else {
			return
		}
		// Not sure this is really needed, but...
		isFirstLayout = false;
		let bounds = messageViewController.view.bounds
		let leftOver = bounds.height - currentInsets.bottom

		chatTableViewController.tableView.contentInset.top = leftOver
		chatTableViewController.scrollToTop(animated: false)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destination = segue.destination
		if segue.identifier == "Segue.message" {
			destination.view.translatesAutoresizingMaskIntoConstraints = false
			guard let controller = destination as? MessageViewController else {
				return
			}
			messageViewController = controller
			messageViewController.currentInsets = currentInsets
		} else if segue.identifier == "Segue.conversation" {
			guard let controller = destination as? ChatTableViewController else {
				return
			}
			chatTableViewController = controller
		}
	}
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destination.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
