//
//  ProfileCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-06-18.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
           super.init(frame: frame)
           setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let categoryLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    
    let valueLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    
    func setUpView() {
        //Category Label
        let categoryWidth = 100
        let categoryHeight = 17
        let categoryX = (Int((self.bounds.size.width)) - categoryWidth)/2
        let categoryY = 10
        categoryLabel.frame = CGRect(x: categoryX, y: categoryY, width: categoryWidth, height: categoryHeight)
        self.addSubview(categoryLabel)
        
        //Value Label
        let valueWidth = 100
        let valueHeight = 14
        let valueX = (Int((self.bounds.size.width)) - categoryWidth)/2
        let valueY = Int(self.bounds.size.height) - 10 - valueHeight
        valueLabel.frame = CGRect(x: valueX, y: valueY, width: valueWidth, height: valueHeight)
        self.addSubview(valueLabel)
        
    }
}
