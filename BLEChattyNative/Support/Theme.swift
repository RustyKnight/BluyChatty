//
//  Theme.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 20/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit

public struct Theme {
	
	static let background: UIColor = UIColor(red: 0.537, green: 0.741, blue: 0.827, alpha: 1.0)
	static let foreground: UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
	static let light: UIColor = UIColor(red: 0.890, green: 0.890, blue: 0.890, alpha: 1.0)
	static let dark: UIColor = UIColor(red: 0.788, green: 0.788, blue: 0.788, alpha: 1.0)
	
	private static let black =  UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
	private static let white =  UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
	
	static let outgoingMessageBackground: UIColor = UIColor(red: 0.604, green: 0.871, blue: 0.644, alpha: 1.0)

	static func applyPrimaryTheme() {
		UILabel.appearance().textColor = Theme.foreground

		PillButton.appearance().tintColor = Theme.black
		PillButton.appearance().backgroundColor = Theme.light
		PillButton.appearance().setTitleColor(Theme.black, for: .normal)
		PillButton.appearance().setTitleColor(Theme.black, for: .selected)
		PillButton.appearance().setTitleColor(Theme.dark, for: .disabled)

		UILabel.appearance(whenContainedInInstancesOf: [PillButton.self]).tintColor = Theme.black
		UILabel.appearance(whenContainedInInstancesOf: [PillButton.self]).textColor = Theme.black

		TemplateView.appearance().backgroundColor = Theme.background
		UICollectionView.appearance().backgroundColor = Theme.background
		UITableView.appearance().backgroundColor = Theme.background
		
		UITableViewCell.appearance().backgroundColor = Theme.background
		UIView.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).backgroundColor = Theme.background

		UITextField.appearance().backgroundColor = Theme.white
	}
}
