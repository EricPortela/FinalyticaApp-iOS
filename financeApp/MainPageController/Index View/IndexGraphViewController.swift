//
//  IndexGraphViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2021-05-30.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class IndexGraphViewController: UIViewController {
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    var indexSymbol = String()
    let headerLabels = [""]
    
    //For Basic Info
    var basicIndexData: [majorIndexFeed] = []
    
    //For Line Chart
    var days = 7
    var rawMajorIndexPrices: [majorIndexPriceDataDaily] = []
    var chartDataSets: [LineChartDataSet] = []
    
    //For Bar Chart
    var volumeDataSets: [BarChartDataSet] = []
    var daysVolume = Int(7)
    var volumeDates = String()
    weak var axisFormatDelegate : IAxisValueFormatter?
    
    let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
    let dispatchGroup = DispatchGroup()
    
    override func viewWillAppear(_ animated: Bool) {
        let tickerLabel = UILabel()
        tickerLabel.text = "Historical Index Data \(indexSymbol)"
        tickerLabel.textAlignment = .center
        tickerLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        tickerLabel.sizeToFit()
        
        self.navigationItem.titleView = tickerLabel
        self.navigationItem.titleView?.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup collectionview
        setUpCollectionView(collectionView: mainCollectionView)
        
        //Request
        completeALLRequests()
        
        //Navigation Controller
        customButtonsNavController()
    }
    
    func customButtonsNavController() {
        let BackImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysOriginal)
        self.navigationController?.navigationBar.backIndicatorImage = BackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = BackImage
        self.navigationController?.navigationBar.tintColor = UIColor.clear
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
        
    func setUpCollectionView(collectionView: UICollectionView) {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(IndexGraphCollectionViewCell.self, forCellWithReuseIdentifier: "indexGraph")
        collectionView.register(VolumeBarChartCollectionViewCell.self, forCellWithReuseIdentifier: "barGraph")
    }
    
    func completeALLRequests() {
        dispatchQueue.async {
            //Request for basic info
            let basicInfoURL = "https://financialmodelingprep.com/api/v3/quote/%5E\(self.indexSymbol)?apikey=\(apiKey)"
            self.getBasicIndexInformation(url: basicInfoURL)
            
            //Request for index prices
            let chartURL = "https://financialmodelingprep.com/api/v3/historical-price-full/%5E\(self.indexSymbol)?apikey=\(apiKey)"
            self.getMajorIndexPrices(url: chartURL, days: self.daysVolume)
            
            self.dispatchGroup.notify(queue: .main) {
                self.prepareMajorIndexPriceData(rawPriceData: self.rawMajorIndexPrices)
                self.prepareMajorIndexVolumeData(rawData: self.rawMajorIndexPrices, days: self.days)
                self.mainCollectionView.reloadData()
            }
        }
    }
    
    func getBasicIndexInformation(url: String) {
        basicIndexData.removeAll()
        dispatchGroup.enter()
        var basicData: [majorIndexFeed] = []
        let url = URL(string: url)

        guard  url != nil else {
            return
        }

        let session = URLSession.shared

        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                do {
                    let dataFeed = try decoder.decode([majorIndexFeed].self, from: data!)
                    
                    for majorIndexData in dataFeed{
                        basicData.append(majorIndexData)
                    }
                    self.basicIndexData = basicData
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
    
    func completeChartRequest(url: String, days: Int) {
        dispatchQueue.async {
            self.getMajorIndexPrices(url: url, days: days)
            
            self.dispatchGroup.notify(queue: .main) {
                self.prepareMajorIndexPriceData(rawPriceData: self.rawMajorIndexPrices)
                self.mainCollectionView.reloadData()
            }
        }
    }
    
    func getMajorIndexPrices(url: String, days: Int) {
        dispatchGroup.enter()
        var dailyPrices : [majorIndexPriceDataDaily] = []
        let url = URL(string: url)
        guard  url != nil else {
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                do {
                    let priceFeed = try decoder.decode(majorIndexPriceFeed.self, from: data!)
                    
                    if let historicalData = priceFeed.historical {
                        if days == 365 {
                            var changeResolution = 5 //Working days
                            for dailyData in historicalData.prefix(days) {
                                if changeResolution % 5 == 0 {
                                    dailyPrices.append(dailyData)
                                }
                                changeResolution += 1
                            }
                        } else if days == 1095 {
                            var changeResolution = 20 //Working days
                            for dailyData in historicalData.prefix(days) {
                                if changeResolution % 20 == 0 {
                                    dailyPrices.append(dailyData)
                                }
                                changeResolution += 1
                            }
                        } else {
                            for dailyData in historicalData.prefix(days) {
                                dailyPrices.append(dailyData)
                            }
                        }
                    }
                    self.rawMajorIndexPrices = dailyPrices
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
    
    func prepareMajorIndexPriceData(rawPriceData: Array<majorIndexPriceDataDaily>){
        chartDataSets.removeAll()
        var count = Double(0)
        
        //Step 1. Create an array containing "ChartDataEntry"
        var lineChartDataEntryClosing: [ChartDataEntry] = []
        var lineChartDataEntryVWAP: [ChartDataEntry] = []
        
        for priceInfo in rawPriceData.reversed(){
            if let closingPrice = priceInfo.close {
                let value = ChartDataEntry(x: count, y: closingPrice)
                lineChartDataEntryClosing.append(value)
            }
            
            if let VWAP = priceInfo.vwap {
                let value = ChartDataEntry(x: count, y: VWAP)
                lineChartDataEntryVWAP.append(value)
            }
            count += 1
        }
        
        //Step 2. Create "LineChartDataSet" with "DataEntry" created above, as its parameter
        let dataSetOne = LineChartDataSet(entries: lineChartDataEntryClosing, label: "Close")
        dataSetOne.colors = [UIColor(red: 0.91, green: 0.68, blue: 0.72, alpha: 1.00)]
        dataSetOne.drawCirclesEnabled = false
        dataSetOne.drawValuesEnabled = false
        dataSetOne.notifyDataSetChanged()
        dataSetOne.mode = .cubicBezier
        chartDataSets.append(dataSetOne)
        
        let dataSetTwo = LineChartDataSet(entries: lineChartDataEntryVWAP, label: "VWAP")
        dataSetTwo.colors = [UIColor(red: 0.73, green: 0.87, blue: 0.93, alpha: 0.87)]
        dataSetTwo.drawCirclesEnabled = false
        dataSetTwo.drawValuesEnabled = false
        dataSetTwo.notifyDataSetChanged()
        dataSetTwo.mode = .cubicBezier
        chartDataSets.append(dataSetTwo)
    }
    
    func prepareMajorIndexVolumeData(rawData: Array<majorIndexPriceDataDaily>, days: Int) {
        volumeDataSets.removeAll()
        var volumeDataEntry: [BarChartDataEntry] = []
        var unadjustedVolumeDataEntry: [BarChartDataEntry] = []
        
        var count = Double(0)
        for priceInfo in rawData.prefix(days) {
            if let date = priceInfo.date {
                volumeDates.append(date)
            }
            if let volume = priceInfo.volume {
                let value = BarChartDataEntry(x: count, y: volume, data: volumeDates)
                volumeDataEntry.append(value)
            }
            
            if let unadjustedVolume = priceInfo.unadjustedVolume {
                let value = BarChartDataEntry(x: count, y: unadjustedVolume)
                unadjustedVolumeDataEntry.append(value)
            }
            count += 1
        }
        
        let dataSetOne = BarChartDataSet(entries: volumeDataEntry, label: "Volume")
        dataSetOne.colors = [UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00)]
        dataSetOne.drawValuesEnabled = false
        dataSetOne.notifyDataSetChanged()
        volumeDataSets.append(dataSetOne)
        
        let dataSetTwo = BarChartDataSet(entries: unadjustedVolumeDataEntry, label: "Unadjusted Volume")
        dataSetTwo.colors = [UIColor(red: 0.65, green: 0.58, blue: 0.98, alpha: 1.00)]
        dataSetTwo.drawValuesEnabled = false
        dataSetTwo.notifyDataSetChanged()
        volumeDataSets.append(dataSetTwo)
    }
    
    func positiveNegativeTextColor(number: Double) -> UIColor {
        let positiveTextColor = UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00)
        let negativeTextColor = UIColor(red: 0.91, green: 0.68, blue: 0.72, alpha: 1.00)
        
        if number > 0 {
            return positiveTextColor
        }
        return negativeTextColor
    }
}

extension IndexGraphViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    
    @objc func changePeriod(segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            print("Hey")
        case 1:
            daysVolume = 7
            let url = "https://financialmodelingprep.com/api/v3/historical-price-full/%5E\(self.indexSymbol)?apikey=\(apiKey)"
            completeChartRequest(url: url, days: daysVolume)
        case 2:
            daysVolume = 30
            let url = "https://financialmodelingprep.com/api/v3/historical-price-full/%5E\(self.indexSymbol)?apikey=\(apiKey)"
            completeChartRequest(url: url, days: daysVolume)
        case 3:
            daysVolume = 90
            let url = "https://financialmodelingprep.com/api/v3/historical-price-full/%5E\(self.indexSymbol)?apikey=\(apiKey)"
            completeChartRequest(url: url, days: daysVolume)
        case 4:
            print("Hey")
        case 5:
            daysVolume = 365
            let url = "https://financialmodelingprep.com/api/v3/historical-price-full/%5E\(self.indexSymbol)?apikey=\(apiKey)"
            completeChartRequest(url: url, days: daysVolume)
        case 6:
            daysVolume = 1095
            let url = "https://financialmodelingprep.com/api/v3/historical-price-full/%5E\(self.indexSymbol)?apikey=\(apiKey)"
            completeChartRequest(url: url, days: daysVolume)
        case 7:
            print("Hey")
        default:
            print("No")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat
        var height: CGFloat
        
        if indexPath.section == 0 {
            width = CGFloat(UIScreen.main.bounds.size.width-40)
            height = 460
        } else {
            width = CGFloat(UIScreen.main.bounds.size.width-40)
            height = 200
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "indexGraph", for: indexPath) as? IndexGraphCollectionViewCell

            cell?.segmentedControl.addTarget(self, action: #selector(changePeriod), for: .valueChanged)
            
            if chartDataSets.count > 0 {
                let data = LineChartData(dataSets: chartDataSets)
                cell?.lineChart.data = data
                cell?.lineChart.data?.notifyDataChanged()
                cell?.lineChart.notifyDataSetChanged()
            }
            
            if basicIndexData.count != 0 {
                //Index Symbol/ticker
                if let symbol = basicIndexData[indexPath.row].symbol {
                    cell?.tickerLabel.text = String(symbol.dropFirst())
                }
                
                //Index Name
                if let name = basicIndexData[indexPath.row].name {
                    cell?.nameLabel.text = name
                }
                
                if let price = basicIndexData[indexPath.row].price, let change = basicIndexData[indexPath.row].changesPercentage {
                    let strPrice = String(format: "%.2f", price)
                    let strChange = String(format: "%.2f", change)
                    let priceAndChange = NSMutableAttributedString.init(string: "\(strPrice) (\(strChange)%)")
                    
                    let percentageTextColor = positiveNegativeTextColor(number: change)
                    priceAndChange.setAttributes([NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 14), NSAttributedString.Key.foregroundColor: percentageTextColor], range: NSMakeRange(strPrice.count+1, strChange.count+3))
                    cell?.priceLabel.attributedText = priceAndChange
                }
            }
            return cell!
        }
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "barGraph", for: indexPath) as? VolumeBarChartCollectionViewCell
        cell?.backgroundColor = .tertiarySystemBackground
        cell?.layer.cornerRadius = 15
        
        if volumeDataSets.count > 0 {
            let data = BarChartData(dataSets: volumeDataSets)
            
            //Set width, spacing, etc. for the groupedBarChart
            //(barWidth + barSpace) * (no.of.bars per group) + groupSpace = 1.00 -> interval per "group"
            let groupSpace = 0.05
            let barSpace = 0.05
            let barWidth = ((1.0-groupSpace)/2)-barSpace
                        
            data.barWidth = barWidth
            data.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
            cell?.barChart.data = data
            cell?.barChart.data?.notifyDataChanged()
            cell?.barChart.notifyDataSetChanged()
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat
        let height: CGFloat
        
        if section == 0 {
            width = 0
            height = 0
        } else {
            width = 0
            height = 40
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = mainCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "IndexSectionHeader", for: indexPath) as! IndexGraphCollectionReusableView
    
        if indexPath.section == 1 {
            sectionHeader.indexPrice.text = "Trading volumes"
        }
        return sectionHeader
    }
}
