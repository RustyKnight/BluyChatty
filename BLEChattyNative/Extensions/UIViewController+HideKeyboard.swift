//
//  UIViewController+HideKeyboard.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
	
	@objc func hideKeyboard() {
		view.endEditing(true)
	}
	
}
