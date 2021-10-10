//
//  BottomViewVC.swift
//  New Places
//
//  Created by Егор Янкович on 29.09.21.
//

import UIKit

class BottomViewVC: UIViewController {

    @IBOutlet var myView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myView = UIView()
        view.addSubview(myView)
        view.backgroundColor = .black
        myView.backgroundColor = .blue
    }

}
