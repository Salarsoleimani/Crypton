//
//  PositionControlInfo.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public final class PositionControlInfo {
	public var position: PositionModel
	public var autoReverse = true
	public var autoUpdate = true
	public var lossMargin: Double
	
	public init (position: PositionModel, lossMargin: Double) {
		self.position = position
		self.lossMargin = lossMargin
	}
}
