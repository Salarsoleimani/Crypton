//
//  ControlPanelUseCase.swift
//  NetworkPlatform
//
//  Created by Behrad Kazemi on 7/23/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import Domain
import RxSwift

public struct ControlPanelUseCase: Domain.ControlPanelUseCase {

	private let manager: Domain.CryptonEngine
	let disposeBag = DisposeBag()
	public init (manager: Domain.CryptonEngine) {
		self.manager = manager
	}
	
	public func currentPrice() -> Observable<PriceChangeModel> {
		return manager.currentPrice(symbol: SymbolType.BTCUSD)
	}
	public func refreshPositions() -> Observable<[PositionModel]> {
		return manager.refreshPositions()
	}
	public func updateRatio(ratio: Double) {
		return manager.update(ProfitRatio: ratio)
	}
	public func panelData() -> Observable<ControlPanelDataModel> {
		return manager.controlInfos.asObservable().map { (info) -> PositionControlInfo? in
			return info.first
			}.unwrappedOptional().map { (info) -> ControlPanelDataModel in
				let totalProfit = PriceChangeModel(price: info.position.profitPercent * 100, type: ChangingType.representType(double: info.position.profitPercent))
				let isAutoReverse = info.autoReverse
				let isAutoUpdate = info.autoUpdate
				let position = info.position
				return ControlPanelDataModel(currentProfit: PriceChangeModel(price: position.profitPercent, type: ChangingType.representType(double: position.profitPercent)), side: position.side, quantity: String(position.quantity), totalProfit: totalProfit, stopLossTrigger: 9800.0, leverage: position.leverage, isAutoReverse: isAutoReverse, isAutoUpdate: isAutoUpdate, symbol: position.symbol)
		}
	}
	public	func endPosition(symbol: SymbolType) -> Observable<Void> {
		return manager.forceClose(symbol: symbol)
	}
	public 	func update(autoReverse: Bool, forSymbol symbol: SymbolType) {
		manager.update(autoReverse: autoReverse, symbol: symbol)
	}
}
