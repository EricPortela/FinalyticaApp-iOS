//
//  AboutCompanyTextCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-06-19.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class AboutCompanyTextCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var test: UILabel!
    @IBOutlet weak var testBtn: UIButton!
    
    
    
    /*
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        //addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let aboutLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.sizeToFit()
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let moreButton: UIButton = {
        let btn = UIButton()
        let textColor = UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00)
        btn.setTitle("Read more", for: .normal)
        btn.setTitle("Read more", for: .selected)
        btn.setTitleColor(textColor, for: .normal)
        btn.setTitleColor(textColor, for: .selected)
        btn.contentHorizontalAlignment = .left
        btn.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        return btn
    }()
    
    func setUpView() {
        
        //About Label
        let lblYPosition = 0
        let lblXPosition = 0
        let lblHeight = 0
        let lblWidth = Int(UIScreen.main.bounds.size.width - 40)
        
        //aboutLabel.frame = CGRect(x: lblXPosition, y: lblYPosition, width: lblWidth, height: lblHeight)
        //self.addSubview(aboutLabel)
        
        
        //More Button
        let yBtnPosition = Int(self.bounds.size.height - 20)
        let xBtnPosition = 0
        let heightBtn = 15
        let widthBtn = 100
        
        moreButton.frame = CGRect(x: xBtnPosition, y: yBtnPosition, width: widthBtn, height: heightBtn)
        self.addSubview(moreButton)
    }
    
    private func addConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        //Add
        constraints.append(aboutLabel.leadingAnchor.constraint(equalTo: self.contentView.trailingAnchor))
        constraints.append(aboutLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor))
        aboutLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 30).isActive = true
        constraints.append(aboutLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor))
        constraints.append(aboutLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor))
        
        //Activate (Applying constraints to the view)
        NSLayoutConstraint.activate(constraints)
    }
    */
}
