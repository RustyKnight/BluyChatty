//
//  Range+Animator.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 23/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import UIKit

// MARK: Animatable range helpers
// These extensions provide a useful place to perform some "animation" calculations
// They can be used to calculate the current value between two points based on
// a given progression point
public extension Range where Bound == Double {
	func value(at point: Double) -> Double {
		// Normalise the progression
		let lower = lowerBound
		let upper = upperBound
		let distant = upper - lower
		return (distant * point) + lower
	}
}

public extension Range where Bound == Int {
	func value(at point: Double) -> Int {
		// Normalise the progression
		let lower = lowerBound
		let upper = upperBound
		let distant = upper - lower
		return Int(round((Double(distant) * point))) + lower
	}
}

public extension ClosedRange where Bound == Int {
	func value(at point: Double) -> Int {
		// Normalise the progression
		let lower = lowerBound
		let upper = upperBound
		let distant = upper - lower
		return Int(round((Double(distant) * point))) + lower
	}
}

public extension ClosedRange where Bound == Double {
	func value(at point: Double) -> Double {
		// Normalise the progression
		let lower = lowerBound
		let upper = upperBound
		let distant = upper - lower
		return (distant * point) + lower
	}
}
