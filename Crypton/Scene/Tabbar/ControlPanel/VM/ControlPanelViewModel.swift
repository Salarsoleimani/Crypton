//
//  ControlPanelViewModel.swift
//  Crypton
//
//  Created by Behrad Kazemi on 7/21/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import Domain
import RxCocoa
import RxSwift
final class ControlPanelViewModel: ViewModelType {

	public let usecase: ControlPanelUseCase
	private let navigator: ControlPanelNavigator
	init(useCase: ControlPanelUseCase, navigator: ControlPanelNavigator) {
    self.usecase = useCase
		self.navigator = navigator
  }
	
	func transform(input: Input) -> Output {
		let showHeader = input.scrollViewOffset.map {$0.y > 32 ? true : false}

		let data = usecase.panelData()
		let currentChange = usecase.currentPrice().asDriverOnErrorJustComplete()
		let side = data.map{$0.side}.asDriverOnErrorJustComplete()
		let quantity = data.map{$0.quantity}.asDriverOnErrorJustComplete()
		let totalProfit = data.map{$0.totalProfit}.asDriverOnErrorJustComplete()
		let stopLoss = data.map{String($0.stopLossTrigger)}.asDriverOnErrorJustComplete()
		let leverage = data.map{String($0.leverage)}.asDriverOnErrorJustComplete()
		let isAutoReverse = data.map{$0.isAutoReverse}.asDriverOnErrorJustComplete()
		let isAutoUpdate = data.map{$0.isAutoUpdate}.asDriverOnErrorJustComplete()
		let currentProfit = data.map{$0.currentProfit}.asDriverOnErrorJustComplete()
		let lossMargin = Observable.just(Constants.Defaults.acceptableLossPercent()).asDriverOnErrorJustComplete()
		
		let autoReverseAction = input.autoReverse.do(onNext: { [usecase](isAutoReverse) in
			usecase.update(autoReverse: isAutoReverse, forSymbol: SymbolType.BTCUSD)
		}).mapToVoid()
		let endPosition = input.endButton.asObservable().flatMapLatest { [usecase](_) -> Observable<Void> in
			return usecase.endPosition(symbol: .BTCUSD)
		}
		let updateRatio = input.ratio.debounce(1).do(onNext: { [usecase](ratio) in
			usecase.updateRatio(ratio: Double(ratio))
		}).asDriver().mapToVoid()
		
		let ratioText = Driver.combineLatest(input.ratio, lossMargin).map({ (ratio, lossMargin) -> String in
			let newLossMargin = Double(ratio) * lossMargin
			return "\(String(format: "%.2f", ratio)) - margin: \(String(format: "%.4f", newLossMargin))%"
		})

		let refreshAction = input.refreshPositions.asObservable().flatMapLatest { [usecase](_) -> Observable<Void> in
			return usecase.refreshPositions().mapToVoid()
		}
		return Output(updateRatio: updateRatio, showScrollViewHeader: showHeader, currentChange: currentChange, positionSide: side, quantity: quantity, totalProfit: totalProfit, stopLossTrigger: stopLoss, leverage: leverage, isAutoReverse: isAutoReverse, ratiostring: ratioText.asDriver(), isAutoUpdate: isAutoUpdate, currentProfit: currentProfit, controlInfo: data.asDriverOnErrorJustComplete(), refreshPositionsAction: refreshAction, endPosition: endPosition, autoReverseAction: autoReverseAction.asDriver())
	}

}
extension ControlPanelViewModel {
	public struct Input {
		let scrollViewOffset: Driver<CGPoint>
		let endButton: Driver<Void>
		let autoReverse: Driver<Bool>
		let autoUpdate: Driver<Bool>
		let ratio: Driver<Float>
		let refreshPositions: Driver<Void>
	}
	
	public struct Output {
		public let updateRatio: Driver<Void>
		public let showScrollViewHeader: Driver<Bool>
		public let currentChange: Driver<PriceChangeModel>
		public let positionSide: Driver<OrderSide>
		public let quantity: Driver<String>
		public let totalProfit: Driver<PriceChangeModel>
		public let stopLossTrigger: Driver<String>
		public let leverage: Driver<String>
		public let isAutoReverse: Driver<Bool>
		public let ratiostring: Driver<String>
		public let isAutoUpdate: Driver<Bool>
		public let currentProfit: Driver<PriceChangeModel>
		public let controlInfo: Driver<ControlPanelDataModel>
		public let refreshPositionsAction: Observable<Void>
		public let endPosition: Observable<Void>
		public let autoReverseAction: Driver<Void>
	}
}
