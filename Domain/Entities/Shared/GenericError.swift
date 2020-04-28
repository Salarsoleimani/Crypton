//
//  GenericError.swift
//  Domain
//
//  Created by Behrad Kazemi on 8/29/18.
//  Copyright © 2018 Behrad Kazemi. All rights reserved.
//

import Foundation
public enum ErrorResponse {
  public struct Base: Codable {
    public let error: Err
  }
  public struct Err: Codable {
    public let message: String
    public let name: String

  }
}
