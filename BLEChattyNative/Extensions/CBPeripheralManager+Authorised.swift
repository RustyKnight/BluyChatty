//
//  CBPeripheralManager+Authorised.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import CoreBluetooth
import Cadmus

extension CBManagerAuthorization: CustomStringConvertible {
	public var description: String {
		switch self {
        case .allowedAlways: return "allowedAlways"
        case .denied: return "denied"
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
		}
	}
}

extension CBPeripheralManager {
	
	static var requiresAuthorisation: Bool {
        CBPeripheralManager.authorization == .notDetermined
	}
	
	static var isAuthroised: Bool {
        CBPeripheralManager.authorization == .allowedAlways
	}
	
	static var isDenied: Bool {
        CBPeripheralManager.authorization == .denied
	}
	
	static var isRestricted: Bool {
        CBPeripheralManager.authorization == .restricted
	}

}
