//
//  ChatTableViewController.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit
import LogWrapperKit

class ChatTableViewController: UITableViewController {
	
	var keyboardHelper: KeyboardHelper = KeyboardHelper()
	var messages: [Message] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
		if #available(iOS 11.0, *) {
			tableView.contentInsetAdjustmentBehavior = .never
		} else {
			var insets = tableView.contentInset
			insets.top = 0
			tableView.contentInset = insets
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		keyboardHelper.delegate = self
		keyboardHelper.isInstalled = true
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		keyboardHelper.isInstalled = false
		keyboardHelper.delegate = nil
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		log(debug: "messages.count = \(messages.count)")
		return messages.count
	}
	

	open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let message = messages[indexPath.row]
		log(debug: "...")
		if message.direction == .outgoing {
			log(debug: "outgoing")
			let identifier = "Cell.outgoing"
			guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? OutgoingMessageTableViewCell else {
				fatalError("You screwed up")
			}
			cell.configure(with: message)
			cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
			return cell
		} else if message.direction == .incoming {
			log(debug: "incoming")
			let identifier = "Cell.incoming"
			guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? IncomingMessageTableViewCell else {
				fatalError("You screwed up")
			}
			cell.configure(with: message)
			cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
			return cell
		}
		fatalError("You screwed up")
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.00001
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.00001
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView(frame: CGRect.zero)
	}
	
	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return UIView(frame: CGRect.zero)
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
	// MARK: - Scroll Support
	
	public var isAtTop: Bool {
		let yPos = abs(tableView.contentOffset.y)
		return yPos == tableView.contentInset.top
	}
	
	public var isAtBottom: Bool {
		let height = tableView.frame.size.height
		let yOffset = abs(tableView.contentOffset.y)
		let distanceFromBottom = tableView.contentSize.height - yOffset
		return distanceFromBottom < height
	}

	public typealias AfterScrollAnimationCompleted = () -> Void
	internal var afterScroll: AfterScrollAnimationCompleted?

	public func scrollToTop(animated: Bool = true, then: AfterScrollAnimationCompleted? = nil) {
		guard !isAtTop else {
			guard let then = then else {
				return
			}
			then()
			return
		}
		afterScroll = then
		let offset = CGPoint(x: 0, y: -tableView.contentInset.top)
		tableView.setContentOffset(offset, animated: animated)
		guard !animated else {
			return
		}
		afterScroll = nil
		guard let then = then else {
			return
		}
		then()
	}
	
	public func scrollToBottom(animated: Bool = true, then: AfterScrollAnimationCompleted? = nil) {
		guard !isAtBottom else {
			guard let then = then else {
				return
			}
			then()
			return
		}
		afterScroll = then
		
		let bottomOffSet = CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.size.height)
		tableView.setContentOffset(bottomOffSet, animated: animated)
		guard !animated else {
			return
		}
		afterScroll = nil
		guard let then = then else {
			return
		}
		then()
	}
	
	override open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		guard let afterScroll = afterScroll else {
			return
		}
		self.afterScroll = nil
		afterScroll()
	}

}

// MARK: - KeyboardHelperDelegate

extension ChatTableViewController: KeyboardHelperDelegate {
	
	func keyboardStateChanged(with event: KeyboardEvent) {
		//...Change insets/offsets?
	}
	
	func keyboardWillHide(with event: KeyboardEvent) {
		keyboardStateChanged(with: event)
	}
	
	func keyboardWillShow(with event: KeyboardEvent) {
		keyboardStateChanged(with: event)
	}

}

extension ChatTableViewController {
	
	func add(_ message: Message) {
		messages.insert(message, at: 0)
		let indicies = [IndexPath(row: 0, section: 0)]
		tableView.insertRows(at: indicies, with: .automatic)
	}
	
	func update(_ message: Message) {
		guard let index = indexOf(message) else {
			return
		}
		messages[index] = message
		let indicies = [IndexPath(row: index, section: 0)]
		tableView.reloadRows(at: indicies, with: .fade)
	}
	
	func indexOf(_ message: Message) -> Int? {
		return messages.firstIndex(where: { $0.text == message.text && $0.direction == message.direction })
	}
}
