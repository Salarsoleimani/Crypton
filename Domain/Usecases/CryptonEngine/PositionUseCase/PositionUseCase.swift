//
//  PositionUseCase.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import RxSwift
public protocol PositionUseCase {
	var positions: BehaviorSubject<[PositionModel]> { get }
	func getPositions() -> Observable<[PositionModel]>
	func update(symbol: SymbolType, quantity: Double, liquidation: Double)
	func update(symbol: SymbolType, change: PriceChangeModel)
	func update(position: PositionModel)
	func update(leverage: Double, symbol: SymbolType) -> Observable<Void>
}
