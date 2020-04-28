//
//  PositionUseCase.swift
//  NetworkPlatform
//
//  Created by Behrad Kazemi on 7/25/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import Domain
import RxSwift

public final class PositionUseCase: Domain.PositionUseCase {
	public var positions: BehaviorSubject<[PositionModel]>
	
	private let network: PositionNetwork
	private var positionsArray: [PositionModel]{
		didSet {
			positions.onNext(positionsArray)
		}
	}
	init(network: PositionNetwork) {
		self.network = network
		self.positions = BehaviorSubject(value: [PositionModel]())
		self.positionsArray = [PositionModel]()
	}
	
	public func getPositions() -> Observable<[PositionModel]> {
		return network.getInfo().filter{$0.count > 0}.map({ (items) -> [PositionModel] in
			let posItems = items.compactMap{$0.asDomain()}
			self.positionsArray = posItems
			return posItems
		})
	}
	
	public func update(leverage: Double, symbol: SymbolType) -> Observable<Void> {
		let res = network.leverage(requestParameters: LeverageNetworkModel.Request(symbol: symbol.rawValue, leverage: leverage))
		return res.mapToVoid()
	}
	
	public func update(symbol: SymbolType, quantity: Double, liquidation: Double) {
		if let index = positionsArray.firstIndex(where: { (item) -> Bool in
			item.symbol == symbol.rawValue
		}){
			positionsArray[index].quantity = quantity
			positionsArray[index].liquidationPrice = liquidation
			let nextObject = positionsArray
			positions.onNext(nextObject)
		}
	}
	
	public func update(symbol: SymbolType, change: PriceChangeModel) {
		
		if let index = positionsArray.firstIndex(where: { (item) -> Bool in
			item.symbol == symbol.rawValue
		}){
			
			positionsArray[index].update(currentPrice: change.price)
			let nextObject = positionsArray
			
			positions.onNext(nextObject)
			return
		}
	}
	
	public func update(position: PositionModel) {
		if position.leverage > 0 {
			if let index = positionsArray.firstIndex(where: { (item) -> Bool in
				item.symbol == position.symbol
			}){
				positionsArray[index] = position
				let nextObject = positionsArray
				positions.onNext(nextObject)
				return
			}
			positionsArray.append(position)
			let nextObject = positionsArray
			positions.onNext(nextObject)
			return
		}
		if let symbol = SymbolType(rawValue: position.symbol){
			update(symbol: symbol, quantity: position.quantity, liquidation: position.liquidationPrice)
			return
		}
	}
}
