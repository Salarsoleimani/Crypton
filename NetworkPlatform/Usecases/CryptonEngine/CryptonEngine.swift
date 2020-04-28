//
//  CryptonEngine.swift
//  NetworkPlatform
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import RxCocoa
public final class CryptonEngine: Domain.CryptonEngine {
	
	private let scheduler: ConcurrentDispatchQueueScheduler
	public var controlInfos: BehaviorSubject<[PositionControlInfo]>
	private var controlInfoArray: [PositionControlInfo]{
		didSet {
			controlInfos.onNext(controlInfoArray)
		}
	}
	private var updateRatio = 1.0
	private let positionUseCase: Domain.PositionUseCase
	private let dataStream: Domain.DataStreamUsecase
	private let orderUseCase: Domain.OrderUsecase
	private let disposeBag = DisposeBag()
	private var defaultBTCOrderPrice = -1.0
	private var removingPositions = [SymbolType]()
	public init(orderUC: Domain.OrderUsecase, dataStreamUC: Domain.DataStreamUsecase, positionUC: Domain.PositionUseCase) {
		self.positionUseCase = positionUC
		self.orderUseCase = orderUC
		self.scheduler = ConcurrentDispatchQueueScheduler(qos: DispatchQoS(qosClass: DispatchQoS.QoSClass.background, relativePriority: 1))
		self.dataStream = dataStreamUC
		self.controlInfos = BehaviorSubject(value: [PositionControlInfo]())
		self.controlInfoArray = [PositionControlInfo]()
		
	}
	
	public func update(autoUpdate: Bool, symbol: SymbolType) {
		if let index = controlInfoArray.firstIndex(where: { (info) -> Bool in
			info.position.symbol == symbol.rawValue
		}){
			controlInfoArray[index].autoUpdate = autoUpdate
			let nextObject = controlInfoArray
			controlInfos.onNext(nextObject)
		}
	}
	
	public func update(autoReverse: Bool, symbol: SymbolType) {
		if let index = controlInfoArray.firstIndex(where: { (info) -> Bool in
			info.position.symbol == symbol.rawValue
		}){
			controlInfoArray[index].autoReverse = autoReverse
			let nextObject = controlInfoArray
			controlInfos.onNext(nextObject)
		}
	}
	
	public func update(leverage: Double, symbol: SymbolType) -> Observable<Void> {
		return positionUseCase.update(leverage: leverage, symbol: symbol)
	}
	
	public func forceClose(symbol: SymbolType) -> Observable<Void> {
		removingPositions.append(symbol)
		let result = positionUseCase.positions.map { (items) -> PositionModel? in
			return items.first(where: { (position) -> Bool in
				position.symbol == symbol.rawValue
			})
			}.unwrappedOptional()
		
		
		let stopPosition = result.flatMapLatest { [orderUseCase](position) -> Observable<Void> in
			let closeOrder = MarketOrderModel(type: position.side.reverse(), symbol: position.symbol, quantity: position.quantity)
			return orderUseCase.place(order: closeOrder.asBitmexRequestModel()).mapToVoid()
			}.do(onNext: { [unowned self](_) in
				if let index = self.controlInfoArray.firstIndex(where: { (controlInfo) -> Bool in
					return controlInfo.position.symbol == symbol.rawValue
				}){
					self.controlInfoArray.remove(at: index)
					let nextObject = self.controlInfoArray
					self.controlInfos.onNext(nextObject)
					return
				}
			})
		return stopPosition
	}
	
	public func update(lossMargin: Double, symbol: SymbolType) {
		if lossMargin < 1 {
			return
		}
		controlInfoArray.filter{$0.position.symbol == symbol.rawValue}.forEach { (item) in
			item.lossMargin = lossMargin
		}
		let nextObject = controlInfoArray
		controlInfos.onNext(nextObject)
	}
	public func refreshPositions() -> Observable<[PositionModel]>{
		return positionUseCase.getPositions()
	}
	public func update(ProfitRatio ratio: Double){
		print("\nratio updatetd to \(ratio)\n")
		if ratio > 0 {
			self.updateRatio = ratio
		}
	}
  public func update(LossMarginWithTechnicalLossPercent: Double) {
    let leverage = controlInfoArray.count > 0 ? controlInfoArray[0].position.leverage : 1
    let newLossMargin = leverage * LossMarginWithTechnicalLossPercent
    if controlInfoArray.count > 0 {
      controlInfoArray[0].lossMargin = newLossMargin
      let nextObject = controlInfoArray
      controlInfos.onNext(nextObject)
    }
    
  }
	public func startPosition(order: CommonOrderProtocol, leverage: Double, isAutoReverse: Bool) -> Observable<[OrderResponseModel]>{
		
		updateOrders()
		let bulkOrders = [order].map { (order) -> OrderRequestModels.Place in
			order.asBitmexRequestModel()
		}
		print("\n\nStarting Position -> settings orders: \(bulkOrders)\n\n")
		return orderUseCase.placeBulkOrders(orders: OrderRequestModels.Bulk(orders: bulkOrders))
	}
	
	public func placeOrder(order: CommonOrderProtocol) -> Observable<OrderResponseModel> {
		return orderUseCase.place(order: order.asBitmexRequestModel())
	}
	
	public func getOrders(symbol: SymbolType) -> Observable<[OrderModel]> {
		return orderUseCase.getOrders(symbol: symbol.rawValue)
	}
	
	public func currentPrice(symbol: SymbolType) -> Observable<PriceChangeModel> {
		let instrumentUpdate: Observable<InstrumentUpdateSymbol> = dataStream.observe()
		return instrumentUpdate.map { (instrument) -> InstrumentUpdateSymbol.Row? in
			if instrument.table == "instrument" {
				return instrument.data.filter{$0.symbol == symbol.rawValue}.first
			}
			return nil
			}.filter{$0?.lastPrice != nil}.map {
				
				PriceChangeModel(price: $0!.lastPrice!, type: ChangingType.representType(tick: $0!.lastTickDirection ?? .ZeroPlusTick))
		}
	}
	
	public func startEngine() {
		dataStream.startStreaming().do(onNext: { [weak self](connected) in
			self?.startStreamingUpdate()
			self?.startUpdatingStopLosses()
		}).subscribe().disposed(by: disposeBag)
	}
	
	//MARK: - Private Funcs
}

extension CryptonEngine {
	private func makeControlInfos(with positions: [PositionModel]) {
		
		positions.forEach({ (position) in
			if let index = controlInfoArray.firstIndex(where: { (controlInfo) -> Bool in
				return controlInfo.position == position
			}){
				controlInfoArray[index].position = position
				let nextObject = controlInfoArray
				controlInfos.onNext(nextObject)
				return
			}
			let controlInfo = PositionControlInfo(position: position, lossMargin: Constants.Defaults.acceptableLossPercent())
			controlInfoArray.append(controlInfo)
			let nextObject = controlInfoArray
			controlInfos.onNext(nextObject)
		})
	}
	private func updateOrders() {
		let instrumentUpdate: Observable<InstrumentUpdateOrder> = dataStream.observe()
		
		let filledInstrumentUpdates = instrumentUpdate.filter { (item) -> Bool in
			if let safeStatus = item.data.first?.ordStatus, safeStatus == "Filled"{
				return true
			}
			return false
		}
		let positionsUpdate = filledInstrumentUpdates.flatMapLatest { [positionUseCase](item) -> Observable<[PositionModel]> in
			return positionUseCase.getPositions()
		}
		Observable.zip(positionsUpdate, filledInstrumentUpdates).do(onNext: { [makeControlInfos](positions, _) in
			makeControlInfos(positions)
		}).map { (positions, item) -> InstrumentUpdateOrder in
			
			return item
			}.flatMapLatest({ [unowned self ,orderUseCase](item) -> Observable<Void> in
				print("\nthe subscribe filled!! instrument update:\n \(item)")
				self.updateRatio = 1.0
				if let orderResp = item.data.first{
					if !self.removingPositions.contains(SymbolType(rawValue: orderResp.symbol ?? SymbolType.BTCUSD.rawValue)!){
						
						orderUseCase.updateOrders(orderFilled: orderResp)
						let targetPosition = self.controlInfoArray.filter{$0.position.symbol == orderResp.symbol}
						if let controlInfoItem = targetPosition.first{
							
							let newMargin = Double(controlInfoItem.position.side.reverse().sign()) * (controlInfoItem.lossMargin * self.updateRatio)
							let desiredPrice = ( 1 + newMargin / (controlInfoItem.position.leverage * 100)) * controlInfoItem.position.lastPrice
							print("--------------------\nNew stop Loss added at price of : \(desiredPrice)\n------------------\n")
							let quantity = controlInfoItem.autoReverse ? 2 * controlInfoItem.position.quantity : controlInfoItem.position.quantity
							let newStopLoss = StopMarketOrderModel(type: controlInfoItem.position.side.reverse(), symbol: controlInfoItem.position.symbol, triggerPrice: desiredPrice, quantity: abs(quantity))
							
							return orderUseCase.place(order: newStopLoss.asBitmexRequestModel(), withDelay: 1.5).mapToVoid()
						}
					}else {
						return orderUseCase.cancelAllOrders(requestParameter: OrderRequestModels.RemoveAll(symbol: orderResp.symbol, filter: nil, text: "cancel from Crypton!")).do(onNext: { [weak self](_) in
							if let engine = self{
								engine.removingPositions.removeAll()
							}
							
						})
					}
				}
				
				return Observable.just(())
			}).subscribe().disposed(by: disposeBag)
		
		
		
		let canceledInstrumentUpdates = instrumentUpdate.filter { (item) -> Bool in
			if let safeStatus = item.data.first?.ordStatus, safeStatus == OrderStatus.canceled.rawValue{
				return true
			}
			return false
		}
		canceledInstrumentUpdates.subscribe(onNext: { [orderUseCase] (item) in
			if let orderResp = item.data.first {
				orderUseCase.updateOrders(orderCanceled: orderResp)
			}
		}).disposed(by: disposeBag)
		
		
		let insertedInstrumentalUpdate = instrumentUpdate.filter { $0.action == OrderActionSocket.insert.rawValue}
		insertedInstrumentalUpdate.subscribe(onNext: { [orderUseCase](item) in
			print("the subscribe filtered instrument update: \(item)")
			if let orderResp = item.data.first {
				orderUseCase.addNewOrder(newOrder: orderResp)
			}
		}).disposed(by: disposeBag)
	}
	private func startUpdatingStopLosses() {
		//Combile latest data of controlInfos and current available orders on bitmex
		let watch = Observable.combineLatest(controlInfos, orderUseCase.orders).map { [orderUseCase, unowned self] (controlItems, orders) -> [Observable<Void>] in
			
			
			//Checking each position's orders and update them if conditions meeted
			let responses = controlItems.compactMap({ (controlInfoItem) -> Observable<Void>? in
				
				//				if orders.count == 0 {
				//					let newMargin = Double(controlInfoItem.position.side.reverse().sign()) * (controlInfoItem.lossMargin * self.stopLossUpdateRatio)
				//					let changePercent = ( 1 + newMargin / (controlInfoItem.position.leverage * 100))
				//					let	desiredPrice = controlInfoItem.position.profitPercent > 0 ? changePercent * controlInfoItem.position.lastPrice : changePercent * controlInfoItem.position.entryPointPrice
				//					print("--------------------\nNew stop Loss added at price of : \(desiredPrice)\n------------------\n")
				//					let quantity = controlInfoItem.autoReverse ? 2 * controlInfoItem.position.quantity : controlInfoItem.position.quantity
				//					let newStopLoss = StopMarketOrderModel(type: controlInfoItem.position.side.reverse(), symbol: controlInfoItem.position.symbol, triggerPrice: desiredPrice, quantity: abs(quantity))
				//
				//					return self.orderUseCase.place(order: newStopLoss.asBitmexRequestModel(), withDelay: 1).mapToVoid()
				//				}
				
				//Finding StopLoss between orders of a symbol
				return orders.filter({ (item) -> Bool in
					if let stopPx = item.stopPrice {
						let hasCorrectSymbol = item.symbol == controlInfoItem.position.symbol
						let priceChecked = (controlInfoItem.position.lastPrice - stopPx) * Double(controlInfoItem.position.side.sign()) > 0
						return hasCorrectSymbol && priceChecked
					}
					return false
				}).compactMap({ (stopLoss) -> Observable<Void>? in
					//Checking StopLoss Price to update if needed:
					let percentedLeverage = controlInfoItem.position.leverage * 100
					let difference = abs(stopLoss.stopPrice! - controlInfoItem.position.lastPrice) //difference between current price and stoploss
					let currentMarginPercent = (difference / stopLoss.stopPrice!) * percentedLeverage //percent between stopLoss and current symbol price
					var shouldUpdateStopLoss = currentMarginPercent > controlInfoItem.lossMargin * self.updateRatio + ErrorHub.acceptableErrorPercent() //if currentMargin is bigger that our specific lossMargin, we need to update the stopLoss
					
					//if autoReverse was 'true', the quantity of Order must be exact double of position's quantity
					if let safeQuantity = stopLoss.quantity, ((controlInfoItem.autoReverse && abs(safeQuantity) != abs(2 * controlInfoItem.position.quantity)) || (!controlInfoItem.autoReverse && abs(safeQuantity) != abs(controlInfoItem.position.quantity))){
						shouldUpdateStopLoss = true
					}
					
					if shouldUpdateStopLoss, !orderUseCase.isRequesting {
						
						let newMargin = Double(controlInfoItem.position.side.reverse().sign()) * controlInfoItem.lossMargin * self.updateRatio
						let desiredPrice = ( 1 + newMargin / percentedLeverage) * controlInfoItem.position.lastPrice
						let quantity = controlInfoItem.autoReverse ? 2 * controlInfoItem.position.quantity : controlInfoItem.position.quantity
						let newStopLoss = StopMarketOrderModel(type: controlInfoItem.position.side.reverse(), symbol: stopLoss.symbol, triggerPrice: desiredPrice, quantity: abs(quantity))
						print("\n\n\n\n---------------------\nUPDATE STOP LOSS: \ncurrentMargin: \(currentMarginPercent)\nnewMargin: \(newMargin)\ndesiredPrice: \(desiredPrice)\nquantity: \(quantity)\nleverage: \(percentedLeverage)\nlossMargin: \(controlInfoItem.lossMargin)\n------------------------\n\n\n\n")
						return orderUseCase.updateStopLoss(currentOrder: stopLoss , stopLossOrder: newStopLoss.asBitmexRequestModel())
					}
					return nil
				}).first
				
			})
			
			return responses
			//			responses.forEach({ (item) in
			//				item.subscribe().disposed(by: self.disposeBag)
			//			})
			//
			
		}
		watch.subscribe(onNext: { [unowned self](observables) in
			observables.forEach({ (item) in
				item.subscribe().disposed(by: self.disposeBag)
			})
		}).disposed(by: disposeBag)
	}
	
	private func startStreamingUpdate(){
		//Subscribe required topics on bitmex socket
		dataStream.subscribe(topics: [Constants.SocketSubscriptionTopics.Position.rawValue, Constants.SocketSubscriptionTopics.XBTPrice.rawValue, Constants.SocketSubscriptionTopics.Margin.rawValue, Constants.SocketSubscriptionTopics.Order.rawValue, Constants.SocketSubscriptionTopics.QuoteBin1m.rawValue])
		
		//Update positions and orders
		positionUseCase.getPositions().flatMapLatest { [orderUseCase](positions) -> Observable<[OrderModel]> in
			let orderUpdates = positions.map({ (position) -> Observable<[OrderModel]> in
				return orderUseCase.getOrders(symbol: position.symbol)
			})
			let result = Observable.concat(orderUpdates)
			return result
			}.subscribe().disposed(by: disposeBag)
		
		//Streaming current Bitcoin Price and update Position datas
		currentPrice(symbol: SymbolType.BTCUSD).subscribe(onNext: { [positionUseCase](change) in
			self.defaultBTCOrderPrice = change.price
			positionUseCase.update(symbol: SymbolType.BTCUSD, change: change)
		}).disposed(by: disposeBag)
		
		//Streaming events on positions
		let positionUpdate: Observable<InstrumentUpdatePosition> = dataStream.observe()
		positionUpdate.map{$0.data.first}.unwrappedOptional().map{$0.asDomain()}.unwrappedOptional().subscribe(onNext: { [positionUseCase](item) in
			positionUseCase.update(position: item)
		}).disposed(by: disposeBag)
		
		//Creating controlInfos from latest positions response update
		positionUseCase.positions.subscribe(onNext: { [makeControlInfos](positions) in
			makeControlInfos(positions)
		}).disposed(by: disposeBag)
	}
	
	private func getControlInfo(with symbol: SymbolType) -> PositionControlInfo? {
		return controlInfoArray.filter { (item) -> Bool in
			return item.position.symbol == symbol.rawValue
			}.first
	}
}

extension CryptonEngine {
	
	private func placeOrder(order: CommonOrderProtocol, withDelay: TimeInterval) -> Observable<OrderResponseModel> {
		return orderUseCase.place(order: order.asBitmexRequestModel(), withDelay: withDelay)
	}
	
	private func getLastPrice(with symbol: String) -> Double {
		return defaultBTCOrderPrice
	}
}
