//
//  DetailsViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2020-03-16.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit
import Charts
import Firebase
import Lottie

protocol reportTypeSelectionDelegate {
    func didTapType(type: String)
}

class DetailsViewController: UIViewController {
    
    //Bra sida för översättning av nyckeltal till engelska
    //https://www.ekonomikurser.se/ordbok/amneneng2.asp?valdterm=Internal%20financing%20rate&amne=Nyckeltal&sokord=E
    
    private let database = Database.database().reference()
    
    var followAnimation: AnimationView?
    
    let valuation = ["priceBookValueRatio", "priceToBookRatio", "priceToSalesRatio", "priceEarningsRatio", "priceToFreeCashFlowsRatio", "priceToOperatingCashFlowsRatio", "priceCashFlowRatio", "priceEarningsToGrowthRatio", "priceSalesRatio", "enterpriseValueMultiple"]
    
    let capitalStrenght = ["interestCoverage", "debtRatio", "debtEquityRatio", "longTermDebtToCapitalization", "totalDebtToCapitalization"]
    
    let liquidity = ["Quick ratio", "currentRatio", "daysOfSalesOutstanding", "operatingCashFlowSalesRatio"]
    
    let profitability = ["returnOnAssets", "returnOnEquity", "returnOnCapitalEmployed", "grossProfitMargin", "operatingProfitMargin", "pretaxProfitMargin", "netProfitMargin"]
    
    let ratioCategories = ["VALUATION", "LEVERAGE", "LIQUIDITY", "PROFITABILITY"]
    
    struct cleanRatios {
        var ratio: String?
        var dates: Array<String?>?
        var period: Array<String?>?
        var historicalValues: Array<Double?>?
        
        public func getHigh() -> String {
            if let high = historicalValues!.max(by: {
                let first = $0 ?? 0
                let second = $1 ?? 0
                return first < second
            }) {
                if let highValue = high {
                    return String(format: "%.2f", highValue)
                }
            }
            return ""
        }
        
        public func getLow() -> String {
            if let low = historicalValues!.min(by: {
                let first = $0 ?? 0
                let second = $1 ?? 0
                return first < second
            }) {
                if let lowValue = low {
                    return String(format: "%.2f", lowValue)
                }
            }
            return ""
        }
        
        public func getAverage() -> String {
            var sum: Double = 0
            var count: Double = 0
            
            if let history = historicalValues {
                count = Double(history.count)
                for i in history {
                    if let value = i {
                        sum += value
                    }
                }
            }
            
            let avg = String(format: "%.2f", sum/count)
            return avg
        }
    }
    
    var sortedRatios: [cleanRatios] = []
    
    let dispatchGroup = DispatchGroup()
       
    var typeSelectionDelegate: reportTypeSelectionDelegate!

    var datesArray = [String]()
    var closingPrices = [Double]()
    var timePeriodURL = ""
    let keysNumbers = ["price", "beta", "volAvg"]
    let keysStrings = ["country", "symbol", "industry", "sector", "website", "companyName"]
    let allKeys = ["Beta", "Vol. Avg.", "Country", "Symbol", "Industry", "Sector", "Website"]
    var profileInformation: [CompanyProfileFeed] = []
    var companyDescription = [String]()
    

    var collectionViewIsExpanded: Bool = false
    var collectionViewIsExpandedTag: Int = 0
    var testHeight: CGFloat = 0

    var ticker = String()

    //Part 2 (CollectionView)
    @IBOutlet weak var overviewCollectionView: UICollectionView!

    let stockPriceData = LineChartData()
    var dashboardRatios = [RatiosDashboardFeed]()

    //Financial Statements Arrays
    var reportPeriod = "Y"
    var reportType = "I"
    
    var incomeStatementArray = [incomeStatement]()
    var balanceSheetArray = [balanceSheetStatement]()
    var cashFlowArray = [cashFlowStatement]()

    var incomeStatementDataEntries = [[BarChartDataEntry]()]
    var statementItems = [String]()

    let sectionHeaders = ["", "", "", "", "About Company", "Company Insights", "Financials" /*, ""*/,"Financial Ratios & Metrics", "Calendar"]
    var TTMRatiosDashboard = [String]()
    let overviewButtons = ["Key executives", "Financial data & reports", "Press releases", "SEC reports", "Institutional holders"]
    let overviewSubtitles = ["Get to know the key people behind the company.", "Historical data, ratios and earnings reports.", "Check out the latest press releases.", "Insider trading and other SEC files.", "Institutional ownership in the company."]
    let icons = ["icons8-key-29-2", /*"icons8-combo-chart-29"*/"icons8-business-report-29", "icons8-news-29", "icons8-graph-report-29", "icons8-rent-29-2"]

    var incomeStatementData = (Array<Array<BarChartDataEntry>>, Int).self

    var customRatioDict = [String(): [Double]()]
    var selectedRatios = ["Price Cash Flow Ratio", "Return On Equity", "Gross Profit Margin", "Debt Equity Ratio"]
    let ratioDict = ["Days Of Sales Outstanding": "daysOfSalesOutstanding", "Operating Profit Margin": "operatingProfitMargin", "Dividend Yield": "dividendYield", "Price To Sales Ratio": "priceToSalesRatio", "Inventory Turnover": "inventoryTurnover", "Price Earnings To Growth Ratio": "priceEarningsToGrowthRatio", "Cash Flow To Debt Ratio": "cashFlowToDebtRatio", "Debt Ratio": "debtRatio", "Ebit Per Revenue": "ebitPerRevenue", "Operating Cash Flow Sales Ratio": "operatingCashFlowSalesRatio", "Price Earnings Ratio": "priceEarningsRatio", "Free Cash Flow Operating Cash Flow Ratio": "freeCashFlowOperatingCashFlowRatio", "Return On Assets": "returnOnAssets", "Free Cash Flow Per Share": "freeCashFlowPerShare", "Return On Equity": "returnOnEquity", "Total Debt To Capitalization": "totalDebtToCapitalization", "Operating Cycle": "operatingCycle", "Pretax Profit Margin": "pretaxProfitMargin", "Gross Profit Margin": "grossProfitMargin", "Receivables Turnover": "receivablesTurnover", "Payout Ratio": "payoutRatio", "Interest Coverage": "interestCoverage", "Short Term Coverage Ratios": "shortTermCoverageRatios", "Net Profit Margin": "netProfitMargin", "Dividend Payout Ratio": "dividendPayoutRatio", "Enterprise Value Multiple": "enterpriseValueMultiple", "Quick Ratio": "quickRatio", "Price Fair Value": "priceFairValue", "Price To Operating Cash Flows Ratio": "priceToOperatingCashFlowsRatio", "Ebt Per Ebit": "ebtPerEbit", "Company Equity Multiplier": "companyEquityMultiplier", "Dividend Paid And Capex Coverage Ratio": "dividendPaidAndCapexCoverageRatio", "Cash Ratio": "cashRatio", "Cash Per Share": "cashPerShare", "Price Book Value Ratio": "priceBookValueRatio", "Debt Equity Ratio": "debtEquityRatio", "Net Income Per EBT": "netIncomePerEBT", "Long Term Debt To Capitalization": "longTermDebtToCapitalization", "Price To Free Cash Flows Ratio": "priceToFreeCashFlowsRatio", "Operating Cash Flow Per Share": "operatingCashFlowPerShare", "Capital Expenditure Coverage Ratio": "capitalExpenditureCoverageRatio", "Price Cash Flow Ratio": "priceCashFlowRatio", "Return On Capital Employed": "returnOnCapitalEmployed", "Cash Flow Coverage Ratios": "cashFlowCoverageRatios", "Cash Conversion Cycle": "cashConversionCycle", "Current Ratio": "currentRatio", "Days Of Payables Outstanding": "daysOfPayablesOutstanding", "Days Of Inventory Outstanding": "daysOfInventoryOutstanding", "Price Sales Ratio": "priceSalesRatio", "Effective Tax Rate": "effectiveTaxRate", "Fixed Asset Turnover": "fixedAssetTurnover", "Payables Turnover": "payablesTurnover", "Price To Book Ratio": "priceToBookRatio", "Asset Turnover": "assetTurnover"]

    /*
    //For "about company"
    private lazy var boardManager: BLTNItemManager = {
       let item = BLTNPageItem(title: "About Company")
       let font = UIFont(name: "HelveticaNeue", size: 12)
       let attributes = [NSAttributedString.Key.font: font]
       
       if companyDescription.count != 0{
           item.attributedDescriptionText = NSAttributedString(string: companyDescription[0], attributes: attributes)
       }
       
       return BLTNItemManager(rootItem: item)
    }()
    */
    
    private func concurrentAPICall() {
        //Get company stock
        //timePeriodURL = "https://financialmodelingprep.com/api/v3/historical-chart/5min/\(ticker)?apikey=\(apiKey)"
        //getPrice(urlString: timePeriodURL, days: 90)
        
        //Get company profile
        let profileLink = "https://financialmodelingprep.com/api/v3/profile/\(ticker)?apikey=\(apiKey)"
        getCompanyProfile(urlString: profileLink)
        
        //TTMRatios Dashboard
        //let TTMRatiosLink = "https://financialmodelingprep.com/api/v3/ratios-ttm/\(ticker)?apikey=\(apiKey)"
        //getDashboardRatios(urlString: TTMRatiosLink, type: "I")
        
        //Custom Historical Ratios
        let historicalratiosLink = "https://financialmodelingprep.com/api/v3/ratios/\(ticker)?period=quarter&limit=40&apikey=\(apiKey)"
        getCustomRatios(urlString: historicalratiosLink)
        
        let test = "https://financialmodelingprep.com/api/v3/income-statement/\(ticker)?limit=10&apikey=\(apiKey)"
        financialStatement(urlString: test)
        
        dispatchGroup.notify(queue: .main) {
            self.overviewCollectionView.reloadData()
        }
    }


    func getCompanyProfile(urlString : String) {
        profileInformation.removeAll()

        dispatchGroup.enter()
        let url = URL(string: urlString)

        guard url != nil else {
            return
        }

        let session = URLSession.shared

        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                do {
                    let profileFeed = try decoder.decode([CompanyProfileFeed].self, from: data!)

                    var profile = [String]()
                    var companyDescStr = String()

                    self.profileInformation = profileFeed

                    for data in profileFeed {

                        if let beta = data.beta, let volAvg = data.volAvg, let country = data.country, let sym = data.symbol, let ind = data.industry, let sec = data.sector, let companyDesc = data.description {
                            profile.append(String(beta))
                            profile.append(String(volAvg))
                            profile.append(String(country))
                            profile.append(String(sym))
                            profile.append(String(ind))
                            profile.append(String(sec))

                            companyDescStr = companyDesc
                        }
                    }
                    self.companyDescription.append(companyDescStr)
                    self.dispatchGroup.leave()
                    
                }

                catch {
                    print("Error in JSON parsing")
                    self.dispatchGroup.leave()
                }
            }
        }
        dataTask.resume()
    }
    

    func lineChart(prices : Array<Double>) {
        var entry = [ChartDataEntry]()

        for count in 0..<prices.count {
            let price = prices.reversed()[count]
            let value = ChartDataEntry(x: Double(count) , y: price /*data: datesArray*/)
            entry.append(value)
        }

        //--------- Creating linechartdataset for closing prices of stock
        let linePrices = LineChartDataSet(entry)
        //linePrices.fill = Fill(color: UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.0))
        //linePrices.fillAlpha = 0.3
        //linePrices.drawFilledEnabled = true
        //linePrices.fillColor = UIColor(red:0.03, green:0.04, blue:0.32, alpha:1.00)
        linePrices.drawHorizontalHighlightIndicatorEnabled = false //remove horizontal highlighter line
        linePrices.highlightColor = .white
        linePrices.mode = .cubicBezier
        linePrices.colors = [UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00)]
        linePrices.drawCirclesEnabled = false

        //let data = LineChartData(dataSets: [linePrices])
        let data = stockPriceData
        data.dataSets = [linePrices]
        data.setDrawValues(false)
    }
    

    func convertStringDateTimeToStringDate(date: String) -> String {
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

       let secondDateFormatter = DateFormatter()
       secondDateFormatter.dateFormat = "yyyy-MM-dd"

       let calendar = Calendar.current

       let date = dateFormatter.date(from: date)
       let componenets = calendar.dateComponents([.year, .month, .day], from: date!)
       let finalDate = calendar.date(from: componenets)
       let strDate = (secondDateFormatter.string(from: finalDate!))
       return strDate
    }
      

    func getPrice(urlString: String, days: Int) {
        self.closingPrices.removeAll()

        dispatchGroup.enter()

        let url = URL(string: urlString)

        guard url != nil else {
            return
        }

        let session = URLSession.shared


        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()

                do {
                    let priceFeed = try decoder.decode([stockPriceFeed].self, from: data!)

                    var strDates = [String]()
                    var latestDate = String()

                    if let latestDateTime = priceFeed[0].date {
                        latestDate = self.convertStringDateTimeToStringDate(date: latestDateTime)
                    }

                    if days == 1 {
                        for price in priceFeed {
                            if let closingPrice = price.close, let strDate = price.date {
                                if let dateTime = price.date {
                                    let date = self.convertStringDateTimeToStringDate(date: dateTime)
                                    if latestDate == date {
                                        self.closingPrices.append(closingPrice)
                                        strDates.append(strDate) //Date
                                    }
                                }
                            }
                        }
                    }

                    else {
                        for price in priceFeed.prefix(days) {
                            if let closingPrice = price.close, let strDate = price.date {
                                if days == 365 {
                                    var changeResolution = 5
                                    if changeResolution % 5 == 0 {
                                        self.closingPrices.append(closingPrice) //Closing price
                                        strDates.append(strDate) //Date
                                    }
                                    changeResolution += 1
                                }

                                else if days == 1095 {
                                    var changeResolution = 20
                                    if changeResolution % 20 == 0 {
                                        self.closingPrices.append(closingPrice) //Closing price
                                        strDates.append(strDate) //Date
                                    }
                                    changeResolution += 1
                                }
                                else {
                                    self.closingPrices.append(closingPrice) //Closing price
                                    strDates.append(strDate) //Date
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.datesArray = strDates
                        self.lineChart(prices: self.closingPrices)
                        self.dispatchGroup.leave()
                    }
                }
                catch {
                    print("Error in JSON parsing")
                    self.dispatchGroup.leave()
                }
            }
        }
        dataTask.resume()
    }

    func getCustomRatios(urlString: String) {
        dispatchGroup.enter()
        let url = URL(string: urlString)

        guard  url != nil else {
            return
        }

        let session = URLSession.shared

        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()

                do {
                    let ratioFeed = try decoder.decode([YearlyRatios].self, from: data!)
                    self.sortedRatios = self.sortDashBoardRatios(array: ratioFeed)
                    self.dispatchGroup.leave()
                }
                catch {
                    print("Error in JSON parsing")
                    self.dispatchGroup.leave()
                }
            }
        }
        dataTask.resume()
    }
    
    
    private func sortDashBoardRatios(array: Array<YearlyRatios>) -> Array<cleanRatios> {
        var cleanRatiosArray = [cleanRatios]()
                
        let lastEightPeriods = array.prefix(8)
        let dates = array.map({$0.date})
        let periods = array.map({$0.period})
        
        let priceEarnings = cleanRatios(ratio: "PE Ratio",dates: dates, period: periods, historicalValues: lastEightPeriods.map({$0.priceEarningsRatio}))
        let debtEquity = cleanRatios(ratio: "Debt Equity", dates: dates, period: periods, historicalValues: lastEightPeriods.map({$0.debtEquityRatio}))
        let currentRatio = cleanRatios(ratio: "Current Ratio", dates: dates, period: periods, historicalValues: lastEightPeriods.map({$0.currentRatio}))
        let netProfitMargin = cleanRatios(ratio: "Net Profit Margin", dates: dates, period: periods, historicalValues: lastEightPeriods.map({$0.netProfitMargin}))
        
        cleanRatiosArray.append(priceEarnings)
        cleanRatiosArray.append(debtEquity)
        cleanRatiosArray.append(currentRatio)
        cleanRatiosArray.append(netProfitMargin)
        
        return cleanRatiosArray
    }
    

    func financialStatement(urlString: String){
        self.incomeStatementArray.removeAll()
        self.balanceSheetArray.removeAll()
        self.cashFlowArray.removeAll()
        
        dispatchGroup.enter()

        let url = URL(string: urlString)

        guard  url != nil else {
            return
        }

        let session = URLSession.shared


        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()

                do {
                    if urlString.contains("income-statement") {
                        let incomeStatementFeed = try decoder.decode([incomeStatement].self, from: data!)
                        self.incomeStatementArray = incomeStatementFeed

                        let chartData = self.getStatementItems(array: self.incomeStatementArray.reversed())
                        self.incomeStatementDataEntries = chartData.0
                        self.statementItems = chartData.1
                        self.dispatchGroup.leave()
                    }
                    else if urlString.contains("balance-sheet-statement") {
                        let balanceSheetFeed = try decoder.decode([balanceSheetStatement].self, from: data!)
                        self.balanceSheetArray = balanceSheetFeed

                        let chartData = self.getStatementItems(array: self.balanceSheetArray.reversed())
                        self.incomeStatementDataEntries = chartData.0
                        self.statementItems = chartData.1
                        self.dispatchGroup.leave()
                    }
                    else if urlString.contains("cash-flow-statement") {
                        let cashFlowFeed = try decoder.decode([cashFlowStatement].self, from: data!)
                        self.cashFlowArray = cashFlowFeed

                        let chartData = self.getStatementItems(array: self.cashFlowArray.reversed())
                        self.incomeStatementDataEntries = chartData.0
                        self.statementItems = chartData.1
                        self.dispatchGroup.leave()
                    }

                }
                catch {
                    print("Error in JSON parsing")
                    self.dispatchGroup.leave()
                }
            }
        }
        dataTask.resume()
    }

    func getStatementItems(array: Array<Encodable>) -> (Array<Array<BarChartDataEntry>>, Array<String>){
       var revenueArray = [Double]()
       var netIncomeArray = [Double]()
       var costOfRevenueArray = [Double]()
       var rdArray = [Double]()
       
       let incomeItems = ["revenue", "netIncome", "costOfRevenue", "researchAndDevelopmentExpenses"]
       let balanceItems = ["cashAndCashEquivalents", "shortTermInvestments", "cashAndShortTermInvestments", "netReceivables"]
       let cashItems = ["netIncome", "depreciationAndAmortization", "deferredIncomeTax", "stockBasedCompensation"]
       var items = [String]()
       
       
       //var lineData = [ChartDataEntry]()
       var revenueData = [BarChartDataEntry]()
       var netIncomeData = [BarChartDataEntry]()
       var costOfRevenueData = [BarChartDataEntry]()
       var researchAndDevelopmentData = [BarChartDataEntry]()
                       
       for periodCount in 0..<(array.count) {
           let period = (array[periodCount])
           
        if type(of: period) == incomeStatement.self {
               items = incomeItems
           }
           else if type(of: period) == balanceSheetStatement.self {
               items = balanceItems
           }
           else if type(of: period) == cashFlowStatement.self {
               items = cashItems
           }
           
        let periodData = (period.asDictionary)
           
        if let revenue = periodData[items[0]] { //Revenue
               if let rawRevenue = revenue as? Double {
                   revenueArray.append(rawRevenue)
                   
                   //Prepare bar chart 1
                   let roundedRevenue = Double(round(rawRevenue*100)/100)
                   revenueData.append(BarChartDataEntry(x: Double(periodCount), y: Double(roundedRevenue)))
               }
           }
           
           if let netIncome = periodData[items[1]] { //Net Income
               if let rawNetIncome = netIncome as? Double {
                   netIncomeArray.append(rawNetIncome)
                   
                   //Prepare bar chart 2
                   let roundedNetIncome = Double(round(rawNetIncome*100)/100)
                   netIncomeData.append(BarChartDataEntry(x: Double(periodCount), y: Double(roundedNetIncome)))
               }
           }
           
           if let costOfRevenue = periodData[items[2]] { //Cost Of Revenue
               //let rawCOR = (costOfRevenue as? Double)
               if let rawCOR = costOfRevenue as? Double {
                   costOfRevenueArray.append(rawCOR)
                   
                   //Prepare bar chart 3
                   let roundedCOR = Double(round(rawCOR*100)/100)
                   costOfRevenueData.append(BarChartDataEntry(x: Double(periodCount), y: Double(roundedCOR)))
               }
           }
           
           if let researchAndDevelopment = periodData[items[3]] { //Research And Development Expenses
               if let rawRD = researchAndDevelopment as? Double {
                   rdArray.append(rawRD)
                   
                   //Prepare bar chart 4
                   let roundedRD = Double(round(rawRD*100)/100)
                   researchAndDevelopmentData.append(BarChartDataEntry(x: Double(periodCount), y: Double(roundedRD)))
               }
           }
       }
       
       let allDataEntrys = [revenueData, netIncomeData, costOfRevenueData, researchAndDevelopmentData]
               
       return (allDataEntrys, items)
    }

    private func setUpCollectionView() -> Void{
       
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20)
        overviewCollectionView.collectionViewLayout = layout

        //Overview collection view
        overviewCollectionView.register(TopCollectionViewCell.self, forCellWithReuseIdentifier: "topCell")
        overviewCollectionView.register(ProfileContainerCollectionViewCell.self, forCellWithReuseIdentifier: "profileContainer")
        overviewCollectionView.register(LineGraphCollectionViewCell.self, forCellWithReuseIdentifier: "lineChartCell")
        overviewCollectionView.register(FinalyzeCollectionViewCell.self, forCellWithReuseIdentifier: "finalyzeCell")
        //overviewCollectionView.register(AboutCompanyTextCollectionViewCell.self, forCellWithReuseIdentifier: "aboutCompany")
        overviewCollectionView.register(DashboardCollectionViewCell.self, forCellWithReuseIdentifier: "dashboardCell")
        overviewCollectionView.register(CombinedChartCollectionViewCell.self, forCellWithReuseIdentifier: "combinedChartCell")
        overviewCollectionView.register(OverviewCollectionViewCell.self, forCellWithReuseIdentifier: "overviewCell")
        overviewCollectionView.register(RatioBarChartCell.self, forCellWithReuseIdentifier: "ratioBarCell") //Register CustomCellOne
        overviewCollectionView.register(RatioPieChartCell.self, forCellWithReuseIdentifier: "ratioPieCell") //Register CustomCellTwo
        overviewCollectionView.register(CustomCellTwo.self, forCellWithReuseIdentifier: "customTwo")
        overviewCollectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: "calendarCell")

        overviewCollectionView.delegate = self
        overviewCollectionView.dataSource = self
    }

    func drawLine(start: CGPoint, end: CGPoint, view: UIView) {
       //path design
       let path = UIBezierPath()
       path.move(to: start)
       path.addLine(to: end)
       
       //design path in layer
       let shape = CAShapeLayer()
       shape.path = path.cgPath
       shape.strokeColor = UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00).cgColor
       shape.lineWidth = 2.0
       
       view.layer.addSublayer(shape)
    }

    func drawCircle(center: CGPoint, view: UIView) {
       let startAngle = CGFloat(0)
       let endAngle = CGFloat(Double.pi * 2)
       
       let circlePath = UIBezierPath(arcCenter: center, radius: CGFloat(5), startAngle: startAngle, endAngle: endAngle, clockwise: true)
       
       let shape = CAShapeLayer()
       shape.path = circlePath.cgPath
       
       shape.lineWidth = 2
       shape.fillColor = .none
       shape.strokeColor = UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00).cgColor
       
       view.layer.addSublayer(shape)
    }

    private func positiveNegativeTextColor(value: Double) -> UIColor {
        var color: UIColor = UIColor.white
        
        if value > 0 {
            color = UIColor(red: 0.01, green: 0.81, blue: 0.64, alpha: 1.00)
        } else if value == 0 {
            color = UIColor.white
        }
        else {
            color = UIColor(red: 0.89, green: 0.00, blue: 0.40, alpha: 1.00)
        }
        return color
    }
    
    func alreadyFavorite() {
        
        let customView = UIView()
        customView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        self.followAnimation = .init(name: "78472-like")
        self.followAnimation?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.followAnimation?.animationSpeed = 1.5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.favoriteCompany))
        self.followAnimation?.addGestureRecognizer(tapGesture)
        
        database.child("favoriteStocks/\(ticker)").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists() { //Remove it and change label to "follow"
                self.followAnimation?.play(toProgress: 34)
                customView.addSubview(self.followAnimation!)
                
                let rightBarButtonItem = UIBarButtonItem(customView: customView)
                
                self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
            } else { //Add it and change label to "unfollow"
                self.followAnimation?.play(toProgress: 0)
                customView.addSubview(self.followAnimation!)
                let rightBarButtonItem = UIBarButtonItem(customView: customView)
                self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
            }
        })
    }
    
    
    func customButtonsNavController() {
        //Navigation bar title
        //navigationItem.title = "\(company)"
        
        //Back button (left)
        let BackImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysOriginal)
        self.navigationController?.navigationBar.backIndicatorImage = BackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = BackImage
        //self.navigationController?.navigationBar.tintColor = UIColor.clear
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.topItem?.title = "" //remove title of back-button
        
        //Add to favorite list button (right)
        alreadyFavorite()
      }
    
    private func successVibration() -> Void {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func errorVibration() -> Void {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    
    @objc func favoriteCompany(sender: UIBarButtonItem) {
        database.child("favoriteStocks/\(ticker)").observeSingleEvent(of: .value, with: {(snapshot) in
            let customView = UIView()
            customView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            
            self.followAnimation = .init(name: "78472-like")
            self.followAnimation?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            self.followAnimation?.animationSpeed = 1.5
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.favoriteCompany))
            self.followAnimation?.addGestureRecognizer(tapGesture)

            
            if snapshot.exists() {
                self.errorVibration()
                
                self.followAnimation?.play(toProgress: 0)
                customView.addSubview(self.followAnimation!)
                
                let rightBarButtonItem = UIBarButtonItem(customView: customView)

                self.navigationItem.rightBarButtonItem? = rightBarButtonItem
                
                self.database.child("favoriteStocks/\(self.ticker)").removeValue()
            } else { //Add it and change label to "unfollow"
                self.successVibration()
                
                self.followAnimation?.play()
                customView.addSubview(self.followAnimation!)
                let rightBarButtonItem = UIBarButtonItem(customView: customView)
                self.navigationItem.rightBarButtonItem? = rightBarButtonItem
                
                self.database.child("favoriteStocks").child(self.ticker).setValue(self.ticker)
            }
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
  
    override func viewWillAppear(_ animated: Bool) {
        let tickerLabel = UILabel()
        tickerLabel.text = "\(ticker)"
        tickerLabel.textAlignment = .center
        tickerLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        tickerLabel.sizeToFit()
        
        self.navigationItem.titleView = tickerLabel
        self.navigationItem.titleView?.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //axisFormatDelegate = self
                
        concurrentAPICall()

        setUpCollectionView()
        customButtonsNavController()
    }
}


extension DetailsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y) >= 54 {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.navigationItem.titleView?.isHidden = false
                self.navigationItem.titleView?.alpha = 1
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.navigationItem.titleView?.alpha = 0
                //self.navigationItem.titleView?.isHidden = true
           }, completion: nil)
        }
    }
    
    @objc func expandAboutCompany(button: UIButton) {
        if collectionViewIsExpanded {
            collectionViewIsExpanded = false
            self.overviewCollectionView.collectionViewLayout.invalidateLayout()
            self.overviewCollectionView.performBatchUpdates({
                self.overviewCollectionView.reloadItems(at: [IndexPath(row: 0, section: 3)])
            }, completion: nil)
        }
        else {
            collectionViewIsExpanded = true
            self.overviewCollectionView.collectionViewLayout.invalidateLayout()
            self.overviewCollectionView.performBatchUpdates({
                self.overviewCollectionView.reloadItems(at: [IndexPath(row: 0, section: 3)])
            }, completion: nil)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 1
        }
        else if section == 2 {
            return 1
        }
        else if section == 3 {
            return 1
        }
        else if section == 4 {
            return 1
        }
        else if section == 5 {
            return overviewButtons.count
        }
        else if section == 6 {
            return 1
        }
        else if section == 7 {
            return sortedRatios.count + 1
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = overviewCollectionView.dequeueReusableCell(withReuseIdentifier: "topCell", for: indexPath) as? TopCollectionViewCell
            if profileInformation.count != 0 {
                if let ticker = profileInformation[0].symbol {
                    cell?.tickerLabel.text = ticker
                }
                
                if let name = profileInformation[0].companyName{
                    cell?.nameLabel.text = "\(name)"
                }
                
                if let price = profileInformation[indexPath.row].price, let change = profileInformation[indexPath.row].changes {
                    let strPrice = String(format: "%.2f", price)
                    let strChange = String(format: "%.2f", change)
                    let priceAndChange = NSMutableAttributedString.init(string: "$\(strPrice) (\(strChange))")
                    
                    let percentageTextColor = positiveNegativeTextColor(value: change)
                    priceAndChange.setAttributes([NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 14), NSAttributedString.Key.foregroundColor: percentageTextColor], range: NSMakeRange(strPrice.count+2, strChange.count+2))
                    cell?.priceLabel.attributedText = priceAndChange
                }
                return cell!
            }
            return cell!
        }
            
        else if indexPath.section == 1 {
            let cell = overviewCollectionView.dequeueReusableCell(withReuseIdentifier: "profileContainer", for: indexPath) as? ProfileContainerCollectionViewCell
            let profileLink = "https://financialmodelingprep.com/api/v3/profile/\(ticker)?apikey=\(apiKey)"
            cell?.getCompanyProfile(urlString: profileLink)
            return cell!
        }
        
        //SECTION 2 - Stock Price Chart
        //cell: LineGraphCollectionViewCell
        else if indexPath.section == 2 {
            let cell = overviewCollectionView.dequeueReusableCell(withReuseIdentifier: "lineChartCell", for: indexPath) as? LineGraphCollectionViewCell
            let lineChart = cell?.lineChart
            lineChart!.data = stockPriceData
            //lineChart?.xAxis.valueFormatter = axisFormatDelegate
            
            let segmentedControl = cell?.segmentedControl
            segmentedControl!.addTarget(self, action: #selector(changeTimePeriod), for: .valueChanged)
             
            return cell!
        }
        
        else if indexPath.section == 3 {
            let cell = overviewCollectionView.dequeueReusableCell(withReuseIdentifier: "finalyzeCell", for: indexPath) as? FinalyzeCollectionViewCell
            
            return cell!
        }
        
        //SECTION 3 - About company text
        //cell: AboutCompanyTextCollectionViewCell
        else if indexPath.section == 4 {
            let cell = overviewCollectionView.dequeueReusableCell(withReuseIdentifier: "aboutCompany", for: indexPath) as? AboutCompanyTextCollectionViewCell
            cell?.testBtn.addTarget(self, action: #selector(expandAboutCompany), for: .touchUpInside)
            cell?.testBtn.setTitleColor(UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00), for: .normal)
            cell?.layer.cornerRadius = 10
            //cell?.layer.backgroundColor = UIColor.red.cgColor
            
            if companyDescription.count != 0 {
                cell?.test.textColor = .white
                cell?.test.text = companyDescription[0]
                cell?.test.numberOfLines = 0
                cell?.test.lineBreakMode = .byWordWrapping
                cell?.test.sizeToFit()
                
                if let height = cell?.test.bounds.size.height {
                    testHeight = height
                }
            }
            
            if collectionViewIsExpanded {
                //print("To be closed")
                cell?.testBtn.setTitle("Read less", for: .normal)
                
            }
            else {
                //print("To be opened")
                cell?.testBtn.setTitle("Read more", for: .normal)
            }
            
            cell?.layoutIfNeeded()
            return cell!
        }
            
        //SECTION 4 - Company Details
        //cell: OverviewCollectionViewCell
        else if indexPath.section == 5 {
            let cell = overviewCollectionView.dequeueReusableCell(withReuseIdentifier: "overviewCell", for: indexPath) as? OverviewCollectionViewCell
            let imgName = icons[indexPath.row] + ".png"
            
            cell?.layer.cornerRadius = 10
            cell?.layer.borderWidth = 0
            cell?.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell?.layer.shadowColor = UIColor.darkGray.cgColor
            cell?.layer.shadowRadius = 2
            cell?.layer.shadowOpacity = 0.2
            cell?.layer.masksToBounds = false
            cell?.layer.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00).cgColor //UIColor.systemBackground.cgColor //UIColor.tertiarySystemBackground.cgColor
            //cell?.layer.borderColor = UIColor.darkGray.cgColor
            cell?.titleLabel.text = overviewButtons[indexPath.row]
            cell?.subTitleLabel.text = overviewSubtitles[indexPath.row]
            cell?.imgView.image = UIImage(named: imgName)
            cell?.contentView.layer.cornerRadius = 5
            
            return cell!
        }
        
        /*
        //SECTION 5 - Ratios/PieCharts/Charts
        //cell: DashboardCollectionViewCell
        else if indexPath.section == 5 {
            let cell = overviewCollectionView.dequeueReusableCell(withReuseIdentifier: "dashboardCell", for: indexPath) as? DashboardCollectionViewCell

            if TTMRatiosDashboard.count != 0 && ratioValues.count != 0{
                cell?.nameLabel.text = TTMRatiosDashboard[indexPath.row]
                var entries: [PieChartDataEntry] = Array()
                var value : Double?
                
                value = ratioValues[indexPath.row]
                
                if let unwrappedValue = value {
                    let colors: Array<UIColor>
                    let roundedValue = String(format: "%.2f", unwrappedValue*100)
                    let attrStringColor = [NSAttributedString.Key.foregroundColor: UIColor.label]
                    let attrString = NSAttributedString(string: "\(roundedValue)%", attributes: attrStringColor)
                    cell?.pieChart.centerAttributedText = attrString
                    
                    //let start = CGPoint(x:1, y:10)
                    //let end = CGPoint(x: 1, y: 140)
                    
                    if unwrappedValue > 0 {
                        entries.append(PieChartDataEntry(value: unwrappedValue))
                        entries.append(PieChartDataEntry(value: 1-unwrappedValue))
                        colors = [UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00), UIColor.darkGray]
                        //let color = UIColor(red: 0.28, green: 0.87, blue: 0.13, alpha: 1.00)
                        //cell?.drawLine(start: start, end: end, shape: cell!.shape, color: color)
                    } else {
                        entries.append(PieChartDataEntry(value: 1))
                        colors = [UIColor.darkGray]
                        //let color = UIColor(red: 0.90, green: 0.0, blue: 0.0, alpha: 1.00)
                        //cell?.drawLine(start: start, end: end, shape: cell!.shape, color: color)
                    }
                    
                    let dataSet = PieChartDataSet(entries: entries, label: "")
                    dataSet.colors = colors
                    dataSet.drawValuesEnabled = false

                    cell?.pieChart.data = PieChartData(dataSet: dataSet)
                    return cell!
                }
            }
            
            return cell!
        }
        */

        //SECTION 6 - Combo chart
        //cell: CombinedChartCollectionViewCell
        else if indexPath.section == 6 {
            let cell = overviewCollectionView.dequeueReusableCell(withReuseIdentifier: "combinedChartCell", for: indexPath) as? CombinedChartCollectionViewCell
            if incomeStatementDataEntries.count == 4 {
                
                let chart = cell?.combinedChart
                cell?.populateChartTest(chartData: incomeStatementDataEntries, statementItems: statementItems, periods: 10, chart: chart!)
                
                //let chart = cell?.combinedChart
                //cell?.populateChart(selectedRatiosDict: customRatioDict, chart: chart!)
            }
                        
            cell?.segmentedControlType.addTarget(self, action: #selector(changeReportType), for: .valueChanged)
            cell?.segmentedControlPeriod.addTarget(self, action: #selector(changeReportPeriod), for: .valueChanged)
            return cell!
        }
        
        else if indexPath.section == 7 {
            let cell = overviewCollectionView.dequeueReusableCell(withReuseIdentifier: "ratioBarCell", for: indexPath) as? RatioBarChartCell
                        
            if indexPath.row < 3 {
                cell?.categoryLabel.text = ratioCategories[indexPath.row]
                let cleanRatioData = sortedRatios[indexPath.row]
                
                if let ratio = cleanRatioData.ratio, let period = cleanRatioData.period, let historicalData = cleanRatioData.historicalValues {
                    
                    if let lastPeriod = period[0], let latestValue = historicalData[0], let periods = cleanRatioData.period {
                        
                        cell?.quarters = periods.prefix(4).reversed()
                        cell?.nameLabel.text = ratio
                        cell?.latestValueLabel.text = "\(String(format: "%.2f", latestValue)) | \(lastPeriod)"
                        cell?.prepareBarChart(values: historicalData.reversed())
                        
                        cell?.moreDataLabel.text = "H: \(cleanRatioData.getHigh()) | L: \(cleanRatioData.getLow())\nAvg: \(cleanRatioData.getAverage())"
                    }
                }
            }
            else if indexPath.row == 3 {
                let cell = overviewCollectionView.dequeueReusableCell(withReuseIdentifier: "ratioPieCell", for: indexPath) as? RatioPieChartCell
                
                cell?.categoryLabel.text = ratioCategories[indexPath.row]
                
                let cleanRatioData = sortedRatios[indexPath.row]
                if let ratio = cleanRatioData.ratio, let period = cleanRatioData.period, let historicalData = cleanRatioData.historicalValues {
                    
                    if let lastPeriod = period[0], let latestValue = historicalData[0]{
                        cell?.nameLabel.text = ratio
                        cell?.latestValueLabel.text = "\(String(format: "%.2f", latestValue*100))% | \(lastPeriod)"
                        cell?.preparePieChart(value: latestValue)
                        
                        cell?.moreDataLabel.text = "H: \(cleanRatioData.getHigh())\nL: \(cleanRatioData.getLow())\nAvg: \(cleanRatioData.getAverage())"
                    }
                }
                
                return cell!
            }
            
            else {
                let cell = overviewCollectionView.dequeueReusableCell(withReuseIdentifier: "customTwo", for: indexPath) as? CustomCellTwo
                cell?.nameLabel.text = "Customize"
                return cell!
            }
            
            return cell!
        }
        
        //SECTION 8 - Calendar
        //cell: CalendarCollectionViewCell
        let cell = overviewCollectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as? CalendarCollectionViewCell
        
        return cell!
    }
    
    
    @objc func changeTimePeriod(segmentedControl: UISegmentedControl) {
        //let nameAndTicker = (SearchViewController.GlobalVariable.myString)
        //let ticker = getTicker(companySelected: nameAndTicker)
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            timePeriodURL = "https://financialmodelingprep.com/api/v3/historical-chart/1min/\(ticker)?apikey=\(apiKey)"
            getPrice(urlString: timePeriodURL, days: 1)
        case 1:
            timePeriodURL = "https://financialmodelingprep.com/api/v3/historical-chart/5min/\(ticker)?apikey=\(apiKey)"
            getPrice(urlString: timePeriodURL, days: 7)
        case 2:
            timePeriodURL = "https://financialmodelingprep.com/api/v3/historical-chart/5min/\(ticker)?apikey=\(apiKey)"
            getPrice(urlString: timePeriodURL, days: 30)
        case 3:
            timePeriodURL = "https://financialmodelingprep.com/api/v3/historical-chart/5min/\(ticker)?apikey=\(apiKey)"
            getPrice(urlString: timePeriodURL, days: 90)
        case 4:
            timePeriodURL = "https://financialmodelingprep.com/api/v3/historical-chart/5min/\(ticker)?apikey=\(apiKey)"
            getPrice(urlString: timePeriodURL, days: 365)
        case 5:
            timePeriodURL = "https://financialmodelingprep.com/api/v3/historical-chart/5min/\(ticker)?apikey=\(apiKey)"
            getPrice(urlString: timePeriodURL, days: 1095)
        default:
            print("Hey")
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = overviewCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "dashboardHeader", for: indexPath) as! DashboardCollectionReusableView
        header.headerLabel.text = sectionHeaders[indexPath.section]
        header.segmentedControl.isHidden = true
        header.filterButton.isHidden = true
        return header
    }
    
    func acquireReportData(period: String, type: String) {
        var url = String()
        if period == "Y" {
            if type == "I" {
                url = "https://financialmodelingprep.com/api/v3/income-statement/\(ticker)?limit=10&apikey=\(apiKey)"
                financialStatement(urlString: url)
            } else if type == "B" {
                url = "https://financialmodelingprep.com/api/v3/balance-sheet-statement/\(ticker)?limit=10&apikey=\(apiKey)"
                financialStatement(urlString: url)
            } else if type == "C" {
                url = "https://financialmodelingprep.com/api/v3/cash-flow-statement/\(ticker)?limit=10&apikey=\(apiKey)"
                financialStatement(urlString: url)
            }
        } else if period == "Q" {
            if type == "I" {
                url = "https://financialmodelingprep.com/api/v3/income-statement/\(ticker)?period=quarter&limit=10&apikey=\(apiKey)"
                financialStatement(urlString: url)
            } else if type == "B" {
                url = "https://financialmodelingprep.com/api/v3/balance-sheet-statement/\(ticker)?period=quarter&limit=10&apikey=\(apiKey)"
                financialStatement(urlString: url)
            } else if type == "C" {
                url = "https://financialmodelingprep.com/api/v3/cash-flow-statement/\(ticker)?period=quarter&limit=10&apikey=\(apiKey)"
                financialStatement(urlString: url)
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.overviewCollectionView.reloadData()
        }
    }
    
    @objc func changeReportType(segmentedControl: UISegmentedControl) {
        //Ticker
        //let nameAndTicker = (SearchViewController.GlobalVariable.myString)
        //let ticker = getTicker(companySelected: nameAndTicker)
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            reportType = "I"
            acquireReportData(period: reportPeriod, type: reportType)
            //getDashboardRatios(urlString: TTMRatiosLink, type: "I")
        case 1:
            reportType = "B"
            acquireReportData(period: reportPeriod, type: reportType)
            //getDashboardRatios(urlString: TTMRatiosLink, type: "B")
        case 2:
            reportType = "C"
            acquireReportData(period: reportPeriod, type: reportType)
            //getDashboardRatios(urlString: TTMRatiosLink, type: "C")
        default:
            reportType = "I"
            print("Change to income statement data")
            acquireReportData(period: reportPeriod, type: reportType)
            //getDashboardRatios(urlString: TTMRatiosLink, type: "I")
        }
    }
    
    @objc func changeReportPeriod(segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            print("Yearly")
            reportPeriod = "Y"
            acquireReportData(period: reportPeriod, type: reportType)
        case 1:
            print("Quarterly")
            reportPeriod = "Q"
            acquireReportData(period: reportPeriod, type: reportType)
        default:
            print("Yearly")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 5 || section == 2 {
            return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
        else {
            return UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat
        let height: CGFloat
        
        if section == 0 || section == 1 || section == 2 || section == 3 {
            width = 0
            height = 0
        }
        
        else {
            width = UIScreen.main.bounds.size.width - 20.0
            height = 55
        }
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width : CGFloat
        var height : CGFloat
        
        if collectionView == overviewCollectionView {
            if indexPath.section == 0 {
                width = CGFloat(UIScreen.main.bounds.size.width-40)
                height = 80
            }
            else if indexPath.section == 1 {
                width = CGFloat(UIScreen.main.bounds.size.width)
                height = 70
            }
            else if indexPath.section == 2 {
                width = CGFloat(UIScreen.main.bounds.size.width)
                height = 300
            }
            else if indexPath.section == 3 {
                width = CGFloat(UIScreen.main.bounds.size.width-40)
                height = 50
            }
            else if indexPath.section == 4 {
                if collectionViewIsExpanded {

                    width = CGFloat(UIScreen.main.bounds.size.width-40)
                    height = testHeight + 48
                } else {
                    width = CGFloat(UIScreen.main.bounds.size.width-40)
                    height = 145
                }
            }
            else if indexPath.section == 5 {
                width = (UIScreen.main.bounds.size.width) - (40)
                height = 70
            }
            /*
            else if indexPath.section == 5 {
                width = 160
                height = 160
            }
            */
            else if indexPath.section == 6 {
                width = UIScreen.main.bounds.size.width - 40
                height = 450
                //height = 20 + 32 + 10 + 300 + 10 + 32 + 10 + 20 + 20
                
            }
            else if indexPath.section == 7 {
                if indexPath.row < 4 {
                    width = (UIScreen.main.bounds.size.width - 40 - 10)/2
                    height = (UIScreen.main.bounds.width - 40 - 10)/2
                } else {
                    width = (UIScreen.main.bounds.size.width - 40)
                    height = 100
                }
            }
            else {
                width = UIScreen.main.bounds.size.width - 20*2
                height = 300
            }
            return CGSize(width: width, height: height)
        }
        
        return CGSize(width: 110, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            let detailedFinancialsVC = (storyboard?.instantiateViewController(identifier: "financialsDetailed") as! DetailedFinancialsViewController)
            detailedFinancialsVC.ticker = ticker
            navigationController?.present(detailedFinancialsVC, animated: true)
            //detailedFinancialsVC.modalPresentationStyle = .overCurrentContext
            //navigationController?.pushViewController(detailedFinancialsVC, animated: true)
            //present(popOverVC, animated: true, completion: nil) //This line enables the custom popover to cover the whole area of the underlying "root-view", in this case the tab bar controller, hence tabBarController?.present....
        }
        else if indexPath.section == 5 {
            if indexPath.row == 0 {
                let popOverVC = storyboard!.instantiateViewController(withIdentifier: "ratiosCategory") as! RatioViewController
                popOverVC.ticker = ticker
                popOverVC.modalPresentationStyle = .overCurrentContext
                navigationController?.pushViewController(popOverVC, animated: true)
                //present(popOverVC, animated: true, completion: nil) //This line enables the custom popover to cover the whole area of the underlying "root-view", in this case the tab bar controller, hence tabBarController?.present....
            }
            
            else if indexPath.row == 1 {
                let popOverVC = storyboard!.instantiateViewController(withIdentifier: "financials") as! FViewController
                popOverVC.ticker = ticker
                //popOverVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                tabBarController?.present(popOverVC, animated: true, completion: nil) //This line enables the custom popover to cover the whole area of the underlying "root-view", in this case the tab bar controller, hence tabBarController?.present....
            }
                
            else if indexPath.row == 2 {
                let popOverVC = storyboard!.instantiateViewController(withIdentifier: "pressReleaseView") as! PressReleaseViewController
                //popOverVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                //tabBarController?.present(popOverVC, animated: true, completion: nil) //This line enables the custom popover to cover the whole area of the underlying "root-view", in this case the tab bar controller, hence tabBarController?.present....
                navigationController?.present(popOverVC, animated: true)
            }
                
            else if indexPath.row == 3 {
                let popOverVC = storyboard!.instantiateViewController(withIdentifier: "secInfo") as! TestViewController
                popOverVC.ticker = ticker
                popOverVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                tabBarController?.present(popOverVC, animated: true, completion: nil) //This line enables the custom popover to cover the whole area of the underlying "root-view", in this case the tab bar controller, hence tabBarController?.present....
            }
        }
        
        else if indexPath.section == 7 {
            if indexPath.row < 4 {
                let popOverVC = storyboard!.instantiateViewController(withIdentifier: "historicalKPI") as! KPIViewController
                let category = ratioCategories[indexPath.row]
                popOverVC.kpiCategory = (category) //add the current company name to the variable "company" in FundPopUpViewController
                popOverVC.ticker = ticker
                popOverVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                tabBarController?.present(popOverVC, animated: true, completion: nil) //This line enables the custom popover to cover the whole area of the underlying "root-view", in this case the tab bar controller, hence tabBarController?.present....
            } else {
                let popOverVC = storyboard!.instantiateViewController(withIdentifier: "customAnalysis") as! CustomRatioAnalysisViewController
                popOverVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                popOverVC.ticker = ticker
                tabBarController?.present(popOverVC, animated: true, completion: nil) //This line enables the custom popover to cover the whole area of the underlying "root-view", in this case the tab bar controller, hence tabBarController?.present....
            }
        }
    }
}

extension DetailsViewController : IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let sortedYears = datesArray.sorted(by: {$0.compare($1) == .orderedAscending})
        return sortedYears[Int(value)]
    }
}


extension String {
func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
    let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.text = self
    label.font = font
    label.sizeToFit()

    return label.frame.height
    }
}

extension DetailsViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let x = highlight.xPx
        let y = highlight.yPx
        
        print(y)
    }
    
    
}
