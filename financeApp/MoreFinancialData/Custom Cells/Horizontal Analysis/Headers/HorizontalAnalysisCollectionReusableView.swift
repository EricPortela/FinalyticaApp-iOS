//
//  HorizontalAnalysisCollectionReusableView.swift
//  financeApp
//
//  Created by Eric Portela on 2021-10-03.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class HorizontalAnalysisCollectionReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    let closedCellHeight = 100
    let cellWidth = UIScreen.main.bounds.size.width - 40
    
    let mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00)
        return view
    }()
    
    let pieChart: PieChartView = {
        let chart = PieChartView()
        chart.minOffset = 0
        chart.holeRadiusPercent = 0.9
        chart.holeColor = .clear
        chart.legend.enabled = false
        return chart
    }()
    
    let implicationLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.textColor = .white
        lbl.numberOfLines = 0
        lbl.font = UIFont(name: "HelveticaNeue", size: 14)
        lbl.text = "Short text implication of the average value of the analysed data."
        return lbl
    }()
    
    let expandMinimizeButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .gray
        return btn
    }()
    
    let indicationArrowView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    func setUpView() {
        self.layer.backgroundColor = UIColor.clear.cgColor
        
        //Main View
        let width = UIScreen.main.bounds.size.width - 40
        mainView.frame = CGRect(x: 20, y: 0, width: width, height: 100)
        self.addSubview(mainView)
        
        //Pie Chart
        let yPositionChart = CGFloat(closedCellHeight - 60)/2
        createFrameLeft(view: pieChart, width: 60, height: 60, x: 10, y: yPositionChart)
        
        //Button
        let yPositionArrow = CGFloat(closedCellHeight - 15)/2
        createFrameRight(view: indicationArrowView, width: 15, height: 15, xFromRight: 10, y: yPositionArrow)
        
        //Implication label
        let lblWidth = cellWidth - 10 - 60 - 10 - 15 - 20
        let xPositionLbl = CGFloat(10 + 60 + 10)
        let yPositionLbl = CGFloat(closedCellHeight - 80)/2
        createFrameLeft(view: implicationLabel, width: lblWidth, height: 80, x: xPositionLbl, y: yPositionLbl)
        
    }
    
    func createFrameLeft(view: UIView, width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat) {
        view.frame = CGRect(x: x, y: y, width: width, height: height)
        mainView.addSubview(view)
    }
    
    func createFrameRight(view: UIView, width: CGFloat, height: CGFloat, xFromRight: CGFloat, y: CGFloat) {
        let x = CGFloat(cellWidth - xFromRight - width)
        view.frame = CGRect(x: x, y: y, width: width, height: height)
        mainView.addSubview(view)
    }
    
    func negativePositiveColor(value: Double) -> Array<UIColor> {
        var color: [UIColor] = [] //If value == 0
        
        if value > 0 {
            let colorOne = UIColor(red: 0.01, green: 0.81, blue: 0.64, alpha: 1.00) //Green
            let colorTwo = UIColor.gray
            color.append(colorOne)
            color.append(colorTwo)
        }
            
        else if value >= 1 {
            let colorOne = UIColor(red: 0.01, green: 0.81, blue: 0.64, alpha: 1.00) //Green
            color.append(colorOne)
        }
        
        else if value < 0 {
            let colorOne = UIColor(red: 0.89, green: 0.00, blue: 0.40, alpha: 1.00) //Red
            color.append(colorOne)
        }
        return color
    }
    
    func preparePieChart(avgValue: Double) {
        let dataColor = negativePositiveColor(value: avgValue)
        var entries = [ChartDataEntry]()
        
        if avgValue < 0 {
            //entries.append(ChartDataEntry(x: 0, y: avgValue))
            entries.append(ChartDataEntry(x: 0, y: 1))
        }
        else if avgValue > 1{
            entries.append(ChartDataEntry(x: 0, y: 1))
        }
        else {
            entries.append(ChartDataEntry(x: 0, y: avgValue))
            entries.append(ChartDataEntry(x: 0, y: 1-avgValue))
        }
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.drawValuesEnabled = false
        dataSet.colors = dataColor //Color for dataset
        dataSet.selectionShift = 0 //Removes the offsets and makes chart "big"/use all space to the edges
        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
        pieChart.notifyDataSetChanged()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
