//
//  Constants.swift
//  Domain
//
//  Created by Behrad Kazemi on 12/26/18.
//  Copyright © 2018 Behrad Kazemi. All rights reserved.
//

public enum Constants {
  public enum Messages: String {
    case stopLossEdited = "Stoploss edited from Crypton"
  }
	public enum Keys: String {
		//MARK: - Schedulers name
		case cacheSchedulerQueueName = "com.bekapps.Network.Cache.queue"
		
		//MARK: - Storage Keys
		public enum Authentication: String {
			case refreshToken = "com.bekapps.storagekeys.authentication.token.refresh"
			case accessToken = "com.bekapps.storagekeys.authentication.token.access"
			case UUID = "com.bekapps.storagekeys.authentication.info.uuid"
		}
	}
	
	public enum Defaults {
    
		public static let acceptableLossPercent = { return 28.0 }
    public static let defaultLeverage = { return 100.0}
		public static let stopLossUpdatingStrategy = { return StopLossUpdateStrategy.autoUpdate }
		public static let positionUpdateStrategy = { return PositionUpdateStrategy.forceClose }
	}
	public enum SocketSubscriptionTopics: String {
		case XBTPrice = "instrument:XBTUSD"
		case Position = "position"
		case Margin = "margin"
    case Order = "order"
    case QuoteBin1m = "quoteBin1m"
	}
	
	public enum EndPoints: String {
		//Main
		case ipInfo = "http://ip-api.com/json"
		case defaultBitmexSocket = "wss://www.bitmex.com/realtime"
		case socketXBT = "?subscribe=instrument:XBTUSD"
		
		case defaultBitmexURL = "https://www.bitmex.com"
		case userModel = "/api/v1/user"
		case position = "/api/v1/position"
		case leverage = "/api/v1/position/leverage"
		case exchangeInfo = "exchangeInfo"
    
    // Order
    case order = "/api/v1/order"
    case bulkOrders = "/api/v1/order/bulk"
    case cancelAllOrders = "/api/v1/order/all"
	}
}
