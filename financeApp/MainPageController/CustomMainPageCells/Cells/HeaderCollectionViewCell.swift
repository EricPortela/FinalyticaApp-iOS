//
//  HeaderCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-08-11.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class HeaderCollectionViewCell: UICollectionViewCell {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    let welcomeTitle: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue-Medium", size: 24)
        return lbl
    }()
    
    let welcomeText: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue", size: 14)
        return lbl
    }()
    
    func setUpView() {
        contentView.backgroundColor = UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00)//UIColor(red: 0.31, green: 0.25, blue: 0.60, alpha: 1.00)
        contentView.addSubview(welcomeTitle)
        contentView.addSubview(welcomeText)
    }
    
    override func layoutSubviews() {
        let lblWidth = UIScreen.main.bounds.size.width - 40
        welcomeTitle.frame = CGRect(x: 20, y: 20, width: lblWidth, height: 30)
        welcomeText.frame = CGRect(x: 20, y: 50, width: lblWidth, height: 15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

