//
//  DrawingSettingsViewController.swift
//  Flipbook
//
//  Created by Matthew Hallatt on 23/12/2015.
//  Copyright © 2015 Matthew Hallatt. All rights reserved.
//

import UIKit

protocol DrawingSettingsDelegate {
  
  func colorDidChange(color: UIColor?)
  func lineWidthDidChange(width: CGFloat)
  func freehandDidToggle(enabled: Bool)
  
}

class DrawingSettingsViewController: UIViewController {
  
  @IBOutlet weak var lineWidthLabel: UILabel!
  @IBOutlet weak var freehandButton: UIButton!
  
  var delegate: DrawingSettingsDelegate?
  
  var lineWidth: CGFloat = 2
  
  override func viewDidLoad() {
    updateLineWidth(lineWidth)
    updateFreehand(true)
  }
  
  func updateLineWidth(width: CGFloat) {
    
    lineWidth = width
    lineWidthLabel.text = String(lineWidth)
    
    if let delegate = delegate {
      delegate.lineWidthDidChange(width)
    }
    
  }
  
  func updateFreehand(enabled: Bool) {
    
    freehandButton.selected = enabled
    
    freehandButton.backgroundColor = enabled ? .greenColor() : .redColor()
    
    if let delegate = delegate {
      delegate.freehandDidToggle(enabled)
    }
    
  }
  
  @IBAction func colorButtonDidTouchUpInside(sender: UIButton) {
    
    if let delegate = delegate {
      delegate.colorDidChange(sender.backgroundColor)
    }
    
  }
  
  @IBAction func lineWidthMinusButtonDidTouchUpInside(sender: UIButton) {
    
    if lineWidth > 1 {
      updateLineWidth(lineWidth - 0.1)
    }
    
  }
  
  @IBAction func lineWidthPlusButtonDidTouchUpInside(sender: UIButton) {
    
    updateLineWidth(lineWidth + 0.1)
    
  }
  
  @IBAction func freehandButtonDidTouchUpInside(sender: UIButton) {
    
    updateFreehand(!sender.selected)
    
  }
  
}
