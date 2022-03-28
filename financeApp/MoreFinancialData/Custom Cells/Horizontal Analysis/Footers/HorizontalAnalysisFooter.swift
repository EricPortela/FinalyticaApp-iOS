//
//  HorizontalAnalysisFooter.swift
//  financeApp
//
//  Created by Eric Portela on 2021-10-31.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class HorizontalAnalysisFooter: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    let cellWidth = UIScreen.main.bounds.size.width - 40
    let cellHeight = 25
    
    let cardView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 15
        view.layer.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00).cgColor
        return view
    }()
    
    private func setUpView() -> Void {
        let cardWidth = UIScreen.main.bounds.size.width - 40
        let cardHeight = CGFloat(20)
        
        cardView.frame = CGRect(x: 20, y: 0, width: cardWidth, height: cardHeight)
        self.addSubview(cardView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
