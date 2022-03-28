//
//  HistoryGrowthCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-10-02.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class HistoryGrowthCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    let cellWidth = UIScreen.main.bounds.size.width - 40
    let cellHeight = 25
    
    let periodLbl: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.textColor = .white
        lbl.text = "Period"
        return lbl
    }()
    
    let valueLbl: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.textColor = .white
        lbl.text = "Value"
        return lbl
    }()
    
    let changeLbl: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .right
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.textColor = .white
        lbl.text = "Change"
        return lbl
    }()
    
    let indicationArrowView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
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
        shape.lineWidth = 2.0
        
        view.layer.addSublayer(shape)
    }
    
    func setUpView() {
        
        let start = CGPoint(x: 40, y: 0)
        let end = CGPoint(x: 40, y: 25)
        
        drawLine(start: start, end: end, view: self)
        
        let availableSpace = cellWidth - 60 - 30 - 10
        let widthLbl = Int(availableSpace/3)
        let heightLbl = 25
        let lblY = (cellHeight-heightLbl)/2
                
        periodLbl.frame = CGRect(x: 60, y: lblY, width: widthLbl, height: heightLbl)
        valueLbl.frame = CGRect(x: (widthLbl+60), y: lblY, width: widthLbl, height: heightLbl)
        changeLbl.frame = CGRect(x: (widthLbl*2)+60, y: lblY, width: widthLbl, height: heightLbl)
        indicationArrowView.frame = CGRect(x: (widthLbl*3)+60+10, y: lblY, width: 10, height: heightLbl)

        self.addSubview(periodLbl)
        self.addSubview(valueLbl)
        self.addSubview(changeLbl)
        self.addSubview(indicationArrowView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
