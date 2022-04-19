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
  
  fileprivate var leafView: ZFLeafScrollView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupMiniLeafView()
    
    ////////////////////////////////////////////
    
    let datasCount = 30
    let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    let flowLayout = ZFLeafLayout()
    flowLayout.scrollDirection = .horizontal
    flowLayout.minimumLineSpacing = 0
    flowLayout.lineSpacing = 15
    flowLayout.minAlpha = 0.3
    
    let leafView = ZFLeafScrollView(frame: .zero,
                                    contentInset: contentInset,
                                    flowLayout: flowLayout)
    self.leafView = leafView
    
    leafView.configure(datasCount: datasCount)
    leafView.configure(startIndex: 0)
    
    ////////////////////////////////////////////
    
    leafView.layer.borderColor = UIColor.red.cgColor
    leafView.layer.borderWidth = 1
    
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
    
    
    let randomBtn = UIButton(type: .custom)
    randomBtn.setTitle("random", for: .normal)
    randomBtn.setTitleColor(.black, for: .normal)
    randomBtn.addTarget(self, action: #selector(ViewController.handleRandom), for: .touchUpInside)
    
    self.view.addSubview(randomBtn)
    randomBtn.autoPinEdge(.left, to: .right, of: previousBtn, withOffset: 20)
    randomBtn.autoPinEdge(.top, to: .bottom, of: leafView, withOffset: 20)
    randomBtn.autoSetDimensions(to: CGSize(width: 70, height: 50))
  }
  
}

fileprivate extension ViewController {
  
  @objc func handleNext() {
    self.leafView?.next()
  }
  
  @objc func handlePrevious() {
    self.leafView?.previous()
  }
  
  @objc func handleRandom() {
    self.leafView?.configure(currentIndex: 1)
  }
  
}

fileprivate extension ViewController {
  
  func setupMiniLeafView() {
    let datasCount = 30
    let contentInset = UIEdgeInsets.zero
    
    let flowLayout = ZFLeafLayout()
    flowLayout.scrollDirection = .horizontal
    flowLayout.minimumLineSpacing = 0
    flowLayout.lineSpacing = 15
    flowLayout.minAlpha = 1
    
    let leafView = ZFLeafScrollView(frame: .zero,
                                    contentInset: contentInset,
                                    flowLayout: flowLayout)
    
    leafView.configure(datasCount: datasCount)
    leafView.configure(startIndex: 1)
    
    leafView.layer.borderColor = UIColor.red.cgColor
    leafView.layer.borderWidth = 1
    
    self.view.addSubview(leafView)
    let height: CGFloat = 44
    leafView.autoPinEdge(toSuperviewEdge: .left)
    leafView.autoPinEdge(toSuperviewEdge: .right)
    leafView.autoPin(toTopLayoutGuideOf: self, withInset: 20)
    leafView.autoSetDimension(.height,
                              toSize: height)
    
    
    /////////////
    
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
    
  }
  
}
