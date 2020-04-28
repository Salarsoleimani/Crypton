//
//  PositionModel.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/16/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public final class PositionModel: Codable {
	public let symbol: String 
	public var quantity: Double
	public var profitPercent: Double
	public var liquidationPrice: Double
	public private(set) var entryPointPrice: Double
	public var leverage: Double
	public let side: OrderSide
	public private(set) var lastPrice: Double
	public init(symbol: String, quantity: Double, profitPercent: Double, liquid: Double, entry: Double, leverage: Double, side: OrderSide){
		self.symbol = symbol
		self.quantity = quantity
		self.profitPercent = profitPercent
		self.liquidationPrice = liquid
		self.entryPointPrice = entry
		self.lastPrice = entry
		self.leverage = leverage
		self.side = side
	}
	public func update(currentPrice: Double) {
		let sign = quantity / abs(quantity)
		let change = (currentPrice - entryPointPrice) * sign
		let changePcnt = (change / entryPointPrice) * leverage * 100
		profitPercent = changePcnt
		lastPrice = currentPrice
		
	}
}
extension PositionModel: Equatable {
	public static func == (lhs: PositionModel, rhs: PositionModel) -> Bool {
		return lhs.symbol == rhs.symbol
	}
}
