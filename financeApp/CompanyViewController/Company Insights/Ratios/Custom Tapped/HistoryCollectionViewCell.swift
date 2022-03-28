//
//  HistoryCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-04-01.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import Foundation
import UIKit


class HistoryCollectionViewCell: UICollectionViewCell {
    
    var cellWidth = Int(UIScreen.main.bounds.size.width - 40)/4
    let cellHeight = 30
    
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
