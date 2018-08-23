//
//  UIViewController+DismissKeyboard.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit

// I'm not a fan of this, but this will allow us to maintain state beyond the capabailities of the the extension API
fileprivate var cache = NSMapTable<UIViewController, UITapGestureRecognizer>(keyOptions: .weakMemory, valueOptions: .weakMemory)

extension UIViewController {
	
	fileprivate var tapRecognizer: UITapGestureRecognizer? {
		return cache.object(forKey: self)
	}
	
	fileprivate var isInstalled: Bool {
		return tapRecognizer != nil
	}
	
	var dismissKeyboardOnTap: Bool {
		set {
			if newValue {
				guard !isInstalled else {
					return
				}
				let recognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardLater))
				recognizer.cancelsTouchesInView = false
				view.addGestureRecognizer(recognizer)
				
				cache.setObject(recognizer, forKey: self)
			} else {
				guard let recognizer = tapRecognizer else {
					return
				}
				view.removeGestureRecognizer(recognizer)
				cache.removeObject(forKey: self)
			}
		}
		
		get {
			guard cache.object(forKey: self) != nil else {
				return false
			}
			return true
		}
	}
	
	@objc private func hideKeyboardLater() {
		DispatchQueue.main.async {
			self.hideKeyboard()
		}
	}
	
}
