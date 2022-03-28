//
//  OverviewCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-03-14.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class OverviewCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    let labelWidth = Int(UIScreen.main.bounds.size.width - 90)
    let cellHeight = 70
    let cellWidth = Int(UIScreen.main.bounds.size.width) - (20*2)
    
    let circleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 40/2
        view.clipsToBounds = true
        view.layer.backgroundColor = UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 0.3).cgColor
        return view
    }()
    
    let imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        label.numberOfLines = 0
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 11)
        return label
    }()
    
    func setUpViews() {
        
        let titleHeight = 20
        let titleLabelYPosition = (cellHeight/2) - titleHeight
        
        titleLabel.frame = CGRect(x: 60 , y: titleLabelYPosition, width: labelWidth, height: titleHeight)
        addSubview(titleLabel)
        
        let subTitleLabelYPosition = (titleLabelYPosition + titleHeight + 2)
        subTitleLabel.frame = CGRect(x: 60 , y: subTitleLabelYPosition, width: labelWidth, height: 14)
        addSubview(subTitleLabel)
        
        let imgHeight = 40
        let circleYPosition = ((cellHeight - imgHeight)/2)
        circleView.frame = CGRect(x: 10, y: circleYPosition, width: 40, height: 40)
        addSubview(circleView)
        
        imgView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        circleView.addSubview(imgView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
