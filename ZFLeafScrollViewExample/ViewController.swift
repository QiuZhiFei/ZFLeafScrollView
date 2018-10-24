//
//  ViewController.swift
//  ZFLeafScrollViewExample
//
//  Created by ZhiFei on 2018/10/23.
//  Copyright © 2018 ZhiFei. All rights reserved.
//

import UIKit
import PureLayout
import KVOController

class ViewController: UIViewController {
  
  fileprivate let datasCount = 3
  fileprivate let leafView = ZFLeafScrollView(frame: .zero)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    leafView.layer.borderColor = UIColor.red.cgColor
    leafView.layer.borderWidth = 1
    leafView.configure(datasCount: 30)
    leafView.configure(startIndex: 2)
    
    self.view.addSubview(leafView)
    let height = self.view.bounds.width - 40
    leafView.autoPinEdge(toSuperviewEdge: .left)
    leafView.autoPinEdge(toSuperviewEdge: .right)
    leafView.autoPinEdge(toSuperviewEdge: .top,
                         withInset: 100)
    leafView.autoSetDimension(.height,
                              toSize: height)
    
    leafView.didSelectItemHandler = {
      [weak self] (index) in
      guard let `self` = self else { return }
      debugPrint("did select \(index)")
    }
    leafView.scrollingEndedHandler = {
      [weak self] (index, oldIndex, direction) in
      guard let `self` = self else { return }
      debugPrint("\(direction): \(oldIndex) to \(index)")
    }
    leafView.displayItemHandler = {
      [weak self] (cell, index) in
      guard let `self` = self else { return }
      //      debugPrint("display index == \(index), cur == \(self.cy.currentIndex)")
      if cell.itemView == nil {
        let itemView = ZFCycleScrollItemView(frame: .zero)
        cell.itemView = itemView
        
        cell.contentView.addSubview(itemView)
        itemView.autoPinEdgesToSuperviewEdges(with: .zero)
      }
      if let itemView = cell.itemView as? ZFCycleScrollItemView {
        itemView.configure(text: "\(index)")
      }
    }
    
    
    let nextBtn = UIButton(type: .custom)
    nextBtn.setTitle("next", for: .normal)
    nextBtn.setTitleColor(.black, for: .normal)
    nextBtn.addTarget(self, action: #selector(ViewController.handleNext), for: .touchUpInside)
    
    self.view.addSubview(nextBtn)
    nextBtn.autoPinEdge(toSuperviewEdge: .left)
    nextBtn.autoPinEdge(.top, to: .bottom, of: leafView, withOffset: 20)
    nextBtn.autoSetDimensions(to: CGSize(width: 50, height: 50))
    
    
    let previousBtn = UIButton(type: .custom)
    previousBtn.setTitle("previous", for: .normal)
    previousBtn.setTitleColor(.black, for: .normal)
    previousBtn.addTarget(self, action: #selector(ViewController.handlePrevious), for: .touchUpInside)
    
    self.view.addSubview(previousBtn)
    previousBtn.autoPinEdge(.left, to: .right, of: nextBtn, withOffset: 20)
    previousBtn.autoPinEdge(.top, to: .bottom, of: leafView, withOffset: 20)
    previousBtn.autoSetDimensions(to: CGSize(width: 70, height: 50))
  }
  
}

fileprivate extension ViewController {
  
  @objc func handleNext() {
    self.leafView.next()
  }
  
  @objc func handlePrevious() {
    self.leafView.previous()
  }
  
}
