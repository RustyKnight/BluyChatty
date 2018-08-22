//
//  CBPeripheralManager+Authorised.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import CoreBluetooth
import LogWrapperKit

extension CBPeripheralManagerAuthorizationStatus: CustomStringConvertible {
	public var description: String {
		switch self {
		case .authorized: return "authorized"
		case .denied: return "denied"
		case .notDetermined: return "notDetermined"
		case .restricted: return "restricted"
		}
	}
}

extension CBPeripheralManager {
	
	static var requiresAuthorisation: Bool {
		return CBPeripheralManager.authorizationStatus() == .notDetermined
	}
	
	static var isAuthroised: Bool {
		return CBPeripheralManager.authorizationStatus() == .authorized
	}
	
	static var isDenied: Bool {
		return CBPeripheralManager.authorizationStatus() == .denied
	}
	
	static var isRestricted: Bool {
		return CBPeripheralManager.authorizationStatus() == .restricted
	}

}
