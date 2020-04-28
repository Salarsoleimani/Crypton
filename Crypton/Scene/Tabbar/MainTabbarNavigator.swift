//
//  MainTabbarNavigator.swift
//
//  Created by Behrad Kazemi on 1/26/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import Foundation
import Domain

class MainTabbarNavigator {
	
	private let navigationController: UINavigationController
	private let tabbarVC: UITabBarController
	private let services: Domain.UseCaseProvider
	private let engine: Domain.CryptonEngine
	init(services: Domain.UseCaseProvider, navigationController: UINavigationController, tabbar: UITabBarController, engine: CryptonEngine) {
		self.navigationController = navigationController
		self.tabbarVC = tabbar
		self.engine = engine
		self.services = services
	}
	
	func setup(withIndex index: Int = 0) {
		//Setting up landing quiz
		let startPostionVC = StartPositionController(nibName: "StartPositionController", bundle: nil)
		let startPostionNavigator = StartPositionNavigator(services: services, navigationController: navigationController)
    startPostionVC.viewModel = StartPositionViewModel(navigator: startPostionNavigator, useCase: services.makeStartPositionUseCase(engine: engine))
		
		let controlPanelVC = ControlPanelViewController(nibName: "ControlPanelViewController", bundle: nil)
		let controlPanelNavigator = ControlPanelNavigator(services: services, navigationController: navigationController)
		controlPanelVC.viewModel = ControlPanelViewModel(useCase: services.makeControlPanelUseCase(engine: engine), navigator: controlPanelNavigator)
		
		tabbarVC.viewControllers = [startPostionVC, controlPanelVC]
		tabbarVC.selectedIndex = index
		navigationController.pushViewController(tabbarVC, animated: true)
	}
	
	func toIndex(index: Int){
		tabbarVC.selectedIndex = index
	}
}
