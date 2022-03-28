//
//  SearchCompanyCollectionReusableView.swift
//  financeApp
//
//  Created by Eric Portela on 2021-08-10.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class SearchCompanyCollectionReusableView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    let searchButton: UIButton = {
        let btn = UIButton()
        return btn
    }()
    
    let searchIcon: UIImageView = {
        let img = UIImage(named: "searchbar.png")
        let view = UIImageView(image: img)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    func setUpView() {
        addSubview(searchButton)
        self.layer.backgroundColor = UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00).cgColor //UIColor(red: 0.31, green: 0.25, blue: 0.60, alpha: 1.00).cgColor
    }
    
    override func layoutSubviews() {
        
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        let yPos = (self.bounds.size.height - 36)/2
        searchIcon.frame = CGRect(x: 0, y: yPos, width: 343, height: 36)
        searchButton.addSubview(searchIcon)
        
        let xPos = (UIScreen.main.bounds.size.width-343)/2
        searchButton.frame = CGRect(x: xPos, y: 0, width: 343, height: 36)
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
