//
//  IndexGraphCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-05-31.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class IndexGraphCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
           super.init(frame: frame)
           setUpView()
    }
    
    //Cell dimensions
    var cellHeight = CGFloat(460)
    var cellWidth = CGFloat(UIScreen.main.bounds.size.width - 40)
    
    let mainCard: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = 15
        return view
    }()

    let tickerLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Medium", size: 24)
        lbl.text = "--"
        lbl.textColor = .white
        return lbl
    }()
    
    let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue", size: 16)
        lbl.text = "--"
        lbl.textColor = .lightGray
        return lbl
    }()
    
    let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue", size: 24)
        lbl.text = "--"
        lbl.textColor = .white
        return lbl
    }()

    let segmentedControl: UISegmentedControl = {
        let items = ["1D", "1W", "1M", "3M", "YTD", "1Y", "3Y", "5Y"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        return control
    }()

    let lineChart: LineChartView = {
        let chart = LineChartView()
        chart.leftAxis.enabled = false
        chart.xAxis.enabled = false
        chart.rightAxis.labelTextColor = .white
        chart.legend.textColor = .white
        chart.noDataTextColor = .lightGray
        chart.noDataText = "No data available"
        return chart
    }()
    
    func drawLine(start: CGPoint, end: CGPoint, lineWidth: CGFloat, lineColor: UIColor) {
        //path design
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = lineColor.cgColor
        shape.lineWidth = lineWidth
        
        self.layer.addSublayer(shape)
    }

    func setUpView() {
        
        //Ticker Label
        let tickerHeight = 25
        let tickerWidth = 100
        let yPositionTicker = 15
        tickerLabel.frame = CGRect(x: 0, y: yPositionTicker, width: tickerWidth, height: tickerHeight)
        self.addSubview(tickerLabel)
        
        //Name Label
        let nameHeight = 18
        let nameWidth = 350
        let yPositionName = tickerHeight + yPositionTicker + 5
        nameLabel.frame = CGRect(x: 0, y: yPositionName, width: nameWidth, height: nameHeight)
        self.addSubview(nameLabel)
        
        //Horizontal Divider
        let yPositionDivider = yPositionName + nameHeight + 5
        let start = CGPoint(x: 0, y: yPositionDivider)
        let end = CGPoint(x: Int(cellWidth), y: yPositionDivider)
        drawLine(start: start, end: end, lineWidth: 1, lineColor: .white)
        
        //Price Label
        let priceWidth = CGFloat(200)
        let priceHeight = CGFloat(20)
        let yPositionPrice = CGFloat(yPositionDivider + 21)
        priceLabel.frame = CGRect(x: 0, y: yPositionPrice, width: priceWidth, height: priceHeight)
        self.addSubview(priceLabel)
        
        //Main Card
        let cardWidth = cellWidth
        let cardHeight = cellHeight - 150
        let yPositionCard = yPositionPrice + priceHeight + 20
        mainCard.frame = CGRect(x: 0, y: yPositionCard, width: cardWidth, height: cardHeight)
        self.addSubview(mainCard)
        
        //SegmentedControl
        let segmentedControlWidth = Int(cellWidth - 30)
        let segmentedControlHeight = 32
        let yPositionSegControl =  Int(yPositionCard + 15)
        segmentedControl.frame = CGRect(x: 15, y: yPositionSegControl, width: segmentedControlWidth, height: segmentedControlHeight)
        self.addSubview(segmentedControl)
       
        //Line Chart
        let chartWidth = CGFloat(cellWidth-10)
        let chartHeight = CGFloat(Int(cardHeight) - (segmentedControlHeight + 15 + 5 + 15))
        let yPositionChart = (yPositionSegControl + segmentedControlHeight + 15)
        lineChart.frame = CGRect(x: 5, y: CGFloat(yPositionChart), width: chartWidth, height: chartHeight)
        self.addSubview(lineChart)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
