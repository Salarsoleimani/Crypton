//
//  StartPositionViewModel.swift
//  Crypton
//
//  Created by Salar Soleimani on 7/22/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import RxCocoa

final class StartPositionViewModel: ViewModelType {
  
  public let useCase: Domain.StartPositionUseCase
  private let navigator: StartPositionNavigator
  
  private let order: BehaviorSubject<OrderModel>
  var orderModel: OrderModel {
    didSet {
      order.onNext(orderModel)
    }
  }
  
  private let disposeBag = DisposeBag()
  init(navigator: StartPositionNavigator, useCase: StartPositionUseCase) {
    self.useCase = useCase
    self.navigator = navigator
    let baseOrder = OrderModel(symbol: SymbolType.BTCUSD.rawValue, direction: OrderSide.long)
    baseOrder.leverage = Constants.Defaults.defaultLeverage()
    self.orderModel = baseOrder
    self.order = BehaviorSubject.init(value: baseOrder)
  }
  
  func updateLeverage(leverage: Double, symbol: SymbolType) {
    
  }
  func transform(input: Input) -> Output {
    // UI Transforms
    let showHeader = input.scrollViewOffset.map {$0.y > 32 ? true : false}
    let leverageValueString = input.leverageValue.map{ "\(Int($0 * 100))" }
    let leverageValueFloat = input.leverageTextFieldValue.map { (leverageStr) -> Float in
      if leverageStr.isEmpty {
        return 0.01
      }
      if let leverageFloat = Float(leverageStr) {
        if leverageFloat > 100 {
          return 1
        } else if leverageFloat < 1 {
          return 0.01
        } else {
          return leverageFloat / 100
        }
      } else {
        return 0.01
      }
    }
    let techLossPercentValueString = input.technicalLossPercentValue.map{ "\(Double($0))" }
    let tlpValueFloat = input.technicalLossPercentTextFieldValue.map { (tlpStr) -> Float in
      if tlpStr.isEmpty {
        return 0.001
      }
      if let tlpFloat = Float(tlpStr) {
        if tlpFloat > 100 {
          return 100
        } else if tlpFloat < 1 {
          return 0.001
        } else {
          return tlpFloat
        }
      } else {
        return 0.001
      }
    }
    let placeOrderAction = input.placeOrderButton.flatMapLatest({ _ -> Observable<[OrderResponseModel]> in
      let limitPrice = self.orderModel.limitPrice ?? 0
      if limitPrice > 0 {
        let limitOrderRequest = LimitOrderModel(type: self.orderModel.direction, symbol: self.orderModel.symbol, price: limitPrice, quantity: self.orderModel.quantity ?? 0)
        return self.useCase.placeOrder(order: limitOrderRequest, leverage: self.orderModel.leverage!, isAutoReverse: self.orderModel.isAutoReverse)
      }
      
      let marketOrderRequest = MarketOrderModel(type: self.orderModel.direction, symbol: self.orderModel.symbol, quantity: self.orderModel.quantity ?? 0)
      return self.useCase.placeOrder(order: marketOrderRequest, leverage: self.orderModel.leverage!, isAutoReverse: self.orderModel.isAutoReverse)
    })
    
    // Network Transforms
    let currentChange = useCase.currentPrice().asDriverOnErrorJustComplete()
    
    // Last Output
    return Output(showScrollViewHeader: showHeader, leverageValueString: leverageValueString, leverageValueFloat: leverageValueFloat, technicalLossPercentValueString: techLossPercentValueString, technicalLossPercentValueFloat: tlpValueFloat, currentPrice: currentChange, placeOrderAction: placeOrderAction, isAutoReverse: input.autoReverse)
  }
  
}
extension StartPositionViewModel {
  struct Input {
    let scrollViewOffset: Driver<CGPoint>
    let placeOrderButton: Observable<Void>
    let leverageValue: Driver<Float>
    let leverageTextFieldValue: Driver<String>
    let technicalLossPercentValue: Driver<Float>
    let technicalLossPercentTextFieldValue: Driver<String>
    let triggerPrice: Driver<String>
    let quantity: Driver<String>
    let isLong: BehaviorSubject<Bool>
    let autoReverse: Driver<Bool>
  }
  
  struct Output {
    
    let showScrollViewHeader: Driver<Bool>
    let leverageValueString: Driver<String>
    let leverageValueFloat: Driver<Float>
    let technicalLossPercentValueString: Driver<String>
    let technicalLossPercentValueFloat: Driver<Float>
    let currentPrice: Driver<PriceChangeModel>
    let placeOrderAction: Observable<[OrderResponseModel]>
    public let isAutoReverse: Driver<Bool>
  }
}
