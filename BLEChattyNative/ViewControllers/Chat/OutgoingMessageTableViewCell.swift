//
//  OutgoingMessageTableViewCell.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 23/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit
import LogWrapperKit

class OutgoingMessageTableViewCell: UITableViewCell {
	
	let animator: DurationAnimator = DurationAnimator(duration: 1.0)
	
	@IBOutlet var messageLabel: UILabel!
	@IBOutlet var messageBackground: UIView!
	@IBOutlet var messageStatusImageView: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
		
		messageBackground.backgroundColor = Theme.outgoingMessageBackground
		messageBackground.layer.cornerRadius = 16
		messageLabel.backgroundColor = nil
		messageLabel.isOpaque = false
		
		messageStatusImageView.alpha = 0
		messageStatusImageView.isHidden = true
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
//		stopAnimation()
	}
	
	func stopAnimation() {
		animator.stop()
		animator.delegate = nil
	}
	
	func startAnimation() {
		animator.delegate = self
		animator.start()
	}
	
	func hideImageView() {
		guard !messageStatusImageView.isHidden else {
			return
		}
		UIView.animate(withDuration: 0.3, animations: {
			self.messageStatusImageView.alpha = 0
		}) { (completed) in
			self.messageStatusImageView.isHidden = true
		}
	}
	
	func showImageView() {
		guard messageStatusImageView.isHidden else {
			return
		}
		UIView.animate(withDuration: 0.3, animations: {
			self.messageStatusImageView.alpha = 1
		}) { (completed) in
			self.messageStatusImageView.isHidden = false
		}
	}

	func configure(with message: Message) {
		messageStatusImageView.backgroundColor = nil
		messageLabel.text = message.text
		switch message.status {
		case .delivered:
			stopAnimation()
			hideImageView()
		case .sending:
			startAnimation()
			messageStatusImageView.image = BluyChat.imageOfSendingIndicator()
			showImageView()
		case .failed:
			stopAnimation()
			messageStatusImageView.image = BluyChat.imageOfSendingFailed
			showImageView()
		}
	}
	
}

extension OutgoingMessageTableViewCell: DurationAnimatorDelegate {
	
	func didTick(animation: DurationAnimator, progress: Double) {
		messageStatusImageView.image = BluyChat.imageOfSendingIndicator(tickProgress: CGFloat(progress))
	}
	
	func didComplete(animation: DurationAnimator, completed: Bool) {
		guard completed else {
			return
		}
		startAnimation()
	}
	
	
}

