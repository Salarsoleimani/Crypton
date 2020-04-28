//
//  OrderUseCase.swift
//  NetworkPlatform
//
//  Created by Behrad Kazemi on 7/25/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import Domain
import RxSwift

public final class OrderUseCase: Domain.OrderUsecase {
	
	private let disposeBag = DisposeBag()
	var stopLossObject: OrderModel?
	let disposeBage = DisposeBag()
	public var orders: BehaviorSubject<[OrderModel]>
  public var isRequesting: Bool = false

	private var ordersArray: [OrderModel]{
		didSet {
			orders.onNext(ordersArray)
		}
	}
	//private var tempRemoveOrders = [OrderModel]()
	private let network: OrderNetwork
	init(network: OrderNetwork) {
		self.network = network
		self.orders = BehaviorSubject(value: [OrderModel]())
		self.ordersArray = [OrderModel]()
	}
	public func remove(orderID: String) -> Observable<Void> {
		let removeOrderReq = OrderRequestModels.Remove(orderID: orderID, clOrdID: nil, text: "Canceled from Crypton motherFucker")
		return network.cancelOrder(requestParameter: removeOrderReq).mapToVoid()
	}
	
	public func updateStopLoss(currentOrder: OrderModel, stopLossOrder: OrderRequestModels.Place) -> Observable<Void> {
    isRequesting = true
		if let orderId = currentOrder.orderId {
			let editedStopLossModel = OrderRequestModels.Edit(orderID: orderId, clOrdID: nil, origClOrdID: nil, orderQty: stopLossOrder.orderQty, leavesQty: nil, price: stopLossOrder.price, stopPx: stopLossOrder.stopPx, pegOffsetValue: stopLossOrder.pegOffsetValue, text: Constants.Messages.stopLossEdited.rawValue)
			//tempRemoveOrders.append(currentOrder)
			//self.update(removeOrderId: orderId) //COUSES RETAIN CYCLE [TODO] WHY?
			return editOrder(order: editedStopLossModel).do(onNext: { [addNewOrder] (orderResponse) in
				addNewOrder(orderResponse)
			}, onError: { (error) in
				print("\nOrder retrived!:\(error)\n")
//        if self.tempRemoveOrders.count > 0 {
//          let removingObject = self.tempRemoveOrders.removeFirst()
//          self.safeAddToOrderArrayAndUpdate(order: removingObject)
//        }
			}).mapToVoid()
		}
		return Observable.error(NSError(domain: "OrderUseCase -> UpdateStopLoss", code: ErrorHub.codes.nullData.rawValue, userInfo: ["reason": "orderId is null"]))
	}
	public func place(order: OrderRequestModels.Place) -> Observable<OrderResponseModel> {
		return place(order: order, withDelay: 0)
	}
	public func placeBulkOrders(orders: OrderRequestModels.Bulk) -> Observable<[OrderResponseModel]> {
		return network.placeBulkOrders(requestParameter: orders)
	}
	public func addNewOrder(newOrder: OrderResponseModel) {
    isRequesting = false
		safeAddToOrderArrayAndUpdate(order: newOrder.asDomain())
	}
	public func updateOrders(orderFilled filledOrder: OrderResponseModel) {
		
		update(removeOrderId: filledOrder.orderID)
	}
	public 	func updateOrders(orderCanceled canceledOrder: OrderResponseModel) {
		update(removeOrderId: canceledOrder.orderID)
	}
	
	private func update(removeOrderId orderId: String) {
		if let index = ordersArray.firstIndex(where: { (item) -> Bool in
			return item.orderId == orderId
		}) {
			ordersArray.remove(at: index)
			let nextObject = ordersArray
			orders.onNext(nextObject)
		}
	}
	
	public func getOrders(symbol: String) -> Observable<[OrderModel]> {
		print("\ngetting orders for symbol : \(symbol)\n")
		let response = network.getOrders()
		return response.map { (items) -> [OrderResponseModel] in
			return items.filter{$0.ordStatus == "New"}
			}.map({ [unowned self](items) -> [OrderModel] in
				let orderItems = items.compactMap{$0.asDomain()}
				self.ordersArray = orderItems
				return orderItems
			})
	}
	
	public func place(order: OrderRequestModels.Place, withDelay: TimeInterval = 0) -> Observable<OrderResponseModel> {
		let res = network.placeOrder(requestParameter: order, delayTime: withDelay)
		return res
	}
	
	public func cancel(order: OrderRequestModels.Remove) -> Observable<Void> {
		return network.cancelOrder(requestParameter: order).map({ (response) -> Void in
			print("response of cancel order : \(response)")
		})
	}
	
	public func cancelAllOrders(requestParameter: OrderRequestModels.RemoveAll) -> Observable<Void> {
		return network.cancelAllOrders(requestParameter: requestParameter).map({ (response) -> Void in
			print("response of cancel orderss : \(response)")
		})
	}
	
	public func editOrder(order: OrderRequestModels.Edit) -> Observable<OrderResponseModel> {
		return network.updateOrder(requestParameter: order)
	}
	
	private func safeAddToOrderArrayAndUpdate(order: OrderModel) {
		let sameObjectCount = ordersArray.filter { (item) -> Bool in
			item.orderId == order.orderId ?? ""
			}.count
		if sameObjectCount > 0 {
			return
		}
		ordersArray.append(order)
		let nextObject = ordersArray
		orders.onNext(nextObject)
	}
}
