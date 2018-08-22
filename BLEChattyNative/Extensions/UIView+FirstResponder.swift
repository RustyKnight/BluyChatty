//
//  UIView+FirstResponder.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
	
	var firstResponder: UIView? {
		guard !isFirstResponder else {
			return self
		}
		for view in subviews {
			guard let responder = view.firstResponder else {
				continue
			}
			return responder
		}
		return nil
	}
	
}

