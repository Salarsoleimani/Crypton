//
//  IPCheckModel.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
public struct IPCheckModel: Codable{
	public let `as`: String
	public let city: String
	public let country: String
	public let countryCode: String
	public let isp: String
	public let lat: Double
	public let lon: Double
	public let org: String
	public let query: String
	public let region: String
	public let regionName: String
	public let status: String
	public let timezone: String
	public let zip: String
}
