//
//  CryptonEngine.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import RxSwift
public protocol CryptonEngine {
	
	var controlInfos: BehaviorSubject<[PositionControlInfo]> { get }
	func update(autoUpdate: Bool, symbol: SymbolType)
	func update(autoReverse: Bool, symbol: SymbolType)
	func update(lossMargin: Double, symbol: SymbolType)
  func update(LossMarginWithTechnicalLossPercent: Double)
	func update(leverage: Double, symbol: SymbolType) -> Observable<Void>
	func startEngine()
	func forceClose(symbol: SymbolType) -> Observable<Void> 
	func placeOrder(order: CommonOrderProtocol) -> Observable<OrderResponseModel>
  func startPosition(order: CommonOrderProtocol, leverage: Double, isAutoReverse: Bool) -> Observable<[OrderResponseModel]>
	func getOrders(symbol: SymbolType) -> Observable<[OrderModel]>
	func currentPrice(symbol: SymbolType) -> Observable<PriceChangeModel>
	func refreshPositions() -> Observable<[PositionModel]>
	func update(ProfitRatio ratio: Double)
}
