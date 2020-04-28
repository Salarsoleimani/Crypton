//
//  StartPositionUseCase.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import RxSwift

public protocol StartPositionUseCase {
	func currentPrice() -> Observable<PriceChangeModel>
	func placeOrder(order: CommonOrderProtocol, leverage: Double, isAutoReverse: Bool?) -> Observable<[OrderResponseModel]>
  func updateLeverage(leverage: Double, symbol: SymbolType) -> Observable<Void>
  func updateLossMargin(technicalLossPercent: Double)
}
