//
//  BluToothPermissionsViewController.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit

class BluToothPermissionsViewController: UIViewController {
	
	@IBOutlet weak var logoImageView: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		logoImageView.image = BluyChat.imageOfBlutoothCommunication
	}
	
	@IBAction func requestAuthorisation(_ sender: Any) {
//		BTService.shared.startCentralManager()
		BTService.shared.startPeripheralManager()
	}
	
}
