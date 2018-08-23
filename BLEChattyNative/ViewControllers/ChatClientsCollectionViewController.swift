//
//  ChatClientsCollectionViewController.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit
import LogWrapperKit
import UserNotifications
import BeamUserNotificationKit
import Hydra
import CoreBluetooth

private let reuseIdentifier = "Cell.user"

class ChatClientsCollectionViewController: UICollectionViewController {
	
	var chatClients: [ChatClient] = []
	var selectedChatClient: ChatClient?
	
	var updateTimer: Timer?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationController?.viewControllers = [self]
		navigationItem.setHidesBackButton(true, animated: false)
		
		displaceOnKeyboard = false
		dismissKeyboardOnTap = false
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		scheduleCleanUpTimer()
		
		addMessagingNotifications()
		ChatServiceManager.shared.start()

		NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if let timer = updateTimer {
			timer.invalidate()
		}
		updateTimer = nil
		removeMessagingNotifications()
	}
	
	func scheduleCleanUpTimer() {
		if let timer = updateTimer {
			timer.invalidate()
			self.updateTimer = nil
		}
		updateTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.cleanUp), userInfo: nil, repeats: true)
	}
	
	func update(_ client: ChatClient) {
		guard let index = indexOf(client) else {
			// 😳 Should we add them?!
			return
		}
		let indicies: [IndexPath] = [IndexPath(row: index, section: 0)]
//		collectionView.reloadItems(at: indicies)
	}
	
	@objc func cleanUp() {
		let removedClients = ChatServiceManager.shared.removePeripherialsWith(timeout: 5.0)
		guard !removedClients.isEmpty else {
			return
		}
		var indicies: [IndexPath] = []
		for client in removedClients {
			guard let index = indexOf(client) else {
				continue
			}
			indicies.append(IndexPath(row: index, section: 0))
		}
		guard !indicies.isEmpty else {
			return
		}
		for index in indicies {
			chatClients.remove(at: index.row)
		}
		collectionView.deleteItems(at: indicies)
	}
	
	func indexOf(_ client: ChatClient) -> Int? {
		return chatClients.firstIndex(where: { return $0.peripheral.identifier == client.peripheral.identifier })
	}
	
	// MARK: - Notifications

	func addMessagingNotifications() {
		log(debug: "")
		NotificationCenter.default.addObserver(self, selector: #selector(bluToothStateChanged), name: .BTStateChanged, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(newPeripheralDiscovered), name: .BTNewPeripherialDiscovered, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(peripheralUpdated), name: .BTPeripherialUpdated, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(messageWasRecieved), name: ChatServiceManager.MessageRecieved, object: nil)
	}
	
	func removeMessagingNotifications() {
		log(debug: "")
		NotificationCenter.default.removeObserver(self, name: .BTNewPeripherialDiscovered, object: nil)
		NotificationCenter.default.removeObserver(self, name: .BTPeripherialUpdated, object: nil)
		NotificationCenter.default.removeObserver(self, name: ChatServiceManager.MessageRecieved, object: nil)
	}
	
	// MARK: - Application support
	
	@objc func didEnterBackground(_ notification: Notification) {
		log(debug: "")
		removeMessagingNotifications()
	}
	
	@objc func willEnterForeground(_ notification: Notification) {
		log(debug: "")
		addMessagingNotifications()
	}
	
	// MARK: - Chat support

	@objc func bluToothStateChanged(_ notification: NSNotification) {
		guard let userInfo = notification.userInfo else {
			return
		}
		guard let state = userInfo[BTNotificationKey.managerState] as? CBManagerState else {
			return
		}
		
		switch state {
		case .poweredOn:
			log(debug :"Start scanning")
			ChatServiceManager.shared.startScanning()
		default:
			log(debug :"Stop scanning")
			ChatServiceManager.shared.stopScanning()
		}
	}

	func processDevice(notification: NSNotification) {
		guard Thread.isMainThread else {
			DispatchQueue.main.async {
				self.processDevice(notification: notification)
			}
			return
		}
		log(debug: "")
		guard let userInfo = notification.userInfo else {
			log(debug: "No user info in notification")
			return
		}
		guard let device = userInfo[BTNotificationKey.device] as? ChatClient else {
			log(debug: "No device in notification")
			return
		}
		
		guard !contains(device) else {
			update(device)
			return
		}
		chatClients.append(device)
		collectionView.insertItems(at: [IndexPath(item: chatClients.count - 1, section: 0)])
	}
	
	func contains(_ client: ChatClient) -> Bool {
		return chatClients.contains(where: { $0.peripheral.identifier == client.peripheral.identifier })
	}

	@objc func newPeripheralDiscovered(_ notification: NSNotification) {
		processDevice(notification: notification)
	}
	
	@objc func peripheralUpdated(_ notification: NSNotification) {
		processDevice(notification: notification)
	}
	
	@objc func messageWasRecieved(_ notification: Notification) {
		log(debug: "")
		guard Thread.isMainThread else {
			DispatchQueue.main.async {
				self.messageWasRecieved(notification)
			}
			return
		}
		guard let userInfo = notification.userInfo else {
			log(debug: "didReceiveWrite notification without userInfo")
			return
		}
		guard let message = userInfo[ChatServiceManager.MessageKeys.message] as? IncomingMessage else {
			log(debug: "didReceiveWrite notification without device")
			return
		}
		
		let name = message.client.displayName
		let text = message.text
		
		log(debug: "Message = \(text);\n\tfrom: \(name)")
		
		NotificationServiceManager.shared.add(identifier: UUID().uuidString,
																					title: "\(name) said", body: text).catch { (error) -> (Void) in
			log(debug: "Failed to deliver notification \(error)")
		}
	}

	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		log(debug: "")
		if segue.identifier == "Segue.chat" {
			guard let controller = segue.destination as? ChatViewController else {
				return
			}
			if #available(iOS 11, *) {
				controller.currentInsets = view.safeAreaInsets
			} else {
				controller.currentInsets = view.layoutMargins
			}
			
			controller.client = selectedChatClient!
			
		}
	}

	// MARK: UICollectionViewDataSource
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if chatClients.isEmpty {
			collectionView.setEmptyMessage("You have no friends 😓")
		} else {
			collectionView.restore()
		}
		return chatClients.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
		if let cell = cell as? UserCollectionViewCell {
			let chatClient = chatClients[indexPath.row]
			cell.configure(with: chatClient)
		}
		return cell
	}
	
	// MARK: UICollectionViewDelegate
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		log(debug: "")
		selectedChatClient = chatClients[indexPath.row]
		performSegue(withIdentifier: "Segue.chat", sender: self)
	}
	
	/*
	// Uncomment this method to specify if the specified item should be highlighted during tracking
	override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
	return true
	}
	*/
	
	/*
	// Uncomment this method to specify if the specified item should be selected
	override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
	return true
	}
	*/
	
	/*
	// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
	override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
	return false
	}
	
	override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
	return false
	}
	
	override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
	
	}
	*/
	
}
