//
//  ColorButton.swift
//  Flipbook
//
//  Created by Matthew Hallatt on 23/12/2015.
//  Copyright © 2015 Matthew Hallatt. All rights reserved.
//

import UIKit

class ColorButton: UIButton {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setTitle("", forState: .Normal)
    layer.borderColor  = UIColor.darkGrayColor().CGColor
    layer.borderWidth  = 1
    layer.cornerRadius = 3
  }
  
}
