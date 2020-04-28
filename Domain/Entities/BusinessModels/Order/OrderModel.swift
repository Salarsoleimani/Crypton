//
//  OrderModel.swift
//  Domain
//
//  Created by Salar Soleimani on 2019-08-02.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public final class OrderModel: Codable {
  public var symbol: String
  public var type: OrderType?
  public var quantity: Double?
  public var direction: OrderSide
  public var limitPrice: Double?
	public var orderId: String?
  public var leverage: Double?
	public var stopPrice: Double?
	public var removing = false
  public var isAutoReverse: Bool?
  public var technicalLossPercent: Double?
	public init(symbol: String, direction: OrderSide) {
    self.symbol = symbol
		self.direction = direction
  }
  public init(symbol: String, type: OrderType?, quantity: Double?, direction: OrderSide, limitPrice: Double?, orderId: String, leverage: Double?, stopPrice: Double?, isAutoReverse: Bool?, technicalLossPercent: Double?) {
    self.symbol = symbol
		self.stopPrice = stopPrice
    self.type = type
    self.quantity = quantity
    self.direction = direction
    self.limitPrice = limitPrice
    self.orderId = orderId
    self.leverage = leverage
    self.isAutoReverse = isAutoReverse
    self.technicalLossPercent = technicalLossPercent
  }
}
extension OrderModel: Equatable {
  public static func == (lhs: OrderModel, rhs: OrderModel) -> Bool {
    return lhs.symbol == rhs.symbol
  }
}
