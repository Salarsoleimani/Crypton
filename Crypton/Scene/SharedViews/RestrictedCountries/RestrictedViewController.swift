//
//  RestrictedViewController.swift
//  Crypton
//
//  Created by Behrad Kazemi on 7/30/19.
//  Copyright © 2019 Behrad Kazemi. All rights reserved.
//

import UIKit

class RestrictedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

	@IBAction func openSettings(_ sender: Any) {
		UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
	}
}
