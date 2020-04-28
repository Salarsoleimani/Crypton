//
//  DataStreamUsecase.swift
//  NetworkPlatform
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import RxSwift
import Domain
import Starscream
import RxStarscream
public struct DataStreamUsecase: Domain.DataStreamUsecase {
	
	private let socket: WebSocket
	private let disposeBag = DisposeBag()
	
	public init(sourceURL: URL){
		self.socket = WebSocket(url: sourceURL)
	}	
	public func observe<T: Codable>() -> Observable<T> {
		let update = socket.rx.text.flatMapLatest { (message) -> Maybe<T> in
			let result = Maybe<T>.create { maybe in
				do{
					let data = message.data(using: .utf8)!
					let decoder = JSONDecoder()
					let dateFormatter = DateFormatter()
					dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
					decoder.dateDecodingStrategy = .formatted(dateFormatter)
					
					let object = try decoder.decode(T.self, from: data)
					
					maybe(.success(object))
				} catch {
					maybe(.completed)
				}
				return Disposables.create {}
			}
			return result
		}
		return update
	}
	public func startStreaming() -> Observable<Bool>{
		socket.connect()
		return socket.rx.connected.do(onNext: { (connected) in
			print("\nWARN\nSocket is \(connected ? "" : "NOT") connected\n")
			if connected {
				self.authorize()
			}else{
				print("\nTrying to reconnect ...")
				Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (_) in
					self.socket.connect()
				})
			}
		})
	}
	public func subscribe(topics: [String]) {
		let parameters: [String: Any] = ["op": "subscribe", "args": topics]
		if let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
			let stringData = String(data: jsonData, encoding: .utf8)!
			socket.write(string: stringData)
		}
	}
	private func authorize(){
		let authInfo = AccountInfoModel().getSocketAuthMessage()
		if let jsonData = try? JSONSerialization.data(withJSONObject: authInfo, options: []) {
			let stringData = String(data: jsonData, encoding: .utf8)!
			socket.write(string: stringData)
		}
		
	}
}
