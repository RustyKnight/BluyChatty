//
//  UserCollectionViewCell.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var avatarLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	
	func configure(with chatClient: ChatClient) {
		avatarLabel.text = chatClient.avatar
		nameLabel.text = chatClient.displayName
	}
	
	var isHeightCalculated: Bool = false
	
	override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		//Exhibit A - We need to cache our calculation to prevent a crash.
		if !isHeightCalculated {
			setNeedsLayout()
			layoutIfNeeded()
			let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
			var newFrame = layoutAttributes.frame
//			let frameSize = max(size.width, size.height)
			newFrame.size.width = CGFloat(ceilf(Float(size.width)))
//			newFrame.size.height = frameSize
			layoutAttributes.frame = newFrame
			isHeightCalculated = true
		}
		return layoutAttributes
	}

}
