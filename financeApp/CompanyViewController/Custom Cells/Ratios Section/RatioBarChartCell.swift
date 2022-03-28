//
//  RatioBarChartCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-10-28.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class RatioBarChartCell: UICollectionViewCell, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if value >= 0 && Int(value) < quarters.count {
            if let quarter = quarters[Int(value)] {
                return quarter
            }
            
        }
        return ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    public var quarters: [String?] = [] //["s", "d", "s", "d","s", "d","s", "d"]
    
    private let imgViewHeight : CGFloat = 26
    private let imgViewWidth : CGFloat = 26
    
    private let lblViewHeight : CGFloat = 20
    private let lblViewWidth : CGFloat = 120
    
    private let cellHeight: CGFloat = (UIScreen.main.bounds.width - 40 - 10)/2
    private let cellWidth: CGFloat = (UIScreen.main.bounds.width - 40 - 10)/2
    
    private weak var axisFormatDelegate : IAxisValueFormatter?
    
    let imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        label.text = "-"
        label.textColor = .white
        return label
    }()
    
    let latestValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        label.text = "- | -"
        label.textColor = .white
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 8)
        label.text = "--"
        label.textColor = .gray
        return label
    }()
    
    let barChart: BarChartView = {
        let chart = BarChartView()
        
        //Editing the chart generally
        chart.noDataText = ""
        chart.xAxis.granularity = 1 //Makes the labels on the x-axis correctly aligned!
        chart.isUserInteractionEnabled = false
        chart.minOffset = 0
        chart.legend.enabled = false //remove the legend/color box
        chart.doubleTapToZoomEnabled = false //remove double tap zoom
        chart.pinchZoomEnabled = false //remove pinch zoom
        chart.setScaleEnabled(false) //removes all zoom/scaling

        //y-Axis editing (leftAxis and rightAxis)
        chart.leftAxis.enabled = false //disables everything on leftaxis (labels, gridlines, etc)
        chart.rightAxis.enabled = false
        
        //x-Axis editing
        chart.xAxis.labelTextColor = .label
        //chart.xAxis.centerAxisLabelsEnabled = true
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelFont = UIFont(name: "HelveticaNeue-Bold", size: 10)!

        return chart
    }()
    
    
    let combinedChart: CombinedChartView = {
        let chart = CombinedChartView()
        
        chart.noDataText = ""
        
        //Editing the chart generally
        chart.xAxis.granularity = 1 //Makes the labels on the x-axis correctly aligned!

        chart.pinchZoomEnabled = false //remove pinch zoom
        chart.setScaleEnabled(false) //removes all zoom/scaling
        
        //Editing the chart generally
        chart.isUserInteractionEnabled = false
        chart.minOffset = 0
        chart.legend.enabled = false //remove the legend/color box
        chart.doubleTapToZoomEnabled = false //remove double tap zoom
        chart.pinchZoomEnabled = false //remove pinch zoom
        chart.setScaleEnabled(false) //removes all zoom/scaling

        //y-Axis editing (leftAxis and rightAxis)
        chart.leftAxis.enabled = false //disables everything on leftaxis (labels, gridlines, etc)
        chart.rightAxis.enabled = false

        //x-Axis editing
        chart.xAxis.labelTextColor = .label
        chart.xAxis.centerAxisLabelsEnabled = true
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelFont = UIFont(name: "HelveticaNeue-Bold", size: 10)!
        chart.isUserInteractionEnabled = false
        return chart
    }()
    
    let moreDataLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
        lbl.numberOfLines =  0
        lbl.textAlignment = .center
        lbl.text = "H: -- | L: -- \nAVG: --"
        return lbl
    }()
    
    private func setBarColorT(value: Double) -> UIColor {
        let color: UIColor
        
        if value > 0 {
            color = (UIColor(red: 0.01, green: 0.81, blue: 0.64, alpha: 1.00))
        }
        else {
            color = (UIColor(red: 0.89, green: 0.00, blue: 0.40, alpha: 1.00))
        }
        
        return color
    }
    
    private func setBarColor(bars: Int) -> Array<UIColor>{
        var colors: [UIColor] = []
        
        for _ in 0..<bars-1 {
            colors.append(.gray)
        }
        colors.append(UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00))
        
        return colors
    }
    
    public func prepareBarChart(values: Array<Double?>) -> Void {
        
        if values.count == 8 {
            var entryLatest: [BarChartDataEntry] = []
            var entryOldest: [BarChartDataEntry] = []
            
            var count: Double = 0
            var colorSetOne: [UIColor] = []
            var colorSetTwo: [UIColor] = []
            
            for unwrappedValue in values {
                if let value = unwrappedValue {
                    if count <= 3 {
                        let dataEntry = BarChartDataEntry(x: count, y: value, data: quarters as AnyObject?)
                        entryLatest.append(dataEntry)
                        colorSetOne.append(setBarColorT(value: value))
                    }
                    else {
                        let dataEntry = BarChartDataEntry(x: count-4, y: value, data: quarters as AnyObject?)
                        entryOldest.append(dataEntry)
                        colorSetTwo.append(setBarColorT(value: value))
                    }
                    count += 1
                }
            }
            
            let setOne = BarChartDataSet(entries: entryLatest, label: "")
            setOne.highlightEnabled = false
            setOne.drawValuesEnabled = false
            setOne.colors = colorSetOne //[UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00)]
            
            let setTwo = BarChartDataSet(entries: entryOldest, label: "")
            setTwo.highlightEnabled = false
            setTwo.drawValuesEnabled = false
            setTwo.colors = colorSetTwo //[UIColor.darkGray]
            
            //Grouped bar chart
            var groupedBarDataSet : [BarChartDataSet] = [BarChartDataSet]()
            groupedBarDataSet.append(setOne)
            groupedBarDataSet.append(setTwo)
            
            //Constants for the groupedBarSets to calculate correct domensions/spacing
            // (barWidth + barSpace) * (no.of.bars per group) + groupSpace = 1.00 -> interval per "group"
            // (0.4 + 0.02) * 2 + 0.16 = 1.00
            let groupSpace = 0.36
            let barWidth = 0.3
            let barSpace = 0.02
            
            let groupedBarChartData = BarChartData(dataSets: groupedBarDataSet)

            groupedBarChartData.barWidth = barWidth
            groupedBarChartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
            
            let xAxisValue = combinedChart.xAxis
            xAxisValue.valueFormatter = axisFormatDelegate //connect formatting on x-axis with the axis delegate protocol

            //CombinedData
            let combinedData : CombinedChartData = CombinedChartData()
            combinedData.barData = groupedBarChartData
            
            combinedChart.xAxis.axisMinimum = Double(0)
            combinedChart.xAxis.axisMaximum = Double(4)
            combinedChart.data = combinedData
            
        } else {
            let lastFourQuarters = values.suffix(4)
            var entry: [BarChartDataEntry] = []
            var count: Double = 0
            var colorSet: [UIColor] = []
            
            for unwrappedValue in lastFourQuarters {
                if let value = unwrappedValue {
                    let dataEntry = BarChartDataEntry(x: count, y: value, data: quarters as AnyObject?)
                    entry.append(dataEntry)
                    count += 1
                    colorSet.append(setBarColorT(value: value))
                }
            }
                        
            let set = BarChartDataSet(entries: entry, label: "")
            set.highlightEnabled = false
            set.drawValuesEnabled = false
            set.colors = colorSet
            set.highlightAlpha = 0
            
            let xAxisValue = barChart.xAxis
            xAxisValue.valueFormatter = axisFormatDelegate //connect formatting on x-axis with the axis delegate protocol
            
            let data = BarChartData(dataSet: set)
            //data.barWidth = 0.5
            
            /*
            //CombinedData
            let combinedData : CombinedChartData = CombinedChartData()
            combinedData.barData = data
            
            //combinedChart.xAxis.axisMinimum = Double(0)
            //combinedChart.xAxis.axisMaximum = Double(entry.count)
            combinedChart.data = combinedData
            //combinedChart.xAxis.avoidFirstLastClippingEnabled = false
            
            //combinedChart.xAxis.centerAxisLabelsEnabled = true
            */
            
            //barChart.xAxis.axisMinimum = 0
            //barChart.xAxis.axisMaximum = Double(entry.count)
            barChart.data = data
        }
    }
    
    private func positionLabel(lblView: UILabel, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> Void{
        //Create the frame size for UILabel
        let lblFrame = CGRect(x: x, y: y, width: width, height: height)

        //Attach frame
        lblView.frame = lblFrame
        
        self.addSubview(lblView)
    }
    
    private func positionCombinedChart (chartView: CombinedChartView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> Void {
        let chartFrame = CGRect(x: x, y: y, width: width, height: height)
        
        //Attach frame
        chartView.frame = chartFrame
        
        self.addSubview(chartView)
    }
    
    private func positionBarChart (chartView: BarChartView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> Void {
        let chartFrame = CGRect(x: x, y: y, width: width, height: height)
        
        //Attach frame
        chartView.frame = chartFrame
        
        self.addSubview(chartView)
    }
    
    private func positionArrow() -> Void {
        imgView.image = UIImage(named: "rightArrow-1.png")
        
        let xPosArrow = cellWidth - 10 - 15
        imgView.frame = CGRect(x: xPosArrow, y: 10, width: 15, height: 15)
        
        self.addSubview(imgView)
    }
    
    func setUpViews() {
        axisFormatDelegate = self

        layer.cornerRadius = 10
        backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00) //UIColor.tertiarySystemBackground
        
        //Arrow
        positionArrow()
        
        //Category Label
        positionLabel(lblView: categoryLabel, x: 10, y: 10, width: 120, height: 15)
        
        //Latest Value Label
        positionLabel(lblView: latestValueLabel, x: 10, y: 30, width: 120, height: 20)
        
        //Name Label
        positionLabel(lblView: nameLabel, x: 10, y: 50, width: 100, height: 10)
        
        //Bar Chart
        let chartHeight = CGFloat(50)
        let chartWidth = cellWidth - 20
        let yPosChart = CGFloat(70) //cellHeight - chartHeight - 10
        
        //Combined Chart
        positionCombinedChart(chartView: combinedChart, x: 10, y: yPosChart, width: chartWidth, height: chartHeight)
        
        //Bar Chart
        positionBarChart(chartView: barChart, x: 10, y: yPosChart, width: chartWidth, height: chartHeight)

        
        //More Data Label
        let moreDataHeight = CGFloat(25)
        let moreDataWidth = cellWidth - 20
        let yPosMoreData = cellHeight - moreDataHeight - 10
        let xPosMoreData = CGFloat(10)
        positionLabel(lblView: moreDataLabel, x: xPosMoreData, y: yPosMoreData, width: moreDataWidth, height: moreDataHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
