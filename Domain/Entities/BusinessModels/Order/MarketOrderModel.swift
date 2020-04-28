//
//  MarketOrderModel.swift
//  Domain
//
//  Created by Salar Soleimani on 7/16/19.
//  Copyright © 2019 Salar Soleimani. All rights reserved.
//

import Foundation

/// 🚲 Crypton Market Order Type
public struct MarketOrderModel: CommonOrderProtocol {  
  public let type: OrderType

  /// OrderSide. Valid options: Buy, Sell. Defaults to 'Buy' unless orderQty is negative.
  public let direction: OrderSide
  
  /// Instrument symbol. e.g. 'XBTUSD'.  public let type: OrderSide
  public let symbol: String
  
  /// Amount of contracts
  public let quantity: Double
  
  /**
   Initializes a new Crypton Stop Market Order Model.
   
   - Parameters:
   - type: OrderSide. Valid options: Buy, Sell. Defaults to 'Buy' unless orderQty is negative.
   - symbol: Instrument symbol. e.g. 'XBTUSD'.  public let type: OrderSide
   - quantity: Amount of contracts

   - Returns: MarketOrderModel
   */
  public init(type: OrderSide, symbol: String, quantity: Double) {
    self.direction = type
    self.symbol = symbol
    self.quantity = abs(quantity)
    self.type = OrderType.Market
  }
  
  /**
   Change the Crypton Market Order Model to OrderRequestNetworkModel
   
   - Parameter
   - Precondition
   - Author: Salar Soleimani
   */
  public func asBitmexRequestModel() -> OrderRequestModels.Place {
    return OrderRequestModels.Place(symbol: symbol, side: direction.rawValue, orderQty: quantity, price: nil, displayQty: nil, stopPx: nil, clOrdID: nil, pegOffsetValue: nil, pegPriceType: nil, ordType: OrderType.Market.rawValue, timeInForce: nil, execInst: nil, text: nil)
  }
}
