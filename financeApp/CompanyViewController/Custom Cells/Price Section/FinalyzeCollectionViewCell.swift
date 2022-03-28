//
//  FinalyzeCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-10-12.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class FinalyzeCollectionViewCell: UICollectionViewCell {
    
    let cellWidth = CGFloat(UIScreen.main.bounds.size.width - 40)
    let cellHeight = CGFloat(50)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    let imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "finalyze.png")
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private func setUpViews() {
        let imgWidth = CGFloat(80)
        let imgHeight = CGFloat(20)
        let xPos = ((cellWidth - imgWidth)/2)
        let yPos = ((cellHeight - imgHeight)/2)
            
        imgView.frame = CGRect(x: xPos, y: yPos, width: imgWidth, height: imgHeight)
        self.addSubview(imgView)
        
        self.layer.cornerRadius = 10
        self.layer.backgroundColor = UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00).cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
