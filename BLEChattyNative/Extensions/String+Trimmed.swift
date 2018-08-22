//
//  String+Trimed.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation

extension String {
	var trimmed: String {
		return self.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
