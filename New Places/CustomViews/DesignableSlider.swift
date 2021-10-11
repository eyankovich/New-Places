//
//  DesignableSlider.swift
//  New Places
//
//  Created by Егор Янкович on 11.10.21.
//

import UIKit

@IBDesignable

class DesignableSlider: UISlider {
   @IBInspectable var tumbImage: UIImage? {
        didSet {
            setThumbImage(tumbImage, for: .normal)
        }
    }
    @IBInspectable open var trackWidth:CGFloat = 2 {
            didSet {setNeedsDisplay()}
        }

        override open func trackRect(forBounds bounds: CGRect) -> CGRect {
            let defaultBounds = super.trackRect(forBounds: bounds)
            return CGRect(
                x: defaultBounds.origin.x,
                y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
                width: defaultBounds.size.width,
                height: trackWidth
            )
        }
}
