//
//  FinancialItemCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-07-17.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class FinancialItemCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    var itemName: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.textColor = .white
        lbl.textAlignment = .left
        lbl.text = "Item NAME"
        return lbl
    }()
    
    var itemValue: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.textColor = .white
        lbl.textAlignment = .right
        lbl.text = "Item VALUE"
        return lbl
    }()
    
    func setUpView() {
        
        //Item Name
        let nameWidth = Int(UIScreen.main.bounds.size.width - 40 - 40)/2
        let nameHeight = 15
        let xPosName = 20
        let yPosName = 0
        itemName.frame = CGRect(x: xPosName, y: yPosName, width: nameWidth, height: nameHeight)
        self.addSubview(itemName)
        
        //Item Value
        let valueWidth = nameWidth
        let valueHeight = 15
        let xPosValue = nameWidth + 20
        let yPosValue = 0
        itemValue.frame = CGRect(x: xPosValue, y: yPosValue, width: valueWidth, height: valueHeight)
        self.addSubview(itemValue)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
