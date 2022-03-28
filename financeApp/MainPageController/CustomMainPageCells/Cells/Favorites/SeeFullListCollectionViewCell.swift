//
//  SeeFullListCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-07-30.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class SeeFullListCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    private let cellHeight = 40
    private let cellWidth = UIScreen.main.bounds.size.width - 40
    
    let seeMoreLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "View Full List"
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        lbl.textAlignment = .center
        lbl.textColor = .white//UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00)
        return lbl
    }()
    
    func setUpView() {
        let height = 14
        let width = Int(UIScreen.main.bounds.size.width - 40 - 20)
        let xPos = 10
        let yPos = (cellHeight - height)/2
        
        //self.layer.borderWidth = 2
        //self.layer.borderColor = UIColor(red: 0.31, green: 0.25, blue: 0.60, alpha: 1.00).cgColor
        self.layer.cornerRadius = 10
        /*
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false
        */
        
        seeMoreLbl.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        self.addSubview(seeMoreLbl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
