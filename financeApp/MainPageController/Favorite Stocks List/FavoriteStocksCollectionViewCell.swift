//
//  FavoriteStocksCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-07-30.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class FavoriteStocksCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    let cellWidth = Int(UIScreen.main.bounds.size.width - 40)
    let cellHeight = 50
    
    let ticker: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        lbl.text = "--"
        lbl.textColor = .white//UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00)
        return lbl
    }()
    
    let closingPrice: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.text = "--"
        lbl.textColor = .white
        return lbl
    }()
    
    let eps: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.text = "--"
        lbl.textColor = .white
        return lbl
    }()
    
    let pe: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.text = "--"
        lbl.textColor = .white
        return lbl
    }()
    
    let marketCap: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.text = "--"
        lbl.textColor = .white
        return lbl
    }()
    
    func setUpView() {
        //ticker
        //ticker.frame = CGRect(x: 5, y: yPos, width: labelWidth, height: labelHeight)
        contentView.addSubview(ticker)
        
        //price
        //let xPrice = 5 + spacing + labelWidth
        //closingPrice.frame = CGRect(x: xPrice, y: yPos, width: labelWidth, height: labelHeight)
        contentView.addSubview(closingPrice)

        //eps
        //let xEPS = 5 + spacing*2 + labelWidth*2
        //eps.frame = CGRect(x: xEPS, y: yPos, width: labelWidth, height: labelHeight)
        contentView.addSubview(eps)

        //pe
        //let xPE = 5 + spacing*3 + labelWidth*3
        //pe.frame = CGRect(x: xPE, y: yPos, width: labelWidth, height: labelHeight)
        contentView.addSubview(pe)

        //market cap
        //let xMarketCap = 5 + spacing*4 + labelWidth*4
        //marketCap.frame = CGRect(x: xMarketCap, y: yPos, width: labelWidth, height: labelHeight)
        contentView.addSubview(marketCap)
        
        let yPositionHorizontalDivider = cellHeight - 1
        let start = CGPoint(x: 0, y: yPositionHorizontalDivider)
        let end = CGPoint(x: cellWidth, y: yPositionHorizontalDivider)
        drawLine(start: start, end: end, lineWidth: 1, lineColor: .tertiarySystemBackground)
    }
    
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
    
    override func layoutSubviews() {
        let numberOfLabels = 5
        let spacing = 5
        let spacingAmount = 4
        let labelWidth = (cellWidth - (spacing*spacingAmount))/numberOfLabels
        let labelHeight = 15
        let yPos = (cellHeight-labelHeight)/2
        
        //ticker
        ticker.frame = CGRect(x: 5, y: yPos, width: labelWidth, height: labelHeight)

        //price
        let xPrice = 5 + spacing + labelWidth
        closingPrice.frame = CGRect(x: xPrice, y: yPos, width: labelWidth, height: labelHeight)

        //eps
        let xEPS = 5 + spacing*2 + labelWidth*2
        eps.frame = CGRect(x: xEPS, y: yPos, width: labelWidth, height: labelHeight)

        //pe
        let xPE = 5 + spacing*3 + labelWidth*3
        pe.frame = CGRect(x: xPE, y: yPos, width: labelWidth, height: labelHeight)

        //market cap
        let xMarketCap = 5 + spacing*4 + labelWidth*4
        marketCap.frame = CGRect(x: xMarketCap, y: yPos, width: labelWidth, height: labelHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
