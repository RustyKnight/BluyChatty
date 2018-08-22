//
//  PillButton.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit

@IBDesignable
class PillButton: UIButton {

	@IBInspectable var outlineColor: UIColor? {
		didSet {
			applyOutline()
		}
	}
	
	override var isEnabled: Bool {
		didSet {
			applyEnabledState(animated: true)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configure()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		configure()
	}
	
	func configure() {
		isOpaque = true
		layer.cornerRadius = frame.size.height / 2.0
		clipsToBounds = true
		tintColor = nil
		applyOutline()
		applyEnabledState(animated: false)
		
		setNeedsDisplay()
	}
	
	func applyOutline() {
		defer {
			setNeedsDisplay()
		}
		guard let outlineColor = outlineColor else {
			layer.borderColor = nil
			layer.borderWidth = 0.0
			return
		}
		layer.borderColor = outlineColor.cgColor
		layer.borderWidth = 1.0
	}
	
	func applyEnabledState(animated: Bool) {
		var targetColor = backgroundColor?.withAlphaComponent(0.0)
		if isEnabled {
				targetColor = backgroundColor?.withAlphaComponent(1.0)
		}
		
		if animated {
			UIView.animate(withDuration: 0.3) {
				self.backgroundColor = targetColor
			}
		} else {
			backgroundColor = targetColor
		}
	}
	
}
