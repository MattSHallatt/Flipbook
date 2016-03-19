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
  
  private var startingPoint: CGPoint?
  private var endingPoint:   CGPoint?
  private var strokeStartDate: NSDate?
  
  private var lines: [NSDate : [Line]] = Dictionary()
  
  var count: Int { return lines.count }
  
  var freehand: Bool = true
  var strokeColor: UIColor! = .blackColor()
  var strokeWidth: CGFloat = 1
  
  var lineDrawn: (Void -> Void)?
  
  func currentCanvas() -> UIImage {
    UIGraphicsBeginImageContext(frame.size)
    drawViewHierarchyInRect(bounds, afterScreenUpdates: false)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
  
  func clearCanvas() {
    lines = Dictionary()
    setNeedsDisplay()
  }
  
  func undoLastStroke() {
    var latestDate: NSDate?
    for (date, _) in lines {
      if let tempLatestDate = latestDate {
        if date.compare(tempLatestDate) == .OrderedDescending {
          latestDate = date
        }
      } else {
        latestDate = date
      }
    }
    lines.removeValueForKey(latestDate!)
    setNeedsDisplay()
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    strokeStartDate = NSDate()
    lines[strokeStartDate!] = [ ]
    startingPoint = touches.first?.locationInView(self)
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesMoved(touches, withEvent: event)
    
    endingPoint = touches.first?.locationInView(self)
    
    if (freehand) {
      lines[strokeStartDate!]!.append(Line(startingPoint: startingPoint, endingPoint: endingPoint, color: strokeColor, width: strokeWidth))
      startingPoint = endingPoint
    }
    
    setNeedsDisplay()
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesEnded(touches, withEvent: event)
    
    if (!freehand) {
      endingPoint = touches.first?.locationInView(self)
      lines[strokeStartDate!]!.append(Line(startingPoint: startingPoint!, endingPoint: endingPoint!, color: strokeColor, width: strokeWidth))
    }
    
    startingPoint = nil
    endingPoint   = nil
    
    if let lineDrawn = lineDrawn {
      lineDrawn()
    }
    
    setNeedsDisplay()
  }
  
  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    
    let ctx = UIGraphicsGetCurrentContext()
    
    if let startingPoint = startingPoint, let endingPoint = endingPoint {
      CGContextAddLine(ctx, Line(startingPoint: startingPoint, endingPoint: endingPoint, color: strokeColor, width: strokeWidth))
      CGContextDrawPath(ctx, .Stroke)
    }
    
    for (_, line) in lines {
      
      for (lineSegment) in line {
        CGContextAddLine(ctx, lineSegment)
        CGContextDrawPath(ctx, .Stroke)
      }
      
    }
    
  }
  
  func CGContextAddLine(c: CGContext?, _ line: Line) {
    CGContextSetStrokeColorWithColor(c, line.color.CGColor)
    CGContextSetLineWidth(c, line.width)
    CGContextMoveToCGPoint(c, line.startingPoint)
    CGContextAddLineToCGPoint(c, line.endingPoint)
  }
  
  func CGContextMoveToCGPoint(c: CGContext?, _ point: CGPoint) {
    CGContextMoveToPoint(c, point.x, point.y)
  }
  
  func CGContextAddLineToCGPoint(c: CGContext?, _ point: CGPoint) {
    CGContextAddLineToPoint(c, point.x, point.y)
  }
  
}
