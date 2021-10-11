//
//  TabBarController.swift
//  New Places
//
//  Created by Егор Янкович on 10.10.21.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let items = tabBar.items {
            // Setting the title text color of all tab bar items:
            for item in items {
                item.setTitleTextAttributes([.foregroundColor: UIColor.init(named: "Custom Pink") as Any], for: .selected)
                item.setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
            }
        }
    }
}
