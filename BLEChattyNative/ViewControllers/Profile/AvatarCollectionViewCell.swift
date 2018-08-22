//
//  AvatarCollectionViewCell.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit

class AvatarCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var label: UILabel!
	
	var emoji: String? {
		didSet {
			label.text = emoji
		}
	}
	
	override var isSelected: Bool {
		didSet {
			if self.isSelected {
				self.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
				self.contentView.backgroundColor = Theme.dark
			} else {
				self.transform = CGAffineTransform.identity
				self.contentView.backgroundColor = UIColor.clear
			}
		}
	}
	
	var isHeightCalculated: Bool = false
	
	override func awakeFromNib() {
		super.awakeFromNib()
		layer.cornerRadius = 20
	}
	
	override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		//Exhibit A - We need to cache our calculation to prevent a crash.
		if !isHeightCalculated {
			setNeedsLayout()
			layoutIfNeeded()
			let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
			var newFrame = layoutAttributes.frame
			let frameSize = max(size.width, size.height)
			newFrame.size.width = frameSize//CGFloat(ceilf(Float(size.width)))
			newFrame.size.height = frameSize
			layoutAttributes.frame = newFrame
			isHeightCalculated = true
		}
		return layoutAttributes
	}
	
}
