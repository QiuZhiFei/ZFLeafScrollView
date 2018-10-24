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
    leafView.configure(datasCount: 3)
    
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
      [weak self] (index) in
      guard let `self` = self else { return }
      debugPrint("end \(index)")
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
  }
  
}

