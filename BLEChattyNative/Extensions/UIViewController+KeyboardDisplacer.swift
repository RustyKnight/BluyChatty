//
//  UIViewController+KeyboardDisplacer.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit

// I'm not a fan of this, but this will allow us to maintain state beyond the capabailities of the the extension API
fileprivate var cache = NSHashTable<UIViewController>(options: .weakMemory)
//	NSMapTable<UIViewController, UITapGestureRecognizer>(keyOptions: .weakMemory, valueOptions: .weakMemory)

extension UIViewController {
	
	fileprivate var isInstalled: Bool {
		return cache.contains(self)
	}
	
	var displaceOnKeyboard: Bool {
		set {
			if newValue {
				guard !isInstalled else {
					return
				}
				cache.add(self)
				NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisplacerWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
				NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisplacerWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
			} else {
				NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
				NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
				cache.remove(self)
			}
		}
		
		get {
			return isInstalled
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
	
	@objc func keyboardDisplacerWillShow(_ notification: Notification) {
		guard let view = view else {
			return
		}
		guard let userInfo = notification.userInfo else {
			return
		}
		guard let endBounds = keyboardEndBounds(from: notification) else {
			return
		}
		//		guard let beginingBounds = keyboardBeginingBounds(from: notification) else {
		//			return
		//		}
		//		let delta = endBounds.origin.y - beginingBounds.origin.y
		var frame = view.frame
		var needsDisplacement = true
		
		// Only display the view if the keyboard covers the current responder
		if let currentResponder = view.firstResponder {
			let rect = currentResponder.convert(currentResponder.frame, to: view)
			needsDisplacement = endBounds.contains(rect)
		}
		
		guard needsDisplacement else {
			return
		}
		
		guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
			let curve =  userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
			frame.origin.y -= endBounds.height
			view.frame = frame
			
			return
		}
		
		UIView.animate(withDuration: duration, delay: 0, options: [UIView.AnimationOptions(rawValue: curve)], animations: {
			frame.origin.y -= endBounds.height
			view.frame = frame
		}) { (completed) in
		}
	}
	
	@objc func keyboardDisplacerWillHide(_ notification: Notification) {
		guard let view = view else {
			return
		}
		guard let userInfo = notification.userInfo else {
			return
		}
		var frame = view.frame
		guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
			let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
			frame.origin.y = 0
			view.frame = frame
			return
		}
		
		UIView.animate(withDuration: duration, delay: 0, options: [UIView.AnimationOptions(rawValue: curve)], animations: {
			frame.origin.y = 0
			view.frame = frame
		}) { (completed) in
		}
	}
	
}
