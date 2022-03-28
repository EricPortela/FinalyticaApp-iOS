//
//  SegmentedControlCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-05-29.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class SegmentedControlCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    var cellWidth = CGFloat(UIScreen.main.bounds.size.width - 40)
    var cellHeight = CGFloat(62)
    
    let segmentedControl: UISegmentedControl = {
        let items = ["Gainers", "Losers", "Most Active"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        return control
    }()
    
    func drawLine(start: CGPoint, end: CGPoint, lineWidth: CGFloat, lineColor: UIColor) {
        //path design
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = lineColor.cgColor
        shape.lineWidth = lineWidth
        
        self.contentView.layer.addSublayer(shape)
    }
    
    func setUpView(){
        //Segmented Control
        let segmentedHeight = CGFloat(32)
        let segmentedWidth = CGFloat(cellWidth)
        segmentedControl.frame = CGRect(x: 0, y: ((cellHeight-segmentedHeight)/2), width: segmentedWidth, height: segmentedHeight)
        self.addSubview(segmentedControl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
