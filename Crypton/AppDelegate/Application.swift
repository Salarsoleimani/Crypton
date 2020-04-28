//
//  Application.swift
//
//  Created by Behrad Kazemi on 11/20/18.
//  Copyright © 2018 Behrad Kazemi. All rights reserved.
//

import NetworkPlatform
import Domain
import RxSwift
final class Application {
  static let shared = Application()
  
  private let networkUseCaseProvider: NetworkPlatform.UseCaseProvider
	public let engine: Domain.CryptonEngine
	let disposeBag = DisposeBag()
  private init() {
    AnalyticProxy.setup()
		self.networkUseCaseProvider = NetworkPlatform.UseCaseProvider()
		self.engine = self.networkUseCaseProvider.makeEngine()
  }
  
  func configureMainInterface(in window: UIWindow) {
    let mainNavigationController = MainNavigationController()
    window.rootViewController = mainNavigationController
    window.makeKeyAndVisible()
		let restrictedCountriesVC = RestrictedViewController(nibName: "RestrictedViewController", bundle: nil)
		let info = networkUseCaseProvider.makeIPCheckUseCase().getInfo()
		info.subscribe(onNext: {(legal) in
			
			if legal {
				self.engine.startEngine()
				SplashNavigator(navigationController: mainNavigationController, services: self.networkUseCaseProvider, engine: self.engine).setup()
				return
			}
			mainNavigationController.pushViewController(restrictedCountriesVC, animated: true)
		}, onError: { (error) in
			mainNavigationController.pushViewController(restrictedCountriesVC, animated: true)
		}).disposed(by: disposeBag)
  }

}

