//
//  Observable+Tools.swift
//  NetworkPlatform
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
extension Observable where Element: OptionalType {
	func unwrappedOptional() -> Observable<Element.Wrapped> {
		return self.filter { $0.asOptional != nil }.map { $0.asOptional! }
	}
}
protocol OptionalType {
	associatedtype Wrapped
	var asOptional:  Wrapped? { get }
}

extension Optional: OptionalType {
	var asOptional: Wrapped? { return self }
}
extension Observable {
	func mapToVoid() -> Observable<Void> {
		return self.map{ _ -> Void in}
	}
}
