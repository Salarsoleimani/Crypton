//
//  LimitOrderModel.swift
//  Domain
//
//  Created by Salar Soleimani on 7/16/19.
//  Copyright © 2019 Salar Soleimani. All rights reserved.
//

import Foundation

/// 🚲 Crypton Limit Order Type
public struct LimitOrderModel: CommonOrderProtocol {
  public let type: OrderType
  
  /// OrderSide. Valid options: Buy, Sell. Defaults to 'Buy' unless orderQty is negative.
  public let direction: OrderSide
  
  /// Instrument symbol. e.g. 'XBTUSD'.	public let type: OrderSide
	public let symbol: String
  
  /// Close at price
	public let price: Double
  
  /// Amount of contracts
  public let quantity: Double
  
  /**
   Initializes a new Crypton Limit Order.
   
   - Parameters:
   - type: OrderSide. Valid options: Buy, Sell. Defaults to 'Buy' unless orderQty is negative.
   - symbol: Instrument symbol. e.g. 'XBTUSD'.  public let type: OrderSide
   - price: Close at price
   - quantity: Amount of contracts

   - Returns: CloseOrderModel
   */
  public init(type: OrderSide, symbol: String, price: Double, quantity: Double) {
		self.direction = type
		self.symbol = symbol
		self.price = price
    self.quantity = quantity
    self.type = OrderType.Limit
	}
  
  /**
   Change the Crypton Limit Order Model to OrderRequestNetworkModel
   
   - Parameter
   - Precondition
   - Author: Salar Soleimani
   */
	public func asBitmexRequestModel() -> OrderRequestModels.Place {
    return OrderRequestModels.Place(symbol: symbol, side: direction.rawValue, orderQty: quantity, price: price, displayQty: nil, stopPx: nil, clOrdID: nil, pegOffsetValue: nil, pegPriceType: nil, ordType: OrderType.Limit.rawValue, timeInForce: nil, execInst: nil, text: nil)
	}
}
