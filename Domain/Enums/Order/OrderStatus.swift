//
//  OrderStatus.swift
//  Domain
//
//  Created by Behrad Kazemi on 8/8/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public enum OrderStatus: String, Codable{
	case new = "New"
	case filled = "Filled"
	case canceled = "Canceled"
}
