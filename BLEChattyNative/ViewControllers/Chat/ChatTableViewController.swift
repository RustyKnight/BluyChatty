//
//  ChatTableViewController.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController {
	
	var keyboardHelper: KeyboardHelper = KeyboardHelper()
	
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
		// #warning Incomplete implementation, return the number of rows
		return 100
	}
	

	open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
		cell.textLabel?.text = "Test \(indexPath.row)"
		return cell
	}
	
//	open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//		guard let view = super.tableView(tableView, viewForFooterInSection: section) else {
//			return nil
//		}
//		view.transform = CGAffineTransform(scaleX: 1, y: -1)
//		return view
//	}
//
//	open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//		guard let view = super.tableView(tableView, viewForHeaderInSection: section) else {
//			return nil
//		}
//		view.transform = CGAffineTransform(scaleX: 1, y: -1)
//		return view
//	}
	
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
	
//	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		tableView.deselectRow(at: indexPath, animated: false)
//	}
	
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
//		guard let duration = event.duration, let curve = event.curve else {
//			self.updateMessageEntryPosition()
//			return
//		}
//		UIView.animate(withDuration: duration, delay: 0, options: [curve], animations: {
//			self.updateMessageEntryPosition()
//			self.view.layoutIfNeeded()
//		}) { (completed) in
//		}
	}
	
	func keyboardWillHide(with event: KeyboardEvent) {
		keyboardStateChanged(with: event)
	}
	
	func keyboardWillShow(with event: KeyboardEvent) {
		keyboardStateChanged(with: event)
	}

}
