//
//  UICollectionView+BackgroundMessage.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
	
	func setEmptyMessage(_ message: String) {
		let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
		messageLabel.text = message
		messageLabel.numberOfLines = 0;
		messageLabel.textAlignment = .center;
		messageLabel.font = UIFont(name: "TrebuchetMS", size: 24)
		messageLabel.sizeToFit()
		messageLabel.textColor = Theme.foreground
		
		self.backgroundView = messageLabel;
	}
	
	func restore() {
		self.backgroundView = nil
	}
}
