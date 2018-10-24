//
//  ZFLeafCollectionView.swift
//  ZFLeafScrollViewExample
//
//  Created by ZhiFei on 2018/10/24.
//  Copyright © 2018 ZhiFei. All rights reserved.
//

import Foundation
import UIKit

class ZFLeafCollectionView: UICollectionView {
  
  fileprivate var willBeginDraggingOffset: CGPoint?
  
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with: event)
    
    if self.isTracking {
      return self.getHitTest(point, with: event, in: view)
    }
    
    if self.isDragging {
      return self.getHitTest(point, with: event, in: view)
    }
    
    if self.isDecelerating {
      return self.getHitTest(point, with: event, in: view)
    }
    
    return view
  }
  
}

extension ZFLeafCollectionView {
  
  func configure(willBeginDraggingOffset: CGPoint) {
    self.willBeginDraggingOffset = willBeginDraggingOffset
  }
  
}

fileprivate extension ZFLeafCollectionView {
  
    func getHitTest(_ point: CGPoint, with event: UIEvent?, in view: UIView?) -> UIView? {
      if let layout = self.collectionViewLayout as? ZFLeafLayout, let willBeginDraggingOffset = self.willBeginDraggingOffset {
        let distance = abs(self.contentOffset.x - willBeginDraggingOffset.x)
        if distance > layout.itemSize.width / 2.0 {
          return nil
        }
      }
      return view
    }
  
}
