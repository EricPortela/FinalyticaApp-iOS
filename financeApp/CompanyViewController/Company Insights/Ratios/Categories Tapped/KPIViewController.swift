//
//  KPIViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2020-11-27.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class KPIViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var kpiTypeLbl: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var KPICollectionView: UICollectionView!
    @IBOutlet weak var mainView: UIView!
    
    @IBAction func closePopUpView(_ sender: Any) {
           self.dismiss(animated: true, completion: nil)
       }
    
    var ticker = String()
    var yearlyRatiosDates : [Date] = []
    var yearlyRatiosDict = [String() : [String : Any]()]
    
    var kpiCategory = String() //Get which KPI category user has chosen
    let dateFormatter = DateFormatter()
    let dispatchGroup = DispatchGroup()
    
    
    var kpiNames = [String]()
    var kpiValues = [String]()
    var kpiDates = [String]()
    
    //var allKPIValues = [[String]()]

    //Valuation ratios
    var valuationValues = [String]()

    //Capital strenght
    var capitalStrenghtValues = [String]()
    
    //Liqudity
    var liquidityValues = [String]()

    //Profitability
    var profitabilityValues = [String]()
    
    //All KPIs
    let allKPIs = ["VALUATION" : ["priceToBookRatio", "priceToSalesRatio", "priceEarningsRatio", "priceToFreeCashFlowsRatio", "priceToOperatingCashFlowsRatio","priceCashFlowRatio", "priceEarningsToGrowthRatio", "priceSalesRatio", "enterpriseValueMultiple"],
                   
                   
                   "LEVERAGE" : ["interestCoverage", "debtRatio", "debtEquityRatio", "longTermDebtToCapitalization", "totalDebtToCapitalization"], //CAPITAL STRENGHT
                   
                   
                   "LIQUIDITY" : ["quickRatio", "currentRatio", "daysOfSalesOutstanding", "operatingCashFlowSalesRatio"],
                   
                   
                   "PROFITABILITY" : ["returnOnAssets", "returnOnEquity", "returnOnCapitalEmployed", "grossProfitMargin", "operatingProfitMargin", "pretaxProfitMargin",
                                      "netProfitMargin"]] as [String : Array<String>]
    
    var kpiHistoricalValuesForChart = [String() : [NSNumber()]]
    
    var timePeriod = "Y"

    @IBAction func chooseTimePeriod(_ sender: UISegmentedControl) {
        //Ticker
        switch sender.selectedSegmentIndex {
            case 0:
                //Get yearly financial data
                dispatchGroup.notify(queue: .main) {
                    self.timePeriod = "Y"
                    let ratioLink = self.getRatioLink(period: self.timePeriod)
                    self.getYearlyRatios(urlLink: ratioLink)
                }
            case 1:
                //Get quarterly financial data
                dispatchGroup.notify(queue: .main) {
                    self.timePeriod = "Q"
                    let ratioLink = self.getRatioLink(period: self.timePeriod)
                    self.getYearlyRatios(urlLink: ratioLink)
                }
            default:
                print("Latest")
        }
    }
    
    
    func getRatioLink(period: String) -> String {
        var ratioLink = ""
        if period == "Q" {
            ratioLink = "https://financialmodelingprep.com/api/v3/ratios/\(ticker)?period=quarter&limit=40&apikey=\(apiKey)"
        } else if period == "Y" {
            ratioLink = "https://financialmodelingprep.com/api/v3/ratios/\(ticker)?limit=40&apikey=\(apiKey)"
        }
        return ratioLink
    }
        
    func getYearlyRatios(urlLink : String ) {
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        
        yearlyRatiosDates.removeAll()
        
        //Retrieve yearly ratio data
        guard let url = URL(string: urlLink) else { return }
              URLSession.shared.dataTask(with: url) { (data, response, err) in
                guard let data = data else { return }
                  do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                        DispatchQueue.main.async{ //https://medium.com/@broebling/dispatchqueue-main-the-main-queue-is-a-serial-queue-4607417fe535 or check "search documentation in swift" under "Updating UI from a Completion Handler"
                            
                            for yearlyRatios in json { //Iterate through the data array
                                if let dataset = yearlyRatios as? Dictionary<String, Any> { //Handle optional values, in case the retrived data is nil
                                    if let strDate = dataset["date"] as? String { //Handle optional values, in case the date is nil
                                        self.yearlyRatiosDict[strDate] = dataset //Populate the dictionary with date as key and the retrieved data for that date, as value
                                        //print(strDate)
                                        //print(dataset)
                                        
                                        if let date = self.dateFormatter.date(from: strDate) {
                                            self.yearlyRatiosDates.append(date) //Append all yearly dates to the array
                                        }
                                    }
                                }
                            }
                            
                          //When upper iteration is finished and all data has been added to our dict and array, keep working from this point
                        let periodDate = self.yearlyRatiosDates.first //Get kpi from last year
                            
                            
                        let tenLastYears = Array(self.yearlyRatiosDates.prefix(10))
                        //Get ratios for last period/year
                          self.dateFormatter.dateFormat = "yyyy-MM-dd"
                          if let year = periodDate {
                             let strPeriodDate = self.dateFormatter.string(from: year)
                              if let latestPeriodData = self.yearlyRatiosDict[strPeriodDate] {
                                self.getDataLatestYear(dict: latestPeriodData, date: periodDate!) //Populate UICollectionView
                                print(latestPeriodData)
                                //print(self.yearlyRatiosDict)
                                self.preparationForMiniChart(dict: latestPeriodData, yearsArray: tenLastYears, APIResponse: (self.yearlyRatiosDict)) //Populate the minicharts in UICollectionView with data
                              }
                          }
                        }
                    }
                } catch let jsonErr {
                    print("Error serializing json:", jsonErr)
                  }
              }.resume()
        }
    
    
    func preparationForMiniChart(dict : Dictionary<String, Any>, yearsArray: Array<Date>, APIResponse : Dictionary<String, Dictionary<String, Any>>) {
        var historicalKPIs = [NSNumber]()
        
        if let kpisInCategory = (allKPIs[kpiCategory]) {
            kpiHistoricalValuesForChart.removeAll()
            for kpi in kpisInCategory {
                historicalKPIs.removeAll()
                for year in yearsArray {
                    self.dateFormatter.dateFormat = "yyyy-MM-dd"
                    let strYear = self.dateFormatter.string(from: year)
                    //print(strYear)
                    if let yearlyData = APIResponse[strYear] {
                        if let historicalKPI = (yearlyData[kpi]) as? NSNumber {
                            //print(historicalKPI)
                            historicalKPIs.append(historicalKPI)
                        }
                    }
                }
                kpiHistoricalValuesForChart[kpi] = historicalKPIs.reversed()
            }
            KPICollectionView.reloadData()
        }
    }
    
    func miniBarChart(barChart : BarChartView, kpiType : String, kpiHistoricalValues : Dictionary<String, Array<NSNumber>>) {
        var entry = [BarChartDataEntry]()
        var c = 0
        var colorArray = [UIColor]()

        if let historicalValues = kpiHistoricalValues[kpiType] {
            for value in historicalValues {
                let roundedValue = (round(Double(value)*100)/100)
                let dataEntry = BarChartDataEntry(x: Double(c), y: Double(roundedValue))
                entry.append(dataEntry)
                
                if Float(value) >= 0 {
                    colorArray.append(UIColor(red: 0.09, green: 0.56, blue: 0.80, alpha: 1.00))
                } else {
                    colorArray.append(UIColor(red: 0.81, green: 0.12, blue: 0.66, alpha: 1.00))
                }
                c += 1
               }
        }
            
           
        let set = BarChartDataSet(entries: entry, label: "")
        set.drawValuesEnabled = false
        set.highlightEnabled = false
        set.colors = [UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00)] //colorArray
        set.valueColors = [UIColor.white]

        let data = BarChartData(dataSet: set)
        barChart.data = data

        //Editing the chart generally
        //barChart.animate(yAxisDuration: 1.0, easingOption: .easeInOutQuart)
        barChart.legend.enabled = false //remove the legend/color box
        barChart.doubleTapToZoomEnabled = false //remove double tap zoom
        barChart.pinchZoomEnabled = false //remove pinch zoom
        barChart.setScaleEnabled(false) //removes all zoom/scaling

        //y-Axis editing (leftAxis and rightAxis)
        barChart.leftAxis.enabled = false //disables everything on leftaxis (labels, gridlines, etc)
        barChart.rightAxis.enabled = false

        //x-Axis editing
        barChart.xAxis.enabled = false
    }
      
    
    func getDataLatestYear(dict : Dictionary<String, Any>, date: Date) {
        kpiNames.removeAll()
        kpiValues.removeAll()
        kpiDates.removeAll()
        
        let strYear = self.dateFormatter.string(from: date)
        
        dispatchGroup.enter()
        if let selectedCategory = allKPIs[kpiCategory] {
            for kpi in selectedCategory {
                kpiNames.append(kpi)
                //convertCamelCase(camelCase: kpi)
                if let value = dict[kpi] as? Double {
                    let strValue = String(format: "%.2f", value)
                    kpiValues.append(strValue)
                    KPICollectionView.reloadData()
                    kpiDates.append(strYear)
                    }
                else {
                    kpiValues.append("n/A")
                    KPICollectionView.reloadData()
                    kpiDates.append("n/A")
                    }
                KPICollectionView.reloadData()
                }
            
            KPICollectionView.reloadData()
            dispatchGroup.leave()
        }
    }
    
    func convertCamelCase(camelCase: String) -> String {
        var word = String()
        
        var count = 0
        for i in camelCase{
            if i.isUppercase == true{
                word += " \(i)"
            } else if count == 0{
                word += String(i.uppercased())
            } else{
                word += String(i)
            }
            count += 1
        }
        return word
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeBtn.layer.cornerRadius = 10
                
        //Ticker
        kpiTypeLbl.text = "\(kpiCategory) (\(ticker))"//Top label, KPI type/category

        //Get yearly financial data per default
        if kpiCategory != "" {
            dispatchGroup.notify(queue: .main) {
                let ratioLink = self.getRatioLink(period: self.timePeriod)
                self.getYearlyRatios(urlLink: ratioLink)
            }
        }
    }
}

extension KPIViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kpiValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (KPICollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? KPICollectionViewCell)
        
        let kpiName = kpiNames[indexPath.row]
        cell?.KPILbl.text = convertCamelCase(camelCase: kpiName)
        cell?.KPIValue.text = kpiValues[indexPath.row]
        cell?.KPIDate.text = kpiDates[indexPath.row]
        //cell?.contentView.layer.cornerRadius = 20
                
        //Cell Shadow
        cell?.contentView.layer.cornerRadius = 20
        /*
        cell?.layer.shadowColor = UIColor.gray.cgColor
        cell?.layer.shadowOffset = .zero //CGSize(width: 2, height: 2)
        cell?.layer.shadowRadius = 2
        cell?.layer.shadowOpacity = 0.5
        cell?.layer.masksToBounds = false
        cell?.layer.shadowPath = UIBezierPath(roundedRect: cell!.bounds, cornerRadius: cell!.contentView.layer.cornerRadius).cgPath
        */
        
        miniBarChart(barChart: (cell?.miniBarChart)!, kpiType: kpiNames[indexPath.row], kpiHistoricalValues: kpiHistoricalValuesForChart)
        
        return cell!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let details = storyboard.instantiateViewController(withIdentifier: "showHistoricalData") as! historicalKPIViewController
        details.kpiType = kpiNames[indexPath.row]
        details.timePeriod = timePeriod
        details.ticker = ticker
        self.present(details, animated: true, completion: nil)
    }
}

extension KPIViewController {
    
    func convertCamelCase(camelCase: String) {
        var count = 0
        var wordCount = 0
        
        for i in camelCase {
            if i.isUppercase && wordCount == 0{
                print(camelCase.prefix(count))
                print(camelCase[camelCase.index(camelCase.startIndex, offsetBy: count)])
                wordCount += 1
            } else if i.isUppercase{
               
            }
            
            count += 1
        }
    }
}
