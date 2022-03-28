//
//  FavoriteStocksGraphCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-05-24.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class FavoriteStocksGraphCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    //Cell dimensions
    var cellHeight = CGFloat(300)
    var cellWidth = CGFloat(UIScreen.main.bounds.size.width-40)
    
    let segmentedControl: UISegmentedControl = {
        let items = ["1D", "1W", "1M", "3M", "YTD", "1Y", "3Y", "5Y"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 5
        return control
    }()
    
    let lineChart: LineChartView = {
        let chart = LineChartView()
        chart.leftAxis.enabled = false
        chart.xAxis.enabled = false
        chart.rightAxis.drawGridLinesEnabled = false
        chart.rightAxis.labelTextColor = .white
        chart.legend.textColor = .white
        chart.noDataTextColor = .lightGray
        chart.noDataText = "No data available"
        chart.minOffset = 0 //removes outer border of chartview
        chart.rightAxis.labelPosition = .insideChart
        return chart
    }()
    
    let moreButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("More info", for: .normal)
        btn.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        btn.setTitleColor(.lightGray, for: .normal)
        return btn
    }()
    
    func setUpView() {
        //SegmentedControl
        let segmentedControlWidth = Int(cellWidth - 20)
        let segmentedControlHeight = 32
        segmentedControl.frame = CGRect(x: 10, y: 15, width: segmentedControlWidth, height: segmentedControlHeight)
        self.addSubview(segmentedControl)
        
        //Combined Chart
        let chartWidth = CGFloat(UIScreen.main.bounds.size.width - 40)
        let chartHeight = CGFloat(cellHeight - CGFloat(segmentedControlHeight + 65))
        lineChart.frame = CGRect(x: 0, y: CGFloat(segmentedControlHeight + 25), width: chartWidth, height: chartHeight)
        self.addSubview(lineChart)
        
        //More Button
        let btnWidth = CGFloat(120)
        let btnHeight = CGFloat(15)
        moreButton.frame = CGRect(x: ((cellWidth-btnWidth)/2), y: ((cellHeight-25)), width: btnWidth, height: btnHeight)
        self.addSubview(moreButton)
        
        self.layer.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00).cgColor //UIColor.tertiarySystemBackground.cgColor
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
