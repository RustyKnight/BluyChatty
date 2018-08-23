//
//  UIResponder+CurrentResponder.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 24/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit

private var firstResponderRef: UIResponder? = nil

extension UIResponder {
	static var currentResponder: UIResponder? {
		get {
			firstResponderRef = nil
			// The trick here is, that the selector will be invoked on the first responder
			UIApplication.shared.sendAction(#selector(setFirstResponderRef), to: nil, from: nil, for: nil)
			return firstResponderRef
		}
	}
	
	@objc private func setFirstResponderRef() {
		firstResponderRef = self
	}
}
