//
//  OrderTimeInForce.swift
//  Domain
//
//  Created by Salar Soleimani on 2019-07-27.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation

enum OrderTimeInForce: String {
  case Day, GoodTillCancel, ImmediateOrCancel, FillOrKill
}
