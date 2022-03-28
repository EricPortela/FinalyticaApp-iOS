//
//  NewsCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-08-14.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class NewsCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    let cellHeight = CGFloat(85)
    let cellWidth = CGFloat(UIScreen.main.bounds.size.width - 40)
    
    let newsImg: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()

    let title: UILabel = {
        let lbl = UILabel()
        lbl.text = "--"
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        lbl.textColor = .white
        return lbl
    }()
    
    let publishedDate: UILabel = {
        let lbl = UILabel()
        lbl.text = "--"
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "HelveticaNeue", size: 10)
        lbl.textColor = .gray
        return lbl
    }()
    
    let symbol: UILabel = {
        let lbl = UILabel()
        lbl.text = "--"
        lbl.textAlignment = .center
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        lbl.textColor = .white
        return lbl
    }()
    
    let miniCard: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor.gray.cgColor
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 5
        return view
    }()
    
    func addImage(url: String) {
        newsImg.layer.cornerRadius = 10
        newsImg.load(urlString: url)
    }
     
    func setUpView() {
        
        newsImg.frame = CGRect(x: 0, y: 0, width: cellHeight, height: cellHeight)
        
        let cardWidth = CGFloat(60)
        let cardHeight = CGFloat(20)
        let cardX = cellWidth - cardWidth - 15
        let cardY = cellHeight - cardHeight - 10
        miniCard.frame = CGRect(x: cardX, y: cardY, width: cardWidth, height: cardHeight)
        
        let symbolWidth = CGFloat(50)
        let symbolHeight = CGFloat(15)
        let symbolX = (cardWidth - symbolWidth)/2
        let symbolY = (cardHeight - symbolHeight)/2
        symbol.frame = CGRect(x: symbolX, y: symbolY, width: symbolWidth, height: symbolHeight)
        
        let titleWidth = CGFloat(cellWidth - cellHeight - 10 - 15)
        let titleHeight = CGFloat(35)
        let titleX = CGFloat(cellHeight + 10)
        let titleY = CGFloat(10)
        title.frame = CGRect(x: titleX, y: titleY, width: titleWidth, height: titleHeight)
        
        let dateWidth = CGFloat(130)
        let dateHeight = CGFloat(15)
        let dateX = CGFloat(titleX)
        let dateY = cardY + 5
        publishedDate.frame = CGRect(x: dateX, y: dateY, width: dateWidth, height: dateHeight)
        
    }
     
    override func layoutSubviews() {
        self.addSubview(newsImg)
        
        miniCard.addSubview(symbol)
        self.addSubview(miniCard)
        
        self.addSubview(title)
        
        self.addSubview(publishedDate)
        
        self.layer.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00).cgColor //UIColor.tertiarySystemBackground.cgColor
        
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
