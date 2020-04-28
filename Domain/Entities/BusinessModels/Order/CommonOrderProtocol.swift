//
//  CommonOrderProtocol.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/16/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation

public protocol CommonOrderProtocol {
	var direction: OrderSide { get }
	var symbol: String { get }
  var type: OrderType { get }
  
	func asBitmexRequestModel() -> OrderRequestModels.Place
}
