//
//  FavoriteStocksViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2021-07-30.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Firebase
import Charts

class FavoriteStocksViewController: UIViewController {
    
    let screenWidth = UIScreen.main.bounds.size.width - 10
    let screenHeight = UIScreen.main.bounds.size.height / 5
    var selectedRow = 0
    var alert = UIAlertController(title: "Sort Favorites", message: "", preferredStyle: .actionSheet)
    
    private let dispatchGroup = DispatchGroup()
    var favoriteTickers: String = ""
    let sortOptions = ["Alphabetical", "Closing Price", "EPS", "Market Cap", "PE"]
    
    private var allRawStockPriceData: [[dailyStockPrices]] = []
    private var stockPriceLineChartDataSets: [LineChartDataSet] = []
    private var favoriteStocksOrdered = [String]()
    
    private let database = Database.database().reference()

    @IBOutlet weak var favoriteStocksCollectionView: UICollectionView!
    
    var batchData = [majorIndexFeed]()
    
    //Dispatch Queue
    let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stockPricesBatchRequest(baseURL: "https://financialmodelingprep.com/api/v3/historical-price-full/", days: 365, tickers: ["AAPL", "TSLA", "MSFT", "BABA"])
        getFavorites()
        
        dispatchGroup.notify(queue: .main) {
            self.prepareStockPriceBatchData(rawStockPriceData: self.allRawStockPriceData)
            self.favoriteStocksCollectionView.reloadData()
        }
        //Set up collectionview
        setUpCollectionView()

        
        //Set up custom navigation controller
        customButtonsNavController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tickerLabel = UILabel()
        tickerLabel.text = "Favorite Stocks"
        tickerLabel.textAlignment = .center
        tickerLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        tickerLabel.sizeToFit()

        self.navigationItem.titleView = tickerLabel
        self.navigationItem.titleView?.isHidden = true
     }
    
    func customButtonsNavController() {
        let BackImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysOriginal)
        self.navigationController?.navigationBar.backIndicatorImage = BackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = BackImage
        self.navigationController?.navigationBar.tintColor = UIColor.clear
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setUpCollectionView() {
        favoriteStocksCollectionView.delegate = self
        favoriteStocksCollectionView.dataSource = self
        favoriteStocksCollectionView.register(FavoriteStocksTopCollectionViewCell.self, forCellWithReuseIdentifier: "topCell")
        favoriteStocksCollectionView.register(FavoriteStocksGraphCollectionViewCell.self, forCellWithReuseIdentifier: "graphCell")
        favoriteStocksCollectionView.register(FavoriteStocksCollectionViewCell.self, forCellWithReuseIdentifier: "favoriteStocksCell")
        favoriteStocksCollectionView.register(FavoriteStocksCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "favoriteStocksHeader")
        favoriteStocksCollectionView.backgroundColor = .none
        favoriteStocksCollectionView.showsHorizontalScrollIndicator = false
        favoriteStocksCollectionView.showsVerticalScrollIndicator = false
        let layout = favoriteStocksCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    func getFavorites() {
        var tickerArray: [String] = []
        database.child("favoriteStocks").observe(.value) { (snapshot) in
            let lenght = (snapshot.childrenCount)
            self.database.child("favoriteStocks").observe(.childAdded) { (snapshot) in
                guard let value = snapshot.value as? String else {return}
                tickerArray.append(value)
                if tickerArray.count == lenght {
                    let groupedTickers = tickerArray.joined(separator: ",")
                    
                    let url = "https://financialmodelingprep.com/api/v3/quote/\(groupedTickers)?apikey=\(apiKey)"
                    self.getFavoriteStocksData(url: url)
                }
            }
        }
    }
    
    func sortFavorites(sortBy: String) {
        if sortBy == "Alphabetical" {
            batchData.sort {
                let first = $0.symbol ?? "z"
                let second = $1.symbol ?? "z"
                return first < second
            }
        }
        else if sortBy == "Market Cap" {
            batchData.sort {
                let first = $0.marketCap ?? -9999
                let second = $1.marketCap ?? -9999
                return first > second
            }
        }
        else if sortBy == "PE" {
            batchData.sort {
                let first = $0.pe ?? -9999
                let second = $1.pe ?? -9999
                return first > second
            }
        }
        else if sortBy == "Closing Price" {
            batchData.sort {
                let first = $0.price ?? -9999
                let second = $1.price ?? -9999
                return first > second
            }
        }
        else if sortBy == "EPS" {
            batchData.sort {
                let first = $0.eps ?? -9999
                let second = $1.eps ?? -9999
                return first > second
            }
        }
    }
    
    private func getFavoriteStocksData(url: String) -> Void {
        self.dispatchGroup.enter()
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
                    
                                        
                    DispatchQueue.main.async {
                        self.batchData = dataFeed
                        
                        self.sortFavorites(sortBy: self.sortOptions[self.selectedRow])
                        
                        /*
                        self.favoriteStocksCollectionView.performBatchUpdates({
                            self.favoriteStocksCollectionView.reloadSections(IndexSet(integersIn: 1...1))
                        }, completion: nil)
                        */
                        self.favoriteStocksCollectionView.reloadData()
                        self.dispatchGroup.leave()
                        /*
                         self.favoriteStocksCollectionView.performBatchUpdates({
                             //self.favoriteStocksCollectionView.collectionViewLayout.invalidateLayout()
                             self.favoriteStocksCollectionView.insertItems(at: [IndexPath(row: self.batchData.count-1, section: 1)])
                         }, completion: nil)
                         */
                    }
                    
                    /*
                    if let favoriteCount = (self.database.child("favoriteStocks").key?.count) {
                        //print(favoriteCount)
                        //print(self.batchData.count)
                        if self.batchData.count == favoriteCount {
                            self.dispatchQueue.async {
                                self.favoriteStocksCollectionView.reloadData()
                            }
                        }
                    }
                    */
                    
                    //self.dispatchGroup.leave()

                    /*
                    DispatchQueue.main.async {
                        self.favoriteStocksCollectionView.performBatchUpdates({
                            //self.favoriteStocksCollectionView.collectionViewLayout.invalidateLayout()
                            self.favoriteStocksCollectionView.insertItems(at: [IndexPath(row: self.batchData.count-1, section: 1)])
                        }, completion: nil)
                    }
                    */
                }
                catch {
                    print("Error in JSON parsing")
                    self.dispatchGroup.leave()
                }
            }
        }
        dataTask.resume()
    }
    
    private func stockPricesBatchRequest(baseURL: String, days: Int, tickers: Array<String>) -> Void {
        dispatchGroup.enter()
        allRawStockPriceData.removeAll()
        favoriteStocksOrdered.removeAll()
        
        var rawData: [[dailyStockPrices]] = []
        
        var tickersCombined = String()
        for ticker in tickers {
            if ticker == tickers[0] {
                tickersCombined += ticker
            }
            else {
                tickersCombined += ",\(ticker)"
            }
        }

        let urlString = String(baseURL + tickersCombined + "?apikey=\(apiKey)")
        
        let url = URL(string: urlString)
        guard  url != nil else {
          return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                do {
                    let batchPriceFeed = try decoder.decode(batchStocksPriceFeed.self, from: data!)
                    if let historicalBatchData = batchPriceFeed.historicalStockList {
                        for companyData in historicalBatchData { //Iterate through each dataset for every company
                            var dailyStockPriceData: [dailyStockPrices] = []
                            if let dailyHistoricalPriceData = companyData.historical {
                                if days == 365 {
                                    var changeResolution = 5
                                    for dailyPriceData in dailyHistoricalPriceData.prefix(days) {
                                        if changeResolution % 5 == 0 {
                                            //print(dailyPriceData)
                                            dailyStockPriceData.append(dailyPriceData)
                                        }
                                        changeResolution += 1
                                    }
                                } else if days == 1095 {
                                    var changeResolution = 20
                                    for dailyPriceData in dailyHistoricalPriceData.prefix(days) {
                                        if changeResolution % 20 == 0 {
                                            //print(dailyPriceData)
                                            dailyStockPriceData.append(dailyPriceData)
                                        }
                                        changeResolution += 1
                                    }
                                }
                                else {
                                    for dailyPriceData in dailyHistoricalPriceData.prefix(days) {
                                        dailyStockPriceData.append(dailyPriceData)
                                    }
                                }
                            }
                            if let name = companyData.symbol {
                                self.favoriteStocksOrdered.append(name)
                            }
                            DispatchQueue.main.async {
                                rawData.append(dailyStockPriceData)
                                self.allRawStockPriceData = rawData
                            }
                        }
                    }
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
    
    private func prepareStockPriceBatchData(rawStockPriceData: Array<Array<dailyStockPrices>>) -> Void {
        stockPriceLineChartDataSets.removeAll()
        var c = Int(0)
        let lineColors = [UIColor(red: 0.91, green: 0.68, blue: 0.72, alpha: 1.00), UIColor(red: 0.73, green: 0.87, blue: 0.93, alpha: 0.87), UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00), UIColor(red: 0.95, green: 0.56, blue: 0.00, alpha: 1.00)]
        for companyData in rawStockPriceData {
            var count = Double(0)
            var lineChartDataEntry: [ChartDataEntry] = []
            for dailyPriceData in companyData.reversed() {
                if let change = dailyPriceData.close {
                    let value = ChartDataEntry(x: count, y: change)
                    lineChartDataEntry.append(value)
                    count += 1
                }
            }
            let dataSet = LineChartDataSet(entries: lineChartDataEntry, label: favoriteStocksOrdered[c])
            dataSet.colors = [lineColors[c]]
            dataSet.drawCirclesEnabled = false
            dataSet.mode = .cubicBezier
            dataSet.notifyDataSetChanged()
            stockPriceLineChartDataSets.append(dataSet)
            c += 1
        }
    }
    
    @objc func preparePickerView() {
        alert = UIAlertController(title: "Sort Favorites", message: "", preferredStyle: .actionSheet)
        //alert.reloadInputViews()
        
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
            DispatchQueue.main.async {
               self.sortFavorites(sortBy: self.sortOptions[self.selectedRow])
               self.favoriteStocksCollectionView.reloadData()
           }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension FavoriteStocksViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return batchData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = favoriteStocksCollectionView.dequeueReusableCell(withReuseIdentifier: "topCell", for: indexPath) as? FavoriteStocksTopCollectionViewCell
                return cell!
            }
            
            let cell = favoriteStocksCollectionView.dequeueReusableCell(withReuseIdentifier: "graphCell", for: indexPath) as? FavoriteStocksGraphCollectionViewCell
            if stockPriceLineChartDataSets.count > 0 {
                let data = LineChartData(dataSets: stockPriceLineChartDataSets)
                data.setDrawValues(false)
                cell?.lineChart.data = data
                cell?.lineChart.data?.notifyDataChanged()
                cell?.lineChart.notifyDataSetChanged()
            }
            return cell!
        }
        
        let cell = favoriteStocksCollectionView.dequeueReusableCell(withReuseIdentifier: "favoriteStocksCell", for: indexPath) as? FavoriteStocksCollectionViewCell
        /*
         cell?.layer.cornerRadius = 5
         cell?.layer.borderWidth = 2
         cell?.layer.borderColor = UIColor.gray.cgColor
         */
        
        if let symbol = batchData[indexPath.row].symbol {
            cell?.ticker.text = symbol
        } else {
            cell?.ticker.text = "--"
        }
        
        if let closingPrice = batchData[indexPath.row].previousClose {
            let closingPriceStr = "$" + String(format: "%.2f", closingPrice)
            cell?.closingPrice.text = closingPriceStr
        } else {
            cell?.closingPrice.text = "--"
        }
        
        if let eps = batchData[indexPath.row].eps {
            let epsStr = "$" + String(format: "%.2f", eps)
            cell?.eps.text = epsStr
        } else {
            cell?.eps.text = "--"
        }
        
        if let pe = batchData[indexPath.row].pe {
            let peStr = String(format: "%.2f", pe)
            cell?.pe.text = peStr
        } else {
            cell?.pe.text = "--"
        }
        
        if let marketCap = batchData[indexPath.row].marketCap {
            let marketCapStr = "$" + marketCap.abbreviateLargeNumbers(format: "%.0f") //+ String(format: "%.2f", marketCap)
            cell?.marketCap.text = marketCapStr
        } else {
            cell?.marketCap.text = "--"
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat
        let height: CGFloat
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                width = UIScreen.main.bounds.size.width - 40
                height = 80
            } else {
                width = UIScreen.main.bounds.size.width - 40
                height = 300
            }
            
        } else {
            width = UIScreen.main.bounds.size.width - 40
            height = 50
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var top: CGFloat
        var left: CGFloat
        var bottom: CGFloat
        var right: CGFloat
        
        if section == 1 {
            top = 20
            left = 20
            bottom = 0
            right = 20
        }
        
        else {
            top = 0
            left = 0
            bottom = 0
            right = 0
        }
        
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 10
      }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = favoriteStocksCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "favoriteStocksHeader", for: indexPath) as! FavoriteStocksCollectionReusableView
            
            alert.popoverPresentationController?.sourceView = sectionHeader.filterButton
            alert.popoverPresentationController?.sourceRect = sectionHeader.filterButton.bounds
            sectionHeader.filterButton.addTarget(self, action: #selector(preparePickerView), for: .touchUpInside)
            sectionHeader.filterLabel.text = self.sortOptions[self.selectedRow]
            //sectionHeader.layer.borderWidth = 2
            //sectionHeader.layer.borderColor = UIColor.gray.cgColor
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat
        let height: CGFloat
        if section == 1 {
            width = UIScreen.main.bounds.size.width - 40
            height = 80
        }
        else {
            width = 0
            height = 0
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let details = storyboard.instantiateViewController(withIdentifier: "detailsView") as! DetailsViewController
        
        if let ticker = batchData[indexPath.row].symbol {
            details.ticker = ticker
            self.navigationController?.pushViewController(details, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y) >= -25 {
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
}


extension FavoriteStocksViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        sortOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        label.text = sortOptions[row]
        label.sizeToFit()
        return label
    }
}

