//
//  DrawableView.swift
//  Flipbook
//
//  Created by Matthew Hallatt on 21/11/2015.
//  Copyright © 2015 Matthew Hallatt. All rights reserved.
//

import UIKit

struct Line {
  
  let startingPoint: CGPoint!
  let endingPoint: CGPoint!
  let color: UIColor!
  let width: CGFloat!
  
}

class DrawableView: UIView {
  
  fileprivate var startingPoint: CGPoint?
  fileprivate var endingPoint:   CGPoint?
  fileprivate var strokeStartDate: Date?
  
  fileprivate var lines: [Date : [Line]] = Dictionary()
  
  var count: Int { return lines.count }
  
  var freehand: Bool = true
  var strokeColor: UIColor! = .black
  var strokeWidth: CGFloat = 1
  
  var lineDrawn: ((Void) -> Void)?
  
  func currentCanvas() -> UIImage {
    UIGraphicsBeginImageContext(frame.size)
    drawHierarchy(in: bounds, afterScreenUpdates: false)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }
  
  func clearCanvas() {
    lines = Dictionary()
    setNeedsDisplay()
  }
  
  func undoLastStroke() {
    var latestDate: Date?
    for (date, _) in lines {
      if let tempLatestDate = latestDate {
        if date.compare(tempLatestDate) == .orderedDescending {
          latestDate = date
        }
      } else {
        latestDate = date
      }
    }
    lines.removeValue(forKey: latestDate!)
    setNeedsDisplay()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    strokeStartDate = Date()
    lines[strokeStartDate!] = [ ]
    startingPoint = touches.first?.location(in: self)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    
    endingPoint = touches.first?.location(in: self)
    
    if (freehand) {
      lines[strokeStartDate!]!.append(Line(startingPoint: startingPoint, endingPoint: endingPoint, color: strokeColor, width: strokeWidth))
      startingPoint = endingPoint
    }
    
    setNeedsDisplay()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    if (!freehand) {
      endingPoint = touches.first?.location(in: self)
      lines[strokeStartDate!]!.append(Line(startingPoint: startingPoint!, endingPoint: endingPoint!, color: strokeColor, width: strokeWidth))
    }
    
    startingPoint = nil
    endingPoint   = nil
    
    if let lineDrawn = lineDrawn {
      lineDrawn()
    }
    
    setNeedsDisplay()
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    let ctx = UIGraphicsGetCurrentContext()
    
    if let startingPoint = startingPoint, let endingPoint = endingPoint {
      CGContextAddLine(ctx, Line(startingPoint: startingPoint, endingPoint: endingPoint, color: strokeColor, width: strokeWidth))
      ctx?.drawPath(using: .stroke)
    }
    
    for (_, line) in lines {
      
      for (lineSegment) in line {
        CGContextAddLine(ctx, lineSegment)
        ctx?.drawPath(using: .stroke)
      }
      
    }
    
  }
  
  func CGContextAddLine(_ c: CGContext?, _ line: Line) {
    c?.setStrokeColor(line.color.cgColor)
    c?.setLineWidth(line.width)
    CGContextMoveToCGPoint(c, line.startingPoint)
    CGContextAddLineToCGPoint(c, line.endingPoint)
  }
  
  func CGContextMoveToCGPoint(_ c: CGContext?, _ point: CGPoint) {
    c?.move(to: CGPoint(x: point.x, y: point.y))
  }
  
  func CGContextAddLineToCGPoint(_ c: CGContext?, _ point: CGPoint) {
    c?.addLine(to: CGPoint(x: point.x, y: point.y))
  }
  
}
