//
//  OrderNetwork.swift
//  NetworkPlatform
//
//  Created by Salar Soleimani on 7/28/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Domain
import RxSwift

public final class OrderNetwork {
  
  private let network: Network<OrderResponseModel>
	private var lastRequestTimeStamp: Date
	private let allowedRequestPeriodTime = -1.0
  init(network: Network<OrderResponseModel>) {
		self.lastRequestTimeStamp = Date(timeIntervalSinceNow: allowedRequestPeriodTime)
    print(lastRequestTimeStamp)
    self.network = network
  }
  
  public func placeOrder(requestParameter: OrderRequestModels.Place, delayTime: TimeInterval = 0) -> Observable<OrderResponseModel> {
		print("last time For PLacing Order: \(lastRequestTimeStamp.timeIntervalSinceNow) va \(delayTime)")
		
		if delayTime != 0 && delayTime <= abs(allowedRequestPeriodTime) || delayTime == 0 && lastRequestTimeStamp.timeIntervalSinceNow >= allowedRequestPeriodTime {
			return Observable.error(getPeriodicTimeError(endPoint: Constants.EndPoints.order.rawValue))
		}
    
		self.lastRequestTimeStamp = Date()
		
    let res = network.postItem(Constants.EndPoints.order.rawValue, parameters: requestParameter.dictionary!, delayTime: delayTime)
    return res
  }
  public func placeBulkOrders(requestParameter: OrderRequestModels.Bulk) -> Observable<[OrderResponseModel]> {
    return network.postItems(Constants.EndPoints.bulkOrders.rawValue, parameters: requestParameter.dictionary!)
  }
  public func getOrders() -> Observable<[OrderResponseModel]> {

    let res = network.getItems(Constants.EndPoints.order.rawValue)
    return res
  }
	
  public func cancelOrder(requestParameter: OrderRequestModels.Remove) -> Observable<[OrderResponseModel]> {
    let res = network.deleteItem(Constants.EndPoints.order.rawValue, parameters: requestParameter.dictionary!)
    return res
  }
  public func cancelAllOrders(requestParameter: OrderRequestModels.RemoveAll) -> Observable<[OrderResponseModel]> {
//		if lastRequestTimeStamp.timeIntervalSinceNow >= allowedRequestPeriodTime {
//			return Observable.error(getPeriodicTimeError(endPoint: Constants.EndPoints.cancelAllOrders.rawValue))
//		}
//		self.lastRequestTimeStamp = Date()
		
    let res = network.deleteItem(Constants.EndPoints.cancelAllOrders.rawValue, parameters: requestParameter.dictionary!)
    return res
  }
  public func updateOrder(requestParameter: OrderRequestModels.Edit) -> Observable<OrderResponseModel> {
    if lastRequestTimeStamp.timeIntervalSinceNow >= allowedRequestPeriodTime {
			return Observable.error(getPeriodicTimeError(endPoint: Constants.EndPoints.order.rawValue))
    }
    self.lastRequestTimeStamp = Date()
		
    return network.putItem(Constants.EndPoints.order.rawValue, parameters: requestParameter.dictionary!)
  }
	private func getPeriodicTimeError(endPoint: String) -> NSError {
		return NSError(domain: "OrderNetwork", code: ErrorHub.codes.internalError.rawValue, userInfo: ["reason" : "Too much request in a period of time for endPoint: \(endPoint)"])
	}
}
