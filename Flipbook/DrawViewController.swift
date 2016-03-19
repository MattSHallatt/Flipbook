//
//  DrawViewController.swift
//  Flipbook
//
//  Created by Matthew Hallatt on 21/11/2015.
//  Copyright © 2015 Matthew Hallatt. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController {
  
  enum SegueIdentifiers: String {
    case PlaybackEmbedSegueIdentifier
    case DrawingEmbedSegueIdentifier
  }
  
  @IBOutlet weak var previousFrameView: UIImageView!
  @IBOutlet weak var currentFrameView: DrawableView!
  @IBOutlet weak var freehandButton: UIButton!
  @IBOutlet weak var nextFrameButton: UIButton!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var undoButton: UIButton!
  @IBOutlet      var colourButtons: [UIButton]!
  
  @IBOutlet weak var playbackSettingsContainerView: SlideOverView!
  @IBOutlet weak var drawingSettingsContainerView: SlideOverView!
  @IBOutlet weak var timelineSettingsView: SlideOverView!
  
  @IBOutlet weak var playbackSettingsLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var drawingSettingsTrailingConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var backgroundTapGestureRecogniser: UITapGestureRecognizer!
  
  var timer: NSTimer?
  
  var currentFrame = 0
  var shouldRepeat = false
  var isPlaying = false
  
  var frames: [UIImage] = [ ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    currentFrameView.lineDrawn = {
      self.undoButton.enabled = self.currentFrameView.count > 0
    }
    
    playbackSettingsContainerView.present = { [weak self] animated in
      
      self?.updateConstraint(animated) {
        self?.playbackSettingsLeadingConstraint.constant = 0
      }
      
      self?.backgroundTapGestureRecogniser.enabled = true
      
    }
    
    playbackSettingsContainerView.dismiss = { [weak self] animated in
      
      self?.updateConstraint(animated) {
        if let playbackSettingsContainerView = self?.playbackSettingsContainerView {
          self?.playbackSettingsLeadingConstraint.constant = -playbackSettingsContainerView.frame.size.width
        }
      }
      
      self?.backgroundTapGestureRecogniser.enabled = false
      
    }
    
    drawingSettingsContainerView.present = { [weak self] animated in
      
      self?.updateConstraint(animated) {
        self?.drawingSettingsTrailingConstraint.constant = 0
      }
      
      self?.backgroundTapGestureRecogniser.enabled = true
      
    }
    
    drawingSettingsContainerView.dismiss = { [weak self] animated in
      
      self?.updateConstraint(animated) {
        if let drawingSettingsContainerView = self?.drawingSettingsContainerView {
          self?.drawingSettingsTrailingConstraint.constant = drawingSettingsContainerView.frame.size.width
        }
      }
      
      self?.backgroundTapGestureRecogniser.enabled = false
      
    }
    
  }
  
  func updateConstraint(animated: Bool = true, update: (Void -> Void)) {
    
    update()
    
    if animated {
      UIView.animateWithDuration(0.3) { [ weak self] in
        self?.view.layoutIfNeeded()
      }
    } else {
      view.layoutIfNeeded()
    }
    
  }
  
  @IBAction func freehandButtonDidTouchUpInside(sender: UIButton) {
    currentFrameView.freehand.flip()
    freehandButton.setTitle(currentFrameView.freehand ? "Freehand" : "Straight", forState: .Normal)
  }
  
  @IBAction func nextFrameButtonDidTouchUpInside(sender: UIButton) {
    let image = currentFrameView.currentCanvas()
    currentFrameView.clearCanvas()
    previousFrameView.image = image
    frames.append(image)
  }
  
  @IBAction func playButtonDidTouchUpInside(sender: UIButton) {
    if isPlaying {
      stopPlayback()
    } else if !frames.isEmpty {
      startPlayback()
    }
  }
  
  @IBAction func resetButtonDidTouchUpInside(sender: UIButton) {
    stopPlayback()
    currentFrameView.clearCanvas()
    frames = [ ]
    previousFrameView.image = nil
  }
  
  @IBAction func undoButtonDidTouchUpInside(sender: UIButton) {
    currentFrameView.undoLastStroke()
    if currentFrameView.count == 0 {
      undoButton.enabled = false
    }
  }
  
  @IBAction func repeatSwitchDidChangeValue(sender: UISwitch) {
    shouldRepeat.flip()
  }
  
  @IBAction func backgroundWasTapped(recogniser: UITapGestureRecognizer) {
    playbackSettingsContainerView.dismiss(true)
    drawingSettingsContainerView.dismiss(true)
  }
  
  func startPlayback() {
    currentFrame = 0
    currentFrameView.hidden = true
    timer = NSTimer.scheduledTimerWithTimeInterval(1/24, target: self, selector: "updateFrame", userInfo: nil, repeats: true)
    playButton.setTitle("Stop", forState: .Normal)
    isPlaying = true
  }
  
  func stopPlayback() {
    currentFrameView.hidden = false
    timer?.invalidate()
    timer = nil
    playButton.setTitle("Play", forState: .Normal)
    isPlaying = false
    currentFrame = 0
    previousFrameView.image = frames.last
  }
  
  func updateFrame() {
    previousFrameView.image = frames[currentFrame]
    currentFrame++
    if (currentFrame == frames.count) {
      currentFrame = 0
      if !shouldRepeat {
        stopPlayback()
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    super.prepareForSegue(segue, sender: sender)
    
    guard let identifier = segue.identifier else {
      return
    }
    
    switch identifier {
      
    case SegueIdentifiers.DrawingEmbedSegueIdentifier.rawValue:
      let destination: DrawingSettingsViewController = segue.destinationViewController as! DrawingSettingsViewController
      destination.delegate = self
      break
      
    case SegueIdentifiers.PlaybackEmbedSegueIdentifier.rawValue:
      fallthrough
      
    default:
      break
      
    }
  }
  
}

extension DrawViewController {
  
  @IBAction func playbackButtonDidTouchUpInside(sender: UIButton) {
    playbackSettingsContainerView.present(true)
  }
  
}

extension DrawViewController {
  
  @IBAction func drawButtonDidTouchUpInside(sender: UIButton) {
    drawingSettingsContainerView.present(true)
  }
  
}

extension DrawViewController {
  
  @IBAction func timelineButtonDidTouchUpInside(sender: UIButton) {
    timelineSettingsView.present(true)
  }
  
}

extension DrawViewController: DrawingSettingsDelegate {
  
  func colorDidChange(color: UIColor?) {
    currentFrameView.strokeColor = color
  }
  
  func lineWidthDidChange(width: CGFloat) {
    currentFrameView.strokeWidth = width
  }
  
  func freehandDidToggle(enabled: Bool) {
    currentFrameView.freehand = enabled
  }
  
}

extension Bool {
  mutating func flip() {
    self = !self
  }
}
