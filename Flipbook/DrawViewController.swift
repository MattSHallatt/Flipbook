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
  
  var timer: Timer?
  
  var currentFrame = 0
  var shouldRepeat = false
  var isPlaying = false
  
  var frames: [UIImage] = [ ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    currentFrameView.lineDrawn = {
      self.undoButton.isEnabled = self.currentFrameView.count > 0
    }
    
    playbackSettingsContainerView.present = { [weak self] animated in
      
      self?.updateConstraint(animated) {
        self?.playbackSettingsLeadingConstraint.constant = 0
      }
      
      self?.backgroundTapGestureRecogniser.isEnabled = true
      
    }
    
    playbackSettingsContainerView.dismiss = { [weak self] animated in
      
      self?.updateConstraint(animated) {
        if let playbackSettingsContainerView = self?.playbackSettingsContainerView {
          self?.playbackSettingsLeadingConstraint.constant = -playbackSettingsContainerView.frame.size.width
        }
      }
      
      self?.backgroundTapGestureRecogniser.isEnabled = false
      
    }
    
    drawingSettingsContainerView.present = { [weak self] animated in
      
      self?.updateConstraint(animated) {
        self?.drawingSettingsTrailingConstraint.constant = 0
      }
      
      self?.backgroundTapGestureRecogniser.isEnabled = true
      
    }
    
    drawingSettingsContainerView.dismiss = { [weak self] animated in
      
      self?.updateConstraint(animated) {
        if let drawingSettingsContainerView = self?.drawingSettingsContainerView {
          self?.drawingSettingsTrailingConstraint.constant = drawingSettingsContainerView.frame.size.width
        }
      }
      
      self?.backgroundTapGestureRecogniser.isEnabled = false
      
    }
    
  }
  
  func updateConstraint(_ animated: Bool = true, update: ((Void) -> Void)) {
    
    update()
    
    if animated {
      UIView.animate(withDuration: 0.3, animations: { [ weak self] in
        self?.view.layoutIfNeeded()
      }) 
    } else {
      view.layoutIfNeeded()
    }
    
  }
  
  @IBAction func freehandButtonDidTouchUpInside(_ sender: UIButton) {
    currentFrameView.freehand.flip()
    freehandButton.setTitle(currentFrameView.freehand ? "Freehand" : "Straight", for: UIControlState())
  }
  
  @IBAction func nextFrameButtonDidTouchUpInside(_ sender: UIButton) {
    let image = currentFrameView.currentCanvas()
    currentFrameView.clearCanvas()
    previousFrameView.image = image
    frames.append(image)
  }
  
  @IBAction func playButtonDidTouchUpInside(_ sender: UIButton) {
    if isPlaying {
      stopPlayback()
    } else if !frames.isEmpty {
      startPlayback()
    }
  }
  
  @IBAction func resetButtonDidTouchUpInside(_ sender: UIButton) {
    stopPlayback()
    currentFrameView.clearCanvas()
    frames = [ ]
    previousFrameView.image = nil
  }
  
  @IBAction func undoButtonDidTouchUpInside(_ sender: UIButton) {
    currentFrameView.undoLastStroke()
    if currentFrameView.count == 0 {
      undoButton.isEnabled = false
    }
  }
  
  @IBAction func repeatSwitchDidChangeValue(_ sender: UISwitch) {
    shouldRepeat.flip()
  }
  
  @IBAction func backgroundWasTapped(_ recogniser: UITapGestureRecognizer) {
    playbackSettingsContainerView.dismiss(true)
    drawingSettingsContainerView.dismiss(true)
  }
  
  func startPlayback() {
    currentFrame = 0
    currentFrameView.isHidden = true
    timer = Timer.scheduledTimer(timeInterval: 1/24, target: self, selector: #selector(DrawViewController.updateFrame), userInfo: nil, repeats: true)
    playButton.setTitle("Stop", for: UIControlState())
    isPlaying = true
  }
  
  func stopPlayback() {
    currentFrameView.isHidden = false
    timer?.invalidate()
    timer = nil
    playButton.setTitle("Play", for: UIControlState())
    isPlaying = false
    currentFrame = 0
    previousFrameView.image = frames.last
  }
  
  func updateFrame() {
    previousFrameView.image = frames[currentFrame]
    currentFrame += 1
    if (currentFrame == frames.count) {
      currentFrame = 0
      if !shouldRepeat {
        stopPlayback()
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    guard let identifier = segue.identifier else {
      return
    }
    
    switch identifier {
      
    case SegueIdentifiers.DrawingEmbedSegueIdentifier.rawValue:
      let destination: DrawingSettingsViewController = segue.destination as! DrawingSettingsViewController
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
  
  @IBAction func playbackButtonDidTouchUpInside(_ sender: UIButton) {
    playbackSettingsContainerView.present(true)
  }
  
}

extension DrawViewController {
  
  @IBAction func drawButtonDidTouchUpInside(_ sender: UIButton) {
    drawingSettingsContainerView.present(true)
  }
  
}

extension DrawViewController {
  
  @IBAction func timelineButtonDidTouchUpInside(_ sender: UIButton) {
    timelineSettingsView.present(true)
  }
  
}

extension DrawViewController: DrawingSettingsDelegate {
  
  func colorDidChange(_ color: UIColor?) {
    currentFrameView.strokeColor = color
  }
  
  func lineWidthDidChange(_ width: CGFloat) {
    currentFrameView.strokeWidth = width
  }
  
  func freehandDidToggle(_ enabled: Bool) {
    currentFrameView.freehand = enabled
  }
  
}

extension Bool {
  mutating func flip() {
    self = !self
  }
}
