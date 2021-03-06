//
//  IncomingMessageTableViewCell.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 23/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit

class IncomingMessageTableViewCell: UITableViewCell {
	
	@IBOutlet var messageLabel: UILabel!
	@IBOutlet var messageBackground: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		messageBackground.backgroundColor = UIColor.lightGray
		messageBackground.layer.cornerRadius = 16
		messageLabel.backgroundColor = nil
		messageLabel.isOpaque = false
		
	}
	
	func configure(with message: Message) {
		messageLabel.text = message.text
	}
	
}
