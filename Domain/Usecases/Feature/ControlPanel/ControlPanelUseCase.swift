//
//  ControlPanelUseCase.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/23/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import RxSwift

public protocol ControlPanelUseCase {
	func currentPrice() -> Observable<PriceChangeModel>
	func panelData() -> Observable<ControlPanelDataModel>
	func refreshPositions() -> Observable<[PositionModel]>
	func updateRatio(ratio: Double)
	func endPosition(symbol: SymbolType) -> Observable<Void>
	func update(autoReverse: Bool, forSymbol symbol: SymbolType)
}
