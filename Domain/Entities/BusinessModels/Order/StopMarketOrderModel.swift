//
//  StopMarketOrderModel.swift
//  Domain
//
//  Created by Salar Soleimani on 7/16/19.
//  Copyright © 2019 Salar Soleimani. All rights reserved.
//

import Foundation

/// 🚲 Crypton Stop Market Order Type
public struct StopMarketOrderModel: CommonOrderProtocol {
  public let type: OrderType
  
  /// OrderSide. Valid options: Buy, Sell. Defaults to 'Buy' unless orderQty is negative.
  public let direction: OrderSide
  
  /// Instrument symbol. e.g. 'XBTUSD'.  public let type: OrderSide
  public let symbol: String
  
  /// Trigger price
  public let triggerPrice: Double
  
  /// Amount of contracts
  public let quantity: Double
  
  /**
   Initializes a new Crypton Stop Market Order Model.
   
   - Parameters:
   - type: OrderSide. Valid options: Buy, Sell. Defaults to 'Buy' unless orderQty is negative.
   - symbol: Instrument symbol. e.g. 'XBTUSD'.  public let type: OrderSide
   - triggerPrice: Close at price
   - quantity: Amount of contracts
   
   - Returns: CloseOrderModel
   */
  public init(type: OrderSide, symbol: String, triggerPrice: Double, quantity: Double) {
    self.direction = type
    self.symbol = symbol
		let roundedTrigger = Double(Int(triggerPrice))//[TODO] BTC Cannot take value like 10980.4302. it should
		
    self.triggerPrice = roundedTrigger
    self.quantity = quantity
    self.type = OrderType.Stop
  }
  
  /**
   Change the Crypton Stop Market Order model to OrderRequestNetworkModel
   
   - Parameter
   - Precondition
   - Author: Salar Soleimani
   */
  public func asBitmexRequestModel() -> OrderRequestModels.Place {
    return OrderRequestModels.Place(symbol: symbol, side: direction.rawValue, orderQty: quantity, price: nil, displayQty: nil, stopPx: triggerPrice, clOrdID: nil, pegOffsetValue: nil, pegPriceType: nil, ordType: OrderType.Stop.rawValue, timeInForce: nil, execInst: OrderExecutionInstruction.MarkPrice.rawValue, text: nil)
  }
}

