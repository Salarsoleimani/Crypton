//
//  StartPositionController.swift
//  Crypton
//
//  Created by Salar Soleimani on 7/22/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SkyFloatingLabelTextField
import Domain

class StartPositionController: UIViewController {
  //Title
  @IBOutlet weak var symbolLabel: UILabel!
  
  //CurrentPrice
  @IBOutlet weak var arrowDownImage: UIImageView!
  @IBOutlet weak var arrowUpImage: UIImageView!
  @IBOutlet weak var currentPrice: UILabel!
  @IBOutlet weak var scrollCurrentLabel: UILabel!
  @IBOutlet weak var headerBlur: UIVisualEffectView!
  
  @IBOutlet weak var currentPriceDollarSignLabel: UILabel!
  
  @IBOutlet weak var quantityTextField: SkyFloatingLabelTextField!
  @IBOutlet weak var triggerPriceTextField: SkyFloatingLabelTextField!

  @IBOutlet weak var leverageTitleLabel: UILabel!
  @IBOutlet weak var leverageValueTextField: UITextField!
  @IBOutlet weak var leverageSlider: UISlider!
  
  @IBOutlet weak var technicalLossPercentTitleLabel: UILabel!
  @IBOutlet weak var technicalLossPercentValueTextField: UITextField!
  @IBOutlet weak var technicalLossPercentSlider: UISlider!
  
  @IBOutlet weak var longButton: UIButton!
  @IBOutlet weak var shortButton: UIButton!

  @IBOutlet weak var placeOrderButtonContainer: UIView!
  @IBOutlet weak var placeOrderButton: UIButton!
  
  @IBOutlet weak var autoReverseTitleLabel: UILabel!
  @IBOutlet weak var autoReverseSwitch: UISwitch!

  @IBOutlet weak var scrollView: UIScrollView!

  var viewModel: StartPositionViewModel!
  public var isLong = BehaviorSubject.init(value: true)

  
  let disposeBag = DisposeBag()
  var isLongBool = true {
    didSet {
      isLong.onNext(isLongBool)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bindData()
  }
  func setupUI() {
    view.backgroundColor = Appearance.colors.darkBackground()
    [autoReverseSwitch].forEach{
      $0?.onTintColor = Appearance.colors.purple()
    }
    scrollCurrentLabel.alpha = 0
    headerBlur.effect = nil
    scrollView.contentInset = view.safeAreaInsets
    symbolLabel.font = Appearance.hub.fonts.symbol()
    symbolLabel.textColor = Appearance.colors.white()
    scrollCurrentLabel.font = Appearance.hub.fonts.button()
    
    currentPrice.font = Appearance.hub.fonts.bigCurrentPrice()
    currentPriceDollarSignLabel.font = Appearance.hub.fonts.bigMedium()
    
    [longButton, shortButton].forEach {
      $0?.setTitleColor(Appearance.colors.white(), for: .normal)
      $0?.layer.cornerRadius = Appearance.cornerRadius.buttonCornerRadius()
			$0?.titleLabel?.font = Appearance.hub.fonts.bigMedium()
    }
    shortButton.alpha = 0.5
    placeOrderButtonContainer.backgroundColor = Appearance.colors.green()
    placeOrderButton.titleLabel?.font = Appearance.hub.fonts.button()

    [leverageTitleLabel, autoReverseTitleLabel, technicalLossPercentTitleLabel].forEach {
      $0?.font = Appearance.hub.fonts.regular()
      $0?.textColor = Appearance.colors.white()
    }
		[quantityTextField, triggerPriceTextField].forEach { (item) in
			item?.font = Appearance.hub.fonts.button()
		}
    
  }
  private func bindData() {
    let quantityDriver = quantityTextField.rx.text.orEmpty.asDriver()
    let triggerPriceDriver = triggerPriceTextField.rx.text.orEmpty.asDriver()
    let leverageDriver = leverageSlider.rx.value.asDriver()
    let leverageTextFieldDriver = leverageValueTextField.rx.text.orEmpty.asDriver()
    let technicalLossPercentDriver = technicalLossPercentSlider.rx.value.asDriver()
    let tlpTextFieldDriver = technicalLossPercentValueTextField.rx.text.orEmpty.asDriver()
    let autoReverseDriver = autoReverseSwitch.rx.isOn.asDriver()
    
    let input = StartPositionViewModel.Input(scrollViewOffset: scrollView.rx.contentOffset.asDriver(), placeOrderButton: placeOrderButton.rx.tap.asObservable(), leverageValue: leverageDriver, leverageTextFieldValue: leverageTextFieldDriver, technicalLossPercentValue: technicalLossPercentDriver, technicalLossPercentTextFieldValue: tlpTextFieldDriver, triggerPrice: triggerPriceDriver, quantity: quantityDriver, isLong: isLong, autoReverse: autoReverseDriver)
    
    let output = viewModel.transform(input: input)
    updateViewModel(quantityDriver: quantityDriver, triggerPriceDriver: triggerPriceDriver, leverageDriver: leverageDriver, autoReverseDriver: autoReverseDriver, leverageTextField: leverageTextFieldDriver, technicalLossPercentTextField: tlpTextFieldDriver, technicalLossPercentDriver: technicalLossPercentDriver)
    bindTexts(with: output)
    bindTopBlurHeader(with: output)
    bindCurrentPrice(with: output)
  }
  private func bindCurrentPrice(with output: StartPositionViewModel.Output) {
    output.currentPrice.drive(onNext: { (change) in
      self.currentPrice.text = String(change.price)
      self.currentPrice.textColor = change.changeType.getColor()
      self.scrollCurrentLabel.text = String(change.price)
      self.scrollCurrentLabel.textColor = change.changeType.getColor()
      self.currentPriceDollarSignLabel.textColor = change.changeType.getColor()
      self.arrowDownImage.alpha = (change.changeType != .bearish) ? 0 : 1
      self.arrowUpImage.alpha = (change.changeType == .bearish) ? 0 : 1
    }).disposed(by: disposeBag)
  }
  private func updateViewModel(quantityDriver: Driver<String>, triggerPriceDriver: Driver<String>, leverageDriver: Driver<Float>, autoReverseDriver: Driver<Bool>, leverageTextField: Driver<String>, technicalLossPercentTextField: Driver<String>, technicalLossPercentDriver: Driver<Float>) {
    isLong.subscribe(onNext: { (isLong) in
      let direction = isLong ? OrderSide.long : OrderSide.short
      self.viewModel.orderModel.direction = direction
    }).disposed(by: disposeBag)
    quantityDriver.asObservable().subscribe(onNext: { (quantity) in
      self.viewModel.orderModel.quantity = Double(quantity) ?? 0
    }).disposed(by: disposeBag)
    triggerPriceDriver.asObservable().subscribe(onNext: { (triggerPrice) in
      self.viewModel.orderModel.limitPrice = Double(triggerPrice) ?? 0
    }).disposed(by: disposeBag)
    leverageDriver.debounce(1).asObservable().subscribe(onNext: { (leverage) in
      self.viewModel.orderModel.leverage = Double(leverage * 100)
      self.viewModel.useCase.updateLeverage(leverage: self.viewModel.orderModel.leverage!, symbol: SymbolType(rawValue: self.viewModel.orderModel.symbol) ?? .BTCUSD).asDriver(onErrorJustReturn: ()).throttle(1).drive().disposed(by: self.disposeBag)
    }).disposed(by: disposeBag)
    leverageTextField.debounce(1).asObservable().subscribe(onNext: { (leverageStr) in
      if let leverage = Double(leverageStr) {
        if leverage > 100 {
          self.viewModel.orderModel.leverage = 100
        } else if leverage < 1 {
          self.viewModel.orderModel.leverage = 1
        } else {
          self.viewModel.orderModel.leverage = leverage
        }
      } else {
        self.viewModel.orderModel.leverage = 1
      }
      self.leverageValueTextField.text = String(Int(self.viewModel.orderModel.leverage!))
      self.viewModel.useCase.updateLeverage(leverage: self.viewModel.orderModel.leverage!, symbol: SymbolType(rawValue: self.viewModel.orderModel.symbol) ?? .BTCUSD).asDriver(onErrorJustReturn: ()).throttle(1).drive().disposed(by: self.disposeBag)
    }).disposed(by: disposeBag)
    technicalLossPercentDriver.debounce(1).asObservable().subscribe(onNext: { (tlp) in
      self.viewModel.orderModel.technicalLossPercent = Double(tlp)
      self.viewModel.useCase.updateLossMargin(technicalLossPercent: self.viewModel.orderModel.technicalLossPercent!)
    }).disposed(by: disposeBag)
    technicalLossPercentTextField.debounce(1).asObservable().subscribe(onNext: { (tlpStr) in
      if let tlp = Double(tlpStr) {
        if tlp > 100 {
          self.viewModel.orderModel.technicalLossPercent = 100
        } else if tlp < 0.001 {
          self.viewModel.orderModel.technicalLossPercent = 0.001
        } else {
          self.viewModel.orderModel.technicalLossPercent = tlp
        }
      } else {
        self.viewModel.orderModel.technicalLossPercent = 100
      }
      self.leverageValueTextField.text = String(self.viewModel.orderModel.technicalLossPercent!)
      self.viewModel.useCase.updateLossMargin(technicalLossPercent: self.viewModel.orderModel.technicalLossPercent!)
    }).disposed(by: disposeBag)
    autoReverseDriver.asObservable().subscribe(onNext: { (isAutoReverse) in
      self.viewModel.orderModel.isAutoReverse = isAutoReverse
    }).disposed(by: disposeBag)
  }
  private func bindTexts(with output: StartPositionViewModel.Output) {
    output.technicalLossPercentValueString.drive(technicalLossPercentValueTextField.rx.text).disposed(by: disposeBag)
    output.technicalLossPercentValueFloat.drive(technicalLossPercentSlider.rx.value).disposed(by: disposeBag)
    output.leverageValueString.drive(leverageValueTextField.rx.text).disposed(by: disposeBag)
    output.leverageValueFloat.drive(leverageSlider.rx.value).disposed(by: disposeBag)
  }
  private func bindTopBlurHeader(with output: StartPositionViewModel.Output) {
    output.showScrollViewHeader.drive(onNext: { [weak self] (show) in
      UIView.animate(withDuration: 0.2, animations: {
        self?.headerBlur.effect = show ? UIBlurEffect(style: .dark) : nil
        self?.scrollCurrentLabel.alpha = show ? 1 : 0
      })
    }).disposed(by: disposeBag)
  }
  @IBAction private func longAndShortButtonPressed(_ sender: UIButton) {
    if sender == longButton {
      shortButton.alpha = 0.5
      longButton.alpha = 1
      placeOrderButtonContainer.backgroundColor = Appearance.colors.green()
    } else {
      longButton.alpha = 0.5
      shortButton.alpha = 1
      placeOrderButtonContainer.backgroundColor = Appearance.colors.red()
    }
    isLongBool = !isLongBool
  }
}
