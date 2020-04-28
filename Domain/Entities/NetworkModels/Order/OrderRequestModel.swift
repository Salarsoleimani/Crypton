//
//  OrderRequestModel.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/25/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation

public enum OrderRequestModels {
  
  /// Implementation Note: see https://www.bitmex.com/api/explorer/#!/Order/Order_new
  public struct Place: Codable {
    /// Instrument symbol. e.g. 'XBTUSD'.
    public let symbol: String
    
    /// OrderSide. Valid options: Buy, Sell. Defaults to 'Buy' unless orderQty is negative.
    public let side: String?
    
    /// Order quantity in units of the instrument (i.e. contracts).
    public let orderQty: Double?
    
    /// Optional limit price for 'Limit', 'StopLimit', and 'LimitIfTouched' orders.
    public let price: Double?
    
    /// Optional quantity to display in the book. Use 0 for a fully hidden order.
    public let displayQty: Double?
    
    /// Optional trigger price for 'Stop', 'StopLimit', 'MarketIfTouched', and 'LimitIfTouched' orders. Use a price below the current price for stop-sell orders and buy-if-touched orders. Use execInst of 'MarkPrice' or 'LastPrice' to define the current price used for triggering.
    public let stopPx: Double?
    
    /// Optional Client Order ID. This clOrdID will come back on the order and any related executions.
    public let clOrdID: String?
    
    /// Optional trailing offset from the current price for 'Stop', 'StopLimit', 'MarketIfTouched', and 'LimitIfTouched' orders; use a negative offset for stop-sell orders and buy-if-touched orders. Optional offset from the peg price for 'Pegged' orders.
    public let pegOffsetValue: Double?
    
    /// Optional peg price type. Valid options: LastPeg, MidPricePeg, MarketPeg, PrimaryPeg, TrailingStopPeg.
    public let pegPriceType: String?
    
    /// OrderType. Valid options: Market, Limit, Stop, StopLimit, MarketIfTouched, LimitIfTouched, Pegged. Defaults to 'Limit' when price is specified. Defaults to 'Stop' when stopPx is specified. Defaults to 'StopLimit' when price and stopPx are specified.
    public let ordType: String
    
    /// OrderTimeInForce. Valid options: Day, GoodTillCancel, ImmediateOrCancel, FillOrKill. Defaults to 'GoodTillCancel' for 'Limit', 'StopLimit', and 'LimitIfTouched' orders.
    public let timeInForce: String?
    
    /// Optional OrderExecutionInstruction. Valid options: ParticipateDoNotInitiate, AllOrNone, MarkPrice, IndexPrice, LastPrice, Close, ReduceOnly, Fixed. 'AllOrNone' instruction requires displayQty to be 0. 'MarkPrice', 'IndexPrice' or 'LastPrice' instruction valid for 'Stop', 'StopLimit', 'MarketIfTouched', and 'LimitIfTouched' orders.
    public let execInst: String?
    
    /// Optional order annotation. e.g. 'Take profit'.
    public let text: String?
  }
  
  /// Implementation Note: Either an orderID or a clOrdID must be provided.
  public struct Remove: Codable {
    /// Order ID. This orderId will come back on the order and any related executions.
    public let orderID: String

    /// Optional Client Order ID. This clOrdID will come back on the order and any related executions.
    public let clOrdID: String?
    
    /// Optional cancellation annotation. e.g. 'Spread Exceeded'.
    public let text: String?
		
		public init(orderID: String, clOrdID: String?, text: String?){
			self.orderID = orderID
			self.clOrdID = clOrdID
			self.text = text
		}
  }
  
  public struct RemoveAll: Codable {
    /// Optional symbol. If provided, only cancels orders for that symbol.
    public let symbol: String?
    
    /// Optional filter for cancellation. Use to only cancel some orders, e.g. {"side": "Buy"}.
    public let filter: String?
    
    /// Optional cancellation annotation. e.g. 'Spread Exceeded'
    public let text: String?
		public init(symbol: String?, filter: String?, text: String?) {
			self.symbol = symbol
			self.filter = filter
			self.text = text
		}
  }
  
  /// Implementation Notes: Send an orderID or origClOrdID to identify the order you wish to amend. Both order quantity and price can be amended. Only one qty field can be used to amend. Use the leavesQty field to specify how much of the order you wish to remain open. This can be useful if you want to adjust your position's delta by a certain amount, regardless of how much of the order has already filled. > A leavesQty can be used to make a "Filled" order live again, if it is received within 60 seconds of the fill. Like order placement, amending can be done in bulk. Simply send a request to PUT /api/v1/order/bulk with a JSON body of the shape: {"orders": [{...}, {...}]}, each object containing the fields used in this endpoint.
  public struct Edit: Codable {
    /// the order id of the order you want to edit
    public let orderID: String
    
    /// Client Order ID. See POST /order.
    public let origClOrdID: String?
    
    /// Optional new Client Order ID, requires origClOrdID.
    public let clOrdID: String?
    
    /// Optional order quantity in units of the instrument (i.e. contracts).
    public let orderQty: Double?
    
    /// Optional leaves quantity in units of the instrument (i.e. contracts). Useful for amending partially filled orders.
    public let leavesQty: Double?
    
    /// Optional limit price for 'Limit', 'StopLimit', and 'LimitIfTouched' orders.
    public let price: Double?
    
    /// Optional trigger price for 'Stop', 'StopLimit', 'MarketIfTouched', and 'LimitIfTouched' orders. Use a price below the current price for stop-sell orders and buy-if-touched orders
    public let stopPx: Double?
    
    /// Optional trailing offset from the current price for 'Stop', 'StopLimit', 'MarketIfTouched', and 'LimitIfTouched' orders; use a negative offset for stop-sell orders and buy-if-touched orders. Optional offset from the peg price for 'Pegged' orders.
    public let pegOffsetValue: Double?
		
    /// Optional amend annotation. e.g. 'Adjust skew'.
    public let text: String?

    public init(orderID: String, clOrdID: String?, origClOrdID: String?, orderQty: Double?, leavesQty: Double?, price: Double?, stopPx: Double?, pegOffsetValue: Double?, text: String?) {
			self.orderID = orderID
			self.clOrdID = clOrdID
			self.origClOrdID = origClOrdID
			self.orderQty = orderQty
			self.leavesQty = leavesQty
			self.price = price
			self.stopPx = stopPx
			self.pegOffsetValue = pegOffsetValue
      self.text = text
		}
  }
  
  /// Implementation Notes: This endpoint is used for placing bulk orders. Valid order types are Market, Limit, Stop, StopLimit, MarketIfTouched, LimitIfTouched, and Pegged. Each individual order object in the array should have the same properties as an individual POST /order call. This endpoint is much faster for getting many orders into the book at once. Because it reduces load on BitMEX systems, this endpoint is ratelimited at ceil(0.1 * orders). Submitting 10 orders via a bulk order call will only count as 1 request, 15 as 2, 32 as 4, and so on. For now, only application/json is supported on this endpoint.
  public struct Bulk: Codable {
    /// An array of orders.
    public let orders: [Place]
    
    public init(orders: [Place]) {
      self.orders = orders
    }
  }
}
