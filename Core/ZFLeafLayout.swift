//
//  ZFLeafLayout.swift
//  Temp
//
//  Created by ZhiFei on 2018/10/23.
//  Copyright © 2018 ZhiFei. All rights reserved.
//

import Foundation
import UIKit

private let maxScaleOffset: CGFloat = 200

@objcMembers class ZFLeafLayout: UICollectionViewFlowLayout {
  
  // 静止时，item 横向间距
  public var lineSpacing: CGFloat = 0
  
  public var minAlpha: CGFloat = 0.3

  
  override init() {
    super.init()
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: Overwrite
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
  
  public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let result = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
      return nil
    }
    debugPrint("1 start")
    centerScaledAttributes(attributes: result)
    debugPrint("1 end")
    return result
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let result = super.layoutAttributesForElements(in: rect) else {
      return nil
    }
    guard let _ = collectionView else {
      return result
    }
    debugPrint("result count == \(result.count)")
    debugPrint("2 start")
    for attributes in result {
      centerScaledAttributes(attributes: attributes)
    }
    debugPrint("2 end")
    return result
  }
  
  // 滑动结束时，自动滚动到 index
  public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                           withScrollingVelocity velocity: CGPoint) -> CGPoint {
    guard let collectionView = collectionView else {
      return proposedContentOffset
    }
    
    let proposedRect = CGRect(x: proposedContentOffset.x,
                              y: 0,
                              width: collectionView.bounds.width,
                              height: collectionView.bounds.height)
    guard let layoutAttributes = layoutAttributesForElements(in: proposedRect) else {
      return proposedContentOffset
    }
    
    var shouldBeChosenAttributes: UICollectionViewLayoutAttributes?
    var shouldBeChosenIndex: Int = -1
    
    let proposedCenterX = proposedRect.midX
    
    for (i, attributes) in layoutAttributes.enumerated() {
      guard attributes .representedElementCategory == .cell else {
        continue
      }
      guard let currentChosenAttributes = shouldBeChosenAttributes else {
        shouldBeChosenAttributes = attributes
        shouldBeChosenIndex = i
        continue
      }
      if (abs(attributes.frame.midX - proposedCenterX) < abs(currentChosenAttributes.frame.midX - proposedCenterX)) {
        shouldBeChosenAttributes = attributes
        shouldBeChosenIndex = i
      }
    }
    // Adjust the case where a quick but small scroll occurs.
    if (abs(collectionView.contentOffset.x - proposedContentOffset.x) < itemSize.width) {
      if velocity.x < -0.3 {
        shouldBeChosenIndex = shouldBeChosenIndex > 0 ? shouldBeChosenIndex - 1 : shouldBeChosenIndex
      } else if velocity.x > 0.3 {
        shouldBeChosenIndex = shouldBeChosenIndex < layoutAttributes.count - 1 ?
          shouldBeChosenIndex + 1 : shouldBeChosenIndex
      }
      shouldBeChosenAttributes = layoutAttributes[shouldBeChosenIndex]
    }
    guard let finalAttributes = shouldBeChosenAttributes else {
      return proposedContentOffset
    }
    return CGPoint(x: finalAttributes.frame.midX - collectionView.bounds.size.width / 2,
                   y: proposedContentOffset.y)
  }
  
}

fileprivate extension ZFLeafLayout {
  
  func setup() {
    
  }
  
  func centerScaledAttributes(attributes: UICollectionViewLayoutAttributes) {
    guard let collectionView = collectionView else {
      return
    }
    let visibleRect = CGRect(x: collectionView.contentOffset.x,
                             y: collectionView.contentOffset.y,
                             width: collectionView.bounds.size.width,
                             height: collectionView.bounds.size.height)
    let visibleCenterX = visibleRect.midX
    let distanceFromCenter = visibleCenterX - attributes.center.x
    let distance = min(abs(distanceFromCenter), maxScaleOffset)
    
    
    
    let minScale: CGFloat = 137 / 177
    
    let width = attributes.frame.width - lineSpacing * 2
    let height = attributes.frame.height
    attributes.frame = CGRect(x: attributes.frame.origin.x,
                              y: attributes.frame.origin.y,
                              width: width,
                              height: height)
    
//    let scale = distance * (minScale - 1) / maxScaleOffset + 1
    debugPrint(attributes.frame)
    
//    attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
//    attributes.alpha = distance * (minAlpha - 1) / maxScaleOffset + 1
  }
  
}
