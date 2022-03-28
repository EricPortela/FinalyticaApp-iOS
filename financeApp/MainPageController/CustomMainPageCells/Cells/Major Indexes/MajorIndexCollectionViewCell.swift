//
//  MajorIndexCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-05-23.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class MajorIndexCollectionViewCell: UICollectionViewCell {
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    var cellHeight = CGFloat(60)
    var cellWidth = CGFloat(160)
    var halfSubviewWidth = CGFloat((160-25)/2)
    
    let indexName: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        lbl.textColor = .label
        lbl.textAlignment = .left
        lbl.text = "N/A"
        return lbl
    }()
    
    let indexValue: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        lbl.textColor = .gray
        lbl.textAlignment = .left
        lbl.text = "N/A"
        return lbl
    }()
    
    let valuePercentageChange: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        lbl.textAlignment = .left
        lbl.text = "N/A"
        return lbl
    }()
    
    let miniCard: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        return view
    }()
    
    let miniGraph: LineChartView = {
        let chart = LineChartView()
        chart.xAxis.enabled = false
        chart.leftAxis.enabled = false
        chart.rightAxis.enabled = false
        chart.clipsToBounds = true
        chart.layer.cornerRadius = 10
        chart.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        chart.isUserInteractionEnabled = false
        chart.legend.enabled = false
        chart.minOffset = 0 //Removes the outer borders of the ChartView
        return chart
    }()
    
    func setUpView() {
        let labelHeight = CGFloat(12)
        let labelWidth = CGFloat(60)
        
        let totalLabelHeight = 12*3
        let totalLabelSpacing = 5*2
        let totalSpace = totalLabelHeight + totalLabelSpacing
        
        let yPositionLabel = CGFloat(Int(cellHeight) - totalSpace)/2
        
        //Index Name Label
        indexName.frame = CGRect(x: 10, y: yPositionLabel, width: halfSubviewWidth, height: labelHeight)
        self.addSubview(indexName)
        
        //Index Value Label
        let y1 = yPositionLabel+labelHeight+5
        indexValue.frame = CGRect(x: 10, y: y1, width: halfSubviewWidth, height: labelHeight)
        self.addSubview(indexValue)
        
        //Index Value Change
        let y2 = yPositionLabel+(labelHeight*2)+10
        valuePercentageChange.frame = CGRect(x: 10, y: y2, width: halfSubviewWidth, height: labelHeight)
        self.addSubview(valuePercentageChange)
        
        //Graph Placement
        let graphHeight = CGFloat(40)
        miniGraph.frame = CGRect(x: labelWidth + 20, y: 10, width: halfSubviewWidth, height: graphHeight)
        self.addSubview(miniGraph)
        
        
        self.layer.cornerRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false
        self.layer.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00).cgColor //UIColor.tertiarySystemBackground.cgColor
        
        /*
        //Index Value Change/Card
        let cardWidth = CGFloat(55)
        let cardHeight = CGFloat(40)
        miniCard.frame = CGRect(x: cellWidth-cardWidth-15, y: 10, width: cardWidth, height: cardHeight)
        miniCard.backgroundColor = .red
        
        
        //Change label
        let changeLabelHeight = CGFloat(15)
        valueChange.frame = CGRect(x: 5, y: 5, width: cardWidth - 10, height: changeLabelHeight)
        miniCard.addSubview(valueChange)
        
        //Percentage change label
        valuePercentageChange.frame = CGRect(x: 5, y: cardHeight - 20, width: cardWidth - 10, height: changeLabelHeight)
        miniCard.addSubview(valuePercentageChange)
        
        self.addSubview(miniCard)
        
        //Graph Placement
        let graphWidth = cellWidth
        let graphHeight = CGFloat(50)
        miniGraph.frame = CGRect(x: 0, y: cardHeight + 20, width: graphWidth, height: graphHeight)
        self.addSubview(miniGraph)
        */
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

