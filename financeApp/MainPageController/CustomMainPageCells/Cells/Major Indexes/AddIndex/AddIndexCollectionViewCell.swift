//
//  AddIndexCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-09-10.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class AddIndexCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    var cellHeight = CGFloat(75)
    var cellWidth = CGFloat(UIScreen.main.bounds.size.width - 40)
    
    let mainCard: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        return view
    }()
    
    let indexName: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
        lbl.numberOfLines = 0
        lbl.textColor = .label
        lbl.textAlignment = .center
        lbl.text = "N/A"
        return lbl
    }()
    
    let indexCard: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.backgroundColor = UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00).cgColor
        return view
    }()
    
    let indexsymbol: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 8)
        lbl.textColor = .tertiarySystemBackground
        lbl.textAlignment = .center
        return lbl
    }()
    
    let lowLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        lbl.textColor = .white
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.text = "N/A"
        return lbl
    }()
    
    let highLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        lbl.textColor = .white
        lbl.numberOfLines = 0 
        lbl.textAlignment = .center
        lbl.text = "N/A"
        return lbl
    }()
    
    let changeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.textColor = .white
        lbl.textAlignment = .right
        lbl.numberOfLines = 0
        lbl.text = "N/A"
        return lbl
    }()
    
    let selectionBox: UIImageView = {
       let view = UIImageView()
    return view
    }()
    
    private func leftSetUp() -> Void {
        //Main Index Card
        let cardWidth = CGFloat(75)
        mainCard.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cellHeight)
                
        //Index Name Label
        let nameLabelWidth = CGFloat(cardWidth-10)
        let xPosNameLabel = CGFloat(5)
        let yPosLabel = (cellHeight - (30+15) - 5)/2
        indexName.frame = CGRect(x: xPosNameLabel, y: yPosLabel, width: nameLabelWidth, height: 30)
        mainCard.addSubview(indexName)
        
        //Index Symbol
        let symbolHeight = CGFloat(15)
        let yPosIndexCard = cellHeight-yPosLabel-symbolHeight
        let indexCardWidth = CGFloat(cardWidth - 10)
        indexCard.frame = CGRect(x: 5 , y: yPosIndexCard, width: indexCardWidth, height: symbolHeight)
        
        let symbolLabelWidth = indexCardWidth - 10
        indexsymbol.frame = CGRect(x: 5, y: 0, width: symbolLabelWidth, height: symbolHeight)
        indexCard.addSubview(indexsymbol)
        
        mainCard.addSubview(indexCard)
        mainCard.addRightBorderWithColor(color: UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00), width: 1)
        self.addSubview(mainCard)
    }
    
    private func centerSetUp() -> Void {
        let centerSectionWidth = CGFloat(cellWidth - 75 - 30 - 20)
        
        let lowHighLabelWidth = CGFloat(50)
        let lowHighLabelHeight = CGFloat(40)
        let yPosLowHighLabel = (cellHeight - lowHighLabelHeight)/2
        let xPosLowLabel = CGFloat(75 + 10)
        
        lowLabel.frame = CGRect(x: xPosLowLabel, y: yPosLowHighLabel, width: lowHighLabelWidth, height: lowHighLabelHeight)
        self.addSubview(lowLabel)
        
        let xPosHighLabel = CGFloat(xPosLowLabel + lowHighLabelWidth + 10)
        highLabel.frame = CGRect(x: xPosHighLabel, y: yPosLowHighLabel, width: lowHighLabelWidth, height: lowHighLabelHeight)
        self.addSubview(highLabel)
        
        let changeLabelWidth = CGFloat(centerSectionWidth - (2*lowHighLabelWidth) - (3*10))
        let changeLabelHeight = CGFloat(40)
        let xPosChangeLabel = CGFloat(xPosHighLabel + lowHighLabelWidth + 10)
        let yPosChangeLabel = CGFloat((cellHeight-changeLabelHeight)/2)
        changeLabel.frame = CGRect(x: xPosChangeLabel, y: yPosChangeLabel, width: changeLabelWidth, height: changeLabelHeight)
        self.addSubview(changeLabel)
    }
    
    
    private func setUpView() -> Void {
        leftSetUp()
        centerSetUp()
        
        self.layer.cornerRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false
        self.layer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
    }
    
    
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
