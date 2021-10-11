//
//  CustomView.swift
//  New Places
//
//  Created by Егор Янкович on 10.10.21.
//

import UIKit

@IBDesignable
class CustomView: UIView{

@IBInspectable var borderWidth: CGFloat = 0.0{

    didSet{

        self.layer.borderWidth = borderWidth
    }
}

@IBInspectable var borderColor: UIColor = UIColor.clear {

    didSet {

        self.layer.borderColor = borderColor.cgColor
    }
}

override func prepareForInterfaceBuilder() {

    super.prepareForInterfaceBuilder()
}

}
