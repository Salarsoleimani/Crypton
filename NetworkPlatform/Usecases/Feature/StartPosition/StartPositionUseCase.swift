//
//  StartPositionUseCase.swift
//  NetworkPlatform
//
//  Created by Salar Soleimani on 7/31/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import Domain
import RxSwift

public struct StartPositionUseCase: Domain.StartPositionUseCase {
  public func updateLossMargin(technicalLossPercent: Double) {
    manager.update(LossMarginWithTechnicalLossPercent: technicalLossPercent)
  }
  
  private let manager: Domain.CryptonEngine
  let disposeBag = DisposeBag()
  
  public init (manager: Domain.CryptonEngine) {
    self.manager = manager
  }
  
  public func currentPrice() -> Observable<PriceChangeModel> {
    return manager.currentPrice(symbol: SymbolType.BTCUSD)
  }
  public func placeOrder(order: CommonOrderProtocol, leverage: Double, isAutoReverse: Bool?) -> Observable<[OrderResponseModel]> {
    return manager.startPosition(order: order, leverage: leverage, isAutoReverse: isAutoReverse ?? true)
  }
  public func updateLeverage(leverage: Double, symbol: SymbolType) -> Observable<Void> {
    return manager.update(leverage: leverage, symbol: symbol)
  }
}
