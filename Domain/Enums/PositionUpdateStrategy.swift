//
//  PositionUpdateStrategy.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/16/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public enum PositionUpdateStrategy {
	case autoRevert // 2
	case forceClose // 1
	case positionProtection // 3
//	case autoLeverageUpdate
}
