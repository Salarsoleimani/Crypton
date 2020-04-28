//
//  DataStreamUsecase.swift
//  Domain
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import RxSwift
public protocol DataStreamUsecase {
	func subscribe(topics: [String])
	func observe<T: Codable>() -> Observable<T>
	func startStreaming() -> Observable<Bool>
}
