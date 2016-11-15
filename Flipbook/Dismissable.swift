//
//  Dismissable.swift
//  Flipbook
//
//  Created by Matthew Hallatt on 23/12/2015.
//  Copyright © 2015 Matthew Hallatt. All rights reserved.
//

protocol Dismissable {
  
  var dismiss: ((Bool) -> Void) { get set }
  
}
