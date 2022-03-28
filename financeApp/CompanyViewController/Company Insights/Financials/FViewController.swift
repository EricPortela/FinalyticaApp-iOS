//
//  FViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2021-03-24.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class FViewController: UIViewController {

    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var financialsCollectionView: UICollectionView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var lastFiveYears = [String]()
    
    let financialReport = ["Income Statement", "Balance Sheet", "Cash Flow Statement"]
    let partsOfFinancialReport = ["Income Statement" : ["Revenue", "Net Income", "Net Profit Margin"], "Balance Sheet" : [], "Cash Flow Statement" : []]
    
    let dispatchGroup = DispatchGroup()
    
    var rawFinancialDataSets = [[String : Any]()]
    var allFinancialStatements = [String : Any]()
    var cleanedFinancialStatements = [String: [ String : [NSNumber] ]]() // ==> ["Income Statement" : ["Revenue" : [1, 2, 3, 4, 5], "netIncome" : [1, 2, 3, 4, 5]]
    
    //Income Statement variable
    var iSLineChartData = [NSNumber]()
    var iSBarChartData1 = [NSNumber]()
    var iSBarChartData2 = [NSNumber]()
    
    //Balance sheet variable
    var bSLineChartData = [NSNumber]()
    var bSBarChartData1 = [NSNumber]()
    var bSBarChartData2 = [NSNumber]()
    
    var ticker = String()
    
    @IBAction func changeChartPeriod(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            getIncomeStatement(ticker: self.ticker, period: "Y")
            getBalanceSheet(ticker: self.ticker, period: "Y")
        case 1:
            getIncomeStatement(ticker: self.ticker, period: "Q")
            getBalanceSheet(ticker: self.ticker, period: "Q")
        default:
            getIncomeStatement(ticker: self.ticker, period: "Y")
            getBalanceSheet(ticker: self.ticker, period: "Y")
        }
    }
    
    
    @IBAction func changeChartSettings(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popOver = storyboard.instantiateViewController(withIdentifier: "chartSettings") as! ChartSettingsViewController
        popOver.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        tabBarController?.present(popOver, animated: true, completion: nil) //This line enables the custom popover to cover the whole area of the underlying "root-view", in this case the tab bar controller, hence tabBarController?.present....
    }
    
    
    //INCOME STATEMENT
    func getIncomeStatement(ticker: String, period: String) {
        dispatchGroup.enter()
        let incomeStatementLink = getIncomeStatementLink(period: period) //METHOD 1
        fmpIncomeStatement(urlLink: incomeStatementLink) //METHOD 2 + 3 & 4 called in here as well
        dispatchGroup.leave()
    }
    
    //BALANCE SHEET
    func getBalanceSheet(ticker: String, period: String) {
        dispatchGroup.enter()
        let balanceSheetLink = getBalanceSheetLink(period: period) //METHOD 1
        fmpBalanceSheet(urlLink: balanceSheetLink) //METHOD 2 + 3 & 4 called in here as well
        dispatchGroup.leave()
    }
    
    //DISPLAY CHART DATA BY RELOADING COLLECTIONVIEW DATA
    func displayChartData() {
        dispatchGroup.notify(queue: .main, execute: {
            self.financialsCollectionView.reloadData()
            self.financialsCollectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        financialsCollectionView.delegate = self
        financialsCollectionView.dataSource = self
        
        let exitImg = UIImage(named: "exitButton2.png")
        let exitBtn = UIBarButtonItem(image: exitImg, style: .plain, target: self, action: nil)
        self.navigationController?.navigationItem.rightBarButtonItem = exitBtn //navigationItem.rightBarButtonItem = exitBtn
        
        
        getIncomeStatement(ticker: self.ticker, period: "Y")
        getBalanceSheet(ticker: self.ticker, period: "Y")
        financialsCollectionView.reloadData()
        displayChartData()
        
        let layout = financialsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true //makes the header in UICollectionView sticky
    }
    
    
    func convertLargeNumbers(number : NSNumber) {
        let abbreviations : [Int : String] = [4 : "K", 7 : "M", 10 : "B", 13 : "T"]
        let numberAsString = number.stringValue
        var abbreviatedNumber = String()
        
        for (k,v) in abbreviations {
            if String(numberAsString.prefix(1)) != "-" {
                if numberAsString.count == k {
                    abbreviatedNumber = String(numberAsString.prefix(1)) + v
                    print(abbreviatedNumber)
                }
            } else {
                if numberAsString.count - 1 == k {
                    abbreviatedNumber = String(numberAsString.prefix(2)) + v
                    print(abbreviatedNumber)
                }
            }
        }
    }
    
    
    func getArraysForCharts(partOfFinancialStatement: String) -> (lineChartData: Array<NSNumber>, barChartData1: Array<NSNumber>, barChartData2: Array<NSNumber>){
        
        let one = [NSNumber]()
        let two = [NSNumber]()
        let three = [NSNumber]()
        
        if partOfFinancialStatement == "Income Statement" {
            return (iSLineChartData, iSBarChartData1, iSBarChartData2)
        }
        
        else if partOfFinancialStatement == "Balance Sheet" {
            return (bSLineChartData, bSBarChartData1, bSBarChartData2)
        }
        return (one, two, three)
    }
    

    func setCombinedChart(dates: Array<String>, chart: CombinedChartView, partOfFinancialStatement: String, cleanedFinancialData: Dictionary<String, Dictionary<String, Array<NSNumber>>>){
        //let getArrays = getArraysForCharts(partOfFinancialStatement: partOfFinancialStatement)
        
        //Datasets for the combo-chart (line, bar, bar)
        var DataSetLineChart = [NSNumber]()
        var DataSetBar1 = [NSNumber]()
        var DataSetBar2 = [NSNumber]()
        
        //Entry labels
        var entryName1 = String()
        var entryName2 = String()
        var entryName3 = String()
        
            
        for (key, value) in cleanedFinancialData {
            if key == partOfFinancialStatement {
                for (k,v) in value {
                    if k == "Net Profit Margin" || k == "Debt Asset Ratio"{
                        DataSetLineChart = v
                        entryName1 = k
                    }
                    else if k == "Revenue" || k == "Total Assets"{
                        DataSetBar1 = v
                        entryName2 = k
                    }
                    else if k == "Net Income" || k == "Long Term Debt"{
                        DataSetBar2 = v
                        entryName3 = k
                    }
                }
            }
        }
        
        print("Function Charts Set Up")
        print(DataSetLineChart)
        print(DataSetBar1)
        print(DataSetBar2)
        
        var lineData = [ChartDataEntry]()
        var barData1 = [BarChartDataEntry]()
        var barData2 = [BarChartDataEntry]()
        
        //Constants for the groupedBarSets to calculate correct domensions/spacing
        let groupSpace = 0.15
        let barWidth = 0.395
        let barSpace = 0.03
        
        if DataSetLineChart.isEmpty == false || DataSetBar1.isEmpty == false || DataSetBar2.isEmpty == false {
            var count = 0
            for _ in dates {
                
                //Prepare line chart
                //var roundedValue1 = Double(DataSetLineChart[count])*100
                let rawLineValue = Double(DataSetLineChart[count])
                let roundedValue1 = (Double(round(rawLineValue*100*1000)/1000))
                lineData.append(ChartDataEntry(x: Double(count) + barWidth + groupSpace , y: roundedValue1)) //Also add the barWidth
                
                //Prepare bar chart 1
                let rawBarValue1 = Double(DataSetBar1[count])
                let roundedValue2 = Double(round(rawBarValue1*100)/100)
                barData1.append(BarChartDataEntry(x: Double(count), y: Double(roundedValue2)))
                        
                //Prepare bar chart 2
                let rawBarValue2 = Double(DataSetBar2[count])
                let roundedValue3 = Double(round(rawBarValue2*100)/100)
                barData2.append(BarChartDataEntry(x: Double(count), y: Double(roundedValue3)))

                count += 1
            }
                        
                    
            //Setup for line chart
            let lineChartSet = LineChartDataSet(entries: lineData, label: entryName1)
            lineChartSet.colors = [UIColor(red: 0.59, green: 0.31, blue: 0.76, alpha: 1.00)]
            lineChartSet.axisDependency = .right
            lineChartSet.circleRadius = 6
            lineChartSet.circleColors = [UIColor(red: 0.59, green: 0.31, blue: 0.76, alpha: 1.00)]
            lineChartSet.circleHoleColor = UIColor(red: 0.59, green: 0.31, blue: 0.76, alpha: 1.00)
            lineChartSet.valueColors = [.label]
            lineChartSet.valueFont = UIFont(name: "HelveticaNeue-Bold", size: 12)!
            let lineChartData = LineChartData(dataSets: [lineChartSet])
            
            //Setup for the two bar charts
            //1
            let barChartDataSet1 = BarChartDataSet(entries: barData1, label: entryName2)
            barChartDataSet1.colors = [UIColor(red: 0.92, green: 0.13, blue: 0.53, alpha: 1.00)]
            barChartDataSet1.axisDependency = .left
            barChartDataSet1.drawValuesEnabled = false
            
            //2
            let barChartDataSet2 = BarChartDataSet(entries: barData2, label: entryName3)
            barChartDataSet2.axisDependency = .left
            barChartDataSet2.drawValuesEnabled = false
            
            //Grouped bar chart
            var groupedBarDataSet : [BarChartDataSet] = [BarChartDataSet]()
            groupedBarDataSet.append(barChartDataSet1)
            groupedBarDataSet.append(barChartDataSet2)
            
            let groupedBarChartData = BarChartData(dataSets: groupedBarDataSet)
            
            // (barWidth + barSpace) * (no.of.bars per group) + groupSpace = 1.00 -> interval per "group"
            // (0.395 + 0.03) * 2 + 0.15 = 1.00
            groupedBarChartData.barWidth = barWidth
            groupedBarChartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
            
            //CombinedData
            let combinedData : CombinedChartData = CombinedChartData()
            
            combinedData.lineData = lineChartData
            combinedData.barData = groupedBarChartData
            chart.data = combinedData

            
            //Editing the chart generally
            //chart.animate(yAxisDuration: 1, easingOption: .easeInOutQuart)
            chart.pinchZoomEnabled = false //remove pinch zoom
            chart.setScaleEnabled(false) //removes all zoom/scaling
            chart.xAxis.axisMinimum = 0
            chart.xAxis.axisMaximum = Double(dates.count)
            
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
        }
    }
}

//---------------------------------
//I N C O M E   S T A T E M E N T
//---------------------------------
extension FViewController {
    
    //METHOD 1 - ACQUIRES/RETRIEVES URL ENDPOINT (INCOME STATEMENT) FOR THE CHOOSEN COMPANY
    func getIncomeStatementLink(period: String) -> String {
        var ratioLink = ""
        if period == "Y"{
            ratioLink = "https://financialmodelingprep.com/api/v3/income-statement/\(self.ticker)?limit=10&apikey=\(apiKey)"
        } else if period == "Q"{
            ratioLink = "https://financialmodelingprep.com/api/v3/income-statement/\(self.ticker)?period=quarter&limit=400&apikey=\(apiKey)"
        }
        return ratioLink
    }
    
    
    //METHOD 2 - ACQUIRES/RETRIEVES THE RAW DATA FROM THE FMP API
    func fmpIncomeStatement(urlLink : String) { //Argument 2: An array including the three main items from each part of the financial statement. The first element should be the one that is going to be displayed as a line chart, rest are displayed as bar charts.
        var datesArray = [String]()
        datesArray.removeAll()
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
            //Retrieve yearly ratio data
            guard let url = URL(string: urlLink) else { return }
                  URLSession.shared.dataTask(with: url) { (data, response, err) in
                    guard let data = data else { return }
                      do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                            DispatchQueue.main.async{
                                //1. Get all dates from latest reports
                                for quarterlyData in json {
                                    if let quarterlyDataset = quarterlyData as? Dictionary<String, Any> {
                                        if let date = quarterlyDataset["date"] as? String {
                                            datesArray.append(date)
                                        }
                                    }
                                }
                                
                                //2. Get dates for the last five years
                                let sortedDatesArray = (datesArray.sorted().reversed())
                                self.lastFiveYears = Array(sortedDatesArray.prefix(5)).reversed()
                                
                                //3. Get the data for the last five years
                                for yearlyDate in self.lastFiveYears {
                                    for quarterlyData in json {
                                        if let quarterlyDataset = quarterlyData as? Dictionary<String, Any> {
                                            if let date = quarterlyDataset["date"] as? String {
                                                if date == yearlyDate {
                                                    self.rawFinancialDataSets.append(quarterlyDataset)
                                                }
                                            }
                                        }
                                    }
                                }
                                self.cleanIncomeStatement(ratiosDictionary: self.rawFinancialDataSets, datesArray: self.lastFiveYears)
                        }
                    }
                    } catch let jsonErr {
                        print("Error serializing json:", jsonErr)
                      }
                  }.resume()
        }
    
    
    //METHOD 3 - CLEANS THE RAW DATA AND ADDS IT TO A DICTIONARY CONTAINING DATA FROM ALL DIFERENT PARTS OF THE FINANCIAL STATEMENT
    //*** THIS METHOD IS CALLED IN METHOD 2 ***
    func cleanIncomeStatement(ratiosDictionary : Array<Dictionary<String, Any>>, datesArray : Array<String>) {
        
        //Income Statement Preparation
        var incomeStatement = [String : Array<NSNumber>]()
        var revenueArray = [NSNumber]()
        var netIncomeArray = [NSNumber]()
        var netIncomeRatioArray = [NSNumber]()
        
        for yearlyDataSet in ratiosDictionary {
            for date in datesArray {
                if date == yearlyDataSet["date"] as? String{

                    if let revenue = yearlyDataSet["revenue"] as? NSNumber{ //Revenue
                        revenueArray.append(revenue)
                    }

                    if let netIncome = yearlyDataSet["netIncome"] as? NSNumber{ //Net income
                        netIncomeArray.append(netIncome)
                    }

                    if let netProfitMargin = yearlyDataSet["netIncomeRatio"] as? NSNumber{ //Net profit margin
                        netIncomeRatioArray.append(netProfitMargin)
                    }
                }
            }
        }
        incomeStatement["Revenue"] = revenueArray
        incomeStatement["Net Income"] = netIncomeArray
        incomeStatement["Net Profit Margin"] = netIncomeRatioArray
        cleanedFinancialStatements["Income Statement"] = incomeStatement
        displayChartData()
        //financialsCollectionView.reloadData()
        //prepareIncomeStatementDataForCharts(completeFinancialStatementData: cleanedFinancialStatements)
    }
    
    //METHOD 4 - PREPARE THE DATA TO POPULATE CHART
    //*** THIS METHOD IS CALLED IN METHOD 3 ***
    func prepareIncomeStatementDataForCharts(completeFinancialStatementData: Dictionary<String, Dictionary<String, Array<NSNumber>>>){
        for (k,v) in completeFinancialStatementData {
            if k == "Income Statement" {
                for (value,array) in v {
                    if value == "Net Profit Margin"{
                        iSLineChartData = array
                    }
                    else if value == "Net Income"{
                        iSBarChartData1 = array
                    }
                    else if value == "Revenue"{
                        iSBarChartData2 = array
                    }
                }
            }
        }
        print("Test 1")
        print(iSLineChartData)
        print(iSBarChartData1)
        print(iSBarChartData2)
    }
}



//---------------------------------
//B A L A N C E   S H E E T
//---------------------------------
extension FViewController {
    
    //METHOD 1 - ACQUIRES/RETRIEVES URL ENDPOINT (BALANCE SHEET) FOR THE CHOOSEN COMPANY
    func getBalanceSheetLink(period: String) -> String {
        var ratioLink = ""
        if period == "Y" {
            ratioLink = "https://financialmodelingprep.com/api/v3/balance-sheet-statement/\(self.ticker)?limit=10&apikey=\(apiKey)"
        } else if period == "Q" {
            ratioLink = "https://financialmodelingprep.com/api/v3/balance-sheet-statement/\(self.ticker)?period=quarter&limit=400&apikey=\(apiKey)"
        }
        return ratioLink
    }
    
    
    //METHOD 2 - ACQUIRES/RETRIEVES THE RAW DATA FROM THE FMP API
    func fmpBalanceSheet(urlLink : String) { //Argument 2: An array including the three main items from each part of the financial statement. The first element should be the one that is going to be displayed as a line chart, rest are displayed as bar charts.
        var datesArray = [String]()
        datesArray.removeAll()
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        
        //Retrieve yearly ratio data
        guard let url = URL(string: urlLink) else { return }
             URLSession.shared.dataTask(with: url) { (data, response, err) in
               guard let data = data else { return }
                 do {
                   if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                    DispatchQueue.main.async {
                        //1. Get all dates from latest reports
                        for quarterlyData in json {
                            if let quarterlyDataset = quarterlyData as? Dictionary<String, Any> {
                                if let date = quarterlyDataset["date"] as? String {
                                    datesArray.append(date)
                                }
                            }
                        }
                        
                        //2. Get dates for the last five years
                        let sortedDatesArray = (datesArray.sorted().reversed())
                        self.lastFiveYears = Array(sortedDatesArray.prefix(5)).reversed()
                        
                        //3. Get the data for the last five years
                        for yearlyDate in self.lastFiveYears {
                            for quarterlyData in json {
                                if let quarterlyDataset = quarterlyData as? Dictionary<String, Any> {
                                    if let date = quarterlyDataset["date"] as? String {
                                        if date == yearlyDate {
                                            self.rawFinancialDataSets.append(quarterlyDataset)
                                        }
                                    }
                                }
                            }
                        }
                        self.cleanBalanceSheet(ratiosDictionary: self.rawFinancialDataSets, datesArray: self.lastFiveYears)
                    }
                   }
               } catch let jsonErr {
                   print("Error serializing json:", jsonErr)
                 }
             }.resume()
        }
    
    
    //METHOD 3 - CLEANS THE RAW DATA AND ADDS IT TO A DICTIONARY CONTAINING DATA FROM ALL DIFERENT PARTS OF THE FINANCIAL STATEMENT
    //*** THIS METHOD IS CALLED IN METHOD 2 ***
    func cleanBalanceSheet(ratiosDictionary : Array<Dictionary<String, Any>>, datesArray : Array<String>) {
        var debtAssetRatio = NSNumber()
        var tA = NSNumber()
        var tD = NSNumber()
        
        //Balance Sheet Preparation
        var balanceSheet = [String : Array<NSNumber>]()
        var totalAssetsArray = [NSNumber]()
        var longTermDebtArray = [NSNumber]()
        var debtAssetRatioArray = [NSNumber]()
        
        for yearlyDataSet in ratiosDictionary {
            for date in datesArray {
                if date == yearlyDataSet["date"] as? String{
                    
                    if let totalAssets = yearlyDataSet["totalAssets"] as? NSNumber, let totalDebt = yearlyDataSet["totalDebt"] as? NSNumber{ //For debt Asset Ratio and debt Asset Ratio
                        tA = totalAssets
                        tD = totalDebt
                        
                        let debtAssetRatio = (tD.floatValue / tA.floatValue) as NSNumber
                        debtAssetRatioArray.append(debtAssetRatio)
                    }
                    
                    if let totalAssets = yearlyDataSet["totalAssets"] as? NSNumber { //Total Assets
                        totalAssetsArray.append(totalAssets)
                    }
                    
                    if let longTermDebt = yearlyDataSet["longTermDebt"] as? NSNumber { //Long Term Debt
                        longTermDebtArray.append(longTermDebt)
                    }
                }
            }
        }
        balanceSheet["Total Assets"] = totalAssetsArray
        balanceSheet["Long Term Debt"] = longTermDebtArray
        balanceSheet["Debt Asset Ratio"] = debtAssetRatioArray
        cleanedFinancialStatements["Balance Sheet"] = balanceSheet
        displayChartData()
        //financialsCollectionView.reloadData()
        //prepareBalanceSheetDataForCharts(completeFinancialStatementData: cleanedFinancialStatements)
    }
    
    //METHOD 4 - PREPARE THE DATA TO POPULATE CHART
    //*** THIS METHOD IS CALLED IN METHOD 3 ***
    func prepareBalanceSheetDataForCharts(completeFinancialStatementData: Dictionary<String, Dictionary<String, Array<NSNumber>>>){
        for (k,v) in completeFinancialStatementData {
            
            if k == "Balance Sheet" {
                for (value,array) in v {
                    if value == "Debt Asset Ratio"{
                        bSLineChartData = array
                    }
                    else if value == "Total Assets"{
                        bSBarChartData1 = array
                    }
                    else if value == "Long Term Debt"{
                        bSBarChartData2 = array
                    }
                }
            }
        }
        print("Test 2")
        print(bSLineChartData)
        print(bSBarChartData1)
        print(bSBarChartData2)
    }
}
    



extension FViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = financialsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? FinancialsCollectionViewCell
        
        let part = financialReport[indexPath.section]
                
        setCombinedChart(dates: lastFiveYears, chart: (cell?.combinedChartView)!, partOfFinancialStatement: part, cleanedFinancialData: cleanedFinancialStatements)
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = financialsCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "financialsHeader", for: indexPath) as? FinancialStatementCollectionReusableView
        
        header?.backgroundColor = .secondarySystemBackground
        
        header?.headerLabel.text = financialReport[indexPath.section]
        
        return header!
    }

}
