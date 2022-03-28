//
//  CombinedChartCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-03-28.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import Foundation
import UIKit
import Charts

class CombinedChartCollectionViewCell: UICollectionViewCell {
    
    let ratioDict = ["Days Of Sales Outstanding": "daysOfSalesOutstanding", "Operating Profit Margin": "operatingProfitMargin", "Dividend Yield": "dividendYield", "Price To Sales Ratio": "priceToSalesRatio", "Inventory Turnover": "inventoryTurnover", "Price Earnings To Growth Ratio": "priceEarningsToGrowthRatio", "Cash Flow To Debt Ratio": "cashFlowToDebtRatio", "Debt Ratio": "debtRatio", "Ebit Per Revenue": "ebitPerRevenue", "Operating Cash Flow Sales Ratio": "operatingCashFlowSalesRatio", "Price Earnings Ratio": "priceEarningsRatio", "Free Cash Flow Operating Cash Flow Ratio": "freeCashFlowOperatingCashFlowRatio", "Return On Assets": "returnOnAssets", "Free Cash Flow Per Share": "freeCashFlowPerShare", "Return On Equity": "returnOnEquity", "Total Debt To Capitalization": "totalDebtToCapitalization", "Operating Cycle": "operatingCycle", "Pretax Profit Margin": "pretaxProfitMargin", "Gross Profit Margin": "grossProfitMargin", "Receivables Turnover": "receivablesTurnover", "Payout Ratio": "payoutRatio", "Interest Coverage": "interestCoverage", "Short Term Coverage Ratios": "shortTermCoverageRatios", "Net Profit Margin": "netProfitMargin", "Dividend Payout Ratio": "dividendPayoutRatio", "Enterprise Value Multiple": "enterpriseValueMultiple", "Quick Ratio": "quickRatio", "Price Fair Value": "priceFairValue", "Price To Operating Cash Flows Ratio": "priceToOperatingCashFlowsRatio", "Ebt Per Ebit": "ebtPerEbit", "Company Equity Multiplier": "companyEquityMultiplier", "Dividend Paid And Capex Coverage Ratio": "dividendPaidAndCapexCoverageRatio", "Cash Ratio": "cashRatio", "Cash Per Share": "cashPerShare", "Price Book Value Ratio": "priceBookValueRatio", "Debt Equity Ratio": "debtEquityRatio", "Net Income Per EBT": "netIncomePerEBT", "Long Term Debt To Capitalization": "longTermDebtToCapitalization", "Price To Free Cash Flows Ratio": "priceToFreeCashFlowsRatio", "Operating Cash Flow Per Share": "operatingCashFlowPerShare", "Capital Expenditure Coverage Ratio": "capitalExpenditureCoverageRatio", "Price Cash Flow Ratio": "priceCashFlowRatio", "Return On Capital Employed": "returnOnCapitalEmployed", "Cash Flow Coverage Ratios": "cashFlowCoverageRatios", "Cash Conversion Cycle": "cashConversionCycle", "Current Ratio": "currentRatio", "Days Of Payables Outstanding": "daysOfPayablesOutstanding", "Days Of Inventory Outstanding": "daysOfInventoryOutstanding", "Price Sales Ratio": "priceSalesRatio", "Effective Tax Rate": "effectiveTaxRate", "Fixed Asset Turnover": "fixedAssetTurnover", "Payables Turnover": "payablesTurnover", "Price To Book Ratio": "priceToBookRatio", "Asset Turnover": "assetTurnover"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    let cellWidth = Int(UIScreen.main.bounds.size.width - 20*2)
    let ySegOne = 20
    let yChartView = 20 + 32 + 10
    let chartHeight = 300
    let ySegTwo = 20 + 32 + 10 + 300 + 10
    
    let combinedChart: CombinedChartView = {
        var chart = CombinedChartView()
        chart.xAxis.axisMinimum = 0 //Makes grouped bar chart data correctly displayed (on top of the upper lines)
        chart.xAxis.axisMaximum = Double(10)
        
        //Editing the chart generally
        chart.pinchZoomEnabled = false //remove pinch zoom
        chart.setScaleEnabled(false) //removes all zoom/scaling
        chart.animate(yAxisDuration: 1, easingOption: .easeInOutQuad)
        
        //Set position of legends outside the pie chart
        let chartDataLegend = chart.legend
        chartDataLegend.verticalAlignment = .bottom
        chartDataLegend.horizontalAlignment = .left
        chartDataLegend.orientation = .horizontal
        chartDataLegend.textColor = .label
        
        //right axis
        chart.rightAxis.enabled = false
        
        //left axis
        chart.leftAxis.labelTextColor = .label

        //x-Axis editing
        chart.xAxis.labelTextColor = .label
        chart.xAxis.centerAxisLabelsEnabled = true
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.labelRotationAngle = -90
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        chart.isUserInteractionEnabled = false
        return chart
    }()
    
    let segmentedControlType: UISegmentedControl = {
        let items = ["Income", "Balance", "Cash Flow"]
        let segControl = UISegmentedControl(items: items)
        segControl.selectedSegmentIndex = 0
        return segControl
    }()
    
    let segmentedControlPeriod: UISegmentedControl = {
        let items = ["Y", "Q"]
        let segControl = UISegmentedControl(items: items)
        segControl.selectedSegmentIndex = 0
        return segControl
    }()
    
    let filterButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .tertiarySystemBackground
        return btn
    }()
    
    private func positionSegmentedControl(segmentedControl: UISegmentedControl){
        let width = Int(cellWidth - 40)
        let height = 32
        
        if segmentedControl == segmentedControlType {
            segmentedControl.frame = CGRect(x: 20, y: ySegOne, width: width, height: height)
            self.addSubview(segmentedControl)
        }
        
        else {
            segmentedControl.frame = CGRect(x: 20, y: ySegTwo, width: width, height: height)
            self.addSubview(segmentedControl)
        }
    }
    
    private func positionFilterButton(button: UIButton) {
        let width = Int(Double(cellWidth)*0.08)
        let height = width
        button.frame = CGRect(x: (Int(cellWidth) - (width)), y: 20, width: width, height: height)
        self.addSubview(button)
    }
    
    private func positionChartView(chart: CombinedChartView) {
        let width = cellWidth - 20
        
        chart.frame = CGRect(x: 10, y: yChartView, width: width, height: chartHeight)
    }
    
    func lineOrBarChart(selectedRatiosDict: Dictionary<String, Array<Double>>) -> (Array<String>, Array<String>) {
        var ratioNames = [String]()
        var charts = [String]()
        
        if selectedRatiosDict.count != 0 {
            
            //Step 1 - Calculate the means of each ratios historical values
            var ratioMeans = [Double]()
            var meanDict = [String() : Double()]
            meanDict.removeAll()
            
            for (key,val) in selectedRatiosDict {
                let value = (val.reduce(0, +))
                let mean = Double(value / Double(val.count))
                
                ratioMeans.append(mean)
                meanDict["\(key)"] = mean
            }
            
            //Step 2 - Calculate the means proportios in comparison with the greatest mean
            let maxNumber = ratioMeans.max()
            var proportionsDict = [String():Double()]
            proportionsDict.removeAll()
            
            for (k,v) in meanDict {
                let proportionOfMax = Double(v/maxNumber!)
                proportionsDict["\(k)"] = proportionOfMax
            }
            
            //Step 3 - Decide which ratio should be displayed as a bar chart or line chart, depending on "the-20%-treshold in relation to max. mean"
            for (k,v) in proportionsDict {
                ratioNames.append(k)
                if v < 0.2{
                    charts.append("L")
                } else {
                    charts.append("B")
                }
            }
        }
        return (ratioNames, charts)
    }
    
    func populateChartTest(chartData: Array<Array<BarChartDataEntry>>, statementItems: Array<String>, periods: Int, chart: CombinedChartView) {
        //Constants for the groupedBarSets to calculate correct domensions/spacing
        // (barWidth + barSpace) * (no.of.bars per group) + groupSpace = 1.00 -> interval per "group"
        // (0.1825 + 0.03) * 4 + 0.15 = 1.00
        let groupSpace = 0.15
        let barWidth = 0.1825
        let barSpace = 0.03
        
        //Setup for the two bar charts
        //1
        let barChartDataSet1 = BarChartDataSet(entries: chartData[0], label: statementItems[0])
        barChartDataSet1.colors = [UIColor(red: 0.92, green: 0.13, blue: 0.53, alpha: 1.00)]
        barChartDataSet1.axisDependency = .right
        barChartDataSet1.drawValuesEnabled = false
        
        //2
        let barChartDataSet2 = BarChartDataSet(entries: chartData[1], label: statementItems[1])
        barChartDataSet2.colors = [UIColor(red: 0.73, green: 0.87, blue: 0.93, alpha: 0.87)]
        barChartDataSet2.axisDependency = .right
        barChartDataSet2.drawValuesEnabled = false
        
        //3
        let barChartDataSet3 = BarChartDataSet(entries: chartData[2], label: statementItems[2])
        barChartDataSet3.colors = [UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00)]
        barChartDataSet3.axisDependency = .right
        barChartDataSet3.drawValuesEnabled = false
        
        //4
        let barChartDataSet4 = BarChartDataSet(entries: chartData[3], label: statementItems[3])
        barChartDataSet4.colors = [UIColor(red: 0.95, green: 0.56, blue: 0.00, alpha: 1.00)]
        barChartDataSet4.axisDependency = .right
        barChartDataSet4.drawValuesEnabled = false
        
        //Grouped bar chart
        var groupedBarDataSet: [BarChartDataSet] = [BarChartDataSet]()
        groupedBarDataSet.append(barChartDataSet1)
        groupedBarDataSet.append(barChartDataSet2)
        groupedBarDataSet.append(barChartDataSet3)
        groupedBarDataSet.append(barChartDataSet4)
        
        let groupedBarChartData = BarChartData(dataSets: groupedBarDataSet)
        
        groupedBarChartData.barWidth = barWidth
        groupedBarChartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        
        //CombinedData
        let combinedData : CombinedChartData = CombinedChartData()
        
        combinedData.barData = groupedBarChartData
        chart.data = combinedData
        chart.animate(yAxisDuration: 1, easingOption: .easeInOutQuad)

        
        //Editing the chart generally
        //chart.animate(yAxisDuration: 1, easingOption: .easeInOutQuart)
        chart.pinchZoomEnabled = false //remove pinch zoom
        chart.setScaleEnabled(false) //removes all zoom/scaling
        chart.xAxis.axisMinimum = 0
        chart.xAxis.axisMaximum = Double(periods)
        
        //Set position of legends outside the pie chart
        let chartDataLegend = chart.legend
        chartDataLegend.verticalAlignment = .bottom
        chartDataLegend.horizontalAlignment = .left
        chartDataLegend.orientation = .horizontal
        chartDataLegend.textColor = .label
        
        //right axis
        chart.rightAxis.enabled = false
        
        //left axis
        var maxValues = [Double]()
        var minValues = [Double]()
        
        for i in groupedBarDataSet {
            maxValues.append(i.yMax)
            minValues.append(i.yMin)
        }
        
        chart.leftAxis.labelTextColor = .label
        chart.leftAxis.valueFormatter = YAxisValueFormatter()
        //chart.leftAxis.axisMaximum = maxValue * 1.1
        //chart.leftAxis.axisMinimum = minValue * 1.1

        //x-Axis editing
        chart.xAxis.labelTextColor = .label
        chart.xAxis.centerAxisLabelsEnabled = true
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.labelRotationAngle = -90
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
    }
    
    
    func setUpViews() {
        layer.cornerRadius = 15
        backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00) //UIColor.tertiarySystemBackground
        
        addSubview(combinedChart)
        positionChartView(chart: combinedChart)
        positionSegmentedControl(segmentedControl: segmentedControlType)
        positionSegmentedControl(segmentedControl: segmentedControlPeriod)
        //positionFilterButton(button: filterButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
