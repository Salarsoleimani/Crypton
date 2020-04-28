//
//  UseCaseProvider.swift
//  Domain
//
//  Created by Behrad Kazemi on 8/15/18.
//  Copyright © 2018 Behrad Kazemi. All rights reserved.
//

import Foundation

public protocol UseCaseProvider {
	
	//MARK:-
	func makeEngine() -> CryptonEngine
	func makeAuthorizationUseCase() -> AuthorizationUseCase
	func makeControlPanelUseCase(engine: CryptonEngine) -> ControlPanelUseCase
  func makeStartPositionUseCase(engine: CryptonEngine) -> StartPositionUseCase
	func makePositionUseCase() -> PositionUseCase
	func makeOrderUseCase() -> OrderUsecase
	func makeDataStreamUseCase() -> DataStreamUsecase
	func makeIPCheckUseCase() -> IPCheckUseCase
}
