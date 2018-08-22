//
//  PermissionsViewController.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import BeamUserNotificationKit
import Hydra
import LogWrapperKit
import CoreBluetooth

class PermissionsViewController: UIViewController {
	
	@IBOutlet weak var permissionsStackView: UIStackView!
	@IBOutlet weak var logoImageView: UIImageView!
	
	@IBOutlet weak var blutoothContainer: UIView!
	@IBOutlet weak var notificationsContainer: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		logoImageView.image = BluyChat.imageOfBluyChat()
		navigationItem.hidesBackButton = true
		navigationController?.setNavigationBarHidden(true, animated: false)

		permissionsStackView.alpha = 0.0
	}
	
	override func viewWillAppear(_ animated: Bool) {
		log(debug: "")
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(notificationPermissionsDidChange), name: NotificationsPermissionsViewController.PermissionsChanged, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(peripherialManagerDidUpdateState), name: .BTPeripherialManagerDidUpdateState, object: nil)
		
		updateAuthorisedStates()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		log(debug: "")
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		UIView.animate(withDuration: 0.3) {
			self.permissionsStackView.alpha = 1.0
		}
	}
	
	func updateAuthorisedStates() {
		if !CBPeripheralManager.requiresAuthorisation {
			hideBluetooth()
		}
		UNUserNotificationCenter.current().settings().then(in: .main) { (settings) in
			log(debug: "authorizationStatus = \(settings.authorizationStatus)")
			if settings.authorizationStatus != .notDetermined {
				self.hideNotifications()
			}
		}
	}
	
	func requestNotificationPermissions() {
		UNUserNotificationCenter.current().authorise(options: [.alert, .badge, .sound]).always {
		}.catch { (error) -> (Void) in
				log(debug: "Aurthorisation request faield: \(error)")
		}
		
		_ = NotificationServiceManager.shared.set(categories: [])//NotificationServiceManager.shared.categories)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Segue.blutooth" || segue.identifier == "Segue.notifications" {
			segue.destination.view.translatesAutoresizingMaskIntoConstraints = false
		}
	}
	
	@objc func notificationPermissionsDidChange(_ notification: Notification) {
		UNUserNotificationCenter.current().settings().then(in: .main) { (settings) in
			log(debug: "authorizationStatus = \(settings.authorizationStatus)")
			if settings.authorizationStatus == .denied {
				self.notificationsError()
			} else {
				self.hideNotifications()
			}
		}
	}
	
	func notificationsError() {
		var actions = [UIAlertAction.init(title: "OK", style: .default)]
		if let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
			actions.append(UIAlertAction(title: "Enabled from Settings", style: .default) { (action) in
				UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
					guard success else {
						self.presentErrorAlertWith(message: "Unable to open App Settings")
						return
					}
					self.updateAuthorisedStates()
				})
			})
		}
		presentAlertWith(title: "Error", message: "The App is unable to change the notifications permissions state. They need to be updated from the App settings",
										 preferredStyle: .alert,
										 actions: actions)
	}
	
	@objc func peripherialManagerDidUpdateState(_ notification: Notification) {
		guard CBPeripheralManager.isAuthroised else {
			var actions = [UIAlertAction.init(title: "OK", style: .default)]
			if let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
				actions.append(UIAlertAction(title: "Enabled from Settings", style: .default) { (action) in
					UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
						guard success else {
							self.presentErrorAlertWith(message: "Unable to open App Settings")
							return
						}
						self.updateAuthorisedStates()
					})
				})
			}
			presentAlertWith(title: "Error", message: "BluChaty can not operate with out Blutooth accessory support enabled 😢", preferredStyle: .alert, actions: actions)
			return
		}
		hideBluetooth()
	}
	
	func hideNotifications() {
		UIView.animate(withDuration: 0.3, animations: {
			self.notificationsContainer.alpha = 0
			self.notificationsContainer.isHidden = true
		}) { (completed) in
			self.popIfReady()
		}
	}
	
	func hideBluetooth() {
		UIView.animate(withDuration: 0.3, animations: {
			self.blutoothContainer.alpha = 0
			self.blutoothContainer.isHidden = true
		}) { (completed) in
			self.popIfReady()
		}
	}
	
	func popIfReady() {
		guard blutoothContainer.isHidden && notificationsContainer.isHidden else {
			return
		}
		DispatchQueue.main.async {
			self.performSegue(withIdentifier: "Segue.profile", sender: nil)
		}
	}
	
}
