//
//  VolumeBarChartCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-06-01.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class VolumeBarChartCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
       }
    
    let cellWidth = UIScreen.main.bounds.size.width - 40
    let cellHeight = 200
    
    let barChart: BarChartView = {
        let chart = BarChartView()
        chart.leftAxis.enabled = false
        chart.xAxis.enabled = false
        chart.xAxis.axisMinimum = 0
        chart.xAxis.axisMaximum = 7
        chart.rightAxis.labelTextColor = .white
        chart.rightAxis.valueFormatter = YAxisValueFormatter()
        chart.legend.textColor = .white
        chart.noDataTextColor = .lightGray
        chart.noDataText = "No data available"
        return chart
    }()
    
    func setUpView() {
        //Bar Chart
        let barChartWidth = Int(cellWidth - 40)
        let barChartHeight = cellHeight - 20
        barChart.frame = CGRect(x: 20, y: 10, width: barChartWidth, height: barChartHeight)
        self.addSubview(barChart)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
