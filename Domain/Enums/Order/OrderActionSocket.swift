//
//  OrderActionSocket.swift
//  Domain
//
//  Created by Behrad Kazemi on 8/8/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public enum OrderActionSocket: String, Codable {
	case insert = "insert"
	case update = "update"
}
