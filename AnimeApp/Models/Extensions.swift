//
//  Extensions.swift
//  AnimeApp
//
//  Created by Preston Clayton on 4/23/23.
//

import Foundation
import UIKit

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension MutableCollection {
  mutating func modifyEach(_ modify: (inout Element) throws -> Void) rethrows {
    var i = startIndex
    while i != endIndex {
      try modify(&self[i])
      formIndex(after: &i)
    }
  }
}

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

