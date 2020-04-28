//
//  SplashNavigator.swift
//
//  Created by Behrad Kazemi on 12/29/18.
//  Copyright © 2018 Behrad Kazemi. All rights reserved.
//

import Foundation
import Domain
class SplashNavigator {
	
	private let navigationController: UINavigationController
	private let services: UseCaseProvider
	private let engine: CryptonEngine
	init(navigationController: UINavigationController, services: UseCaseProvider, engine: CryptonEngine) {
		self.navigationController = navigationController
		self.services = services
		self.engine = engine
	}
	
	func setup() {
		let splashVC = SplashScreenController(nibName: "SplashScreenController", bundle: nil)
		splashVC.viewModel = SplashViewModel(navigator: self)
		navigationController.viewControllers = [splashVC]
	}
	
	func toHome() {
		let tabbar = UITabBarController()
		MainTabbarNavigator(services: services, navigationController: navigationController, tabbar: tabbar, engine: engine).setup()
	}
}
