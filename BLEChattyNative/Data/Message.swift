//
//  Message.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 23/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation

enum MessageDirection {
	case outgoing
	case incoming
}

enum MessageStatus {
	case sending
	case delivered
	case failed
	
}

protocol Message {
	var text: String { get }
	var direction: MessageDirection { get }
	var status: MessageStatus { get }
}

class DefaultMessage: Message {
	var text: String
	var direction: MessageDirection
	var status: MessageStatus
	
	init(text: String, direction: MessageDirection, status: MessageStatus = .delivered) {
		self.text = text
		self.direction = direction
		self.status = status
	}
}

class IncomingMessage: DefaultMessage {
	var client: ChatClient
	
	init(client: ChatClient, text: String, status: MessageStatus = .delivered) {
		self.client = client
		super.init(text: text, direction: .incoming)
	}
}
