//
//  NetworkProvider.swift
//  NetworkPlatform
//
//  Created by Behrad Kazemi on 12/26/18.
//  Copyright © 2018 Behrad Kazemi. All rights reserved.
//
import Domain

final class NetworkProvider {
	private var apiEndpoint: String {
		var endpoint = Constants.EndPoints.defaultBitmexURL.rawValue
		if let baseURL = UserDefaults.standard.string(forKey: Constants.EndPoints.defaultBitmexURL.rawValue), !baseURL.isEmpty {
            endpoint = baseURL
        }
		return endpoint
	}
	
	//MARK: - Login and Authorization
	public func makeAuthorizationNetwork() -> AuthenticationNetwork {
		let network = Network<TokenModel.Response>(apiEndpoint)
		return AuthenticationNetwork(network: network)
	}
  public func makeOrderNetwork() -> OrderNetwork {
    let network = Network<OrderResponseModel>(apiEndpoint)
    return OrderNetwork(network: network)
  }
	public func makePositionNetwork() -> PositionNetwork{
		let network = Network<PositionNetworkModel.Response>(apiEndpoint)
		return PositionNetwork(network: network)
	}
	public func ipCheckNetwork() -> IPCheckNetwork {
		let network = Network<IPCheckModel>(Constants.EndPoints.ipInfo.rawValue)
		return IPCheckNetwork(network: network)
	}
}
