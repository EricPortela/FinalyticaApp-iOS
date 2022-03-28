//
//  ViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2020-01-04.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit
import Charts
import Lottie
import WebKit
import FirebaseDatabase
import FirebaseAuth

var omxs30 = [Any]()
var imageCache = NSCache<AnyObject, AnyObject>()

private let database = Database.database().reference()
private var favoriteStocksBatchData = [majorIndexFeed]()

//Swedish Indexes
//var selectedSwedishIndex = String()
//var selectedSwedishApiLink = String()

//Nordic Indexes
//var selectedNordicIndex = String()
//var selectedNordicApiLink = String()

//American/North American Indexes

class ViewController: UIViewController {
    private let refreshControl = UIRefreshControl()
    
    //Dispatch Group
    private let dispatchGroup = DispatchGroup()
    
    //Semaphore Group
    private let semaphore = DispatchSemaphore(value: 0)
    
    //Dispatch Queue
    private let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
    
    //Section 1
    //Major Index
    private var selectedMajorIndexes = ["^DJI", "^GSPC", "^NYA", "^IXIC"]
    private var majorIndexData: [majorIndexFeed] = []
    private var allRawMajorIndexPrices: [[majorIndexPriceDataMinute]] = []
    
    //Section 2
    //Headers
    private let headerLabels = ["", "", "Favorites", "News", "Today's ranking lists (10)"]
    
    //Favorite Stock Prices
    private var timePeriod = Int(365)
    private var selectedFavoriteStocks = ["AAPL", "TSLA", "MSFT", "BABA"]
    private var favoriteStocksOrdered = [String]()
    private var newsData: [newsFeed] = []
    private var allRawStockPriceData: [[dailyStockPrices]] = []
    private var stockPriceLineChartDataSets: [LineChartDataSet] = []
    
    //Ranking List
    private var rankingListResults: [rankingListFeed] = []
    private var rankingURL = "https://financialmodelingprep.com/api/v3/gainers?apikey=\(apiKey)"
    
    //CollectionViews
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    //let swedishIndexes = ["OMXS30", "OMXSPI"]
    //let indexLink = ["https://www.quandl.com/api/v3/datasets/NASDAQOMX/OMXS30.json?api_key=h9SqrVVNuEYjS9yhcWe9", "https://www.quandl.com/api/v3/datasets/NASDAQOMX/OMXSPI.json?api_key=h9SqrVVNuEYjS9yhcWe9"]
    //let nordicIndexes = ["OMXC25", "OMXH25", "OMXIPI", "OMXO20GI"]
    //let nordicIndexLink = ["https://www.quandl.com/api/v3/datasets/NASDAQOMX/OMXC25.json?api_key=h9SqrVVNuEYjS9yhcWe9","https://www.quandl.com/api/v3/datasets/NASDAQOMX/OMXH25.json?api_key=h9SqrVVNuEYjS9yhcWe9","https://www.quandl.com/api/v3/datasets/NASDAQOMX/OMXIPI.json?api_key=h9SqrVVNuEYjS9yhcWe9","https://www.quandl.com/api/v3/datasets/NASDAQOMX/OMXO20GI.json?api_key=h9SqrVVNuEYjS9yhcWe9"]
    
    private func changeTopLabel(label: String) -> Void {
        //Makes the top navigation bar transparent!!!
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //navigationController?.navigationBar.shadowImage = UIImage()
        //navigationController?.navigationBar.layoutIfNeeded()
        //navigationController?.navigationBar.backgroundColor = UIColor(red: 0.31, green: 0.25, blue: 0.60, alpha: 1.00)
        //navigationController?.hidesBarsOnSwipe = true
        
        let topLabel = UILabel()
        topLabel.text = label
        topLabel.textAlignment = .left
        topLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20.0)
        self.navigationItem.titleView = topLabel
        //self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
       }
    
    private func welcomeTextGenerator(username: String) -> (String, String) {
        
        var title: String = ""
        var text: String = ""
        
        let date = Date()
        let calendar = Calendar.current
        
        //Morning times
        let morningStart = calendar.date(bySettingHour: 05, minute: 0, second: 1, of: date)!
        let morningEnd = calendar.date(bySettingHour: 12, minute: 59, second: 59, of: date)!
        
        //Afternoon times
        let afternoonStart = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date)!
        let afternoonEnd = calendar.date(bySettingHour: 17, minute: 59, second: 59, of: date)!
        
        //Evening times
        let eveningStart = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: date)!
        let eveningEnd = calendar.date(bySettingHour: 19, minute: 59, second: 59, of: date)!
        
        
        if date >= morningStart && date <= morningEnd {
            title = "Good morning \(username)."
            text = "Search to research a company on NYSE or NASDAQ."
        } else if date >= afternoonStart && date <= afternoonEnd {
            title = "Good afternoon \(username)."
            text = "Search to research a company on NYSE or NASDAQ."
        } else if date >= eveningStart && date <= eveningEnd {
            title = "Good evening \(username)."
            text = "Search to research a company on NYSE or NASDAQ."
        } else {
            title = "Good night \(username)."
            text = "Search to research a company on NYSE or NASDAQ."
        }
        
        return (title, text)

    }
    
    private func headerWelcomeLabels() -> (String, String) {
        
        var welcometext: (String, String)
        
        //guard let usrName = Auth.auth().currentUser?.displayName else { return ("TEST", "TEST")}
        
        if let username = Auth.auth().currentUser?.displayName {
            welcometext = welcomeTextGenerator(username: username)
        } else {
            welcometext = welcomeTextGenerator(username: "Test")
        }
        
        return (welcometext)
    }
    
    private func UICollectionViewSetUp() -> Void {
        
        profileCollectionView.delegate = self
        profileCollectionView.dataSource = self
        
        profileCollectionView.register(HeaderCollectionViewCell.self, forCellWithReuseIdentifier: "headerCell")
        
        //Headers / UICollectionReusableView
        profileCollectionView.register(SearchCompanyCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "searchHeader")
        profileCollectionView.register(NewsCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "newsHeader")
        profileCollectionView.register(RankingCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "rankingHeader")

        
        //Cells
        profileCollectionView.register(MajorCollectionViewCell.self, forCellWithReuseIdentifier: "majorIndexCollectionView")
        
        profileCollectionView.register(FavoriteStocksGraphCollectionViewCell.self, forCellWithReuseIdentifier: "profileCell")
        profileCollectionView.register(FavoriteStocksCollectionViewCell.self, forCellWithReuseIdentifier: "favoriteCell")
        profileCollectionView.register(SeeFullListCollectionViewCell.self, forCellWithReuseIdentifier: "seeFullListCell")
        
        profileCollectionView.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: "newsCell")
        profileCollectionView.register(SegmentedNewsCollectionViewCell.self, forCellWithReuseIdentifier: "segmentedNewsCell")
        
        profileCollectionView.register(RankingListCollectionViewCell.self, forCellWithReuseIdentifier: "rankingCell")
        profileCollectionView.register(SegmentedControlCollectionViewCell.self, forCellWithReuseIdentifier: "segmentedRankingCell")
                
        let layout = profileCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.minimumInteritemSpacing = 10
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    private func customButtonsNavController() -> Void {
        let BackImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysOriginal)
        self.navigationController?.navigationBar.backIndicatorImage = BackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = BackImage
        self.navigationController?.navigationBar.tintColor = UIColor.clear
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func addShadow(view : UIView) -> Void{
        view.layer.cornerRadius = 35
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 1
        view.layer.masksToBounds = false
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTopLabel(label: "Overview")
        UICollectionViewSetUp()
        concurrentAPICalls()
        customButtonsNavController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshControl.tintColor = .white
        refreshControl.layer.zPosition = -1
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        profileCollectionView.addSubview(refreshControl)
    }
    
    @objc private func refresh() -> Void{
        concurrentAPICalls()
        
        let date = Date()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        let dateTimestring = formatter.string(from: date)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Last time updated: \(dateTimestring)", attributes: attributes)
        refreshControl.endRefreshing()
    }
    
    private func concurrentAPICalls() -> Void {
            self.stockPricesBatchRequest(baseURL:  "https://financialmodelingprep.com/api/v3/historical-price-full/", days: self.timePeriod, tickers: self.selectedFavoriteStocks)
            
            self.rankingListsRequest(stringURL: self.rankingURL)
            
            self.getFavorites()
            
            self.getNewsData(url: "https://financialmodelingprep.com/api/v3/stock_news?limit=5&apikey=\(apiKey)")
            
            self.dispatchGroup.notify(queue: .main) {
                //Call sorting function
                //print("Line Chart Data Array, when dispatch group is done!")
                //print(self.allMajorIndexLineChartData.count)
                self.prepareStockPriceBatchData(rawStockPriceData: self.allRawStockPriceData)
                self.sortFavorites(sortBy: "Alphabetical")

                //Reload collectionview
                self.profileCollectionView.reloadData()
            }
        
    }
    
    private func getFavorites() -> Void{
        var tickerArray: [String] = []
        database.child("favoriteStocks").observe(.childAdded) { (snapshot) in
            guard let value = snapshot.value as? String else {return}
            tickerArray.append(value)
            
            if tickerArray.count == 3 {
                let groupedTickers = tickerArray.joined(separator: ",")
                
                let url = "https://financialmodelingprep.com/api/v3/quote/\(groupedTickers)?apikey=\(apiKey)"
                self.getFavoriteStocksData(url: url)
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
                    favoriteStocksBatchData = dataFeed
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
    
    private func sortFavorites(sortBy: String) -> Void {
        if sortBy == "Alphabetical" {
            favoriteStocksBatchData.sort {
                let first = $0.symbol ?? "z"
                let second = $1.symbol ?? "z"
                return first < second
            }
        }
        else if sortBy == "Market Cap" {
            favoriteStocksBatchData.sort {
                let first = $0.marketCap ?? -9999
                let second = $1.marketCap ?? -9999
                return first > second
            }
        }
        else if sortBy == "PE" {
            favoriteStocksBatchData.sort {
                let first = $0.pe ?? -9999
                let second = $1.pe ?? -9999
                return first > second
            }
        }
        else if sortBy == "Closing Price" {
            favoriteStocksBatchData.sort {
                let first = $0.price ?? -9999
                let second = $1.price ?? -9999
                return first > second
            }
        }
        else if sortBy == "EPS" {
            favoriteStocksBatchData.sort {
                let first = $0.eps ?? -9999
                let second = $1.eps ?? -9999
                return first > second
            }
        }
    }
    
    private func favoriteStocksUpdate(baseURL: String, days: Int, tickers: Array<String>) -> Void {
        self.stockPricesBatchRequest(baseURL: baseURL, days: days, tickers: tickers)
        //self.dispatchGroup.wait() //Anything after this point won't be executed until we get a result back from "stockPricesBatchRequest"

        self.dispatchGroup.notify(queue: .main) {
            //Call sorting function
            self.prepareStockPriceBatchData(rawStockPriceData: self.allRawStockPriceData)
            
            //Reload collectionview
            self.profileCollectionView.reloadData()
        }
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
                    self.dispatchGroup.leave()
                    print("Error in JSON parsing")
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
    
    private func getNewsData(url: String) -> Void{
        dispatchGroup.enter()
        //majorIndexPrices.removeAll()
        let url = URL(string: url)
        guard  url != nil else {
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                do {
                    let news = try decoder.decode([newsFeed].self, from: data!)
                    
                    DispatchQueue.main.async {
                        self.newsData.removeAll()
                        self.newsData = news
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
    
    private func newsFavoritesUpdate() -> Void{
        var tickerArray: [String] = []
        database.child("favoriteStocks").observe(.value) { (snapshot) in
            let lenght = (snapshot.childrenCount)
            database.child("favoriteStocks").observe(.childAdded) { (snapshot) in
                guard let value = snapshot.value as? String else {return}
                tickerArray.append(value)
                
                if tickerArray.count == lenght {
                    let groupedTickers = tickerArray.joined(separator: ",")

                    let url = "https://financialmodelingprep.com/api/v3/stock_news?tickers=\(groupedTickers)&limit=5&apikey=\(apiKey)"
                    self.getNewsData(url: url)
                    //Reload collectionview
                    self.dispatchGroup.notify(queue: .main) {
                        //self.profileCollectionView.reloadSections(IndexSet(integer: 3))
                        self.profileCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    private func newsLatestUpdate(stringURL: String) -> Void{
        getNewsData(url: stringURL)
        self.dispatchGroup.notify(queue: .main) {
            //Reload collectionview
            self.profileCollectionView.reloadData()
        }
    }
        
    private func rankingListUpdate(stringURL: String) -> Void{
        self.rankingListsRequest(stringURL: stringURL)
        
        self.dispatchGroup.notify(queue: .main) {
            //Reload collectionview
            self.profileCollectionView.reloadData()
        }
    }
    
    private func rankingListsRequest(stringURL: String) -> Void{
        dispatchGroup.enter()
        rankingListResults.removeAll()
        var result: [rankingListFeed] = []
        
        let url = URL(string: stringURL)
        guard url != nil else {
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                do {
                    let rankingFeed = try decoder.decode([rankingListFeed].self, from: data!)
                    
                    for ranking in rankingFeed {
                        result.append(ranking)
                    }
                    DispatchQueue.main.async {
                        self.rankingListResults = result
                    }
                    self.dispatchGroup.leave()
                }
                catch {
                    self.dispatchGroup.leave()
                    print("Error in JSON parsing")
                }
            }
        }
        dataTask.resume()
    }
}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @objc private func changeFavoriteStocksPeriod(segmentedControl: UISegmentedControl) -> Void {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            print("1D")
        case 1:
            self.timePeriod = 7
            favoriteStocksUpdate(baseURL:"https://financialmodelingprep.com/api/v3/historical-price-full/", days: self.timePeriod, tickers: self.selectedFavoriteStocks)
        case 2:
            self.timePeriod = 30
            favoriteStocksUpdate(baseURL:"https://financialmodelingprep.com/api/v3/historical-price-full/", days: self.timePeriod, tickers: self.selectedFavoriteStocks)
        case 3:
            self.timePeriod = 90
            favoriteStocksUpdate(baseURL:"https://financialmodelingprep.com/api/v3/historical-price-full/", days: self.timePeriod, tickers: self.selectedFavoriteStocks)
        case 4:
            print("YTD")
        case 5:
            self.timePeriod = 365
            favoriteStocksUpdate(baseURL:"https://financialmodelingprep.com/api/v3/historical-price-full/", days: self.timePeriod, tickers: self.selectedFavoriteStocks)
        case 6:
            self.timePeriod = 1095
            favoriteStocksUpdate(baseURL:"https://financialmodelingprep.com/api/v3/historical-price-full/", days: self.timePeriod, tickers: self.selectedFavoriteStocks)
        default:
            print("Default")
        }
    }
    
    @objc private func changeRankingList(segmentedControl: UISegmentedControl) -> Void{
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            rankingURL = "https://financialmodelingprep.com/api/v3/gainers?apikey=\(apiKey)"
            rankingListUpdate(stringURL: rankingURL)
        case 1:
            rankingURL = "https://financialmodelingprep.com/api/v3/losers?apikey=\(apiKey)"
            rankingListUpdate(stringURL: rankingURL)
        case 2:
            rankingURL = "https://financialmodelingprep.com/api/v3/actives?apikey=\(apiKey)"
            rankingListUpdate(stringURL: rankingURL)
        default:
            rankingURL = "https://financialmodelingprep.com/api/v3/gainers?apikey=\(apiKey)"
            rankingListUpdate(stringURL: rankingURL)
        }
    }
    
    @objc private func searchCompany() -> Void{
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchView") as! SearchViewController
        //changeTopLabel(label: "Search Company")
        self.addChild(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    
    @objc private func changeNews(segmentedControl: UISegmentedControl) -> Void{
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            newsLatestUpdate(stringURL: "https://financialmodelingprep.com/api/v3/stock_news?limit=5&apikey=\(apiKey)")
        case 1:
            newsFavoritesUpdate()
        default:
            newsLatestUpdate(stringURL: "https://financialmodelingprep.com/api/v3/stock_news?limit=5&apikey=\(apiKey)")
        }
    }
    
    @objc private func tickerClicked() -> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let details = storyboard.instantiateViewController(withIdentifier: "detailsView") as! DetailsViewController
        //details.ticker = ticker
        self.navigationController?.pushViewController(details, animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return headerLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 5
        }  else if section == 3 {
            return newsData.count
        } else {
            return rankingListResults.prefix(10).count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width: CGFloat
        var height: CGFloat
        
        if indexPath.section == 0 {
            width = CGFloat(UIScreen.main.bounds.size.width)
            height = 70
        } else if indexPath.section == 1 {
            width = CGFloat(UIScreen.main.bounds.size.width)
            height = 60
        }
        else if indexPath.section == 2 {
            if indexPath.row == 4 {
                width = CGFloat(UIScreen.main.bounds.size.width-40)
                height = 300
            } else if indexPath.row == 3 {
                width = CGFloat(UIScreen.main.bounds.size.width-40)
                height = 40
            } else {
                width = CGFloat(UIScreen.main.bounds.size.width-40)
                height = 50
            }
        } else if indexPath.section == 3 {
            width = CGFloat(UIScreen.main.bounds.size.width-40)
            height = 85
        } else {
            width = CGFloat(UIScreen.main.bounds.size.width-40)
            height = 50
        }
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath) as? HeaderCollectionViewCell
            let titleAndText = headerWelcomeLabels()
            cell?.welcomeTitle.text = titleAndText.0
            cell?.welcomeText.text = titleAndText.1
            return cell!
        }
        else if indexPath.section == 1 {
            let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "majorIndexCollectionView", for: indexPath) as? MajorCollectionViewCell
            cell?.selectionDelegate = self
            cell?.indexEditSelectionDelegate = self
            return cell!
        } else if indexPath.section == 2 {
            if indexPath.row == 4 {
                let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as? FavoriteStocksGraphCollectionViewCell
                cell?.segmentedControl.addTarget(self, action: #selector(changeFavoriteStocksPeriod), for: .valueChanged)
                if stockPriceLineChartDataSets.count > 0 {
                    let data = LineChartData(dataSets: stockPriceLineChartDataSets)
                    data.setDrawValues(false)
                    cell?.lineChart.data = data
                    cell?.lineChart.data?.notifyDataChanged()
                    cell?.lineChart.notifyDataSetChanged()
                }
                return cell!
            } else if indexPath.row == 3 {
                let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "seeFullListCell", for: indexPath) as? SeeFullListCollectionViewCell
                cell?.layer.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00).cgColor //UIColor.tertiarySystemBackground.cgColor
                cell?.layer.cornerRadius = 10
                return cell!
            }
            
            let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as? FavoriteStocksCollectionViewCell
            
            if favoriteStocksBatchData.count == 3 {
                if let symbol = favoriteStocksBatchData[indexPath.row].symbol {
                    cell?.ticker.text = symbol
                } else {
                    cell?.ticker.text = "--"
                }
                
                if let closingPrice = favoriteStocksBatchData[indexPath.row].previousClose {
                    let closingPriceStr = "$" + String(format: "%.2f", closingPrice)
                    cell?.closingPrice.text = closingPriceStr
                } else {
                    cell?.closingPrice.text = "--"
                }
                
                if let eps = favoriteStocksBatchData[indexPath.row].eps {
                    let epsStr = "$" + String(format: "%.2f", eps)
                    cell?.eps.text = epsStr
                } else {
                    cell?.eps.text = "--"
                }
                
                if let pe = favoriteStocksBatchData[indexPath.row].pe {
                    let peStr = String(format: "%.2f", pe)
                    cell?.pe.text = peStr
                } else {
                    cell?.pe.text = "--"
                }
                
                if let marketCap = favoriteStocksBatchData[indexPath.row].marketCap {
                    let marketCapStr = "$" + marketCap.abbreviateLargeNumbers(format: "%.0f") //+ String(format: "%.2f", marketCap)
                    cell?.marketCap.text = marketCapStr
                } else {
                    cell?.marketCap.text = "--"
                }
            }
            
            return cell!
            
        } else if indexPath.section == 3 {
            
            let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "newsCell", for: indexPath) as? NewsCollectionViewCell

            if let titleText = newsData[indexPath.row].title {
                cell?.title.text = titleText
            }
            
            if let date = newsData[indexPath.row].publishedDate {
                cell?.publishedDate.text = date
            }
            
            if let symbol = newsData[indexPath.row].symbol {
                cell?.symbol.text = symbol
            }
            
            if let imgURLString = newsData[indexPath.row].image {
                cell?.addImage(url: imgURLString)
            }
            
            return cell!
            
        }
        
        else {
            let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "rankingCell", for: indexPath) as? RankingListCollectionViewCell
            
            if let ticker = rankingListResults[indexPath.row].ticker {
                cell?.tickerLabel.text = ticker
            }
            
            if let price = rankingListResults[indexPath.row].price {
                cell?.priceLabel.text = "$\(price)"
            }
            
            if let changePercentage = rankingListResults[indexPath.row].changesPercentage{
                let change = changePercentage.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: "%", with: "")
                let numberFormatter = NumberFormatter()
                numberFormatter.locale = NSLocale(localeIdentifier: "us_US") as Locale
                numberFormatter.numberStyle = .decimal
                
                if let floatChange = numberFormatter.number(from: change)?.doubleValue{
                    let strChange = String(format: "%.2f", floatChange)
                    cell?.changeLabel.text =  strChange + "%"
                }
            }
            
            if let change = rankingListResults[indexPath.row].changes{
                let positiveViewColor = UIColor(red: 0.01, green: 0.81, blue: 0.64, alpha: 1.00)//UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00)
                let negativeViewColor = UIColor(red: 0.89, green: 0.00, blue: 0.40, alpha: 1.00)//UIColor(red: 0.89, green: 0.00, blue: 0.40, alpha: 1.00)
                
                if change > 0 {
                    cell?.miniCard.backgroundColor = positiveViewColor
                } else {
                    cell?.miniCard.backgroundColor = negativeViewColor
                }
            }
            
            
            return cell!
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            
        } else if indexPath.section == 2 {
            if indexPath.row == 3 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let favoriteStocksList = storyboard.instantiateViewController(identifier: "favoriteStocks") as! FavoriteStocksViewController
                self.navigationController?.pushViewController(favoriteStocksList, animated: true)
            }
            //let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as? FavoriteStocksGraphCollectionViewCell
        } else if indexPath.section == 4 {
            if rankingListResults.count != 0 {
                if let ticker = (rankingListResults[indexPath.row].ticker) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let details = storyboard.instantiateViewController(withIdentifier: "detailsView") as! DetailsViewController
                    details.ticker = ticker
                    self.navigationController?.pushViewController(details, animated: true)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section == 1 {
                let sectionHeader = profileCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "searchHeader", for: indexPath) as! SearchCompanyCollectionReusableView
                sectionHeader.searchButton.addTarget(self, action: #selector(searchCompany), for: .touchUpInside)
                return sectionHeader
            } else if indexPath.section == 3 {
                let sectionHeader = profileCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "newsHeader", for: indexPath) as! NewsCollectionReusableView
                
                sectionHeader.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.00) //.systemBackground
                sectionHeader.headerLabel.text = headerLabels[indexPath.section]
                sectionHeader.segmentedControl.addTarget(self, action: #selector(changeNews), for: .valueChanged)
                
                return sectionHeader
            } else if indexPath.section == 4 {
                let sectionHeader = profileCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "rankingHeader", for: indexPath) as! RankingCollectionReusableView
                
                sectionHeader.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.00) //.systemBackground
                sectionHeader.headerLabel.text = headerLabels[indexPath.section]
                sectionHeader.segmentedControl.addTarget(self, action: #selector(changeRankingList), for: .valueChanged)
                return sectionHeader
            }
            
            else {
                let sectionHeader = profileCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! IndexCollectionReusableView
                sectionHeader.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.00)//.systemBackground
                sectionHeader.indexCountry.text = headerLabels[indexPath.section]
                return sectionHeader
            }
        } else {
            return IndexCollectionReusableView()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat
        let height: CGFloat
        
        if collectionView == profileCollectionView {
            if section == 0 {
                width = 0
                height = 0
                return CGSize(width: width, height: height)
            }
            else if section == 1 {
                width = UIScreen.main.bounds.size.width
                height = 50
                return CGSize(width: width, height: height)
            } else if section == 3 || section == 4 {
                width = UIScreen.main.bounds.size.width
                height = 85
                return CGSize(width: width, height: height)
            }
            else {
                width = UIScreen.main.bounds.size.width
                height = 44
                return CGSize(width: width, height: height)
            }
        }
        width = 0
        height = 0
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var top: CGFloat
        var left: CGFloat
        var bottom: CGFloat
        var right: CGFloat

        if section == 0 {
            top = 0
            left = 0
            bottom = 0
            right = 0
        } else if section == 1 {
            top = 15
            left = 0
            bottom = 10
            right = 0
        } else if section == 2 {
            top = 0
            left = 20
            bottom = 10
            right = 20
        }
        else if section == 3 || section == 4 {
            top = 0
            left = 0
            bottom = 10
            right = 0
        } else {
            top = 0
            left = 20
            bottom = 10
            right = 20
        }
        
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 2 {
            return 15
        } else if section == 3 {
            return 10
        }
        
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y)
    }
}

extension UIButton {
    open override var isEnabled: Bool{
        didSet {
            alpha = isEnabled ? 1.0 : 0.3
        }
    }
}

extension ViewController: IndexSelectionDelegate, IndexEditSelectionDelegate {
    func didTap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsView = storyboard.instantiateViewController(withIdentifier: "editIndexView") as! EditMajorIndexViewController
        self.present(detailsView, animated: true, completion: nil)
    }
    
    func didTap(symbol: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsView = storyboard.instantiateViewController(withIdentifier: "indexGraphView") as! IndexGraphViewController
        detailsView.indexSymbol = String(symbol.dropFirst())
        self.navigationController?.pushViewController(detailsView, animated: true)
        //self.present(detailsView, animated: true, completion: nil)
    }
}

extension UIImageView {
    func load(urlString: String) {
        
        if let image = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = image
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageCache.setObject(image, forKey: urlString as NSString)
                        self?.image = image
                    }
                }
            }
        }
    }
}
