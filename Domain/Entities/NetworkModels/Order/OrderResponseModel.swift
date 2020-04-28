//
//  OrderResponseModel.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/25/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public struct OrderResponseModel: Codable {
  
  public var orderID: String
  
  ///Unique identifier for Order as assigned by the buy-side (institution, broker, intermediary etc.) (identified by SenderCompID (49) or OnBehalfOfCompID (5) as appropriate). Uniqueness must be guaranteed within a single trading day. Firms, particularly those which electronically submit multi-day orders, trade globally or throughout market close periods, should ensure uniqueness across days, for example by embedding a date within the ClOrdID field.
  public var clOrdID: String?
  
  ///Permits order originators to tie together groups of orders in which trades resulting from orders are associated for a specific purpose, for example the calculation of average execution price for a customer or to associate lists submitted to a broker as waves of a larger program trade.
  public var clOrdLinkID: String?
  
  ///Account mnemonic as agreed between buy and sell sides, e.g. broker and institution or investor/intermediary and fund manager.
  public var account: Double?
  public var symbol: String?
  public var side: String?
  public var simpleOrderQty: Double?
  public var orderQty: Double?
  public var price: Double?
  public var displayQty: Double?
  public var stopPx: Double?
  public var pegOffsetValue: Double?
  public var pegPriceType: String?
  public var currency: String?
  public var settlCurrency: String?
  public var ordType: String?
  public var timeInForce: String?
  public var execInst: String?
  public var contingencyType: String?
  public var exDestination: String?
  public var ordStatus: String?
  public var triggered: String?
  public var workingIndicator: Bool?
  public var ordRejReason: String?
  public var simpleLeavesQty: Double?
  public var leavesQty: Double?
  public var simpleCumQty: Double?
  public var cumQty: Double?
  public var avgPx: Double?
  public var multiLegReportingType: String?
  public var text: String?
  public var transactTime: Date?
  public var timestamp: Date?
  
  public init(orderID: String, clOrdID: String?, clOrdLinkID: String?, account: Double?, symbol: String?, side: String?, simpleOrderQty: Double?, orderQty: Double?, price: Double?, displayQty: Double?, stopPx: Double?, pegOffsetValue: Double?, pegPriceType: String?, currency: String?, settlCurrency: String?, ordType: String?, timeInForce: String?, execInst: String?, contingencyType: String?, exDestination: String?, ordStatus: String?, triggered: String?, workingIndicator: Bool?, ordRejReason: String?, simpleLeavesQty: Double?, leavesQty: Double?, simpleCumQty: Double?, cumQty: Double?, avgPx: Double?, multiLegReportingType: String?, text: String?, transactTime: Date?, timestamp: Date?) {
    
    self.orderID = orderID
    self.clOrdID = clOrdID
    self.clOrdLinkID = clOrdLinkID
    self.account = account
    self.symbol = symbol
    self.side = side
    self.simpleOrderQty = simpleOrderQty
    self.orderQty = orderQty
    self.price = price
    self.displayQty = displayQty
    self.stopPx = stopPx
    self.pegOffsetValue = pegOffsetValue
    self.pegPriceType = pegPriceType
    self.currency = currency
    self.settlCurrency = settlCurrency
    self.ordType = ordType
    self.timeInForce = timeInForce
    self.execInst = execInst
    self.contingencyType = contingencyType
    self.exDestination = exDestination
    self.ordStatus = ordStatus
    self.triggered = triggered
    self.workingIndicator = workingIndicator
    self.ordRejReason = ordRejReason
    self.simpleLeavesQty = simpleLeavesQty
    self.leavesQty = leavesQty
    self.simpleCumQty = simpleCumQty
    self.cumQty = cumQty
    self.avgPx = avgPx
    self.multiLegReportingType = multiLegReportingType
    self.text = text
    self.transactTime = transactTime
    self.timestamp = timestamp
  }
}

extension OrderResponseModel {
  public func asDomain() -> OrderModel {
    return OrderModel(symbol: self.symbol ?? SymbolType.BTCUSD.rawValue, type: self.ordType.map { OrderType(rawValue: $0) ?? OrderType.None } ?? OrderType.None, quantity: self.orderQty ?? 0, direction: self.side.map { OrderSide(rawValue: $0) ?? OrderSide.none } ?? OrderSide.none, limitPrice: self.price, orderId: orderID, leverage: nil, stopPrice: self.stopPx, isAutoReverse: true, technicalLossPercent: nil)
  }
}
