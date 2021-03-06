//
//  OrderType.swift
//  Domain
//
//  Created by Salar Soleimani on 2019-07-25.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation

public enum OrderType: String, Codable {
  /// The default order type. Specify an orderQty and price.
  case Limit
  
  /// Like a Stop Market, but enters a Limit order instead of a Market order. Specify an orderQty, stopPx, and price.
  case StopLimit
  
  /// A traditional Market order. A Market order will execute until filled or your bankruptcy price is reached, at which point it will cancel.
  case Market
  
  /// A Stop Market order. Specify an orderQty and stopPx. When the stopPx is reached, the order will be entered into the book. On sell orders, the order will trigger if the triggering price is lower than the stopPx. On buys, higher.
  case Stop
  
  /// Stop orders do not consume margin until triggered. Be sure that the required margin is available in your account so that it may trigger fully.
  case Note
  
  /// Stops don't require an orderQty. See Execution Instructions below.
  case Close
  
  /// Similar to a Stop, but triggers are done in the opposite direction. Useful for Take Profit orders.
  case MarketIfTouched
  
  /// As above; use for Take Profit Limit orders.
  case LimitIfTouched
  
  /// the Crypton Usage for optional handling
  case None
}
