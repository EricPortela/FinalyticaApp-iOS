//
//  RankingCollectionReusableView.swift
//  financeApp
//
//  Created by Eric Portela on 2021-08-18.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class RankingCollectionReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
           super.init(frame: frame)
           setUpView()
    }
       
    var cellWidth = CGFloat(UIScreen.main.bounds.size.width - 40)
    var cellHeight = CGFloat(62)

    let headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        return lbl
    }()

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

        self.layer.addSublayer(shape)
    }

    func setUpView(){
        //Header Label
        let headerHeight = CGFloat(22)
        let headerWidth = cellWidth
        let headerY = CGFloat(10)
        headerLabel.frame = CGRect(x: 20, y: headerY, width: headerWidth, height: headerHeight)
        self.addSubview(headerLabel)
        
        //Segmented Control
        let segmentedHeight = CGFloat(32)
        let segmentedWidth = CGFloat(cellWidth)
        let segmentedY = CGFloat(headerY + headerHeight + 10)
        segmentedControl.frame = CGRect(x: 20, y: segmentedY, width: segmentedWidth, height: segmentedHeight)
        self.addSubview(segmentedControl)
        
        //self.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
