//
//  RankingListCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-05-27.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class RankingListCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    var cellWidth = CGFloat(UIScreen.main.bounds.size.width - 40)
    var cellHeight = CGFloat(50)
    
    let tickerLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont(name: "HelveticaNeue", size: 14)
        lbl.textAlignment = .center
        lbl.text = "--"
        return lbl
    }()
    
    let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont(name: "HelveticaNeue", size: 14)
        lbl.textAlignment = .center
        lbl.text = "--"
        return lbl
    }()
    
    let changeLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        lbl.textAlignment = .center
        lbl.text = "--"
        return lbl
    }()
    
    let miniCard: UIView = {
        let view = UIView()
        //view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 5
        return view
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
        
        self.contentView.layer.addSublayer(shape)
    }
    
    func setUpView() {
        //Ticker Label
        let tickerWidth = CGFloat(70)
        let tickerHeight = CGFloat(20)
        tickerLabel.frame = CGRect(x: 10, y: ((cellHeight-tickerHeight)/2), width: tickerWidth, height: tickerHeight)
        self.addSubview(tickerLabel)
        
        //Price Label
        let priceWidth = CGFloat(70)
        let priceHeight = CGFloat(20)
        priceLabel.frame = CGRect(x: ((cellWidth-priceWidth)/2), y: ((cellHeight-priceHeight)/2), width: priceWidth, height: priceHeight)
        self.addSubview(priceLabel)
        
        //Mini Card
        let miniCardWidth = CGFloat(80)
        let miniCardHeight = CGFloat(cellHeight*0.6)
        miniCard.frame = CGRect(x: cellWidth-miniCardWidth-10, y: ((cellHeight-miniCardHeight)/2), width: miniCardWidth, height: miniCardHeight)
        self.addSubview(miniCard)

        //Change Label
        let lblHeight = CGFloat(20)
        let lblWidth = CGFloat(70)
        changeLabel.frame = CGRect(x: ((miniCardWidth-lblWidth)/2), y: ((miniCardHeight-lblHeight)/2), width: lblWidth, height: lblHeight)
        miniCard.addSubview(changeLabel)
        
        let yPositionHorizontalDivider = cellHeight - 1
        let start = CGPoint(x: 0, y: yPositionHorizontalDivider)
        let end = CGPoint(x: cellWidth, y: yPositionHorizontalDivider)
        drawLine(start: start, end: end, lineWidth: 1, lineColor: .tertiarySystemBackground)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
