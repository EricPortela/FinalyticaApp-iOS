//
//  TopCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-06-17.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class TopCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
           super.init(frame: frame)
           setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Cell dimensions
    var cellHeight = CGFloat(460)
    var cellWidth = CGFloat(UIScreen.main.bounds.size.width - 40)

    let tickerLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Medium", size: 24)
        lbl.text = "--"
        lbl.textColor = .white
        return lbl
    }()
    
    let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue", size: 16)
        lbl.text = "--"
        lbl.textColor = .lightGray
        return lbl
    }()
    
    let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue", size: 24)
        lbl.text = "--"
        lbl.textColor = .white
        return lbl
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
    
    func setUpView() {
        //Ticker Label
        let tickerHeight = 25
        let tickerWidth = Int(cellWidth)
        tickerLabel.frame = CGRect(x: 0, y: 0, width: tickerWidth, height: tickerHeight)
        self.addSubview(tickerLabel)
        
        //Horizontal Divider
        //let yPositionDivider = yPositionName + nameHeight + 10
        //let start = CGPoint(x: 0, y: yPositionDivider)
        //let end = CGPoint(x: Int(cellWidth), y: yPositionDivider)
        //drawLine(start: start, end: end, lineWidth: 1, lineColor: .white)
        
        //Name Label
        let nameHeight = 18
        let nameWidth = 350
        let yPositionName = Int(tickerHeight + 5)
        nameLabel.frame = CGRect(x: 0, y: yPositionName, width: nameWidth, height: nameHeight)
        self.addSubview(nameLabel)
        
        //Price Label
        let priceWidth = CGFloat(200)
        let priceHeight = CGFloat(20)
        let yPositionPrice = CGFloat(yPositionName + nameHeight + 10)
        priceLabel.frame = CGRect(x: 0, y: yPositionPrice, width: priceWidth, height: priceHeight)
        self.addSubview(priceLabel)
    }
}
