//
//  StopLimitOrderModel.swift
//  Domain
//
//  Created by Salar Soleimani on 7/16/19.
//  Copyright © 2019 Salar Soleimani. All rights reserved.
//

import Foundation

/// 🚲 Crypton Stop Limit Order Type
public struct StopLimitOrderModel: CommonOrderProtocol {
  public var type: OrderType

  /// OrderSide. Valid options: Buy, Sell. Defaults to 'Buy' unless orderQty is negative.
  public let direction: OrderSide
  
  /// Instrument symbol. e.g. 'XBTUSD'.  public let type: OrderSide
  public let symbol: String
  
  /// Trigger price
  public let triggerPrice: Double
  
  /// Amount of contracts
  public let quantity: Double
  
  /// Sell/Buy at price
  public let price: Double

  /**
   Initializes a new Crypton Stop Limit.
   
   - Parameters:
   - type: OrderSide. Valid options: Buy, Sell. Defaults to 'Buy' unless orderQty is negative.
   - symbol: Instrument symbol. e.g. 'XBTUSD'.  public let type: OrderSide
   - triggerPrice: Trigger price
   - quantity: Amount of contracts
   - price: Sell/Buy at price
   
   - Returns: StopLimitOrderModel
   */
  public init(type: OrderSide, symbol: String, price: Double, quantity: Double, triggerPrice: Double) {
    self.direction = type
    self.symbol = symbol
    self.quantity = quantity
    self.price = price
    self.triggerPrice = triggerPrice
    self.type = OrderType.StopLimit
  }
  
  /**
   Change the Crypton Stop Limit Order to OrderRequestNetworkModel
   
   - Parameter
   - Precondition
   - Author: Salar Soleimani
   */
  public func asBitmexRequestModel() -> OrderRequestModels.Place {
    return OrderRequestModels.Place(symbol: symbol, side: direction.rawValue, orderQty: quantity, price: price, displayQty: nil, stopPx: triggerPrice, clOrdID: nil, pegOffsetValue: nil, pegPriceType: nil, ordType: OrderType.StopLimit.rawValue, timeInForce: nil, execInst: nil, text: nil)
  }
}
