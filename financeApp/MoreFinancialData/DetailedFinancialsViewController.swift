//
//  DetailedFinancialsViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2021-07-16.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class DetailedFinancialsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    var ticker = String()
    
    var dispatchGroup = DispatchGroup()
    
    var alert = UIAlertController(title: "Change period", message: "", preferredStyle: .actionSheet)
    let screenWidth = UIScreen.main.bounds.size.width - 10
    let screenHeight = UIScreen.main.bounds.size.height / 5
    var selectedRow = 0
    
    let yearsOptions = [3, 5, 7, 10]
    
    //
    var testArray: [dataHorizontalAnalysis] = []
    
    //Financial Statement
    var itemNames = [String]()
    var itemValues = [Double]()
    
    //Financial Statement Growth
    var incomeStatementGrowthArray = [incomeStatementGrowth]()
    var horizontalAnalysisArray = [horizontalAnalysisItem]()
    let incomeGrowthItems: [String] = ["Revenue Growth", "EPS Growth"]
    let balanceGrowthItems: [String] = []
    let cashFlowGrowthItems: [String] = []
    var itemsGrowth = [Double]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up of the Collection View.
        setUpCollectionView()
        
        //API call
        let url = "https://financialmodelingprep.com/api/v3/income-statement/\(self.ticker)?limit=\(3)&apikey=\(apiKey)"
        getFinancialStatement(urlString: url)
        
        let urlTest = "https://financialmodelingprep.com/api/v3/income-statement-growth/\(self.ticker)?limit=5&apikey=\(apiKey)"
        getFinancialStatementGrowth(urlString: urlTest)
        
        dispatchGroup.notify(queue: .main) {
            self.collectionView.reloadData()
        }
    }
    
    private func setUpCollectionView() -> Void {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(CombinedChartCollectionViewCell.self, forCellWithReuseIdentifier: "comboChartCell")
        collectionView.register(FinancialStatementsCollectionViewCell.self, forCellWithReuseIdentifier: "detailedFinancialsCell")
        collectionView.register(FinancialItemCollectionViewCell.self, forCellWithReuseIdentifier: "financialItem")
        
        collectionView.register(HorizontalAnalysisHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "horizontalAnalysisHeader")
        collectionView.register(HorizontalAnalysisCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "horizontalAnalysis")
        collectionView.register(HistoryGrowthCollectionViewCell.self, forCellWithReuseIdentifier: "historyCell")
        collectionView.register(HorizontalAnalysisFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "horizontalAnalysisFooter")
    }
    
    private func getFinancialStatement(urlString: String) -> Void {
        testArray.removeAll()

        dispatchGroup.enter()
        
        let url = URL(string: urlString)
        guard  url != nil else {
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                //1. INCOME STATEMENT
                self.parseIncomeStatement(url: urlString, decoder: decoder, data: data, error: error)
                
                //2. BALANCE SHEET
                self.parseBalanceSheet(url: urlString, decoder: decoder, data: data, error: error)
            
                //3. CASH FLOW
                self.parseCashFlow(url: urlString, decoder: decoder, data: data, error: error)
                
                self.dispatchGroup.leave()
            }
        }
        dataTask.resume()
    }
        
    private func parseIncomeStatement(url: String, decoder: JSONDecoder, data: Data?, error: Error?) -> Void {
                
        if url.contains("income-statement") {
            do {
                let feed = try decoder.decode([incomeStatement].self, from: data!)
                
                //Selected Period
                let selectedPeriod = feed
                
                //Last Period
                let lastPeriod = Array(feed.prefix(1))
                
                DispatchQueue.main.async {
                    let incomeStatementContent = self.cleanLastStatementData(rawStatement: lastPeriod)
                    self.itemNames = incomeStatementContent.0
                    self.itemValues = incomeStatementContent.1
                    self.cleanIncomeStatement(rawData: selectedPeriod)
                }
            }
            catch {
                self.dispatchGroup.leave()
                print("Error in JSON parsing for Income Statement")
                print("API Endpoint: \(url)")
                print(error.localizedDescription)
            }
        }
    }
    
    private func parseBalanceSheet(url: String, decoder: JSONDecoder, data: Data?, error: Error?) -> Void {
        if url.contains("balance-sheet-statement") {
            do {
                let feed = try decoder.decode([balanceSheetStatement].self, from: data!)
                
                //Selected Period
                let selectedPeriod = feed
                
                //Last Period
                let lastPeriod = Array(feed.prefix(1))
                
                DispatchQueue.main.async {
                    let incomeStatementContent = self.cleanLastStatementData(rawStatement: lastPeriod)
                    self.itemNames = incomeStatementContent.0
                    self.itemValues = incomeStatementContent.1
                    //self.incomeStatementArray = selectedPeriod
                }
            }
            catch {
                self.dispatchGroup.leave()
                print("Error in JSON parsing for Balance Sheet")
                print("API Endpoint: \(url)")
                print(error.localizedDescription)
            }
        }
    }
    
    private func parseCashFlow(url: String, decoder: JSONDecoder, data: Data?, error: Error?) -> Void {
        if url.contains("cash-flow-statement") {
            do {
                let feed = try decoder.decode([cashFlowStatement].self, from: data!)
                
                //Selected Period
                let selectedPeriod = feed
                
                //Last Period
                let lastPeriod = Array(feed.prefix(1))
                
                DispatchQueue.main.async {
                    let incomeStatementContent = self.cleanLastStatementData(rawStatement: lastPeriod)
                    self.itemNames = incomeStatementContent.0
                    self.itemValues = incomeStatementContent.1
                }
            }
            catch {
                self.dispatchGroup.leave()
                print("Error in JSON parsing for Cash Flow")
                print("API Endpoint: \(url)")
                print(error.localizedDescription)
            }
        }
    }
    
    
    private func cleanLastStatementData(rawStatement: Array<Decodable>) -> (Array<String>, Array<Double>) {
        var itemValues = [Double]()
        var itemNames = [String]()
        
        let latestData = rawStatement[0]
        let mirror = Mirror(reflecting: latestData)
        
        for child in mirror.children {
            if let itemValue = child.value as? Double {
                if let itemName = child.label {
                    itemValues.append(itemValue)
                    itemNames.append(itemName.firstLetterCapitalized())
                }
            }
        }
        return (itemNames, itemValues)
    }
    
    private func horizontalAnalysisChange(array: Array<Double>) -> Array<Double> {
        var horizontalAnalysis: [Double] = []

        if let baseValue = array.last {
            for i in array {
                let trend = ((i*100)/baseValue)
                horizontalAnalysis.append(trend)
            }
        }
        return horizontalAnalysis
    }
    
    private func getPercentageChangeYoY(array: Array<Double>) -> Array<Double>{
        let orderedArray = array.reversed()
        let percentageChangeArray = [0] + zip(orderedArray, orderedArray.dropFirst()).map {
            100.0 * ($1 - $0) / abs($0) 
        }
        return percentageChangeArray.reversed()
    }
    
    
    private func cleanIncomeStatement(rawData: Array<incomeStatement>) -> Void {
        var revenueArray: [Double] = []
        var epsArray: [Double] = []
        var netIncomeArray: [Double] = []
        var periods: [String] = []
                
        for period in rawData {
            if let revenue = period.revenue, let eps = period.eps, let netIncome = period.netIncome, let period = period.date {
                revenueArray.append(round((100*revenue))/100)
                epsArray.append(round((100*eps))/100)
                netIncomeArray.append(round((100*netIncome))/100)
                periods.append(period)
            }
        }
        
        let revenueChange = getPercentageChangeYoY(array: revenueArray)
        let epsChange = getPercentageChangeYoY(array: epsArray)
        let netIncomeChange = getPercentageChangeYoY(array: netIncomeArray)
        
        let revenueHorizontal = horizontalAnalysisChange(array: revenueArray)
        let epsHorizontal = horizontalAnalysisChange(array: epsArray)
        let netIncomeHorizontal = horizontalAnalysisChange(array: netIncomeArray)
        
        let aagrRevenue = average(array: revenueChange)
        let aagrEPS = average(array: epsChange)
        let aagrNetIncome = average(array: netIncomeChange)
        
        let revenue = dataHorizontalAnalysis(isExpanded: false, itemName: "Revenue", valuesRegularStatement: revenueArray, valuesGrowthStatement: revenueChange, valuesHorizontalAnalysis: revenueHorizontal, aagr: aagrRevenue, periods: periods)
        
        let eps = dataHorizontalAnalysis(isExpanded: false, itemName: "EPS", valuesRegularStatement: epsArray, valuesGrowthStatement: epsChange, valuesHorizontalAnalysis: epsHorizontal, aagr: aagrEPS, periods: periods)
        
        let netIncome = dataHorizontalAnalysis(isExpanded: false, itemName: "Net Income", valuesRegularStatement: netIncomeArray, valuesGrowthStatement: netIncomeChange, valuesHorizontalAnalysis: netIncomeHorizontal, aagr: aagrNetIncome, periods: periods)
        
        testArray.append(revenue)
        testArray.append(eps)
        testArray.append(netIncome)
    }
        
    
    private func getFinancialStatementGrowth(urlString: String) -> Void {
        dispatchGroup.enter()
        
        incomeStatementGrowthArray.removeAll()

        let url = URL(string: urlString)
        
        guard  url != nil else {
            return
        }
        
        let session = URLSession.shared


        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                //1. Income Statement Growth
                self.parseIncomeStatementGrowth(url: urlString, decoder: decoder, data: data, error: error)
                
                self.dispatchGroup.leave()
            }
        }
        dataTask.resume()
    }
    
    
    private func parseIncomeStatementGrowth(url: String, decoder: JSONDecoder, data: Data?, error: Error?) -> Void {
        if url.contains("income-statement") {
            do {
                let incomeStatementFeed = try decoder.decode([incomeStatementGrowth].self, from: data!)
                for period in incomeStatementFeed {
                    self.incomeStatementGrowthArray.append(period)
                }
                DispatchQueue.main.async {
                    self.itemsGrowth = self.cleanIncomeStatementGrowth(rawData: self.incomeStatementGrowthArray)
                }
            }
            catch {
                dispatchGroup.leave()
                print("Error in JSON parsing for Income Statement Growth")
                print("API Endpoint: \(url)")
                print(error.localizedDescription)
            }
        }
    }
    
    
    private func cleanIncomeStatementGrowth(rawData: Array<incomeStatementGrowth>) -> Array<Double> {
        var averageGrowth = [Double]()
        var periods = [String]()
        
        var revenueGrowthArray = [Double]()
        var epsGrowthArray = [Double]()
        var netIncomeGrowthArray = [Double]()
        
        for period in rawData {
            if let revenueGrowth = period.growthRevenue, let epsGrowth = period.growthEPS, let netIncomeGrowth = period.growthNetIncome {
                revenueGrowthArray.append(revenueGrowth)
                epsGrowthArray.append(epsGrowth)
                netIncomeGrowthArray.append(netIncomeGrowth)
            }
            
            if let period = period.date {
                periods.append(period)
            }
        }
        
        let avgRevenueGrowth = average(array: revenueGrowthArray)
        let avgEPSGrowth = average(array: epsGrowthArray)
        let avgNetIncomeGrowth = average(array: netIncomeGrowthArray)
        
        let revenue = horizontalAnalysisItem(isExpanded: false, name: "revenue", increasePositive: true, average: avgRevenueGrowth, growthValues: revenueGrowthArray, periods: periods)
        let eps = horizontalAnalysisItem(isExpanded: false, name: "EPS", increasePositive: true, average: avgEPSGrowth, growthValues: epsGrowthArray, periods: periods)
        let netIncome = horizontalAnalysisItem(isExpanded: false, name: "net income", increasePositive: true, average: avgNetIncomeGrowth, growthValues: netIncomeGrowthArray, periods: periods)

        horizontalAnalysisArray.append(revenue)
        horizontalAnalysisArray.append(eps)
        horizontalAnalysisArray.append(netIncome)
        
        averageGrowth.append(avgRevenueGrowth)
        averageGrowth.append(avgEPSGrowth)
        averageGrowth.append(avgNetIncomeGrowth)
        
        return averageGrowth
    }
    
    
    func cleanGrowthData(reportType: String) -> (Array<Double>) {
        var averageGrowth = [Double]()
        var periods = [String]()
        
        if reportType == "I" {
            var revenueGrowthArray = [Double]()
            var epsGrowthArray = [Double]()
            var netIncomeGrowthArray = [Double]()
            
            for period in incomeStatementGrowthArray {
                if let revenueGrowth = period.growthRevenue, let epsGrowth = period.growthEPS, let netIncomeGrowth = period.growthNetIncome {
                    revenueGrowthArray.append(revenueGrowth)
                    epsGrowthArray.append(epsGrowth)
                    netIncomeGrowthArray.append(netIncomeGrowth)
                }
                
                
                if let period = period.date {
                    periods.append(period)
                }
            }
            let avgRevenueGrowth = average(array: revenueGrowthArray)
            let avgEPSGrowth = average(array: epsGrowthArray)
            let avgNetIncomeGrowth = average(array: netIncomeGrowthArray)
            
            let revenue = horizontalAnalysisItem(isExpanded: false, name: "revenue", increasePositive: true, average: avgRevenueGrowth, growthValues: revenueGrowthArray, periods: periods)
            let eps = horizontalAnalysisItem(isExpanded: false, name: "EPS", increasePositive: true, average: avgEPSGrowth, growthValues: epsGrowthArray, periods: periods)
            let netIncome = horizontalAnalysisItem(isExpanded: false, name: "net income", increasePositive: true, average: avgNetIncomeGrowth, growthValues: netIncomeGrowthArray, periods: periods)

            horizontalAnalysisArray.append(revenue)
            horizontalAnalysisArray.append(eps)
            horizontalAnalysisArray.append(netIncome)
            
            averageGrowth.append(avgRevenueGrowth)
            averageGrowth.append(avgEPSGrowth)
            averageGrowth.append(avgNetIncomeGrowth)
        }
        
        else if reportType == "B" {
            
        }
        
        else if reportType == "C" {
            
        }
        return averageGrowth
    }
    
    func average(array: Array<Double>) -> (Double){
        let sum = array.reduce(0, +) //Sum of all elements in array
        let digits = Double(array.count) //Count the amount of digits/numbers
        let average = sum/digits //Calculate average
        return average
    }
}

extension DetailedFinancialsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @objc func expandMinimizeHeader(button: UIButton) {
        
        let section = (button.tag)
        var indexPaths = [IndexPath]()
        
        if (testArray.count != 0) {
            for row in 0..<testArray[section-4].periods.count {
                let indexPath = IndexPath(row: row, section: section)
                indexPaths.append(indexPath)
            }
            
            let isExpanded = testArray[section-4].isExpanded
            testArray[section-4].isExpanded = !isExpanded
            
            if isExpanded {
                self.collectionView.performBatchUpdates({
                    collectionView.deleteItems(at: indexPaths)
                }, completion: nil)
            } else {
                self.collectionView.performBatchUpdates({
                    collectionView.insertItems(at: indexPaths)
                }, completion: nil)
            }
        }
    }
    
    @objc func preparePickerView() {
        alert = UIAlertController(title: "Change Period", message: "", preferredStyle: .actionSheet)
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            return
        }))
        
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { (UIAlertAction) in
            self.selectedRow = pickerView.selectedRow(inComponent: 0)
            let selectedPeriod = self.yearsOptions[self.selectedRow]
            let url = "https://financialmodelingprep.com/api/v3/income-statement/\(self.ticker)?limit=\(selectedPeriod)&apikey=\(apiKey)"
            self.getFinancialStatement(urlString: url)
            
            let urlTest = "https://financialmodelingprep.com/api/v3/income-statement-growth/\(self.ticker)?limit=5&apikey=\(apiKey)"
            self.getFinancialStatementGrowth(urlString: urlTest)
            
            self.dispatchGroup.notify(queue: .main) {
                self.collectionView.reloadData()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
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
    
    private func positiveNegativeArrow(value: Double) -> UIImage {
        var image = UIImage()
    
        if value > 0 {
            image = UIImage(named: "arrow_increase.png")!
        } else if value == 0 {
            image = UIImage()
        } else {
            image = UIImage(named: "arrow_decrease.png")!
        }
        return image
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        }
        else if section == 2 {
            return itemValues.count
        }
        else if section == 3 {
            return 0
        }
        
        /*
         else if section == 3 {
             return horizontalAnalysisArray.count
         }
         */
        
        else {
            if testArray.count != 0 {
                if !(testArray[section-4].isExpanded) {
                    return 0
                } else {
                    return testArray[section-4].periods.count
                }
            }
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader && indexPath.section == 3 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "horizontalAnalysisHeader", for: indexPath) as? HorizontalAnalysisHeaderCollectionReusableView
            header?.headerLbl.text = "Horizontal Quick Analysis"
            header?.periodDropDown.addTarget(self, action: #selector(preparePickerView), for: .touchUpInside)
            if testArray.count != 0 {
                header?.periodDropDownLabel.text = String(testArray[0].valuesGrowthStatement.count) + " years"
            }
            return header!
        }
        
        else if kind == UICollectionView.elementKindSectionHeader && indexPath.section >= 4 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "horizontalAnalysis", for: indexPath) as? HorizontalAnalysisCollectionReusableView
            
            let expandMinimizeButton = UIButton()
            expandMinimizeButton.frame = CGRect(x: 0, y: 0, width: collectionView.contentSize.width, height: 100)
            expandMinimizeButton.setTitle("", for: .normal)
            expandMinimizeButton.backgroundColor = .clear
            expandMinimizeButton.addTarget(self, action: #selector(expandMinimizeHeader), for: .touchUpInside)
            expandMinimizeButton.tag = indexPath.section
            header?.addSubview(expandMinimizeButton)
            
            if testArray.count != 0 {
                let itemGrowth = testArray[indexPath.section-4].aagr
                let strValue = String(format: "%.1f", itemGrowth) + "%"
                let attributedString = NSMutableAttributedString(string: strValue)
                attributedString.setAttributes([NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 12), NSAttributedString.Key.foregroundColor: UIColor.white], range: NSMakeRange(0, strValue.count))
                header?.pieChart.centerAttributedText = attributedString
                header?.preparePieChart(avgValue: itemGrowth/100)
                
                header?.implicationLabel.text = testArray[indexPath.section-4].itemName
                
                /*
                if testArray[indexPath.row].isExpanded == true {
                    header?.indicationArrowView.image = UIImage(named: "arrowDown.png")
                } else {
                    header?.indicationArrowView.image = UIImage(named: "arrowUp.png")
                }
                */
            }
            
            /*
            let itemGrowth = itemsGrowth[indexPath.section-3]
            let strValue = String(format: "%.0f", itemGrowth*100) + "%"
            let attributedString = NSMutableAttributedString(string: strValue)
            attributedString.setAttributes([NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 12), NSAttributedString.Key.foregroundColor: UIColor.white], range: NSMakeRange(0, strValue.count))
            header?.pieChart.centerAttributedText = attributedString
            header?.preparePieChart(avgValue: itemGrowth)
            */
            
            return header!
        }
        
        else if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "horizontalAnalysisFooter", for: indexPath)
            return footer
        }
        
        else {
            return IndexCollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "comboChartCell", for: indexPath) as? CombinedChartCollectionViewCell
            cell?.layer.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00).cgColor
            return cell!
        }
        
        else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailedFinancialsCell", for: indexPath) as? FinancialStatementsCollectionViewCell
            cell?.layer.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00).cgColor
            cell?.layer.cornerRadius = 15
            cell?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            return cell!
        }
        else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "financialItem", for: indexPath) as? FinancialItemCollectionViewCell
            cell?.layer.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00).cgColor
            cell?.itemName.text = itemNames[indexPath.row]
            let value = itemValues[indexPath.row]//.abbreviateLargeNumbers() //ADJUST THIS/CREATE NEW FUNCTION SPECIFICALLY FOR FINANCIAL STATEMENTS
            cell?.itemValue.text = String(format: "%.2f", value)
            
            return cell!
        }
        
        else if indexPath.section == 3 {
            
        }
        
        /*
        if indexPath.section == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "horizontalAnalysisCell", for: indexPath) as? HorizontalQuickAnalysisCollectionViewCell
            
            
            let itemGrowth = itemsGrowth[indexPath.row]
            let strValue = String(format: "%.0f", itemGrowth*100) + "%"
            let attributedString = NSMutableAttributedString(string: strValue)
            attributedString.setAttributes([NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 12), NSAttributedString.Key.foregroundColor: UIColor.white], range: NSMakeRange(0, strValue.count))
            cell?.pieChart.centerAttributedText = attributedString
            cell?.preparePieChart(avgValue: itemGrowth)
            
            
            cell?.implicationLabel.text = horizontalAnalysisArray[indexPath.row].dataImplication()
            cell?.layer.cornerRadius = 15
            
            let growthVals = horizontalAnalysisArray[indexPath.row].growthValues
            let per = horizontalAnalysisArray[indexPath.row].periods
            cell?.configureNestedCollectionView(growthValues: growthVals, absoluteValues: growthVals, periods: per)
            
            
            return cell!
        }
        */
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "historyCell", for: indexPath) as? HistoryGrowthCollectionViewCell
        
        cell?.layer.backgroundColor = UIColor.clear.cgColor //UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00).cgColor
        
        let absVal = testArray[indexPath.section-4].valuesRegularStatement[indexPath.row]
        let pctChange = testArray[indexPath.section-4].valuesGrowthStatement[indexPath.row]
        let period = testArray[indexPath.section-4].periods[indexPath.row]
        let arrow = positiveNegativeArrow(value: pctChange)
        
        if let year = (period.split(separator: "-").first) {
            let yearStr = String(year)
            cell?.periodLbl.text = yearStr
        }
        
        cell?.valueLbl.text = "$" + absVal.abbreviateLargeNumbers(format: "%.2f") //String(format: "%.2f", absVal)
        cell?.valueLbl.textColor = positiveNegativeTextColor(value: absVal)
        
        cell?.changeLbl.text = String(format: "%.2f", pctChange) + "%"
        cell?.changeLbl.textColor = positiveNegativeTextColor(value: pctChange)
        
        cell?.indicationArrowView.image = arrow
                
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat
        let height: CGFloat
        
        if section == 3 {
            width = UIScreen.main.bounds.size.width - 40
            height = 80
        }
        
        else if section >= 4 {
            width = UIScreen.main.bounds.size.width - 40
            height = 100
        }
        
        else {
            width = 0
            height = 0
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat
        var height: CGFloat
        
        if indexPath.section == 0 {
            width = UIScreen.main.bounds.size.width - 40
            height = 450
        }

        else if indexPath.section == 1 {
            width = UIScreen.main.bounds.size.width - 40
            height = 130
        }
        
        else if indexPath.section == 2 {
            width = UIScreen.main.bounds.size.width - 40
            height = 20
        }
        
        /*
         else if indexPath.section == 3{
             if horizontalAnalysisArray[indexPath.row].isExpanded == true {
                 width = UIScreen.main.bounds.size.width - 40
                 height = 500
             } else {
                 width = UIScreen.main.bounds.size.width - 40
                 height = 100
             }
         }
         */
        
        else {
            width = UIScreen.main.bounds.size.width - 40
            height = 25
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 || section == 1 /*|| section == 3*/ {
            return UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        }
        else if section == 6 {
            return UIEdgeInsets(top: 0, left: 20, bottom: 50, right: 20)
        }
        else if section >= 4{
            return UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        }
        else {
            return UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        }
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        if section >= 4 {
            width = UIScreen.main.bounds.size.width-40
            height = 20
        }
        return CGSize(width: width, height: height)
    }
    */
}

extension DetailedFinancialsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        yearsOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        label.text = String(yearsOptions[row])
        label.sizeToFit()
        return label
    }
    
}
