//
//  PriceChangeModel.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/22/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public struct PriceChangeModel {
	public let price: Double
	public let changeType: ChangingType
	public let change: Double
	public init(price: Double, type: ChangingType, change: Double = 0.0) {
		self.price = price
		self.changeType = type
		self.change = change
	}
	public static func defaultModel() -> PriceChangeModel{
		return PriceChangeModel(price: 0.0, type: ChangingType.representType(double: 0.0))
	}
}
