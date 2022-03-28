//
//  FavoriteStocksCollectionReusableView.swift
//  financeApp
//
//  Created by Eric Portela on 2021-07-30.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class FavoriteStocksCollectionReusableView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    let cellWidth = Int(UIScreen.main.bounds.size.width - 40)
    let cellHeight = 80
    
    let filterButton: UIButton = {
        let btn = UIButton()
        return btn
    }()
    
    let filterLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Alphabetical"
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        return lbl
    }()
    
    let filterIcon: UIImageView = {
        let img = UIImage(named: "sortIcon.png")
        let view = UIImageView(image: img)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let ticker: UILabel = {
        let lbl = UILabel()
        lbl.text = "Ticker"
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        lbl.textColor = .white
        return lbl
    }()
    
    let closingPrice: UILabel = {
        let lbl = UILabel()
        lbl.text = "Close"
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        lbl.textColor = .white
        return lbl
    }()
    
    let eps: UILabel = {
        let lbl = UILabel()
        lbl.text = "EPS"
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        lbl.textColor = .white
        return lbl
    }()
    
    let pe: UILabel = {
        let lbl = UILabel()
        lbl.text = "PE"
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        lbl.textColor = .white
        return lbl
    }()
    
    let marketCap: UILabel = {
        let lbl = UILabel()
        lbl.text = "MCap"
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        lbl.textColor = .white
        return lbl
    }()

    func drawLine(start: CGPoint, end: CGPoint, view: UIView) {
        //path design
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = UIColor.white.cgColor
        shape.lineWidth = 1.0
        
        view.layer.addSublayer(shape)
    }
    
    func setUpView() {
        //Filter button
        filterButton.frame = CGRect(x: 25, y: 10, width: 100, height: 20)
        
        //Icon
        filterIcon.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        filterButton.addSubview(filterIcon)
        
        //Label
        filterLabel.frame = CGRect(x: 30, y: 0, width: 100, height: 20)
        filterButton.addSubview(filterLabel)
        self.addSubview(filterButton)
        
        //Horizontal divider
        let start = CGPoint(x: 25, y: cellHeight/2)
        let end = CGPoint(x: cellWidth+20, y: cellHeight/2)
        drawLine(start: start, end: end, view: self)
        
        self.layer.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.00).cgColor
        
        let numberOfLabels = 5
        let spacing = 5
        let spacingAmount = 4
        let labelWidth = (cellWidth - (spacing*spacingAmount))/numberOfLabels
        let labelHeight = 15
        let yPos = 60
                
        //ticker
        ticker.frame = CGRect(x: 25, y: yPos, width: labelWidth, height: labelHeight)
        self.addSubview(ticker)
        
        //price
        let xPrice = 25 + spacing + labelWidth
        closingPrice.frame = CGRect(x: xPrice, y: yPos, width: labelWidth, height: labelHeight)
        self.addSubview(closingPrice)

        //eps
        let xEPS = 25 + spacing*2 + labelWidth*2
        eps.frame = CGRect(x: xEPS, y: yPos, width: labelWidth, height: labelHeight)
        self.addSubview(eps)

        //pe
        let xPE = 25 + spacing*3 + labelWidth*3
        pe.frame = CGRect(x: xPE, y: yPos, width: labelWidth, height: labelHeight)
        self.addSubview(pe)

        //market cap
        let xMarketCap = 25 + spacing*4 + labelWidth*4
        marketCap.frame = CGRect(x: xMarketCap, y: yPos, width: labelWidth, height: labelHeight)
        self.addSubview(marketCap)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
