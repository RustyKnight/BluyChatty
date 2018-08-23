//
//  User.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import CoreBluetooth

func == (lhs: ChatClient, rhs: ChatClient) -> Bool{
	return lhs.peripheral.identifier == rhs.peripheral.identifier
}

protocol ChatClient {
	var displayName: String { get }
	var avatar: String { get }
	
	var peripheral: CBPeripheral { get } // :/
	
	var rssi: NSNumber { get }
	
	func write(message: String) throws
}
