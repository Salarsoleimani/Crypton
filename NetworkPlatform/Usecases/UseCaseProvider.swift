//
//  UseCaseProvider.swift
//  NetworkPlatform
//
//  Created by Behrad Kazemi on 12/26/18.
//  Copyright © 2018 Behrad Kazemi. All rights reserved.
//
import Foundation
import Domain

public final class UseCaseProvider: Domain.UseCaseProvider {
  private let networkProvider: NetworkProvider

	public init() {
    networkProvider = NetworkProvider()

  }
  
  public func makeAuthorizationUseCase() -> Domain.AuthorizationUseCase {
    return AuthorizationUseCase(network: networkProvider.makeAuthorizationNetwork())
  }
	
	public func makeControlPanelUseCase(engine: Domain.CryptonEngine) -> Domain.ControlPanelUseCase {
//		let market = MarketUseCase(manager: positionManager)
		return ControlPanelUseCase(manager: engine)
	}
  public func makeStartPositionUseCase(engine: Domain.CryptonEngine) -> Domain.StartPositionUseCase {
    return StartPositionUseCase(manager: engine)
  }
	public func makeIPCheckUseCase() -> Domain.IPCheckUseCase {
		return IPCheckUseCase(network: networkProvider.ipCheckNetwork())
	}
	
	public func makePositionUseCase() -> Domain.PositionUseCase{
		return PositionUseCase(network: networkProvider.makePositionNetwork())
	}
	
	public func makeOrderUseCase() -> Domain.OrderUsecase{
		return OrderUseCase(network: networkProvider.makeOrderNetwork())
	}
	
	public func makeDataStreamUseCase() -> Domain.DataStreamUsecase{
		return DataStreamUsecase(sourceURL: URL(string: Constants.EndPoints.defaultBitmexSocket.rawValue)!)
	}
	
	public func makeEngine() -> Domain.CryptonEngine {
		return CryptonEngine(orderUC: makeOrderUseCase(), dataStreamUC: makeDataStreamUseCase(), positionUC: makePositionUseCase())
	}
}
