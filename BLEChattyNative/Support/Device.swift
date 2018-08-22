//
//  Device.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit

struct Device {
	
	// MARK: - Singletons
	
	static var shared: UIDevice {
		struct Singleton {
			static let device = UIDevice.current
		}
		return Singleton.device
	}
	
	static var version: String {
		struct Singleton {
			static let version = UIDevice.current.systemVersion
		}
		return Singleton.version
	}
	
	static var height: CGFloat {
		struct Singleton {
			static let height = UIScreen.main.bounds.size.height
		}
		return Singleton.height
	}
	
	// MARK: - Device Idiom Checks
	
	static var deviceType: String {
		if isPhone() {
			return "iPhone"
		} else if isTablet() {
			return "iPad"
		}
		return "Not iPhone nor iPad"
	}
	
	static var releaseType: String {
		#if DEBUG
		return "Debug"
		#else
		return "Release"
		#endif
	}
	
	static var simulatorOrDevice: String {
		#if targetEnvironment(simulator)
		return "Simulator"
		#else
		return "Device"
		#endif
	}
	
	//    static var deviceModel: String {
	//        return GBDeviceInfo.deviceInfo().modelString
	//    }
	
	static func isPhone() -> Bool {
		return shared.userInterfaceIdiom == .phone
	}
	
	static func isTablet() -> Bool {
		return shared.userInterfaceIdiom == .pad
	}
	
	static func isDebug() -> Bool {
		return releaseType == "Debug"
	}
	
	static func isRelease() -> Bool {
		return releaseType == "Release"
	}
	
	static func isSimulator() -> Bool {
		return simulatorOrDevice == "Simulator"
	}
	
	static func isDevice() -> Bool {
		return simulatorOrDevice == "Device"
	}
	
	// MARK: - Device Version Checks
	
	enum Versions: Float {
		case five = 5.0
		case six = 6.0
		case seven = 7.0
		case eight = 8.0
		case nine = 9.0
	}
	
	static func isVersion(_ version: Versions) -> Bool {
		guard let currentVersion = Float(Device.version) else {
			return false
		}
		return currentVersion >= version.rawValue && currentVersion < (version.rawValue + 1.0)
	}
	
	static func isVersionOrLater(_ version: Versions) -> Bool {
		guard let currentVersion = Float(Device.version) else {
			return false
		}
		return currentVersion >= version.rawValue
	}
	
	static func isVersionOrEarlier(_ version: Versions) -> Bool {
		guard let currentVersion = Float(Device.version) else {
			return false
		}
		return currentVersion < (version.rawValue + 1.0)
	}
	
	// MARK: iOS 5 Checks
	
	static func isOS5() -> Bool {
		return isVersion(.five)
	}
	
	static func isOS5OrLater() -> Bool {
		return isVersionOrLater(.five)
	}
	
	static func isOS5OrEarler() -> Bool {
		return isVersionOrEarlier(.five)
	}
	
	// MARK: iOS 6 Checks
	
	static func isOS6() -> Bool {
		return isVersion(.six)
	}
	
	static func isOS6OrLater() -> Bool {
		return isVersionOrLater(.six)
	}
	
	static func isOS6OrEarlier() -> Bool {
		return isVersionOrEarlier(.six)
	}
	
	// MARK: iOS 7 Checks
	
	static func isOS7() -> Bool {
		return isVersion(.seven)
	}
	
	static func isOS7OrLater() -> Bool {
		return isVersionOrLater(.seven)
	}
	
	static func isOS7OrEarler() -> Bool {
		return isVersionOrEarlier(.seven)
	}
	
	// MARK: iOS 8 Checks
	
	static func isOS8() -> Bool {
		return isVersion(.eight)
	}
	
	static func isOS8OrLater() -> Bool {
		return isVersionOrLater(.eight)
	}
	
	static func isOS8OrEarler() -> Bool {
		return isVersionOrEarlier(.eight)
	}
	
	// MARK: iOS 9 Checks
	
	static func isOS9() -> Bool {
		return isVersion(.nine)
	}
	
	static func isOS9OrLater() -> Bool {
		return isVersionOrLater(.nine)
	}
	
	static func isOS9OrEarler() -> Bool {
		return isVersionOrEarlier(.nine)
	}
	
	// MARK: - Device Size Checks
	
	enum Heights: CGFloat {
		case inches35 = 480
		case inches4 = 568
		case inches47 = 667
		case inches55 = 736
	}
	
	static func isSize(_ height: Heights) -> Bool {
		return Device.height == height.rawValue
	}
	
	static func isSizeOrLarger(_ height: Heights) -> Bool {
		return Device.height >= height.rawValue
	}
	
	static func isSizeOrSmaller(_ height: Heights) -> Bool {
		return Device.height <= height.rawValue
	}
	
	static var currentSize: String {
		if is35Inches() {
			return "3.5 Inches"
		} else if is4Inches() {
			return "4 Inches"
		} else if is47Inches() {
			return "4.7 Inches"
		} else if is55Inches() {
			return "5.5 Inches"
		}
		return "\(Device.height) Points"
	}
	
	// MARK: Retina Check
	
	static func isRetina() -> Bool {
		//        return UIScreen.main.responds(to: "scale")
		return NSObject.responds(to: #selector(getter: UIScreen.scale))
	}
	
	// MARK: 3.5 Inch Checks
	
	static func is35Inches() -> Bool {
		return isPhone() && isSize(.inches35)
	}
	
	static func is35InchesOrLarger() -> Bool {
		return isPhone() && isSizeOrLarger(.inches35)
	}
	
	static func is35InchesOrSmaller() -> Bool {
		return isPhone() && isSizeOrSmaller(.inches35)
	}
	
	// MARK: 4 Inch Checks
	
	static func is4Inches() -> Bool {
		return isPhone() && isSize(.inches4)
	}
	
	static func is4InchesOrLarger() -> Bool {
		return isPhone() && isSizeOrLarger(.inches4)
	}
	
	static func is4InchesOrSmaller() -> Bool {
		return isPhone() && isSizeOrSmaller(.inches4)
	}
	
	// MARK: 4.7 Inch Checks
	
	static func is47Inches() -> Bool {
		return isPhone() && isSize(.inches47)
	}
	
	static func is47InchesOrLarger() -> Bool {
		return isPhone() && isSizeOrLarger(.inches47)
	}
	
	static func is47InchesOrSmaller() -> Bool {
		return isPhone() && isSizeOrLarger(.inches47)
	}
	
	// MARK: 5.5 Inch Checks
	
	static func is55Inches() -> Bool {
		return isPhone() && isSize(.inches55)
	}
	
	static func is55InchesOrLarger() -> Bool {
		return isPhone() && isSizeOrLarger(.inches55)
	}
	
	static func is55InchesSmaller() -> Bool {
		return isPhone() && isSizeOrLarger(.inches55)
	}
	
	// MARK: - International Checks
	
	//    static var currentRegion: String {
	//        Locale.current.
	//        guard let value = Locale.current.object(forKey: Locale.Key.countryCode) as? String else {
	//            return "?"
	//        }
	//        return value
	//    }
}
