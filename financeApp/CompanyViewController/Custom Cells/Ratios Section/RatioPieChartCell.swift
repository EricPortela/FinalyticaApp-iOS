//
//  RatioPieChartCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-10-28.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class RatioPieChartCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    let imgViewHeight : CGFloat = 26
    let imgViewWidth : CGFloat = 26
    
    let lblViewHeight : CGFloat = 20
    let lblViewWidth : CGFloat = 120
    
    let cellWidth: CGFloat = (UIScreen.main.bounds.width - 40 - 10)/2
    let cellHeight : CGFloat = (UIScreen.main.bounds.width - 40 - 10)/2

    
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
    
    let pieChart: PieChartView = {
        var chart = PieChartView()
        chart.isUserInteractionEnabled = false
        chart.legend.enabled = false
        chart.holeColor = UIColor.clear
        chart.holeRadiusPercent = 0.8
        chart.rotationEnabled = false
        chart.minOffset = 0
        chart.legend.enabled = false //remove the legend/color box
        return chart
    }()
    
    let moreDataLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
        lbl.numberOfLines =  0
        lbl.textAlignment = .left
        lbl.text = "H: --\nL: --\nAVG: --"
        return lbl
    }()
    
    func negativePositiveColor(value: Double) -> Array<UIColor> {
        var color: [UIColor] = [] //If value == 0
        
        if value > 0 {
            let colorOne = UIColor(red: 0.01, green: 0.81, blue: 0.64, alpha: 1.00) //Green
            let colorTwo = UIColor.darkGray
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
    
    public func preparePieChart(value: Double?) -> Void {
        var entry: [PieChartDataEntry] = []
        var count: Double = 0
        
        if let unwrappedValue = value {
            if unwrappedValue > 0 && unwrappedValue < 1 {
                entry.append(PieChartDataEntry(value: unwrappedValue))
                entry.append(PieChartDataEntry(value: 1-unwrappedValue))
            }
            else if unwrappedValue > 1 {
                entry.append(PieChartDataEntry(value: 1))
            }
            else {
                entry.append(PieChartDataEntry(value: 1))
            }
            count += 1
        }
        
        
        let set = PieChartDataSet(entries: entry, label: "")
        set.selectionShift = 0
        set.highlightEnabled = false
        set.drawValuesEnabled = false
        if let unwrappedValue = value {
            set.colors = negativePositiveColor(value: unwrappedValue)
        }
        set.valueColors = [UIColor.white]

        let data = PieChartData(dataSet: set)
        pieChart.data = data
    }
    
    private func positionLabel(lblView: UILabel, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> Void{
        //Create the frame size for UILabel
        let lblFrame = CGRect(x: x, y: y, width: width, height: height)

        //Attach frame
        lblView.frame = lblFrame
        
        self.addSubview(lblView)
    }
    
    private func positionChart (chartView: PieChartView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> Void {
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
        let chartHeight = CGFloat(cellHeight - 80)
        let chartWidth = CGFloat(80)
        let yPosChart = cellHeight - chartHeight - 10
        positionChart(chartView: pieChart, x: 10, y: yPosChart, width: chartWidth, height: chartHeight)
        
        //More Data Label
        let moreDataHeight = CGFloat(50)
        let moreDataWidth = CGFloat(50)
        let yPosMoreData = (yPosChart + chartHeight/2 - moreDataHeight/2)
        let xPosMoreData = chartWidth + 20
        positionLabel(lblView: moreDataLabel, x: xPosMoreData, y: yPosMoreData, width: moreDataWidth, height: moreDataHeight)
        
        //self.layer.borderWidth = 5
        //self.layer.borderColor = UIColor.gray.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
