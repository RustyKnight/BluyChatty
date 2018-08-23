//
//  KeyboadHelper.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 23/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit

struct KeyboardEvent {
	let beginingBounds: CGRect
	let endBounds: CGRect
	
	var yDelta: CGFloat {
		return endBounds.origin.y - beginingBounds.origin.y
	}
	
	let duration: Double?
	let curve: UIView.AnimationOptions?
}

protocol KeyboardHelperDelegate {
	func keyboardWillShow(with event: KeyboardEvent)
	func keyboardWillHide(with event: KeyboardEvent)
}

class KeyboardHelper {
	
	var delegate: KeyboardHelperDelegate? = nil
	
	private(set) var isKeyboardVisible: Bool = false
	private(set) var keyboardInfo: KeyboardEvent? = nil
	
	var isInstalled: Bool = false {
		didSet {
			if isInstalled {
				NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisplacerWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
				NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisplacerWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
			} else {
				NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
				NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
			}
		}
	}
	
	fileprivate func keyboardBounds(from notification: Notification, forKey key: String) -> CGRect? {
		guard let userInfo = notification.userInfo else {
			return nil
		}
		guard let keyboardHeight = userInfo[key] as? CGRect else {
			return nil
		}
		return keyboardHeight
	}
	
	fileprivate func keyboardEndBounds(from notification: Notification) -> CGRect? {
		return keyboardBounds(from: notification, forKey: UIResponder.keyboardFrameEndUserInfoKey)
	}
	
	fileprivate func keyboardBeginingBounds(from notification: Notification) -> CGRect? {
		return keyboardBounds(from: notification, forKey: UIResponder.keyboardFrameBeginUserInfoKey)
	}
	
	fileprivate func keyboardEvent(from notification: Notification) -> KeyboardEvent? {
		guard let userInfo = notification.userInfo else {
			return nil
		}
		guard let endBounds = keyboardEndBounds(from: notification) else {
			return nil
		}
		guard let beginingBounds = keyboardBeginingBounds(from: notification) else {
			return nil
		}
		let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
		var curve: UIView.AnimationOptions? = nil
		if let value = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
			curve = UIView.AnimationOptions(rawValue: value)
		}
		
		return KeyboardEvent(beginingBounds: beginingBounds, endBounds: endBounds, duration: duration, curve: curve)
	}
	
	@objc func keyboardDisplacerWillShow(_ notification: Notification) {
		guard !isKeyboardVisible else {
			return
		}
		isKeyboardVisible = true
		guard let event = keyboardEvent(from: notification) else {
			return
		}
		keyboardInfo = event
		delegate?.keyboardWillShow(with: event)
	}
	
	@objc func keyboardDisplacerWillHide(_ notification: Notification) {
		isKeyboardVisible = false
		guard let event = keyboardEvent(from: notification) else {
			return
		}
		keyboardInfo = event
		delegate?.keyboardWillHide(with: event)
	}
	
}
