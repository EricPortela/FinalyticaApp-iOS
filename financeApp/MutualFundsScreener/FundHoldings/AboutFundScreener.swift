//
//  AboutFundScreener.swift
//  financeApp
//
//  Created by Eric Portela on 2020-09-10.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Charts
import Lottie

class AboutFundScreener: UIViewController {
    
    //Variables for the Screener/Colectionview
    var selectedIndex: IndexPath = IndexPath(row: 0, section: 0)
    var searching = false
    var searchHolding = [String]()
    var test = [String]()
    var holdingsName = [String]()
    @IBOutlet weak var holdingsSearchBar: UISearchBar!
    
    //Important arrays/variables
    var basicFundData = [String:Any]()
    var holdingsData = [[String:Any]()]
    var hodingsCountries = [Any]()
    @IBOutlet weak var holdingsDataScreenerCollection: UICollectionView!
        
    var ref: DatabaseReference!
    var company = String()
    var fund = String()
    
    //Child view 1 / Container view 1
    @IBOutlet weak var fundName: UILabel!
    @IBOutlet weak var countriesPieChart: PieChartView!
    
    //Child view 2 / Container view 2
    @IBOutlet weak var basicDataView: UIView!
    @IBOutlet weak var activeRisk: UILabel!
    @IBOutlet weak var instituteNr: UILabel!
    @IBOutlet weak var isinFund: UILabel!
    @IBOutlet weak var fortune: UILabel!
    @IBOutlet weak var cashAndEquivalents: UILabel!
    @IBOutlet weak var otherAssetsAndLiabilities: UILabel!

    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            countriesPieChart.isHidden = false
            basicDataView.isHidden = false
            holdingsDataScreenerCollection.isHidden = true
            holdingsSearchBar.isHidden = true
        case 1:
            countriesPieChart.isHidden = true
            basicDataView.isHidden = true
            holdingsDataScreenerCollection.isHidden = false
            holdingsSearchBar.isHidden = false
        default:
            countriesPieChart.isHidden = false
            basicDataView.isHidden = false
            holdingsDataScreenerCollection.isHidden = true
            holdingsSearchBar.isHidden = true
        }
    }
    
    
    func customButtonsNavController() {
       let BackImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysOriginal)
         self.navigationController?.navigationBar.backIndicatorImage = BackImage
         self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = BackImage
         self.navigationController?.navigationBar.tintColor = UIColor.clear
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
         
         //Makes the top navigation bar transparent!!!
         navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
         navigationController?.navigationBar.shadowImage = UIImage()
    }

    func updateChartData(grouped : Dictionary<String, Int>) {
        var pieChartData = [PieChartDataEntry]()
        var colors = [NSUIColor]()
        var sortedAmounts = [Int]()
        
        //Sort the values representing the amount of holdings per country
        for (_,v) in grouped {
            sortedAmounts.append(v)
            sortedAmounts.sort() {$0 > $1}
        }        
        
        for (k,v) in grouped {
            let value = PieChartDataEntry(value: Double(v), label: k)
            pieChartData.append(value)
        }
        let chartDataSet = PieChartDataSet(entries: pieChartData, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        countriesPieChart.holeRadiusPercent = 0.5
        countriesPieChart.holeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        for _ in 0..<grouped.count {
            let red = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
      
        chartDataSet.colors = colors
        countriesPieChart.drawEntryLabelsEnabled = false
        countriesPieChart.setExtraOffsets(left: -20, top: -20, right: -20, bottom: -20)
        countriesPieChart.rotationEnabled = false
        countriesPieChart.highlightPerTapEnabled = false
        countriesPieChart.chartAnimator.animate(xAxisDuration: 1, easingOption: ChartEasingOption.easeInOutCubic) //easeInOutQuint, easeInOutBack, easeInOutCirc, easeInQuint, easeInCubic, easeInQuad, easeInSine, easeInExpo,
        countriesPieChart.chartAnimator.animate(yAxisDuration: 1)
        
        
        chartDataSet.drawValuesEnabled = false //removes the values on the chart
        chartDataSet.valueTextColor = UIColor.white
        chartDataSet.valueLineColor = UIColor.white
        chartDataSet.selectionShift = 33
        chartDataSet.valueFont = .systemFont(ofSize: 12)
        
        //Set position of legends outside the pie chart
        let chartDataLegend = countriesPieChart.legend
        chartDataLegend.verticalAlignment = .bottom
        chartDataLegend.horizontalAlignment = .left
        chartDataLegend.orientation = .horizontal
        chartDataLegend.textColor = .white
        
        
        countriesPieChart.data = chartData
    }
    
    func countCountries(dict : Array<Any>) -> [String:Int]{
        var grouped: [String: Int] = [:]
        
        for country in dict {
            if let actualCountry = country as? String{
               grouped[actualCountry , default: 0] += 1
            }
        }
        return grouped
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        holdingsDataScreenerCollection.isHidden = true
        holdingsSearchBar.isHidden = true
        
        fundName.text = fund
        customButtonsNavController()
        self.holdingsData = []

        //Set the firebase reference
        ref = Database.database().reference()
        
        //Retrieve fondinnehav
        ref.child("Fondinnehav/\(yearAndQuarter)/\(company)/\(fund)/VärdepappersfondInnehav/Fondinformation/0/FinansiellaInstrument/FinansielltInstrument").observe(.childAdded, with: { (snapshot ) in
            
            let fundData = snapshot.value as? [String:Any]
            
            if let actualFundData = fundData {
                self.holdingsData.append(actualFundData)
                self.hodingsCountries.append(actualFundData["Landkod_Emittent"])
                if let instrument = (actualFundData["Instrumentnamn"]) as? String {
                    self.holdingsName.append(instrument)
                    self.test.append(instrument)
                }
            }
            //print(self.hodingsCountries)
            if self.hodingsCountries.count != 0 {
                let pieData = self.countCountries(dict: self.hodingsCountries)
                self.updateChartData(grouped: pieData)
            }
            
            self.holdingsDataScreenerCollection.reloadData()
        })
        
        
        ref.child("Fondinnehav/\(yearAndQuarter)/\(company)/\(fund)/VärdepappersfondInnehav/Fondinformation").observe(.childAdded, with: { (snapshot ) in
                   
                   let fundData = snapshot.value as? [String:Any]
                   if let actualFundData = fundData {
                    
                    if let active_risk = actualFundData["Aktiv_risk"]{
                        self.activeRisk.text = "\(active_risk)"
                    }
                    if let institute_nr = actualFundData["Fond_institutnummer"] {
                        self.instituteNr.text = "\(institute_nr)"
                    }
                    if let isin_fund = actualFundData["Fond_ISIN-kod"]{
                        self.isinFund.text = "\(isin_fund)"
                    }
                    if let fortune = actualFundData["Fondförmögenhet"] {
                        self.fortune.text = "\(fortune)"
                    }
                    if let cash_eq = actualFundData["Likvida_medel"] {
                        self.cashAndEquivalents.text = "\(cash_eq)"
                    }
                    if let other_assets = actualFundData["Övriga_tillgångar_och_skulder"] {
                        self.otherAssetsAndLiabilities.text = "\(other_assets)"
                    }
                    
                   }
               })
        
            }
        }

extension AboutFundScreener: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let standardCellSize = CGSize(width: screenWidth - 15, height: 80)
        
        
        if selectedIndex == indexPath {
            let cellSize = CGSize(width: screenWidth - 15, height: 300)
            return cellSize
        }
        
        return standardCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if test.count == 0 {
            return 1
        }
        return test.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = holdingsDataScreenerCollection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HoldingsCollectionViewCell
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        if test.count != 0 {
            let filteredCompany = test[indexPath.row]
            
            for holding in holdingsData {
                if let company = holding["Instrumentnamn"] as? String {
                    if filteredCompany == company {
                        cell?.amountOfInstruments.text = String(indexPath.row + 1)
                        
                        cell?.holdingsName.text = (holding["Instrumentnamn"]) as? String
                        cell?.holdingsISIN.text = (holding["ISIN-kod_instrument"]) as? String
                        
                        
                        if let marketVal = (holding["Marknadsvärde_instrument"]) as? String {
                            let marketValue = (marketVal as NSString).floatValue //Convert the string to float
                            if let marketValueKronor = currencyFormatter.string(from: NSNumber(value: marketValue)) {
                                    cell?.marketValue.text = "\(marketValueKronor)"
                                }
                        }
                        
                        cell?.amountValue.text = (holding["Antal"]) as? String
                        
                        if let fortune = (holding["Andel_av_fondförmögenhet_instrument"]) as? String {
                            cell?.fractionValue.text = "\(fortune)%"
                        }
                        
                        cell?.assetTypeValue.text = (holding["Tillgångsslag_enligt_LVF_5_kap"]) as? String
                        
                        //self.holdingsDataScreenerCollection.reloadData()
                    }
                }
            }
        }
        
        else {
            cell?.holdingsName.text = "No results, try again!"
            cell?.holdingsISIN.text = ""
            cell?.marketValue.text = ""
            cell?.amountValue.text = ""
            cell?.fractionValue.text = ""
            cell?.assetTypeValue.text = ""
            cell?.amountOfInstruments.text = "0"
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        holdingsDataScreenerCollection.performBatchUpdates(nil, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let searchView: UICollectionReusableView = holdingsDataScreenerCollection.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "searchHoldings", for: indexPath)
        
        return searchView
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.test.removeAll()
        for company in self.holdingsName {
            if (company.lowercased().contains(searchText.lowercased())) {
                self.test.append(company)
            }
        }
        
        if (searchText.count) == 0 {
            self.test = self.holdingsName
        }
        self.holdingsDataScreenerCollection.reloadData()
    }
}
