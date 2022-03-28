//
//  MajorCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-08-06.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

protocol IndexSelectionDelegate {
    func didTap(symbol: String)
}

protocol IndexEditSelectionDelegate {
    func didTap()
}

class MajorCollectionViewCell: UICollectionViewCell {
    
    public var selectionDelegate: IndexSelectionDelegate!
    public var indexEditSelectionDelegate: IndexEditSelectionDelegate!
    
    private struct majorIndex {
        var symbol: String?
        var close: Double?
        var change: Double?
        var pctChange: Double?
        var priceData: [majorIndexPriceDataDaily]?
    }
    
    private var majorIndexData: [majorIndex] = []
    private var selectedMajorIndexes = ["DJI", "GSPC", "NYA", "IXIC"]
    private var allMajorIndexLineChartDataSets : [LineChartDataSet?] = []
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    private let majorIndexCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
     
    private func setUpView() -> Void {
        
        //Delegate and DataSource
        majorIndexCollectionView.dataSource = self
        majorIndexCollectionView.delegate = self
        
        //Register cell
        majorIndexCollectionView.register(MajorIndexCollectionViewCell.self, forCellWithReuseIdentifier: "majorIndexCell")
        majorIndexCollectionView.register(MajorIndexCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "majorIndexHeader")
        
        //Layout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: 160, height: 60)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 15
        majorIndexCollectionView.collectionViewLayout = layout
        layout.sectionHeadersPinToVisibleBounds = true
        
        //Frame
        let collectionViewWidth = UIScreen.main.bounds.size.width
        let collectionViewHeight = CGFloat(70)
        majorIndexCollectionView.frame = CGRect(x: 20, y: 0, width: collectionViewWidth, height: collectionViewHeight)
        self.addSubview(majorIndexCollectionView)
        
        //API Call
        var joinedSymbols = String()
        for symbol in selectedMajorIndexes {
            joinedSymbols += "%5E\(symbol),"
        }
        
        let url = "https://financialmodelingprep.com/api/v3/historical-price-full/\(joinedSymbols)?apikey=\(apiKey)"
        self.getMajorIndexPrices(url: url)        
    }

    private func convertStringDateTimeToStringDate(date: String) -> String {
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
    
    private func sortData() -> Void {
        majorIndexData.sort {
            let first = $0.close ?? -9999
            let second = $1.close ?? -9999
            return first > second
        }
    }

    private func getMajorIndexPrices(url: String) -> Void {
        self.majorIndexData.removeAll()
        
        let url = URL(string: url)
        guard  url != nil else {
         return
        }

        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
         if error == nil && data != nil {
             let decoder = JSONDecoder()
             
             do {
                 let historicalPriceFeed = try decoder.decode(majorIndexBatchFeed.self, from: data!)
                 
                if let batchData = historicalPriceFeed.historicalStockList {
                    
                    for indexData in batchData {
                        if let historicalPrices = indexData.historical {
                            let priceData = Array(historicalPrices.suffix(120))
                            
                            if let latest = priceData[0].close, let earliest = priceData.last?.close, let symbol = indexData.symbol {
                                let change = latest - earliest
                                let pctChange = ((latest*100)/earliest) - 100
                                let briefData = majorIndex(symbol: symbol, close: latest, change: change, pctChange: pctChange, priceData: priceData)
                                self.majorIndexData.append(briefData)
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.sortData()
                    self.prepareMajorIndexPriceData(rawPriceData: self.majorIndexData)

                    //Reload collectionview
                    self.majorIndexCollectionView.performBatchUpdates({
                        self.majorIndexCollectionView.reloadSections(IndexSet(integersIn: 0...0))
                    }, completion: nil)
                    //self.majorIndexCollectionView.reloadData()
                }
             }
             catch {
                 print("Error in JSON parsing")
             }
         }
    }
    dataTask.resume()
    }

    private func prepareMajorIndexPriceData(rawPriceData: Array<majorIndex>) -> Void{
        allMajorIndexLineChartDataSets.removeAll()
        for majorIndexData in rawPriceData {
            var count = Double(0)
            
            //Step 1. Create an array containing "ChartDataEntry"
            var lineChartDataEntry: [ChartDataEntry] = []
            
            if let priceData = majorIndexData.priceData {
                for priceInfo in priceData.reversed(){
                    if let closingPrice = priceInfo.close {
                        let value = ChartDataEntry(x: count, y: closingPrice)
                        lineChartDataEntry.append(value)
                        count += 1
                    }
                }
            }
            
            //Step 2. Create "LineChartDataSet" with "DataEntry" created above, as its parameter
            let dataSet = LineChartDataSet(lineChartDataEntry)
            dataSet.drawCirclesEnabled = false
            allMajorIndexLineChartDataSets.append(dataSet)
        }
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MajorCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @objc func editMajorIndexList() {
        print("Add new index")
        indexEditSelectionDelegate.didTap()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMajorIndexLineChartDataSets.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = majorIndexCollectionView.dequeueReusableCell(withReuseIdentifier: "majorIndexCell", for: indexPath) as? MajorIndexCollectionViewCell
        
        let positiveViewColor = UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00)
        let negativeViewColor = UIColor(red: 0.89, green: 0.00, blue: 0.40, alpha: 1.00)
        
        //Index Symbol
        if let symbol = majorIndexData[indexPath.row].symbol {
            cell?.indexName.text = symbol
        }
        //Index Value
        if let value = majorIndexData[indexPath.row].close{
            cell?.indexValue.text = String(format: "%.2f", value)
        }
        
        //Index Percentage Change
        if let percentageChange = majorIndexData[indexPath.row].pctChange {
            if percentageChange > 0 {
                cell?.valuePercentageChange.textColor = positiveViewColor
            } else {
                cell?.valuePercentageChange.textColor = negativeViewColor
            }
            cell?.valuePercentageChange.text = String(format: "%.2f", percentageChange) + "%"
        }
        
        //Populate Mini Charts
        if let dataSet = allMajorIndexLineChartDataSets[indexPath.row] {
            if let change = majorIndexData[indexPath.row].change{
                if change > 0 {
                    dataSet.colors = [UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00)] //[positiveViewColor]
                    //dataSet.fillColor = positiveViewColor
                } else {
                    dataSet.colors = [UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00)] //[negativeViewColor]
                    //dataSet.fillColor = negativeViewColor
                }
                //dataSet.drawFilledEnabled = true
                dataSet.fillAlpha = 0.3
                //cell?.miniGraph.clear()
                let data = LineChartData(dataSet: dataSet)
                data.setDrawValues(false)
                cell?.miniGraph.data = data
                dataSet.notifyDataSetChanged()
                cell?.miniGraph.data?.notifyDataChanged()
                cell?.miniGraph.notifyDataSetChanged()
            }
        }
        
        cell?.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00)
        cell?.layer.cornerRadius = 10
        cell?.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell?.layer.shadowColor = UIColor.darkGray.cgColor
        cell?.layer.shadowRadius = 2
        cell?.layer.shadowOpacity = 0.2
        cell?.layer.masksToBounds = false
        cell?.layer.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00).cgColor //UIColor.tertiarySystemBackground.cgColor
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = majorIndexCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "majorIndexHeader", for: indexPath) as! MajorIndexCollectionReusableView
            header.addButton.addTarget(self, action: #selector(editMajorIndexList), for: .touchUpInside)
            return header
        } else {
            return IndexCollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let symbol = majorIndexData[indexPath.row].symbol {
            selectionDelegate?.didTap(symbol: symbol)
        }
    }
}



