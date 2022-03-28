//
//  Structs.swift
//  financeApp
//
//  Created by Eric Portela on 2021-03-26.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import Foundation
import UIKit


//REMOVE!!!!
func getTicker(companySelected : String) -> String {
    let tick = (companySelected.split(separator: " ")).last
    let ticker = tick?.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
    return "TSLA"
    //return ticker!
}

func getURL(companySelected : String, url: String) -> String {
    var ratioLink = ""
    ratioLink = (url)
    return ratioLink
}

struct newsFeed: Codable {
    var symbol: String?
    var publishedDate: String?
    var title: String?
    var image: String?
    var site: String?
    var text: String?
    var url: String?
}

struct majorIndexFeed: Codable {
    var symbol: String?
    var name: String?
    var price: Double?
    var changesPercentage: Double?
    var change: Double?
    var dayLow: Double?
    var dayHigh: Double?
    var yearHigh: Double?
    var yearLow: Double?
    var marketCap: Double?
    var priceAvg50: Double?
    var priceAvg200: Double?
    var volume: Double?
    var avgVolume: Double?
    var exchange : String?
    var open: Double?
    var previousClose: Double?
    var eps: Double?
    var pe: Double?
    var earningsAnnouncement: String?
    var sharesOutstanding: Double?
    var timestamp: Double?
}

struct majorIndexPriceDataMinute: Codable {
    var date: String?
    var open: Double?
    var low: Double?
    var high: Double?
    var close: Double?
    var volume: Double?
}

struct majorIndexBatchFeed: Codable {
    var historicalStockList: Array<majorIndexPriceFeed>?
}

struct majorIndexPriceFeed: Codable {
    var symbol: String?
    var historical: Array<majorIndexPriceDataDaily>?
}

struct majorIndexPriceDataDaily: Codable {
    var date: String?
    var open: Double?
    var high: Double?
    var low: Double?
    var close: Double?
    var adjClose: Double?
    var volume: Double?
    var unadjustedVolume: Double?
    var change: Double?
    var changePercent: Double?
    var vwap: Double?
    var label: String?
    var changeOverTime: Double?
}


struct batchStocksPriceFeed: Codable {
    var historicalStockList: Array<dailyStockPriceData>?
}

struct dailyStockPriceData: Codable {
    var symbol: String?
    var historical: Array<dailyStockPrices>?
}

struct dailyStockPrices: Codable {
    var date: String
    var open: Double?
    var high: Double?
    var low: Double?
    var close: Double?
    var adjClose: Double?
    var volume: Double?
    var unadjustedVolume: Double?
    var change: Double?
    var changePercent: Double?
    var vwap: Double?
    var label: String?
    var changeOverTime: Double?
}

struct stockPriceFeed: Codable {
    var date: String?
    var open: Double?
    var low: Double?
    var high: Double?
    var close: Double?
    var volume: Double?
}

struct rankingListFeed: Codable {
    var ticker: String?
    var changes: Double?
    var price: String?
    var changesPercentage: String?
    var companyName: String?
}

struct searchFeed: Codable {
    var symbol: String?
    var name: String?
    var currency: String?
    var stockExchange: String?
    var exchangeShortName: String?
}
    
struct RatiosDashboardFeed : Codable {
    var dividendYielTTM: Double?
    var dividendYielPercentageTTM: Double?
    var peRatioTTM: Double?
    var pegRatioTTM: Double?
    var payoutRatioTTM: Double?
    var currentRatioTTM: Double?
    var quickRatioTTM: Double?
    var cashRatioTTM: Double?
    var daysOfSalesOutstandingTTM: Double?
    var daysOfInventoryOutstandingTTM: Double?
    var operatingCycleTTM: Double?
    var daysOfPayablesOutstandingTTM: Double?
    var cashConversionCycleTTM: Double?
    var grossProfitMarginTTM: Double?
    var operatingProfitMarginTTM: Double?
    var pretaxProfitMarginTTM: Double?
    var netProfitMarginTTM: Double?
    var effectiveTaxRateTTM: Double?
    var returnOnAssetsTTM: Double?
    var returnOnEquityTTM: Double?
    var returnOnCapitalEmployedTTM: Double?
    var netIncomePerEBTTTM: Double?
    var ebtPerEbitTTM: Double?
    var ebitPerRevenueTTM: Double?
    var debtRatioTTM: Double?
    var debtEquityRatioTTM: Double?
    var longTermDebtToCapitalizationTTM: Double?
    var totalDebtToCapitalizationTTM: Double?
    var interestCoverageTTM: Double?
    var cashFlowToDebtRatioTTM: Double?
    var companyEquityMultiplierTTM: Double?
    var receivablesTurnoverTTM: Double?
    var payablesTurnoverTTM: Double?
    var inventoryTurnoverTTM: Double?
    var fixedAssetTurnoverTTM: Double?
    var assetTurnoverTTM: Double?
    var operatingCashFlowPerShareTTM: Double?
    var freeCashFlowPerShareTTM: Double?
    var cashPerShareTTM: Double?
    var operatingCashFlowSalesRatioTTM: Double?
    var freeCashFlowOperatingCashFlowRatioTTM: Double?
    var cashFlowCoverageRatiosTTM: Double?
    var shortTermCoverageRatiosTTM: Double?
    var capitalExpenditureCoverageRatioTTM: Double?
    var dividendPaidAndCapexCoverageRatioTTM: Double?
    var priceBookValueRatioTTM: Double?
    var priceToBookRatioTTM: Double?
    var priceToSalesRatioTTM: Double?
    var priceEarningsRatioTTM: Double?
    var priceToFreeCashFlowsRatioTTM: Double?
    var priceToOperatingCashFlowsRatioTTM: Double?
    var priceCashFlowRatioTTM: Double?
    var priceEarningsToGrowthRatioTTM: Double?
    var priceSalesRatioTTM: Double?
    var dividendYieldTTM: Double?
    var enterpriseValueMultipleTTM: Double?
    var priceFairValueTTM: Double?
    var dividendPerShareTTM: Double?
}

struct incomeStatement: Codable {
    var date: String?
    var symbol: String?
    var reportedCurrency: String?
    var fillingDate: String?
    var acceptedDate: String?
    var period: String?
    var revenue: Double?
    var costOfRevenue: Double?
    var grossProfit: Double?
    var grossProfitRatio: Double?
    var researchAndDevelopmentExpenses: Double?
    var generalAndAdministrativeExpenses: Double?
    var sellingAndMarketingExpenses: Double?
    var sellingGeneralAndAdministrativeExpenses: Double?
    var otherExpenses: Double?
    var operatingExpenses: Double?
    var costAndExpenses: Double?
    var interestExpense: Double?
    var depreciationAndAmortization: Double?
    var ebitda: Double?
    var ebitdaratio: Double?
    var operatingIncome: Double?
    var operatingIncomeRatio: Double?
    var totalOtherIncomeExpensesNet: Double?
    var incomeBeforeTax: Double?
    var incomeBeforeTaxRatio: Double?
    var incomeTaxExpense: Double?
    var netIncome: Double?
    var netIncomeRatio: Double?
    var eps: Double?
    var epsdiluted: Double?
    var weightedAverageShsOut: Double?
    var weightedAverageShsOutDil: Double?
    var link: String?
    var finalLink: String?
}


extension Encodable {
    var asDictionary: [String: Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({(label: String?, value: Any) -> (String, Any)? in
            guard let label = label else {return nil}
            return (label, value)
        }).compactMap{ $0 })
        return dict
    }
}


struct balanceSheetStatement: Codable {
    var date: String?
    var symbol: String?
    var reportedCurrency: String?
    var fillingDate: String?
    var acceptedDate: String?
    var period: String?
    var cashAndCashEquivalents: Double?
    var shortTermInvestments: Double?
    var cashAndShortTermInvestments: Double?
    var netReceivables: Double?
    var inventory: Double?
    var otherCurrentAssets: Double?
    var totalCurrentAssets: Double?
    var propertyPlantEquipmentNet: Double?
    var goodwill: Double?
    var intangibleAssets: Double?
    var goodwillAndIntangibleAssets: Double?
    var longTermInvestments: Double?
    var taxAssets: Double?
    var otherNonCurrentAssets: Double?
    var totalNonCurrentAssets: Double?
    var otherAssets: Double?
    var totalAssets: Double?
    var accountPayables: Double?
    var shortTermDebt: Double?
    var taxPayables: Double?
    var deferredRevenue: Double?
    var otherCurrentLiabilities: Double?
    var totalCurrentLiabilities: Double?
    var longTermDebt: Double?
    var deferredRevenueNonCurrent: Double?
    var deferredTaxLiabilitiesNonCurrent: Double?
    var otherNonCurrentLiabilities: Double?
    var totalNonCurrentLiabilities: Double?
    var otherLiabilities: Double?
    var totalLiabilities: Double?
    var commonStock: Double?
    var retainedEarnings: Double?
    var accumulatedOtherComprehensiveIncomeLoss: Double?
    var othertotalStockholdersEquity: Double?
    var totalStockholdersEquity: Double?
    var totalLiabilitiesAndStockholdersEquity: Double?
    var totalInvestments: Double?
    var totalDebt: Double?
    var netDebt: Double?
    var link: String?
    var finalLink: String?
}

struct cashFlowStatement: Codable {
    var date: String?
    var symbol: String?
    var reportedCurrency: String?
    var fillingDate: String?
    var acceptedDate: String?
    var period: String?
    var netIncome: Double?
    var depreciationAndAmortization: Double?
    var deferredIncomeTax: Double?
    var stockBasedCompensation: Double?
    var changeInWorkingCapital: Double?
    var accountsReceivables: Double?
    var inventory: Double?
    var accountsPayables: Double?
    var otherWorkingCapital: Double?
    var otherNonCashItems: Double?
    var netCashProvidedByOperatingActivities: Double?
    var investmentsInPropertyPlantAndEquipment: Double?
    var acquisitionsNet: Double?
    var purchasesOfInvestments: Double?
    var salesMaturitiesOfInvestments: Double?
    var otherInvestingActivites: Double?
    var netCashUsedForInvestingActivites: Double?
    var debtRepayment: Double?
    var commonStockIssued: Double?
    var commonStockRepurchased: Double?
    var dividendsPaid: Double?
    var otherFinancingActivites: Double?
    var netCashUsedProvidedByFinancingActivities: Double?
    var effectOfForexChangesOnCash: Double?
    var netChangeInCash: Double?
    var cashAtEndOfPeriod: Double?
    var cashAtBeginningOfPeriod: Double?
    var operatingCashFlow: Double?
    var capitalExpenditure: Double?
    var freeCashFlow: Double?
    var link: String?
    var finalLink: String?
}

struct incomeStatementGrowth: Codable {
    var date: String?
    var symbol: String?
    var period: String?
    var growthRevenue: Double?
    var growthCostOfRevenue: Double?
    var growthGrossProfit: Double?
    var growthGrossProfitRatio: Double?
    var growthResearchAndDevelopmentExpenses: Double?
    var growthGeneralAndAdministrativeExpenses: Double?
    var growthSellingAndMarketingExpenses: Double?
    var growthOtherExpenses: Double?
    var growthOperatingExpenses: Double?
    var growthCostAndExpenses: Double?
    var growthInterestExpense: Double?
    var growthDepreciationAndAmortization: Double?
    var growthEBITDA: Double?
    var growthEBITDARatio: Double?
    var growthOperatingIncome: Double?
    var growthOperatingIncomeRatio: Double?
    var growthTotalOtherIncomeExpensesNet: Double?
    var growthIncomeBeforeTax: Double?
    var growthIncomeBeforeTaxRatio: Double?
    var growthIncomeTaxExpense: Double?
    var growthNetIncome: Double?
    var growthNetIncomeRatio: Double?
    var growthEPS: Double?
    var growthEPSDiluted: Double?
    var growthWeightedAverageShsOut: Double?
    var growthWeightedAverageShsOutDil: Double?
}

struct YearlyRatios: Codable {
    var symbol: String?
    var date: String?
    var period: String?
    var currentRatio: Double?
    var quickRatio: Double?
    var cashRatio: Double?
    var daysOfSalesOutstanding: Double?
    var daysOfInventoryOutstanding: Double?
    var operatingCycle: Double?
    var daysOfPayablesOutstanding: Double?
    var cashConversionCycle: Double?
    var grossProfitMargin: Double?
    var operatingProfitMargin: Double?
    var pretaxProfitMargin: Double?
    var netProfitMargin: Double?
    var effectiveTaxRate: Double?
    var returnOnAssets: Double?
    var returnOnEquity: Double?
    var returnOnCapitalEmployed: Double?
    var netIncomePerEBT: Double?
    var ebtPerEbit: Double?
    var ebitPerRevenue: Double?
    var debtRatio: Double?
    var debtEquityRatio: Double?
    var longTermDebtToCapitalization: Double?
    var totalDebtToCapitalization: Double?
    var interestCoverage: Double?
    var cashFlowToDebtRatio: Double?
    var companyEquityMultiplier: Double?
    var receivablesTurnover: Double?
    var payablesTurnover: Double?
    var inventoryTurnover: Double?
    var fixedAssetTurnover: Double?
    var assetTurnover: Double?
    var operatingCashFlowPerShare: Double?
    var freeCashFlowPerShare: Double?
    var cashPerShare: Double?
    var payoutRatio: Double?
    var operatingCashFlowSalesRatio: Double?
    var freeCashFlowOperatingCashFlowRatio: Double?
    var cashFlowCoverageRatios: Double?
    var shortTermCoverageRatios: Double?
    var capitalExpenditureCoverageRatio: Double?
    var dividendPaidAndCapexCoverageRatio: Double?
    var dividendPayoutRatio: Double?
    var priceBookValueRatio: Double?
    var priceToBookRatio: Double?
    var priceToSalesRatio: Double?
    var priceEarningsRatio: Double?
    var priceToFreeCashFlowsRatio: Double?
    var priceToOperatingCashFlowsRatio: Double?
    var priceCashFlowRatio: Double?
    var priceEarningsToGrowthRatio: Double?
    var priceSalesRatio: Double?
    var dividendYield: Double?
    var enterpriseValueMultiple: Double?
    var priceFairValue: Double?
}

struct YearlyRatiosFeed : Codable {
    var symbol: String = ""
    var date: String = ""
    var currentRatio: Float?
    var quickRatio: Float?
    var cashRatio: Float?
    var daysOfSalesOutstanding: Float?
    var daysOfInventoryOutstanding: Float?
    var operatingCycle: Float?
    var daysOfPayablesOutstanding: Float?
    var cashConversionCycle: Float?
    var grossProfitMargin: Float?
    var operatingProfitMargin: Float?
    var pretaxProfitMargin: Float?
    var netProfitMargin: Float?
    var effectiveTaxRate: Float?
    var returnOnAssets: Float?
    var returnOnEquity: Float?
    var returnOnCapitalEmployed: Float?
    var netIncomePerEBT: Float?
    var ebtPerEbit: Float?
    var ebitPerRevenue: Float?
    var debtRatio: Float?
    var debtEquityRatio: Float?
    var longTermDebtToCapitalization: Float?
    var totalDebtToCapitalization: Float?
    var interestCoverage: Float?
    var cashFlowToDebtRatio: Float?
    var companyEquityMultiplier: Float?
    var receivablesTurnover: Float?
    var payablesTurnover: Float?
    var inventoryTurnover: Float?
    var fixedAssetTurnover: Float?
    var assetTurnover: Float?
    var operatingCashFlowPerShare: Float?
    var freeCashFlowPerShare: Float?
    var cashPerShare: Float?
    var payoutRatio: Float?
    var operatingCashFlowSalesRatio: Float?
    var freeCashFlowOperatingCashFlowRatio: Float?
    var cashFlowCoverageRatios: Float?
    var shortTermCoverageRatios: Float?
    var capitalExpenditureCoverageRatio: Float?
    var dividendPaidAndCapexCoverageRatio: Float?
    var dividendPayoutRatio: Float?
    var priceBookValueRatio: Float?
    var priceToBookRatio: Float?
    var priceToSalesRatio: Float?
    var priceEarningsRatio: Float?
    var priceToFreeCashFlowsRatio: Float?
    var priceToOperatingCashFlowsRatio: Float?
    var priceCashFlowRatio: Float?
    var priceEarningsToGrowthRatio: Float?
    var priceSalesRatio: Float?
    var dividendYield: Float?
    var enterpriseValueMultiple: Float?
    var priceFairValue: Float?
}

struct CompanyProfileFeed: Codable {
    var symbol: String?
    var price: Double?
    var beta: Double?
    var volAvg: Double?
    var mktCap: Double?
    var lastDiv: Double?
    var range: String?
    var changes: Double?
    var companyName: String?
    var currency: String?
    var cik: String?
    var isin: String?
    var cusip: String?
    var exchange: String?
    var exchangeShortName: String?
    var industry: String?
    var website: String?
    var description: String?
    var ceo: String?
    var sector: String?
    var country: String?
    var fullTimeEmployees: String?
    var phone: String?
    var address: String?
    var city: String?
    var state: String?
    var zip: String?
    var dcfDiff: Double?
    var dcf: Double?
    var image: String?
    var ipoDate: String?
    var defaultImage: Bool?
    var isEtf: Bool?
    var isActivelyTrading: Bool?
}

struct pressReleaseFeed: Codable {
    var symbol = ""
    var date = ""
    var title = ""
    var text = ""
}

struct SECReportFeed : Codable {
    var symbol: String
    var fillingDate: String
    var acceptedDate: String
    var cik: String
    var type: String
    var link: String
    var finalLink: String
}

struct SECInsiderFeed : Codable {
    var symbol : String
    var transactionDate : String
    var reportingCik : String
    var transactionType : String
    var securitiesOwned : Float
    var companyCik : String
    var reportingName : String
    var typeOfOwner: String
    var acquistionOrDisposition : String
    var formType : String
    var securitiesTransacted : Float
    var securityName : String
    var link : String
}

struct screenerFeed: Codable {
    var symbol: String?
    var companyName: String?
    var marketCap: Double?
    var sector: String?
    var industry: String?
    var beta: Double?
    var price: Double?
    var lastAnnualDividend: Double?
    var volume: Double?
    var exchange: String?
    var exchangeShortName: String?
    var country: String?
}
