//
//  SlideOverView.swift
//  Flipbook
//
//  Created by Matthew Hallatt on 23/12/2015.
//  Copyright © 2015 Matthew Hallatt. All rights reserved.
//

import UIKit

class SlideOverView: UIView, Presentable, Dismissable {
  
  var presentDuration: Double = 0.3
  var dismissDuration: Double = 0.3
  
  var present: (Bool -> Void) = { _ in }
  var dismiss: (Bool -> Void) = { _ in }
  
}
