//
//  CustomRatioAnalysisViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2021-02-02.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class CustomRatioAnalysisViewController: UIViewController /*,UIScrollViewDelegate*/ {
    
    let ratioDict = ["Days Of Sales Outstanding": "daysOfSalesOutstanding", "Operating Profit Margin": "operatingProfitMargin", "Dividend Yield": "dividendYield", "Price To Sales Ratio": "priceToSalesRatio", "Inventory Turnover": "inventoryTurnover", "Price Earnings To Growth Ratio": "priceEarningsToGrowthRatio", "Cash Flow To Debt Ratio": "cashFlowToDebtRatio", "Debt Ratio": "debtRatio", "Ebit Per Revenue": "ebitPerRevenue", "Operating Cash Flow Sales Ratio": "operatingCashFlowSalesRatio", "Price Earnings Ratio": "priceEarningsRatio", "Free Cash Flow Operating Cash Flow Ratio": "freeCashFlowOperatingCashFlowRatio", "Return On Assets": "returnOnAssets", "Free Cash Flow Per Share": "freeCashFlowPerShare", "Return On Equity": "returnOnEquity", "Total Debt To Capitalization": "totalDebtToCapitalization", "Operating Cycle": "operatingCycle", "Pretax Profit Margin": "pretaxProfitMargin", "Gross Profit Margin": "grossProfitMargin", "Receivables Turnover": "receivablesTurnover", "Payout Ratio": "payoutRatio", "Interest Coverage": "interestCoverage", "Short Term Coverage Ratios": "shortTermCoverageRatios", "Net Profit Margin": "netProfitMargin", "Dividend Payout Ratio": "dividendPayoutRatio", "Enterprise Value Multiple": "enterpriseValueMultiple", "Quick Ratio": "quickRatio", "Price Fair Value": "priceFairValue", "Price To Operating Cash Flows Ratio": "priceToOperatingCashFlowsRatio", "Ebt Per Ebit": "ebtPerEbit", "Company Equity Multiplier": "companyEquityMultiplier", "Dividend Paid And Capex Coverage Ratio": "dividendPaidAndCapexCoverageRatio", "Cash Ratio": "cashRatio", "Cash Per Share": "cashPerShare", "Price Book Value Ratio": "priceBookValueRatio", "Debt Equity Ratio": "debtEquityRatio", "Net Income Per EBT": "netIncomePerEBT", "Long Term Debt To Capitalization": "longTermDebtToCapitalization", "Price To Free Cash Flows Ratio": "priceToFreeCashFlowsRatio", "Operating Cash Flow Per Share": "operatingCashFlowPerShare", "Capital Expenditure Coverage Ratio": "capitalExpenditureCoverageRatio", "Price Cash Flow Ratio": "priceCashFlowRatio", "Return On Capital Employed": "returnOnCapitalEmployed", "Cash Flow Coverage Ratios": "cashFlowCoverageRatios", "Cash Conversion Cycle": "cashConversionCycle", "Current Ratio": "currentRatio", "Days Of Payables Outstanding": "daysOfPayablesOutstanding", "Days Of Inventory Outstanding": "daysOfInventoryOutstanding", "Price Sales Ratio": "priceSalesRatio", "Effective Tax Rate": "effectiveTaxRate", "Fixed Asset Turnover": "fixedAssetTurnover", "Payables Turnover": "payablesTurnover", "Price To Book Ratio": "priceToBookRatio", "Asset Turnover": "assetTurnover"]
    
    let ratioNamesArray = ["Long Term Debt To Capitalization", "Days Of Inventory Outstanding", "Price Sales Ratio", "Net Profit Margin", "Price Fair Value", "Effective Tax Rate", "Operating Cycle", "Days Of Sales Outstanding", "Dividend Yield", "Return On Capital Employed", "Fixed Asset Turnover", "Price To Free Cash Flows Ratio", "Interest Coverage", "Operating Profit Margin", "Cash Per Share", "Enterprise Value Multiple", "Current Ratio", "Total Debt To Capitalization", "Capital Expenditure Coverage Ratio", "Payables Turnover", "Gross Profit Margin", "Asset Turnover", "Operating Cash Flow Sales Ratio", "Price Cash Flow Ratio", "Price To Sales Ratio", "Debt Ratio", "Dividend Paid And Capex Coverage Ratio", "Dividend Payout Ratio", "Pretax Profit Margin", "Free Cash Flow Operating Cash Flow Ratio", "Receivables Turnover", "Return On Assets", "Quick Ratio", "Company Equity Multiplier", "Price To Book Ratio", "Price Earnings To Growth Ratio", "Short Term Coverage Ratios", "Ebt Per Ebit", "Free Cash Flow Per Share", "Inventory Turnover", "Ebit Per Revenue", "Price Book Value Ratio", "Cash Flow Coverage Ratios", "Cash Flow To Debt Ratio", "Price To Operating Cash Flows Ratio", "Days Of Payables Outstanding", "Net Income Per EBT", "Cash Conversion Cycle", "Cash Ratio", "Payout Ratio", "Price Earnings Ratio", "Debt Equity Ratio", "Operating Cash Flow Per Share", "Return On Equity"]
    
    var ticker = String()
    
    var userSelectedRatios = [String]()
    
    //Main API array
    //All raw data grabbed directly from API is appended to this object
    var ratioArray = [YearlyRatiosFeed]()
    
    //Static array - holding user selected financial ratios
    //Static since it has to be accessed from other classes inside this viewController
    //Needed for populating data in combinedGraph, collectionView and tableView
    static var selectedRatios: [String] =
        ["Days Of Inventory Outstanding", "Net Profit Margin", "Effective Tax Rate", "Fixed Asset Turnover"] //"Net Profit Margin"
    
    //For tableView
    var tableViewData: Array? = [[String]()]
    var historyData = [[String]()]
    
    //For collectionView
    var collectionViewData = [String]()
    
    //Subview outlets + variables
    //@IBOutlet weak var latestRatiosCollectionView: UICollectionView!
    
    @IBOutlet weak var historyCollectionView: UICollectionView!
    
    @IBOutlet weak var historicalRatiosTableView: UITableView!
    @IBOutlet weak var combinedChartView: CombinedChartView!
    @IBOutlet weak var topLabel: UILabel!
    var filterView = UIView()
    var filterCollectionView: UICollectionView?
    let filterTableViewHeight: CGFloat = (UIScreen.main.bounds.size.height * 0.65)
    
    //@IBOutlet var testCollectionView: UICollectionView!
    
    //Constraint height outlets
    //Outlets for mainView and tableView height constraints, which are manipulated depending on the acquired data size from API in order to fit the scrollView
    //The value of the constraints are changed after the tableView has been populated with the relevant data in the method called "prepareTableAndCollectionViewData"
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    //@IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    //@IBOutlet weak var chartHeight: NSLayoutConstraint!
    
    @IBAction func closePopUp(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func filterRatios(_ sender: Any) {
        let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first //This line gets us the whole window view, including the navigation bar on the underlying window
        filterView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        filterView.frame = self.view.frame
        window?.addSubview(filterView)
                
        let screenSize = UIScreen.main.bounds.size
        
        window?.addSubview(filterCollectionView!)
        filterCollectionView?.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: filterTableViewHeight)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(getFilterView))
        filterView.addGestureRecognizer(gestureRecognizer)
        filterView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 1.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: { [self] in
            self.filterView.alpha = 0.7
            self.filterCollectionView?.frame = CGRect(x: 0, y: screenSize.height-self.filterTableViewHeight, width: screenSize.width, height: self.filterTableViewHeight)
        }, completion: nil)
    }
    
    @objc func getFilterView() {
        let ratioURL = getRatioLink(period: "Y", historicalPeriods: 10)
        apiRequest(urlString: ratioURL)
        
        //historicalRatiosTableView.register(customHistoricalCell.self, forCellReuseIdentifier: "customCellOne")
        
        let screenSize = UIScreen.main.bounds.size
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: { [self] in
            self.filterView.alpha = 0
            self.filterCollectionView?.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.filterTableViewHeight)
        }, completion: nil)
    }
    
    func userSelectedRatios(allRatios: Array<YearlyRatiosFeed>, selectedRatios: Array<String> /*,period: Int*/){
        
        var selectedRatiosDict = [String(): [Float()]]
        selectedRatiosDict.removeAll()
                
        var collectedData = [[Float]()]
        
        for selectedRatio in selectedRatios{
            var historicalRatios = [Float]()
            for periodRatios in allRatios {
                let mirror = Mirror(reflecting: periodRatios)
                for (k,v) in ratioDict {
                    if selectedRatio == k {
                        for child in mirror.children {
                            if v == child.label {
                                if let ratio = child.value as? Float {
                                    //print("\(selectedRatio)")
                                    //print("\(periodRatios.date): \(ratio)")
                                    historicalRatios.append(ratio)
                                }
                            }
                        }
                    }
                }
                selectedRatiosDict[selectedRatio] = historicalRatios.reversed()
                collectedData.append(historicalRatios.reversed())
            }
        }
        populateChart(selectedRatiosDict: selectedRatiosDict, chart: combinedChartView)
    }
    
    
    func prepareTableAndCollectionViewData(selectedRatios: Array<String>, allRatios: Array<YearlyRatiosFeed>) {
        
        tableViewData = []
        historyData.removeAll()
        historicalRatiosTableView.reloadData()
        
        var count = 0
        for periodRatios in allRatios {
            var index = 0
            var periodValues = [String]()
            for selectedRatio in selectedRatios{
                let mirror = Mirror(reflecting: periodRatios)
                for (k,v) in ratioDict {
                    if selectedRatio == k {
                        for child in mirror.children {
                            if v == child.label { //if true, we have found our ratio! e.g. "net profit margin"
                                if let ratio = child.value as? Float {
                                    let strValue = (String(format: "%.3f", ratio))
                                    periodValues.append(strValue)
                                }
                            }
                        }
                    }
                }
                index += 1
            }
            if count == 0 {
                collectionViewData = periodValues
                //latestRatiosCollectionView.reloadData()
                count += 1
            }
            
            if index == selectedRatios.count && selectedRatios.count != 0{
                tableViewData?.append(periodValues)
                historyData.append(periodValues)
            }
            print("HEEEEEJ")
            print(historyData)
        }
        
        if selectedRatios.count != 0 {
            historicalRatiosTableView.reloadData()
            historyCollectionView.reloadData()
            let extraSpaces = CGFloat(79 + 20 + 20 + 324)
            let totalHeight = historicalRatiosTableView.contentSize.height + 80//latestRatiosCollectionView.contentSize.height
            viewHeight.constant = CGFloat(totalHeight + extraSpaces)
            tableViewHeight.constant = CGFloat(historicalRatiosTableView.contentSize.height)
        }
    }
    
    
    func getRatioLink(period: String, historicalPeriods: Int) -> String {
        var ratioLink = ""
        if period == "Q" {
            ratioLink = "https://financialmodelingprep.com/api/v3/ratios/\(self.ticker)?period=quarter&limit=\(historicalPeriods)&apikey=\(apiKey)"
        } else if period == "Y" {
            ratioLink = "https://financialmodelingprep.com/api/v3/ratios/\(ticker)?limit=\(historicalPeriods)&apikey=\(apiKey)"
        }
        
        return ratioLink
    }
    
    
    func apiRequest(urlString: String){
        self.ratioArray.removeAll()
        
        let url = URL(string: urlString)
        
        guard  url != nil else {
            return
        }
        
        let session = URLSession.shared
        
        
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                do {
                    let ratioFeed = try decoder.decode([YearlyRatiosFeed].self, from: data!)
                    
                    for periodRatios in ratioFeed {
                        self.ratioArray.append(periodRatios)
                        //self.createRatioArrayAndDict(val: periodRatios)
                    }
                    
                    DispatchQueue.main.async {
                        self.userSelectedRatios(allRatios: ratioFeed, selectedRatios: CustomRatioAnalysisViewController.self.selectedRatios)
                        self.prepareTableAndCollectionViewData(selectedRatios: CustomRatioAnalysisViewController.selectedRatios, allRatios: self.ratioArray)
                        
                    }
                }
                
                catch {
                    print("Error in JSON parsing")
                }
            }
        }
        dataTask.resume()
    }
    
    
    func lineOrBarChart(selectedRatiosDict: Dictionary<String, Array<Float>>) -> (Array<String>, Array<String>) {
        var ratioNames = [String]()
        var charts = [String]()
        
        if selectedRatiosDict.count != 0 {
            
            //Step 1 - Calculate the means of each ratios historical values
            var ratioMeans = [Float]()
            var meanDict = [String() : Float()]
            meanDict.removeAll()
            
            for (key,val) in selectedRatiosDict {
                let value = (val.reduce(0, +))
                let mean = Float(value / Float(val.count))
                
                ratioMeans.append(mean)
                meanDict["\(key)"] = mean
            }
            
            //Step 2 - Calculate the means proportios in comparison with the greatest mean
            let maxNumber = ratioMeans.max()
            var proportionsDict = [String():Float()]
            proportionsDict.removeAll()
            
            for (k,v) in meanDict {
                let proportionOfMax = Float(v/maxNumber!)
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
    
    
    func populateChart(selectedRatiosDict: Dictionary<String, Array<Float>>, chart: CombinedChartView){
        
        if selectedRatiosDict.count != 0 {
            
            let chartsForRatios = self.lineOrBarChart(selectedRatiosDict: selectedRatiosDict)
            let ratioNames = chartsForRatios.0
            let ratioChart = chartsForRatios.1
            
            var groupedBarDataSet : [BarChartDataSet] = [BarChartDataSet]()
            let groupedBarChartData = BarChartData(dataSets: groupedBarDataSet)
            
            var groupedLineDataSet : [LineChartDataSet] = [LineChartDataSet]()
            let groupedLineChartData = LineChartData(dataSets: groupedLineDataSet)
            
            var countBarCharts = 0
            var countLineCharts = 0
            
            
            let combinedData : CombinedChartData = CombinedChartData()
            
            var barWidth = Double()
            let groupSpace = (0.1)
            let barSpace = (0.02)
            
            for i in ratioChart {
                if i == "B" {
                    countBarCharts += 1
                    //Set width, spacing, etc. for the groupedBarChart
                    //(barWidth + barSpace) * (no.of.bars per group) + groupSpace = 1.00 -> interval per "group"
                    
                    let denominator = Double(countBarCharts)
                    barWidth = ((1.0-groupSpace)/denominator)-barSpace
                    
                    //print("Next LINE should be equal to 1!")
                    //print((barSpace+barWidth)*denominator+groupSpace)
                } else {
                    countLineCharts += 1
                }
            }
            
            let colorOne = UIColor.orange
            let colorTwo = UIColor(red: 1.00, green: 0.44, blue: 0.38, alpha: 1.00)
            let colorThree = UIColor(red: 0.77, green: 0.16, blue: 0.61, alpha: 1.00)
            let colorFour = UIColor(red: 0.96, green: 0.92, blue: 0.48, alpha: 1.00)
            let colorFive = UIColor(red: 1.00, green: 0.68, blue: 0.32, alpha: 1.00)
            
            let colorLineArray = [colorOne, colorTwo, colorThree, colorFour, colorFive]
            
            let colorBarOne = UIColor(red: 0.59, green: 0.31, blue: 0.76, alpha: 1.00)
            let colorBarTwo = UIColor(red: 0.23, green: 0.12, blue: 0.30, alpha: 1.00)
            let colorBarThree = UIColor(red: 0.31, green: 0.00, blue: 0.50, alpha: 1.00)
            let colorBarFour = UIColor(red: 0.53, green: 0.05, blue: 0.82, alpha: 1.00)
            let colorBarFive = UIColor(red: 0.62, green: 0.00, blue: 1.00, alpha: 1.00)
            
            let colorBarArray = [colorBarOne, colorBarTwo, colorBarThree, colorBarFour, colorBarFive]
            var indexBar = 0
            var indexLine = 0
                        
            for (k,v) in selectedRatiosDict{
                if let found = ratioNames.firstIndex(of: "\(k)") {
                    let chartType = ratioChart[found]
                    if chartType == "B"{
                        //1. Create dataEntries
                        var dataEntry = [BarChartDataEntry]()
                        
                        //2. Append values to the dataEntry
                        var count = 0
                        for value in v {
                            dataEntry.append(BarChartDataEntry(x: Double(count), y: Double(value)))
                            count += 1
                        }
                        
                        //3. Create dataSet
                        let set = BarChartDataSet(entries: dataEntry, label: "\(k)")
                        set.axisDependency = .left
                        set.colors = [colorBarArray[indexBar]]
                        set.valueColors = [UIColor.label]
                        set.drawValuesEnabled = false
                        
                        //4. Create grouped dataSet + grouped data
                        groupedBarDataSet.append(set)
                        groupedBarChartData.dataSets = groupedBarDataSet
                        
                        indexBar += 1
                        
                    } else if chartType == "L"{
                        var dataEntry = [ChartDataEntry]()
                        
                        //2. Append values to the dataEntry
                        var count = 0
                        for value in v {
                            dataEntry.append(ChartDataEntry(x: Double(count) + barWidth + groupSpace, y: Double(value)))
                            count += 1
                        }
                        
                        //3. Create dataSet
                        let set = LineChartDataSet(entries: dataEntry, label: "\(k)")
                        set.drawHorizontalHighlightIndicatorEnabled = false
                        let color = colorLineArray[indexLine]
                        set.axisDependency = .right
                        set.colors = [color]
                        set.circleColors = [color]
                        set.circleHoleColor = .label
                        set.circleRadius = 6
                        set.valueColors = [.label]
                        set.mode = .cubicBezier
                        
                        //4. Create grouped dataSet + grouped data
                        groupedLineDataSet.append(set)
                        groupedLineChartData.dataSets = groupedLineDataSet
                        combinedData.lineData = groupedLineChartData
                        
                        indexLine += 1
                    }
                }
            }
            
            groupedBarChartData.barWidth = Double(barWidth)
            groupedBarChartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
            combinedData.barData = groupedBarChartData
            chart.xAxis.axisMinimum = 0 //Makes grouped bar chart data correctly displayed (on top of the upper lines)
            chart.xAxis.axisMaximum = Double(10)
            chart.data = combinedData
            chart.animate(yAxisDuration: 1.0, easingOption: .easeInOutQuart)
            
            //Editing the chart generally
            //chart.animate(yAxisDuration: 1, easingOption: .easeInOutQuart)
            chart.pinchZoomEnabled = false //remove pinch zoom
            chart.setScaleEnabled(false) //removes all zoom/scaling
            
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
    
    func prepareFilterCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.main.bounds.size.width
        
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: screenWidth - 30, height: 44)
        
        //CollectionView customization
        filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        filterCollectionView?.delegate = self
        filterCollectionView?.dataSource = self
        filterCollectionView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        filterCollectionView?.layer.cornerRadius = 20
        filterCollectionView?.backgroundColor = .tertiarySystemBackground
        filterCollectionView?.allowsMultipleSelection = true
        filterCollectionView?.register(customFilterCell.self, forCellWithReuseIdentifier: "customFilterCell")
    }

    /*
    func prepareTestCollectionView() {
        testCollectionView.delegate = self
        testCollectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.main.bounds.size.width
        
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: screenWidth - 30, height: 44)
        
        testCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        testCollectionView.register(customTestCell.self, forCellWithReuseIdentifier: "test")
    }
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ratioURL = getRatioLink(period: "Y", historicalPeriods: 10)
        apiRequest(urlString: ratioURL)
        historicalRatiosTableView.register(customHistoricalCell.self, forCellReuseIdentifier: "customCellOne")
        
        historyCollectionView.register(HistoryCollectionViewCell.self, forCellWithReuseIdentifier: "historyCell")
        
        prepareFilterCollectionView()
        
        //historyCollectionView.isHidden = true
        
        //prepareTestCollectionView()
    }
}

class customFilterCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var isSelected: Bool {
        didSet{
            if self.isSelected {
                selectionImage.image = UIImage(named: "checkMark.png")
        } else {
                selectionImage.image = UIImage(named: "checkMarkBorder.png")
            }
        }
    }
    
    
    let screenSize = UIScreen.main.bounds.size
    let cellHeight: CGFloat = 44
    let imgWidth: CGFloat = 25
    let imgHeight: CGFloat = 25
    
    var ratioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 11)
        label.text = "CustomCell"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    var selectionImage: UIImageView = {
        let imgView = UIImageView()
        return imgView
    }()
    
    func setUpViews() {
        ratioLabel.frame = CGRect(x: 20, y: 0, width: screenSize.width - 40, height: cellHeight)
        self.addSubview(ratioLabel)
        
        
        let y = (cellHeight-imgHeight)/2
        selectionImage.frame = CGRect(x: screenSize.width-45, y: y, width: imgWidth, height: imgHeight)
        selectionImage.image = UIImage(named: "checkMarkBorder.png")
        self.addSubview(selectionImage)
        
    }
}

/*
class customTestCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let screenSize = UIScreen.main.bounds.size
    let cellHeight: CGFloat = 44
    let imgWidth: CGFloat = 25
    let imgHeight: CGFloat = 25
    
    var ratioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 11)
        label.text = "CustomCell"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    func setUpViews() {
        ratioLabel.frame = CGRect(x: 20, y: 0, width: screenSize.width - 40, height: cellHeight)
        self.addSubview(ratioLabel)
    }
}
 */


extension CustomRatioAnalysisViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == historyCollectionView {
            return tableViewData!.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == historyCollectionView{//latestRatiosCollectionView {
            return 4
            //return collectionViewData.count
        }
        return ratioNamesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat
        let height: CGFloat
        
        
        if collectionView == historyCollectionView {
            width = (UIScreen.main.bounds.size.width - 40)/4
            height = 30
            //return CGSize(width: width, height: height)
        } else {
            width = UIScreen.main.bounds.size.width
            height = 44
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == historyCollectionView{ //latestRatiosCollectionView {
            let cell = historyCollectionView.dequeueReusableCell(withReuseIdentifier: "historyCell", for: indexPath) as? HistoryCollectionViewCell
                        
            //let cell = latestRatiosCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? LatestRatioCollectionViewCell
            
            cell?.layer.cornerRadius = 10
            //cell?.layer.backgroundColor = UIColor.red.cgColor
            
            if tableViewData?.count != 0 {
                //print(tableViewData)
                
                let data = tableViewData![indexPath.section]
                if data.count != 0 {
                    cell?.label.text = "\(data[indexPath.row])"
                }
                print(indexPath.row)
                print(data)
                //cell?.label.text = "\(data[indexPath.row])"
            }
            
            //cell?.nameRatio.text = "\(CustomRatioAnalysisViewController.selectedRatios[indexPath.row])"
            
            //let count = Int(CustomRatioAnalysisViewController.selectedRatios.count)
            
            /*
            if collectionViewData.count != 0 {
                cell?.valueRatio.text = collectionViewData[indexPath.row]
            }
            */
            return cell!
        }
        
        let cell = filterCollectionView!.dequeueReusableCell(withReuseIdentifier: "customFilterCell", for: indexPath) as? customFilterCell
        cell!.ratioLabel.text = "\(ratioNamesArray[indexPath.row])"
        
        return cell!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == filterCollectionView {
            let cell = filterCollectionView!.dequeueReusableCell(withReuseIdentifier: "customFilterCell", for: indexPath) as? customFilterCell
            cell!.isSelected = true
            CustomRatioAnalysisViewController.selectedRatios.append(ratioNamesArray[indexPath.row]) //Append the selected ratios to the selectedRatios array
            print(CustomRatioAnalysisViewController.selectedRatios)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == filterCollectionView {
            CustomRatioAnalysisViewController.selectedRatios = CustomRatioAnalysisViewController.selectedRatios.filter() {
                $0 != "\(ratioNamesArray[indexPath.row])" //remove element from array
            }
            print(CustomRatioAnalysisViewController.selectedRatios)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return filterCollectionView!.indexPathsForSelectedItems!.count <= Int(4)
    }
}

class customHistoricalCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        setUpViews()
        
        labelArray = [ratioLabelOne, ratioLabelTwo, ratioLabelThree, ratioLabelFour, ratioLabelFive]
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var labelArray = [UILabel]()
    
    let imgViewHeight : CGFloat = 26
    let imgViewWidth : CGFloat = 26
    
    let lblViewHeight : CGFloat = 20
    let lblViewWidth : CGFloat = 120
    
    let cellHeight : CGFloat = 110
        
    var ratioLabelOne: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 11)
        label.text = "CustomCell"
        label.numberOfLines = 0
        return label
    }()
    
    var ratioLabelTwo: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 11)
        label.text = "CustomCell"
        label.numberOfLines = 0
        return label
    }()
    
    var ratioLabelThree: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 11)
        label.text = "CustomCell"
        label.numberOfLines = 0
        return label
    }()
    
    var ratioLabelFour: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 11)
        label.text = "CustomCell"
        label.numberOfLines = 0
        return label
    }()
    
    var ratioLabelFive: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 11)
        label.text = "CustomCell"
        label.numberOfLines = 0
        return label
    }()
        
    func setUpViews() {
        backgroundColor = UIColor.clear
                
        //UILabel
        let width = Int(UIScreen.main.bounds.width)
        
        let spacing = 20
        let ratiosCount = Int(CustomRatioAnalysisViewController.selectedRatios.count)
        var lblWidth = Int()
        
        if ratiosCount != 0 {
            lblWidth = (width-((ratiosCount+1)*spacing))/ratiosCount
        } else {
            lblWidth = (width-(2*spacing))
        }
        
        let allLabels = [ratioLabelOne, ratioLabelTwo, ratioLabelThree, ratioLabelFour, ratioLabelFive]
        
        for i in allLabels {
            i.removeFromSuperview()
        }
        
        for i in 0..<ratiosCount {
            let ratioLabel = allLabels[i]
            
            let lblHeight = 10
            let accumulatedSpacing = spacing*(i+1)
            let accumulatedlblWidth = lblWidth*i
            let xStart = accumulatedlblWidth + accumulatedSpacing
            let yStart = 10
            let frame = CGRect(x: xStart, y: yStart, width: lblWidth, height: lblHeight)
            ratioLabel.frame = frame
            ratioLabel.text = "n/A"
            addSubview(ratioLabel)
        }
    }
    
}


extension CustomRatioAnalysisViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        historicalRatiosTableView.reloadData()
    }
    */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        historicalRatiosTableView.reloadRows(at: [indexPath], with: .none)
        
        let cell = historicalRatiosTableView.dequeueReusableCell(withIdentifier: "customCellOne", for: indexPath) as? customHistoricalCell
                        
        let width = Int(historicalRatiosTableView.contentSize.width)
        
        let labels = [cell?.ratioLabelOne, cell?.ratioLabelTwo, cell?.ratioLabelThree, cell?.ratioLabelFour, cell?.ratioLabelFive]
        
        if tableViewData?.count != 0 {
            let rowData = tableViewData![indexPath.row] 
            for i in 0..<(rowData.count) {
                var label = labels[i]
                label!.text = rowData[i]
            }
        }
        return cell!
    }
    
    
    func createAbbreviation(word: String) -> String {
        var abbreviation = String()
        for letter in word {
            if letter.isUppercase == true {
                abbreviation += String(letter)
            }
        }
        return abbreviation
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let width = Int(historicalRatiosTableView.contentSize.width)
        
        let headerHeight = 90
        
        let headerView = UIView(frame: (CGRect(x: 0, y: 0, width: width, height: headerHeight)))
        
        let topLine = UIView()
        topLine.backgroundColor = UIColor(red: 0.59, green: 0.31, blue: 0.76, alpha: 1.00)
        topLine.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        topLine.frame = CGRect(x: 20, y: 0, width: width-40, height: 6)
        headerView.backgroundColor = .clear
        headerView.addSubview(topLine)

        let headerLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 250, height: 15))
        headerLabel.text = "HISTORICAL VALUES"
        headerLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        headerView.addSubview(headerLabel)

        let bottomLine = UIView()
        bottomLine.backgroundColor = .lightGray
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        bottomLine.frame = CGRect(x: 20, y: 89, width: width-40, height: 1)
        headerView.addSubview(bottomLine)
        
        let spacing = 20
        let ratiosCount = Int(CustomRatioAnalysisViewController.selectedRatios.count)
        var lblWidth = Int()
        
        if ratiosCount != 0 {
            lblWidth = (width-((ratiosCount+1)*spacing))/ratiosCount
        } else {
            lblWidth = (width-(2*spacing))
        }
        
        for i in 0..<ratiosCount {
            let label = UILabel()
            
            let lblHeight = 15
            let accumulatedSpacing = spacing*(i+1)
            let accumulatedlblWidth = lblWidth*i
            let xStart = accumulatedlblWidth + accumulatedSpacing
            let yStart = 60
            let frame = CGRect(x: xStart, y: yStart, width: lblWidth, height: lblHeight)
            
            label.frame = frame
            label.font = UIFont(name: "HelveticaNeue", size: 11)
            label.textAlignment = .center
            label.numberOfLines = 0
                        
            let nameLbl = createAbbreviation(word: CustomRatioAnalysisViewController.selectedRatios[i])
            label.text = nameLbl
            headerView.addSubview(label)
        }
        
        return headerView
    }
}
