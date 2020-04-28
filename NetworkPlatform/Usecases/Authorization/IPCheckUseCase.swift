//
//  IPCheckUseCase.swift
//  NetworkPlatform
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import Domain
import RxSwift
public struct IPCheckUseCase: Domain.IPCheckUseCase {
	
	private let network: IPCheckNetwork
	private let restrictedCountryCodes = ["US", "IR", "CA", "CU", "SY", "KP", "SD", "SS"]
	init(network: IPCheckNetwork) {
		self.network = network
	}
	public func getInfo() -> Observable<Bool> {
		return network.getIPInfo().map({ (model) -> Bool in
			return !self.restrictedCountryCodes.contains(model.countryCode)
		})
	}
}
