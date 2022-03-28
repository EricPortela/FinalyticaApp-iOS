//
//  StockScreenerCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-04-24.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class StockScreenerCollectionViewCell: UICollectionViewCell {
    var cellWidth = Int(UIScreen.main.bounds.size.width - 40)/5
    let cellHeight = 40
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 11)
        label.textAlignment = .center
        label.text = "n/A"
        return label
    }()
    
    func positionLabel(label: UILabel) {
        label.frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
        self.addSubview(label)
    }
    
    func setUpViews() {
        positionLabel(label: label)
    }
}
