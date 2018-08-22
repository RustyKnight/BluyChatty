//
//  UserData.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation

struct UserData {
	
	private let userDataKey = "userData"
	
	var name: String
	var avatar: String
	
	var hasAllDataFilled: Bool {
		return !name.isEmpty && !avatar.isEmpty
	}
	
	public init(name: String, avatar: String) {
		self.name = name
		self.avatar = avatar
	}
	
	public init(){
		if let dictionary = UserDefaults.standard.dictionary(forKey: userDataKey) {
			name = dictionary["name"] as? String ?? ""
			avatar = dictionary["avatarId"] as? String ?? ""
		} else {
			name = ""
			avatar = ""
		}
	}
	
	public func save() {
		
		var dictionary : Dictionary = Dictionary<String, Any>()
		dictionary["name"] = name
		dictionary["avatarId"] = avatar
		
		UserDefaults.standard.set(dictionary, forKey: userDataKey)
	}
	
}
