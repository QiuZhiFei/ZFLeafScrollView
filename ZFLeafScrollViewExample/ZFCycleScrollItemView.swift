//
//  ZFCycleScrollItemView.swift
//  ZFCycleScrollView
//
//  Created by ZhiFei on 2018/10/16.
//  Copyright © 2018 ZhiFei. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class ZFCycleScrollItemView: UIView {
  
  fileprivate let label = UILabel(frame: .zero)
  fileprivate let imageView = UIImageView(frame: .zero)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension ZFCycleScrollItemView {
  
  func configure(text: String) {
    label.text = text
    
    imageView.image = UIImage(named: "\(text).jpg")
  }
  
}

fileprivate extension ZFCycleScrollItemView {
  
  func setup() {
    addSubview(imageView)
    imageView.autoPinEdgesToSuperviewEdges(with: .zero)
    
    addSubview(label)
    label.backgroundColor = .white
    label.autoCenterInSuperview()
  }
  
}
