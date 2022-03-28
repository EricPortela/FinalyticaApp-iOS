//
//  MajorIndexCollectionReusableView.swift
//  financeApp
//
//  Created by Eric Portela on 2021-08-14.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class MajorIndexCollectionReusableView: UICollectionReusableView {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    let cellSide = CGFloat(70)
    
    let addButton: UIButton = {
        let btn = UIButton()
        return btn
    }()
    
    let addLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "+"
        lbl.textAlignment = .center
        lbl.font = UIFont(name: "HelveticaNeue", size: 24)
        lbl.textColor = .white
        return lbl
    }()
    
    func setUpView() {
        let positionY = (cellSide - 24)/2
        self.layer.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00).cgColor //UIColor.tertiarySystemBackground.cgColor
        self.layer.cornerRadius = 10
        addLabel.frame = CGRect(x: 0, y: positionY, width: cellSide, height: 24)
        addButton.frame = CGRect(x: 0, y: 0, width: cellSide, height: cellSide)
    }
    
    override func layoutSubviews() {
        addButton.addSubview(addLabel)
        self.addSubview(addButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
