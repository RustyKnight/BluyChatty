//
//  UIViewController+HideKeyboard.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit
import Cadmus

extension UIViewController {
	
	@objc func hideKeyboard() {
		UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
	}
	
}
