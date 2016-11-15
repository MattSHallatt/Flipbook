//
//  DrawingSettingsViewController.swift
//  Flipbook
//
//  Created by Matthew Hallatt on 23/12/2015.
//  Copyright © 2015 Matthew Hallatt. All rights reserved.
//

import UIKit

protocol DrawingSettingsDelegate {
  
  func colorDidChange(_ color: UIColor?)
  func lineWidthDidChange(_ width: CGFloat)
  func freehandDidToggle(_ enabled: Bool)
  
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
  
  func updateLineWidth(_ width: CGFloat) {
    
    lineWidth = width
    lineWidthLabel.text = String(describing: lineWidth)
    
    if let delegate = delegate {
      delegate.lineWidthDidChange(width)
    }
    
  }
  
  func updateFreehand(_ enabled: Bool) {
    
    freehandButton.isSelected = enabled
    
    freehandButton.backgroundColor = enabled ? .green : .red
    
    if let delegate = delegate {
      delegate.freehandDidToggle(enabled)
    }
    
  }
  
  @IBAction func colorButtonDidTouchUpInside(_ sender: UIButton) {
    
    if let delegate = delegate {
      delegate.colorDidChange(sender.backgroundColor)
    }
    
  }
  
  @IBAction func lineWidthMinusButtonDidTouchUpInside(_ sender: UIButton) {
    
    if lineWidth > 1 {
      updateLineWidth(lineWidth - 0.1)
    }
    
  }
  
  @IBAction func lineWidthPlusButtonDidTouchUpInside(_ sender: UIButton) {
    
    updateLineWidth(lineWidth + 0.1)
    
  }
  
  @IBAction func freehandButtonDidTouchUpInside(_ sender: UIButton) {
    
    updateFreehand(!sender.isSelected)
    
  }
  
}
