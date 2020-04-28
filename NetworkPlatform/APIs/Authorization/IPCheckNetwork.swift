//
//  IPCheckNetwork.swift
//  NetworkPlatform
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import Domain
import RxSwift

public final class IPCheckNetwork {
	
	private let network: Network<IPCheckModel>
	
	init(network: Network<IPCheckModel>) {
		self.network = network
	}
	
	public func getIPInfo() -> Observable<IPCheckModel> {
		
		let res = network.getItem("")
		return res
	}
	
}
