//
//  ErrorHub.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public enum ErrorHub {
	public enum codes: Int {
		case internalError = 1000
		case wrongFormat = 1001
		case notAuthorize = 1002
		case nullData = 1003
		case notInitialized = 1004
		case conditionNotMeeted = 1005
		case externalError = -1000
	}
	public static let acceptableErrorPercent = { return 1.5}
}
