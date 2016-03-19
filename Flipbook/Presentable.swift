//
//  Presentable.swift
//  Flipbook
//
//  Created by Matthew Hallatt on 23/12/2015.
//  Copyright © 2015 Matthew Hallatt. All rights reserved.
//

protocol Presentable {
  
  var present: (Bool -> Void) { get set }
  
}
