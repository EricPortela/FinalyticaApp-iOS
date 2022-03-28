//
//  DashboardCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-03-26.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import Foundation
import UIKit
import Charts

class DashboardCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    let cellWidth = 160
    let cellHeight = 160
    
    let pieChart: PieChartView = {
        var graph = PieChartView()
        graph.legend.enabled = false
        graph.holeColor = UIColor.clear
        graph.holeRadiusPercent = 0.7
        //graph.centerText = "23.4%"
        graph.rotationEnabled = false
        graph.isUserInteractionEnabled = false
        return graph
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        label.text = "CustomCellOne"
        return label
    }()
    
    let shape: CAShapeLayer = {
        let layerShape = CAShapeLayer()
        return layerShape
    }()
    
    func positionLabel(lbl: UILabel) {
        
        let width = cellWidth - 20
        let height = 30
        
        let x = 10
        let y = 5
          
        //Create the frame size for UIImageView + UILabel
        lbl.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    func positionChartView(graphView: PieChartView) {
        
        let graphWidth = cellWidth
        let graphHeight = cellHeight - 20
        
        let x = 0
        let y = 20
          
        //Create the frame size for UIImageView + UILabel
        graphView.frame = CGRect(x: x, y: y, width: graphWidth, height: graphHeight)
        //let imgFrame = CGRect(x: x, y: y, width: imgViewWidth, height: imgViewHeight)
    }
    
    func drawLine(start: CGPoint, end: CGPoint, shape: CAShapeLayer, color: UIColor) {
        //path design
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)

        //design path in layer
        shape.path = path.cgPath
        shape.strokeColor = color.cgColor //UIColor(red: 0.59, green: 0.31, blue: 0.76, alpha: 1.00).cgColor
        shape.lineWidth = 2.0
    }
    
    func setUpViews() {
        layer.cornerRadius = 5
        backgroundColor = UIColor.tertiarySystemBackground
        
        //Label
        addSubview(nameLabel)
        positionLabel(lbl: nameLabel)
        
        //Graph
        addSubview(pieChart)
        positionChartView(graphView: pieChart)
        
        //UIBezierPath
        //layer.addSublayer(shape)
        
        //let start = CGPoint(x:1, y:10)
        //let end = CGPoint(x: 1, y: 140)
        //drawLine(start: start, end: end, shape: shape, color: UIColor(red: 0.59, green: 0.31, blue: 0.76, alpha: 1.00))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


