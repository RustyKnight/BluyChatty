//
//  ChatServiceManager.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//
import Foundation
import CoreBluetooth
import LogWrapperKit

enum ChatServiceManagerError: String, Error, CustomStringConvertible {
	case messageConverstionFailed = "Failed to convert message to data"
	case serviceNotRunning = "Central Service is not running"
	
	var description: String {
		return rawValue
	}
}

// This is the application level manager, it monitors aspects of the BlueTooth service
// it needs and makes updates as required
class ChatServiceManager: NSObject {
	
	static let MessageDelivered = NSNotification.Name(rawValue: "ChatService.messageDelivered")
	static let MessageRecieved = NSNotification.Name(rawValue: "ChatService.messageRecieved")
	
	struct MessageKeys {
		static let message = "Key.message"
		static let client = "Key.client"
	}
	
	static let shared: ChatServiceManager = ChatServiceManager()

	static let SERVICE_UUID = CBUUID(string: "4DF91029-B356-463E-9F48-BAB077BF3EF5")
	static let RX_UUID = CBUUID(string: "3B66D024-2336-4F22-A980-8095F4898C42")
	static let RX_PROPERTIES: CBCharacteristicProperties = .write
	static let RX_PERMISSIONS: CBAttributePermissions = .writeable

	override private init() {
		super.init()
		NotificationCenter.default.addObserver(self, selector: #selector(peripherialManagerStateChanged), name: .BTPeripherialManagerDidUpdateState, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(peripherialDidConnect), name: .BTPeripherialDidConnect, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(didReceiveWrite), name: .BTPeripherialManagerDidReceiveWrite, object: nil)
	}
	
	func start() {
		log(debug: "")
		BTService.shared.scanPeripheralServices = [ChatServiceManager.SERVICE_UUID]
		BTService.shared.scanPeripheralOptions = [CBCentralManagerScanOptionAllowDuplicatesKey : true]
		
		BTService.shared.startCentralManager()
		BTService.shared.startPeripheralManager()
	}
	
	func stop() {
		log(debug: "")
		BTService.shared.stopPeripheralManager()
		BTService.shared.stopCentralManager()
	}
	
	func startScanning() {
		BTService.shared.startScanning()
	}
	
	func stopScanning() {
		BTService.shared.stopScanning()
	}
	
//	func displayName(for device: Device) -> String {
//		let name = device.name
//		let deviceData = name.components(separatedBy: "|")
//		return deviceData[0]
//	}
	
	@objc func peripherialManagerStateChanged(_ notification: Notification) {
		log(debug: "")
		initService()
		updateAdvertisingData()
	}
	
	@objc func peripherialDidConnect(_ notification: Notification) {
		log(debug: "")
		guard let userInfo = notification.userInfo else {
			log(debug: "peripherialDidConnect without userInfo")
			return
		}
		guard let peripheral = userInfo[BTNotificationKey.peripheral] as? CBPeripheral else {
			log(debug: "peripherialDidConnect without peripheral")
			return
		}
		guard hasMoreMessages(for: peripheral) else {
			// Probably not for us
			return
		}
		peripheral.discoverServices(nil)
	}
	
	func initService() {
		log(debug: "")
		guard let manager = BTService.shared.peripheralManager else {
			return
		}
		guard manager.state == .poweredOn else {
			return
		}
		let serialService = CBMutableService(type: ChatServiceManager.SERVICE_UUID, primary: true)
		let rx = CBMutableCharacteristic(type: ChatServiceManager.RX_UUID, properties: ChatServiceManager.RX_PROPERTIES, value: nil, permissions: ChatServiceManager.RX_PERMISSIONS)
		serialService.characteristics = [rx]
		manager.add(serialService)
	}
	
	func updateAdvertisingData() {
		log(debug: "")
		guard let manager = BTService.shared.peripheralManager else {
			return
		}
		guard manager.state == .poweredOn else {
			return
		}
		
		if (manager.isAdvertising) {
			manager.stopAdvertising()
		}
		
		let userData = UserData()
		let advertisementData = String(format: "%@|%@", userData.name, userData.avatar)
		log(debug: "\(advertisementData)")
		
		manager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[ChatServiceManager.SERVICE_UUID],
															CBAdvertisementDataLocalNameKey: advertisementData])
	}
	
	// MARK: Clean cache
	
	// This will remove peripherials which haven't been updated within
	// the specified timeout range.  It would be reasonable to assume
	// that these peripherials are no longer avaliable
	func removePeripherialsWith(timeout: TimeInterval) -> [ChatClient] {
		let now = Date()
		var tmp: [ChatClient] = []
		tmp.append(contentsOf: BTService.shared.chatClients)
		let oldDevices = tmp.filter {
			guard let client = $0 as? DefaultChatClient else {
				return false
			}
			return now.timeIntervalSince(client.lastUpdated) >= timeout
		}
		for entry in oldDevices {
			BTService.shared.deviceCache[entry.peripheral.identifier] = nil
		}
		return oldDevices
	}
	
	// MARK: Messaging Support
	
	fileprivate var messageQueue: [(ChatClient, Data)] = []
	
	func write(_ message: String, to device: ChatClient) throws {
		guard let data = message.data(using: .utf8) else {
			throw ChatServiceManagerError.messageConverstionFailed
		}
		log(debug: "")
		try write(data, to: device)
	}
	
	func write(_ message: Data, to device: ChatClient) throws {
		guard let manager = BTService.shared.centralManager else {
			throw ChatServiceManagerError.serviceNotRunning
		}
		log(debug: "")
		messageQueue.append((device, message))
		device.peripheral.delegate = self
		manager.connect(device.peripheral, options: nil)
	}
	
	
	@objc func didReceiveWrite(_ notification: Notification) {
		log(debug: "")
		guard Thread.isMainThread else {
			DispatchQueue.main.async {
				self.didReceiveWrite(notification)
			}
			return
		}
		guard let userInfo = notification.userInfo else {
			log(debug: "didReceiveWrite notification without userInfo")
			return
		}
		guard let messageDevice = userInfo[BTNotificationKey.device] as? ChatClient else {
			log(debug: "didReceiveWrite notification without device")
			return
		}
		guard let data = userInfo[BTNotificationKey.request] as? Data else {
			log(debug: "didReceiveWrite notification without data")
			return
		}
		guard let text = String(data: data, encoding: .utf8) else {
			log(debug: "didReceiveWrite unable to decode data as text")
			return
		}
		
		let incomingMessage = IncomingMessage(client: messageDevice, text: text)
		let messageInfo = [MessageKeys.message: incomingMessage]
		NotificationCenter.default.post(name: ChatServiceManager.MessageRecieved, object: nil, userInfo: messageInfo)
//
//		let name = messageDevice.displayName
//
//		log(debug: "Message = \(text);\n\tfrom: \(name)")
//
//		NotificationServiceManager.shared.add(identifier: UUID().uuidString,
//																					title: "\(name) said", body: text).catch { (error) -> (Void) in
//																						log(debug: "Failed to deliver notification \(error)")
//		}
	}
}

extension ChatServiceManager: CBPeripheralDelegate {
	
	func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
		log(debug: "peripheral = \(peripheral.identifier)")
		for service in invalidatedServices {
			log(debug: "service = \(service)")
		}
		
		peripheral.discoverServices(nil)
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		log(debug: "")
		if let error = error {
			log(debug: "didDiscoverServices error: \(error)")
			return
		}
		guard let services = peripheral.services else {
			log(debug: "No servivces avaliable")
			return
		}
		for service in services {
			log(debug: "Discover characteristics for \(service.uuid)")
			peripheral.discoverCharacteristics(nil, for: service)
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		log(debug: "")
		if let error = error {
			log(error: "didDiscoverCharacteristicsFor error: \(error)")
			return
		}
		guard var characteristics = service.characteristics else {
			log(debug: "No characteristics avaliable for service \(service.uuid)")
			return
		}
		guard let entry = firstMessage(for: peripheral) else {
			log(error: "didDiscoverCharacteristicsFor - no messages for peripheral \(peripheral.identifier)")
			return
		}
		
		for characteristic in characteristics {
			log(error: "\(characteristic.uuid)")
		}
		
		characteristics = characteristics.filter { $0.uuid.isEqual(ChatServiceManager.RX_UUID) }
		guard characteristics.count > 0 else {
			// Do we really care??
			log(debug: "No chat characteristics avaliable for service \(service.uuid)")
			return
		}
		
		for char in characteristics {
			peripheral.setNotifyValue(true, for: char)
		}
		
		let device = entry.0
		let data = entry.1
		
		log(debug: "Write: [\(String(data: data, encoding: .utf8) ?? "?")] to \(peripheral.identifier)")
		
		for characteristic in characteristics {
			peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
		}
		removeFirstMessage(for: peripheral)
		guard let client = BTService.shared.client(for: peripheral) else {
			return
		}
		let text = String(data: data, encoding: .utf8)!
		let message = DefaultMessage(text: text, direction: .outgoing, status: .delivered)
		let userInfo: [String: Any] = [
			MessageKeys.client: client,
			MessageKeys.message: message
		]
		NotificationCenter.default.post(name: ChatServiceManager.MessageDelivered, object: nil, userInfo: userInfo)
		
		guard !hasMoreMessages(for: peripheral) else {
			return
		}
		device.peripheral.delegate = nil
	}
	
	func hasMoreMessages(for peripheral: CBPeripheral) -> Bool {
		return firstMessage(for: peripheral) != nil
	}
	
	func firstMessage(for peripheral: CBPeripheral) -> (ChatClient, Data)? {
		guard let entry = (messageQueue.first { $0.0.peripheral.identifier == peripheral.identifier }) else {
			return nil
		}
		return entry
	}
	
	func removeFirstMessage(for peripheral: CBPeripheral) {
		guard let index = (messageQueue.index {$0.0.peripheral.identifier == peripheral.identifier}) else {
			return
		}
		messageQueue.remove(at: index)
	}
}
