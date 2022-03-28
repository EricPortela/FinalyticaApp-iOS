//
//  FavoriteStocksTopCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-07-30.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class FavoriteStocksTopCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.text = "Favorite Stocks"
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        lbl.textColor = .white
        return lbl
    }()
    
    let descLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.text = "Here are your top picks! Arrange and sort them how you want."
        lbl.numberOfLines = 0
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.textColor = .gray
        return lbl
    }()

    func setUpView() {
        let lblWidth = Int(UIScreen.main.bounds.size.width - 40)
        let lblHeight = 28
        let lblX = 5
        let lblY = 10
        
        label.frame = CGRect(x: lblX, y: lblY, width: lblWidth, height: lblHeight)
        self.addSubview(label)
        
        let descWidth = Int(UIScreen.main.bounds.size.width - 50)
        let descHeight = 40
        let descX = 5
        let descY = lblHeight + lblY + 5
        descLabel.frame = CGRect(x: descX, y: descY, width: descWidth, height: descHeight)
        self.addSubview(descLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
