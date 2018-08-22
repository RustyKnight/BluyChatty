//
//  UIViewController+Alert.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

	@objc func presentErrorAlertWith(message: String,
															preferredStyle: UIAlertController.Style = .alert,
															handler: AlertActionHandler? = nil) {
		guard Thread.isMainThread else {
			DispatchQueue.main.async(execute: {
				self.presentErrorAlertWith(
					message: message)
			})
			return
		}
		
		presentOkAlertWith(title: "Error", message: message, preferredStyle: preferredStyle, handler: handler)
	}

	@objc func presentAlertWith(title: String? = nil,
													 message: String,
													 preferredStyle: UIAlertController.Style = .alert,
													 actions: [UIAlertAction]) {
		guard Thread.isMainThread else {
			DispatchQueue.main.async(execute: {
				self.presentAlertWith(
					title: title,
					message: message,
					actions: actions)
			})
			return
		}
		let alertController = UIAlertController(title: title,
																						message: message,
																						preferredStyle: .alert)
		for action in actions {
			alertController.addAction(action)
		}
		self.present(alertController,
								 animated: true,
								 completion: nil)
	}
	
	@objc func presentOkAlertWith(title: String? = nil,
														 message: String,
														 preferredStyle: UIAlertController.Style = .alert,
														 handler: AlertActionHandler? = nil) {
		guard Thread.isMainThread else {
			DispatchQueue.main.async(execute: {
				self.presentOkAlertWith(
					title: title,
					message: message,
					handler: handler)
			})
			return
		}
		presentAlertWith(
			title: title,
			message: message,
			actions: [UIAlertAction.okay(handler: handler)])
	}
	
	@objc func presentOkCancelAlertWith(title: String? = nil,
																	 message: String,
																	 preferredStyle: UIAlertController.Style = .alert,
																	 okActionHandler: AlertActionHandler? = nil,
																	 cancelActionHandler: AlertActionHandler? = nil) {
		guard Thread.isMainThread else {
			DispatchQueue.main.async(execute: {
				self.presentOkCancelAlertWith(
					title: title,
					message: message,
					okActionHandler: okActionHandler,
					cancelActionHandler: cancelActionHandler)
			})
			return
		}
		if #available(iOS 9, *) {
			
		} else {
			
		}
		//		let systemVersion = Int(UIDevice.current.systemVersion)!
		//		if systemVersion < 10 {
		//			let alert = UIAlertView(title: title ?? "",
		//															message: message,
		//															delegate: nil,
		//															cancelButtonTitle: "CANCEL_BUTTON_TEXT".localized,
		//															otherButtonTitles: "OK_BUTTON_TEXT".localized)
		//
		//			alert.show()
		//		} else {
		presentAlertWith(
			title: title,
			message: message,
			actions: [
				UIAlertAction.okay(handler: okActionHandler),
				UIAlertAction.cancel(handler: cancelActionHandler)
			])
		//		}
	}
	
	@objc func presentYesNoAlertWith(title: String? = nil,
																message: String,
																preferredStyle: UIAlertController.Style = .alert,
																yesActionHandler: AlertActionHandler? = nil,
																noActionHandler: AlertActionHandler? = nil) {
		guard Thread.isMainThread else {
			DispatchQueue.main.async(execute: {
				self.presentYesNoAlertWith(
					title: title,
					message: message,
					yesActionHandler: yesActionHandler,
					noActionHandler: noActionHandler)
			})
			return
		}
		if #available(iOS 9, *) {
			
		} else {
			
		}
		//		let systemVersion = Int(UIDevice.current.systemVersion)!
		//		if systemVersion < 10 {
		//			let alert = UIAlertView(title: title ?? "",
		//															message: message,
		//															delegate: nil,
		//															cancelButtonTitle: "CANCEL_BUTTON_TEXT".localized,
		//															otherButtonTitles: "OK_BUTTON_TEXT".localized)
		//
		//			alert.present()
		//		} else {
		presentAlertWith(
			title: title,
			message: message,
			actions: [
				UIAlertAction.yes(handler: yesActionHandler),
				UIAlertAction.no(handler: noActionHandler)
			])
		//		}
	}
	
}

