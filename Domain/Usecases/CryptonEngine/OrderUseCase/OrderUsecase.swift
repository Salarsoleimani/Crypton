//
//  OrderUsecase.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/16/19.
//  Copyright © 2019 Salar Soleimani. All rights reserved.
//

import Foundation
import RxSwift

public protocol OrderUsecase {
  var orders: BehaviorSubject<[OrderModel]> { get }
  var isRequesting: Bool { get }
	func getOrders(symbol: String) -> Observable<[OrderModel]>
  func place(order: OrderRequestModels.Place, withDelay: TimeInterval) -> Observable<OrderResponseModel>
  func place(order: OrderRequestModels.Place) -> Observable<OrderResponseModel>
  func placeBulkOrders(orders: OrderRequestModels.Bulk) -> Observable<[OrderResponseModel]>
  func cancelAllOrders(requestParameter: OrderRequestModels.RemoveAll) -> Observable<Void>
  func cancel(order: OrderRequestModels.Remove) -> Observable<Void>
  func addNewOrder(newOrder: OrderResponseModel)
	func updateOrders(orderFilled filledOrder: OrderResponseModel)
	func updateOrders(orderCanceled canceledOrder: OrderResponseModel)
  func updateStopLoss(currentOrder: OrderModel, stopLossOrder: OrderRequestModels.Place) -> Observable<Void>
  func editOrder(order: OrderRequestModels.Edit) -> Observable<OrderResponseModel>
}
