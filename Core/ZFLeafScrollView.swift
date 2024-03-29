//
//  ZFLeafScrollView.swift
//  Temp
//
//  Created by ZhiFei on 2018/10/23.
//  Copyright © 2018 ZhiFei. All rights reserved.
//

import Foundation
import UIKit
import PureLayout
import KVOController

fileprivate let ZFLeafScrollViewCellID = "ZFLeafScrollViewCellID"

/// 移动方向
///
/// - left:   向左移
/// - right:  向右移
enum ZFLeafDirection {
  case left
  case right
}

enum ZFLeafScrollViewType {
  case normal
  case cyclic
}

@objcMembers class ZFLeafScrollView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
  
  public var displayItemHandler: ((_ cell: ZFLeafScrollViewCell, _ index: Int) -> ())?
  public var didSelectItemHandler: ((_ index: Int) -> ())?
  public var scrollingEndedHandler: ((_ index: Int, _ oldIndex: Int, _ direction: ZFLeafDirection) -> ())?
  
  // 仅作为业务数据标识
  public var data: Any?
  
  public var currentIndex: Int {
    if self.datasCount < 1 {
      return 0
    }
    let row = (collectionView.contentOffset.x + contentInset.left)/self.flowLayout.itemSize.width
    let index = Int(row) % self.datasCount
    return index
  }
  
  public var isTracking: Bool {
    return collectionView.isTracking
  }
  
  public var isDragging: Bool {
    return collectionView.isDragging
  }
  
  public var isDecelerating: Bool {
    return collectionView.isDecelerating
  }
  
  public var isZFPagingEnabled: Bool {
    set {
      collectionView.isZFPagingEnabled = newValue
    }
    get {
      return collectionView.isZFPagingEnabled
    }
  }
  
  fileprivate let flowLayout: UICollectionViewFlowLayout
  fileprivate let collectionView: ZFLeafCollectionView
  fileprivate var contentInset = UIEdgeInsets.zero
  
  fileprivate var itemsCount: Int = 0 // item 数量
  public fileprivate(set) var datasCount: Int = 0 // data 数量
  fileprivate var startIndex: Int = 0
  fileprivate var cacheCurrentIndex: Int?
  fileprivate var type: ZFLeafScrollViewType = .cyclic
  
  fileprivate var willEndDraggingOffset: CGPoint = .zero
  fileprivate var willBeginDraggingOffset: CGPoint = .zero
  fileprivate var oldIndex: Int = 0
  
  init(frame: CGRect, contentInset: UIEdgeInsets, flowLayout: UICollectionViewFlowLayout) {
    self.contentInset = contentInset
    self.flowLayout = flowLayout
    
    collectionView = ZFLeafCollectionView(frame: .zero,
                                          collectionViewLayout: flowLayout)
    collectionView.delaysContentTouches = false
    
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: Overwrite
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    let size = collectionView.bounds.size
    flowLayout.itemSize = CGSize(width: size.width - contentInset.left - contentInset.right, height: size.height)
  }
  
  //MARK: UICollectionViewDataSource && UICollectionViewDelegate
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return itemsCount
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZFLeafScrollViewCellID, for: indexPath)
    if let cell = cell as? ZFLeafScrollViewCell {
      let index = getIndex(indexPath: indexPath)
      if let handler = self.displayItemHandler {
        handler(cell, index)
      }
    }
    
    return cell
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let index = self.getIndex(indexPath: indexPath)
    if let handler = self.didSelectItemHandler {
      handler(index)
    }
  }
  
  //MARK: UIScrollViewDelegate
  
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      self.scrollingEnded()
    }
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.scrollingEnded()
  }
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    self.perform(#selector(ZFLeafScrollView.scrollingEnded),
                 with: nil,
                 afterDelay: 0)
  }
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.collectionView.configure(willBeginDraggingOffset: scrollView.contentOffset)
    self.willBeginDraggingOffset = scrollView.contentOffset
  }
  
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    self.willEndDraggingOffset = scrollView.contentOffset
    
    let pointee = targetContentOffset.pointee
    
    if self.willBeginDraggingOffset.x < -contentInset.left {
      // 最左侧滑动
      return
    }
    if self.willBeginDraggingOffset.x > self.collectionView.contentSize.width - self.collectionView.bounds.width + contentInset.right {
      // 最右侧滑动
      return
    }
    
    if abs(pointee.x - self.willBeginDraggingOffset.x) < self.flowLayout.itemSize.width / 2.0 {
      return
    }
    
    let pointeeX = Int(round(pointee.x))
    let willBeginDraggingOffsetX = Int(round(self.willBeginDraggingOffset.x))
    
    if pointeeX == willBeginDraggingOffsetX {
      return
    }
    
    let willBeginDraggingRow = Int(round((self.willBeginDraggingOffset.x + contentInset.left)/self.flowLayout.itemSize.width))
    var next = willBeginDraggingRow
    if pointeeX < willBeginDraggingOffsetX {
      // 左
      if next <= 0 {
        return
      }
      next = next - 1
    }
    if pointeeX > willBeginDraggingOffsetX {
      // 右
      if next >= itemsCount - 1 {
        return
      }
      next = next + 1
    }
    
    let nextPointeeX
      = (flowLayout.itemSize.width + flowLayout.minimumLineSpacing) * CGFloat(next) - contentInset.left
    targetContentOffset.pointee = CGPoint(x: nextPointeeX, y: targetContentOffset.pointee.y)
  }
  
}

extension ZFLeafScrollView {
  
  //Todo: 暂时根据足够多数据实现循环
  func configure(datasCount: Int, type: ZFLeafScrollViewType = .cyclic) {
    self.datasCount = datasCount
    self.type = type
    
    switch type {
    case .normal:
      self.itemsCount = self.datasCount
    case .cyclic:
      if (datasCount > 0) {
        // 取最大的偶数
        var times = Int(Int16.max) / datasCount
        if times % 2 != 0 {
          times = times < 2 ? times : (times - 1)
        }
        self.itemsCount = times * datasCount
      } else {
        self.itemsCount = Int(Int16.max)
      }
    }
  }
  
  func configure(startIndex: Int) {
    self.startIndex = startIndex
    self.oldIndex = startIndex
  }
  
  func scrollToData(at index: Int, animated: Bool) {
    if index < 0 {
      return
    }
    if index > self.datasCount - 1 {
      return
    }
    if index == self.currentIndex {
      return
    }
    
    var item: Int?
    switch self.type {
    case .normal:
      item = index
    case .cyclic:
      item = self.itemsCount / 2 + index
    }
    if let item = item {
      let indexPath = IndexPath(item: item, section: 0)
      collectionView.scrollToItem(at: indexPath,
                                  at: .centeredHorizontally,
                                  animated: animated)
    }
  }
  
  func next() {
    if self.collectionView.isTracking {
      return
    }
    
    if self.collectionView.isDragging {
      return
    }
    
    if self.collectionView.isDecelerating {
      return
    }
    
    let row = (collectionView.contentOffset.x + contentInset.left)/self.flowLayout.itemSize.width
    // 偏移 0.1，不触发 => 用户快速 next
    if abs(row - round(row)) > 0.1 {
      return
    }
    self.scrollToItem(at: Int(round(row)) + 1, animated: true)
  }
  
  func previous() {
    if self.collectionView.isTracking {
      return
    }
    
    if self.collectionView.isDragging {
      return
    }
    
    if self.collectionView.isDecelerating {
      return
    }
    
    let row = (collectionView.contentOffset.x + contentInset.left)/self.flowLayout.itemSize.width
    // 偏移 0.1，不触发 => 用户快速 next
    if abs(row - round(row)) > 0.1 {
      return
    }
    self.scrollToItem(at: Int(round(row)) - 1, animated: true)
  }
  
  func configure(currentIndex: Int) {
    if self.currentIndex == currentIndex {
      return
    }
    
    let contentSize = collectionView.contentSize
    if contentSize.width == 0 || contentSize.height == 0 {
      // set currentIndex 时，kvoController contentsize 可能还没有执行
      self.cacheCurrentIndex = currentIndex
    } else {
      self.scrollToData(at: currentIndex, animated: false)
      self.oldIndex = currentIndex
    }
  }
  
  func reloadData() {
    self.collectionView.reloadData()
  }
  
}

fileprivate extension ZFLeafScrollView {
  
  func setup() {
    collectionView.backgroundColor = UIColor.clear
    collectionView.scrollsToTop = false
    collectionView.contentInset = contentInset
    
    if #available(iOS 11.0, *) {
      collectionView.reorderingCadence = .fast
    }
    
    // 滚动速度
    collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    // 不接受 normal fast 之外的值
    //    collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.1)
    
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.register(ZFLeafScrollViewCell.self,
                            forCellWithReuseIdentifier: ZFLeafScrollViewCellID)
    
    collectionView.dataSource = self
    collectionView.delegate = self
    
    self.addSubview(collectionView)
    collectionView.autoPinEdgesToSuperviewEdges(with: .zero)
    collectionView.backgroundColor = .clear
    
    // 滚动到中间位置
    self.kvoController
      .observe(collectionView,
               keyPath: "contentSize",
               options: [.new, .initial]) {
                [weak self] (observer, contentView, dict) in
                guard let `self` = self else { return }
                let contentSize = self.collectionView.contentSize
                if contentSize.width == 0 {
                  return
                }
                if contentSize.height == 0 {
                  return
                }
                self.kvoController.unobserve(self.collectionView)
                
                if let index = self.cacheCurrentIndex {
                  self.configure(currentIndex: index)
                } else {
                  self.scrollToStartIndex()
                }
    }
  }
  
  func getIndex(indexPath: IndexPath) -> Int {
    if self.datasCount > 0 {
      return indexPath.row % self.datasCount
    }
    return 0
  }
  
  func scrollToStartIndex() {
    if itemsCount > 0, self.startIndex <= self.datasCount - 1 {
      var indexPath: IndexPath?
      switch self.type {
      case .normal:
        indexPath = IndexPath(item: self.startIndex, section: 0)
      case .cyclic:
        indexPath = IndexPath(item: itemsCount / 2 + self.startIndex, section: 0)
      }
      if let indexPath = indexPath {
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: false)
      }
    }
  }
  
  // 移动到 item
  func scrollToItem(at index: Int, animated: Bool) {
    if index < 0 {
      return
    }
    if index > self.itemsCount - 1 {
      return
    }
    
    let indexPath = IndexPath(item: index, section: 0)
    collectionView.scrollToItem(at: indexPath,
                                at: .centeredHorizontally,
                                animated: animated)
  }
  
  @objc func scrollingEnded() {
    let currentIndex = self.currentIndex
    
    var direction = ZFLeafDirection.left
    if self.willEndDraggingOffset.x > self.collectionView.contentOffset.x {
      direction = .right
    }
    
    if let handler = self.scrollingEndedHandler {
      handler(currentIndex, self.oldIndex, direction)
    }
    
    self.oldIndex = currentIndex
  }
  
}
