//
//  OrderSide.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/16/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public enum OrderSide: String, Codable{
	case long = "Buy"
	case short = "Sell"
  case none = "None"
	public func reverse() -> OrderSide {
		return (self == .long) ? .short : .long
	}
	public func sign() -> Int{
		return (self == .long) ? 1 : -1
	}
}
