//
//  PostLaunchViewController.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications
import LogWrapperKit

class PrePermissionsViewController: UIViewController {
	
	@IBOutlet weak var topAlignConstraint: NSLayoutConstraint!
	@IBOutlet weak var verticalCenterConstraint: NSLayoutConstraint!
	@IBOutlet weak var logoImageView: UIImageView!
	
	var blutoothRequiresAuthorisation: Bool = CBPeripheralManager.requiresAuthorisation
	var notificationsRequiresAuthorisation: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		logoImageView.image = BluyChat.imageOfBluyChat()
		
		navigationItem.hidesBackButton = true
		navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		UNUserNotificationCenter.current().settings().then(in: .main) { (settings) in
			self.notificationsRequiresAuthorisation = settings.authorizationStatus == .notDetermined
		}.then(in: .main) { () in
			UIView.animate(withDuration: 0.3, delay: 0.0, options: [UIView.AnimationOptions.curveEaseInOut], animations: {
				self.verticalCenterConstraint.isActive = false
				self.topAlignConstraint.isActive = true
				self.view.setNeedsLayout()
				self.view.layoutIfNeeded()
			}) { (completed) in
				if self.blutoothRequiresAuthorisation || self.notificationsRequiresAuthorisation {
					self.performSegue(withIdentifier: "Segue.permissions", sender: self)
				} else {
					self.performSegue(withIdentifier: "Segue.profile", sender: self)
				}
			}
		}
	}
	
//	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		guard segue.identifier == "Segue.permissions" else {
//			return
//		}
//		guard let destination = segue.destination as? PermissionsViewController else {
//			return
//		}
//	}
	
}
