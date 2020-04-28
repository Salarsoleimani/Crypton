//
//  ControlPanelViewController.swift
//  Crypton
//
//  Created by Behrad Kazemi on 7/21/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import UIKit
import Domain
import RxSwift
class ControlPanelViewController: UIViewController {
	
	//Title
	@IBOutlet weak var symbolLabel: UILabel!
	
	//CurrentPrice
	@IBOutlet weak var arrowDownImage: UIImageView!
	@IBOutlet weak var arrowUpImage: UIImageView!
	@IBOutlet weak var currentPrice: UILabel!
	@IBOutlet weak var scrollCurrentLabel: UILabel!
	@IBOutlet weak var headerBlur: UIVisualEffectView!
	
	@IBOutlet weak var currentPriceDollarSignLabel: UILabel!
	
	//CurrentProfit
	@IBOutlet weak var refreshPositionsButton: UIButton!
	@IBOutlet weak var currentProfitTitleLabel: UILabel!
	@IBOutlet weak var currentProfitPercentLabel: UILabel!
	
	//Table
	@IBOutlet weak var sideTitleLabel: UILabel!
	@IBOutlet weak var sideLabel: UILabel!
	
	@IBOutlet weak var quantityTitleLabel: UILabel!
	@IBOutlet weak var quantityLabel: UILabel!
	
	@IBOutlet weak var profitRatioTitle: UILabel!
	@IBOutlet weak var ratioSlider: UISlider!
	@IBOutlet weak var ratioLabel: UILabel!
	
	@IBOutlet weak var totalProfitTitleLabel: UILabel!
	@IBOutlet weak var totalProfitLabel: UILabel!
	
	@IBOutlet weak var stopLossTitleLabel: UILabel!
	@IBOutlet weak var stopLossLabel: UILabel!
	
	@IBOutlet weak var leverageTitleLabel: UILabel!
	@IBOutlet weak var leverageLabel: UILabel!
	
	@IBOutlet weak var autoUpdateTitleLabel: UILabel!
	@IBOutlet weak var autoUpdateSwitch: UISwitch!
	
	@IBOutlet weak var autoReverseTitleLabel: UILabel!
	@IBOutlet weak var autoReverseSwitch: UISwitch!
	
	@IBOutlet weak var endPositionButton: UIButton!
	var viewModel: ControlPanelViewModel!
	let disposeBag = DisposeBag()
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var endPositionContainer: UIView!
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		bindData()
	}
	
	func setupUI(){
	view.backgroundColor = Appearance.colors.darkBackground()
		[autoUpdateSwitch, autoReverseSwitch].forEach{
			$0?.onTintColor = Appearance.colors.purple()
		}
		
		scrollCurrentLabel.alpha =  0
		headerBlur.effect = nil
		scrollView.contentInset = view.safeAreaInsets
		symbolLabel.font = Appearance.hub.fonts.symbol()
		symbolLabel.textColor = Appearance.colors.white()
		scrollCurrentLabel.font = Appearance.hub.fonts.button()
		
		currentPrice.font = Appearance.hub.fonts.bigCurrentPrice()
		currentProfitTitleLabel.textColor = Appearance.colors.white()
		currentPriceDollarSignLabel.font = Appearance.hub.fonts.bigMedium()
		currentProfitTitleLabel.font = Appearance.hub.fonts.sectionTitle()
		currentProfitPercentLabel.font = Appearance.hub.fonts.bigProfitPercent()
		endPositionContainer.backgroundColor = Appearance.colors.yellow()
		endPositionButton.titleLabel?.font = Appearance.hub.fonts.button()
		[sideLabel,profitRatioTitle, ratioLabel, quantityLabel, totalProfitLabel, stopLossLabel, leverageLabel].forEach{
			$0?.font = Appearance.hub.fonts.regular()
			$0?.textColor = Appearance.colors.white()
		}
			[stopLossTitleLabel, sideTitleLabel, leverageTitleLabel, quantityTitleLabel, autoUpdateTitleLabel, totalProfitTitleLabel, autoReverseTitleLabel].forEach{
			$0?.font = Appearance.hub.fonts.regular()
			$0?.textColor = Appearance.colors.white()
		}
	}
	
	func bindData() {
		
		let input = ControlPanelViewModel.Input(scrollViewOffset: scrollView.rx.contentOffset.asDriver(), endButton: endPositionButton.rx.tap.asDriver(), autoReverse: autoReverseSwitch.rx.isOn.asDriver(), autoUpdate: autoUpdateSwitch.rx.isOn.asDriver(), ratio: ratioSlider.rx.value.asDriver(), refreshPositions: refreshPositionsButton.rx.tap.asDriver())
		
		let output = viewModel.transform(input: input)
		[output.showScrollViewHeader.drive(onNext: { (show) in
			UIView.animate(withDuration: 0.2, animations: {
				self.headerBlur.effect = show ? UIBlurEffect(style: .dark) : nil
				self.scrollCurrentLabel.alpha = show ? 1 : 0
			})
		}),
		 output.currentChange.drive(onNext: { (change) in
			self.currentPrice.text = String(change.price)
			self.currentPrice.textColor = change.changeType.getColor()
			self.scrollCurrentLabel.text = String(change.price)
			self.scrollCurrentLabel.textColor = change.changeType.getColor()
			self.currentPriceDollarSignLabel.textColor = change.changeType.getColor()
			self.arrowDownImage.alpha = (change.changeType != .bearish) ? 0 : 1
			self.arrowUpImage.alpha = (change.changeType == .bearish) ? 0 : 1
		}),
		 output.updateRatio.drive(),
		 output.ratiostring.drive(ratioLabel.rx.text),
		 output.refreshPositionsAction.subscribe(),
		 output.autoReverseAction.drive(),
		 output.endPosition.subscribe(),
		 output.currentProfit.drive(onNext: { (change) in
			self.currentProfitPercentLabel.text = change.price > 0 ? String(format: "+%.2f%%", change.price) : String(format: "%.2f%%", change.price)
			self.currentProfitPercentLabel.textColor = change.changeType.getColor()
		}),
		 output.controlInfo.drive()
		 ].forEach { (item) in
			item.disposed(by: disposeBag)
		}
	
	}
	
}
extension ChangingType {
	func getColor() -> UIColor {
		switch self {
		case .bearish:
			return Appearance.colors.red()
		case .bullish:
			return Appearance.colors.green()
		default:
      return Appearance.colors.green()
		}
	}
}
