//
//  BTNotificationKey.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import CoreBluetooth
import LogWrapperKit

extension NSNotification.Name {
	public static let BTStateChanged: NSNotification.Name = NSNotification.Name("BT.stateChanged")
	public static let BTNewPeripherialDiscovered: NSNotification.Name = NSNotification.Name("BT.newPeripherialDiscovered")
	public static let BTPeripherialUpdated: NSNotification.Name = NSNotification.Name("BT.peripherialUpdated")
	public static let BTPeripherialDidConnect: NSNotification.Name = NSNotification.Name("BT.peripherialDidConnect")
	
	public static let BTPeripherialManagerDidUpdateState: NSNotification.Name = NSNotification.Name("BT.peripherialManagerDidUpdateState")
	public static let BTPeripherialManagerDidReceiveWrite: NSNotification.Name = NSNotification.Name("BT.peripherialManagerDidReceiveWrite")
}

struct BTNotificationKey {
	static let device = "BT.key.device"
	static let request = "BT.key.request"
	static let peripheral = "BT.key.peripheral"
	static let peripheralState = "BT.key.PeripheralState"
	static let managerState = "BT.key.managerState"
}

class DefaultChatClient: ChatClient {
	var displayName: String {
		let deviceData = name.components(separatedBy: "|")
		return deviceData[0]
	}
	var avatar: String {
		let deviceData = name.components(separatedBy: "|")
		if deviceData.count == 1 {
			return "🤖"
		}
		return deviceData[1]
	}
	var peripheral: CBPeripheral
	var rssi: NSNumber
	var name: String
	var lastUpdated: Date
	
	init(device: CBPeripheral, name: String, rssi: NSNumber) {
		self.peripheral = device
		self.name = name
		self.rssi = rssi
		lastUpdated = Date()
	}
	
	func write(message: String) throws {
		try ChatServiceManager.shared.write(message, to: self)
	}
	
}

extension CBManagerState: CustomStringConvertible {
	public var description: String {
		switch self {
		case .unknown: return "unkown"
		case .resetting: return "resetting"
		case .unsupported: return "unsupported"
		case .unauthorized: return "unauthorized"
		case .poweredOff: return "poweredOff"
		case .poweredOn: return "poweredOn"
		}
	}
}

class BTService: NSObject {
	static let shared: BTService = BTService()
	
	var peripheralManager: CBPeripheralManager?
	var centralManager: CBCentralManager?
	
	var scanPeripheralServices: [CBUUID]? = nil
	var scanPeripheralOptions: [String: Any]? = nil
	
	internal var deviceCache: [UUID: DefaultChatClient] = [:]
	internal var cachedPeripheralNames: [String: String] = [:]
	
	var chatClients: [ChatClient] {
		return deviceCache.map({ (entry) -> ChatClient in
			return entry.value
		})
	}
	
	var defaultUnknownDeviceName: String = "Unknown"
	
	override private init() {
		super.init()
	}
	
	func client(for peripheral: CBPeripheral) -> ChatClient? {
		return deviceCache[peripheral.identifier]
	}
	
	func startCentralManager(queue: DispatchQueue? = nil) {
		log(debug: "")
		stopCentralManager()
		centralManager = CBCentralManager(delegate: self, queue: queue)
	}
	
	func startPeripheralManager(peripheralQueue: DispatchQueue? = nil, peripheralOptions options: [String : Any]? = nil) {
		log(debug: "")
		stopPeripheralManager()
		peripheralManager = CBPeripheralManager(delegate: self, queue: peripheralQueue, options: options)
	}
	
	func stopCentralManager() {
		guard let manager = centralManager else {
			return
		}
		log(debug: "")
		if manager.state == .poweredOn {
			manager.stopScan()
		}
		self.centralManager = nil
	}
	
	func stopScanning() {
		guard let manager = centralManager else {
			return
		}
		log(debug: "")
		if manager.state == .poweredOn {
			manager.stopScan()
		}
	}
	
	func startScanning() {
		guard let manager = centralManager else {
			return
		}
		log(debug: "")
		if manager.state == .poweredOn {
			manager.scanForPeripherals(withServices: scanPeripheralServices, options: scanPeripheralOptions)
		}
	}
	
	func stopPeripheralManager() {
		guard let manager = peripheralManager else {
			return
		}
		log(debug: "")
		if manager.state == .poweredOn {
			if manager.isAdvertising {
				manager.stopAdvertising()
			}
			manager.removeAllServices()
		}
		self.peripheralManager = nil
	}
	
}

extension BTService: CBCentralManagerDelegate {
	
	// MARK: CBCentralManagerDelegate
	
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		let state = central.state
		let userInfo = [BTNotificationKey.managerState: state]
		NotificationCenter.default.post(name: .BTStateChanged, object: nil, userInfo: userInfo)
		
		// Probably generate a state notification
//		guard central.state == .poweredOn else {
//			return
//		}
//		guard let manager = centralManager else {
//			return
//		}
//		log(debug: "")
//		manager.scanForPeripherals(withServices: scanPeripheralServices, options: scanPeripheralOptions)
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		let peripheralName = name(of: peripheral, advertisementData: advertisementData)
		
		if let device = deviceCache[peripheral.identifier] {
			// Because we need the last updated state, this will always
			// trigger a state change
			device.name = peripheralName
			device.rssi = RSSI
			device.lastUpdated = Date()
			let userInfo: [String: Any] = [ BTNotificationKey.device: device ]
			NotificationCenter.default.post(name: .BTPeripherialUpdated, object: nil, userInfo: userInfo)
		} else {
			log(debug: "peripheralName = \(peripheralName)")
			let device = DefaultChatClient(device: peripheral, name: peripheralName, rssi: RSSI)
			deviceCache[peripheral.identifier] = device
			let userInfo: [String: Any] = [ BTNotificationKey.device: device ]
			log(debug: "Generate notification")
			NotificationCenter.default.post(name: .BTNewPeripherialDiscovered, object: nil, userInfo: userInfo)
		}
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		let userInfo: [String: Any] = [
			BTNotificationKey.peripheral: peripheral
		]
		log(debug: "didConnect peripheral \(peripheral.identifier)")
		log(debug: "Generate notification")
		NotificationCenter.default.post(name: .BTPeripherialDidConnect, object: nil, userInfo: userInfo)
	}
	
	// MARK: Support
	
	func name(of peripheral: CBPeripheral, advertisementData: [String : Any]? = nil) -> String {
		var peripheralName = cachedPeripheralNames[peripheral.identifier.description] ?? defaultUnknownDeviceName
		
		guard let advertisementData = advertisementData else {
			return peripheralName
		}
		guard let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey] as? String else {
			return peripheralName
		}
		guard advertisementName != peripheralName else {
			return peripheralName
		}
		
		peripheralName = advertisementName
		cachedPeripheralNames[peripheral.identifier.description] = peripheralName
		
		return peripheralName
	}
	
}

extension BTService: CBPeripheralManagerDelegate {
	
	func advertise(data: [String: Any]? = nil) {
		guard let manager = peripheralManager else {
			return
		}
		guard manager.state == .poweredOn else {
			return
		}
		stopAdvertising()
		manager.startAdvertising(data)
	}
	
	func stopAdvertising() {
		guard let manager = peripheralManager else {
			return
		}
		guard manager.state == .poweredOn else {
			return
		}
		guard manager.isAdvertising else {
			return
		}
		manager.stopAdvertising()
	}
	
	func add(peripheralService service: CBMutableService) {
		guard let manager = peripheralManager else {
			return
		}
		guard manager.state == .poweredOn else {
			return
		}
		manager.add(service)
	}
	
	func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
		log(debug: "")
		log(debug: "Generate notification")
		let userInfo: [String: Any] = [
			BTNotificationKey.peripheralState: peripheral.state,
			BTNotificationKey.peripheral: peripheral
		]
		NotificationCenter.default.post(name: .BTPeripherialManagerDidUpdateState, object: nil, userInfo: userInfo)
	}
	
	func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
		for request in requests {
			if let value = request.value {
				let identifier = request.central.identifier
				if let device = deviceCache[identifier] {
					let userInfo: [String: Any] = [
						BTNotificationKey.request: value,
						BTNotificationKey.device: device
					]
					log(debug: "Generate notification")
					NotificationCenter.default.post(name: .BTPeripherialManagerDidReceiveWrite, object: nil, userInfo: userInfo)
				}
			}
			peripheral.respond(to: request, withResult: .success)
		}
	}
	
	//	func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
	//
	//	}
	
}
