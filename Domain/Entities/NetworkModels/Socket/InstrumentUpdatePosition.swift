//
//  InstrumentUpdatePosition.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/27/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public struct InstrumentUpdatePosition: Codable {
	public let table: String
	public let action: String
	public let data: [Row]
}
extension InstrumentUpdatePosition {
	public typealias Row = PositionNetworkModel.Response
}
