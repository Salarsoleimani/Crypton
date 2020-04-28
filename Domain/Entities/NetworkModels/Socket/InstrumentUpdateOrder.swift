//
//  InstrumentUpdateOrder.swift
//  Domain
//
//  Created by Salar Soleimani on 8/5/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public struct InstrumentUpdateOrder: Codable {
  public let table: String
  public let action: String
  public let data: [Row]
}
extension InstrumentUpdateOrder {
  public typealias Row = OrderResponseModel
}
