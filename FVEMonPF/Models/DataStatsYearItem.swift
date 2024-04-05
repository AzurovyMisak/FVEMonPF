//
//  DataStatsYearItem.swift
//  FVEMonPF
//
//  Created by Majkl on 03.04.2024.
//

import Foundation

struct DataStatsYearItem {
    var datumod: Date = Date()
    var spotreba: Float = 0.0 // celkova spotreba domu
    var vyrobenoCelkem: Float = 0.0 // celkem vyrobeno elektrarnou
    var vyrobenoKeSpotrebe: Float = 0.0 //vyrobeno a hned spotrebovano
    var nakupCelkem: Float = 0.0 // celkovy odber ze site
    var nakupCEZ: Float = 0.0 // nakup elektriny od CEZu
    var pretokCelkem: Float = 0.0 // kolik jsem poslal do site
    var pretokVraceny: Float = 0.0 // kolik z pretoku jsem spotrboval zpatky
    var pretokPrebytek: Float = 0.0 // bilance pretoku bud jsem v plusu nebo v minusu
}
