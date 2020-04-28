//
//  Account.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/20/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import CommonCrypto
public struct AccountInfoModel {
	//public let key = "HtDU-bQ8KtMKmcIKMe9RiFbK"
	//public let secret = "ZoKUQBOyN6nRO5PKm6RohdtKmxt1pLuBROSAMVKfja5xWa7X"
  public let key = "1Hcw_YI4pK1ETbDx-pG5AIR3"
  public let secret = "2nXOdljdYvGkm4FLIAKHkxyY1JuSXG8xJfHQx4_N09BZNGk3"
	
	public init(){}
	
	public func getSignature(method: String, path: String, data: String, expires: Int) -> String {
		
		let crypto = EasyCrypt(secret: secret, algorithm: .sha256)
		let stringData = method + path + String(expires) + data
		let signatureString = crypto.hash(stringData)
		let data = Data(base64Encoded: signatureString) ?? Data()
		let signature = data.hexEncodedString()
		return signature
	}
	public func getSocketAuthMessage() -> [String: Any] {
		let expires = Int(Date().timeIntervalSince1970) + 200
		let signature = getSignature(method: "GET", path: "/realtime", data: "", expires: expires)
		
		return ["op": "authKeyExpires", "args": [key, expires, signature]]
	}
}

extension Data {
	struct HexEncodingOptions: OptionSet {
		let rawValue: Int
		static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
	}
	
	func hexEncodedString(options: HexEncodingOptions = []) -> String {
		let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
		return map { String(format: format, $0) }.joined()
	}
}
