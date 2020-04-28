//
//  LeverageNetworkModel.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/25/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public enum LeverageNetworkModel: InteractiveModelType {
	
	typealias Response = PositionNetworkModel.Response
	
	public struct Request: Codable {
		public let symbol: String
		public let leverage: Double
		public init(symbol: String, leverage: Double) {
			self.symbol = symbol
			self.leverage = leverage
		}
	}
	
}

