//
//  MainStatsView.swift
//  FVEMonPF
//
//  Created by Majkl on 03.04.2024.
//

import SwiftUI

struct MainStatsView: View {
    
    @ObservedObject var powerData : PowerData
    
    
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Basic Stats")
                .foregroundColor(Color("theme_gray_6"))
                .fontWeight(.bold)
                .padding(.top, 10)
            HStack() {
                
                //**Prvni sloupec zahlavi
                VStack(alignment: .trailing, spacing: 1) {
                    HStack() {
                        Image(systemName: "chart.bar")
                            .foregroundColor(Color("wire-gradient-light"))
                        TxtN(txt: "kWh")
                            .bold()
                            .overlay {
                                LinearGradient(gradient: Gradient(colors: [Color("wire-gradient-light"),Color("wire-gradient-dark")]), startPoint: .leading, endPoint: .trailing)
                                    .mask(
                                        Text("kWh")
                                            .bold()
                                    )
                            }
                    }
                    
                    TxtN(txt: "Consumed").padding(.top, 0)
                    TxtN(txt: "Generated")
                    TxtN(txt: "Imported")
                    TxtN(txt: "Exported")
                    TxtN(txt: "Balance")
                }.frame(maxWidth: 150, maxHeight: .infinity, alignment: .top)
                    
                //.border(Color.blue)
                //END-VStack-Prvni sloupec zahlavi
                
                //**Druhy sloupec DEN
                VStack(alignment: .trailing) {
                    TxtN(txt: "Day").padding(.top, 5)
                    
                    TxtB(txt: formNum(num: powerData.lstDenniVykony.first?.spotreba ?? 0.0))
                    TxtB(txt: formNum(num: powerData.lstDenniVykony.first?.vyroba ?? 0.0))
                    TxtB(txt: formNum(num: powerData.lstDenniVykony.first?.nakup ?? 0.0))
                    TxtB(txt: formNum(num: powerData.lstDenniVykony.first?.prodej ?? 0.0))
                    let bilance = (powerData.lstDenniVykony.first?.prodej ?? 0.0) - (powerData.lstDenniVykony.first?.nakup ?? 0.0)
                    TxtC(txt: formNum(num: bilance), col: bilance >= 0 ? Color("conn-green") : Color("conn-red"))
                        .padding(.bottom, 5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment:.top)
                .background(Color("theme_gray_7"))
                .clipShape(RoundedRectangle(cornerRadius: 5.0))
                
                
                //.border(Color.blue)
                //END-Vstack-Druhy sloupec DEN
                
                //**Treti sloupec MESIC
                VStack(alignment: .trailing) {
                    TxtN(txt: "Month").padding(.top, 5)
                    TxtB(txt: formNum(num: powerData.lstMesicniVykony.first?.spotreba ?? 0.0))
                    TxtB(txt: formNum(num: powerData.lstMesicniVykony.first?.vyroba ?? 0.0))
                    TxtB(txt: formNum(num: powerData.lstMesicniVykony.first?.nakup ?? 0.0))
                    TxtB(txt: formNum(num: powerData.lstMesicniVykony.first?.prodej ?? 0.0))
                    let bilance = (powerData.lstMesicniVykony.first?.prodej ?? 0.0) - (powerData.lstMesicniVykony.first?.nakup ?? 0.0)
                    TxtC(txt: formNum(num: bilance), col: bilance >= 0 ? Color("conn-green") : Color("conn-red"))
                        .padding(.bottom, 5)
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(Color("theme_gray_7"))
                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                //.border(Color.blue)
                //END-VStack-Treti sloupec MESIC
                
                //**Ctvrty sloupce ROK
                VStack(alignment: .trailing) {
                    TxtN(txt: "Year").padding(.top, 5)
                    TxtB(txt: formNum(num: powerData.rocniVykony.spotreba))
                    TxtB(txt: formNum(num: powerData.rocniVykony.vyrobenoCelkem))
                    TxtB(txt: formNum(num: powerData.rocniVykony.nakupCelkem))
                    TxtB(txt: formNum(num: powerData.rocniVykony.pretokCelkem))
                    let bilance = powerData.rocniVykony.pretokCelkem - powerData.rocniVykony.nakupCelkem
                    TxtC(txt: formNum(num: bilance), col: bilance >= 0 ? Color("conn-green") : Color("conn-red"))
                        .padding(.bottom, 5)
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(Color("theme_gray_7"))
                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                //.border(Color.blue)
                //END-VStack-Ctvrty sloupce ROKl
            }
            .frame(maxWidth: .infinity, maxHeight: 135)
            .padding()
            //.border(Color.red)
            .background(Color("theme_gray_8"))
            //.clipShape(RoundedRectangle(cornerRadius: 10.0))
            //END-Hlavni HStack se sloupcema statistik
        }.frame(maxWidth: .infinity, maxHeight: 200, alignment: .top)
            .background(Color("theme_gray_8"))
    }
}

struct TxtC: View {
    var txt: String
    var col: Color
    var body: some View {
        Text(txt)
            .fontWeight(.heavy)
            .foregroundColor(col)
    }
}

struct TxtB: View {
    var txt: String
    var body: some View {
        Text(txt)
            .fontWeight(.heavy)
            .foregroundColor(Color("txt_light_gray"))
    }
}

struct TxtN: View {
    var txt: String
    var body: some View {
        Text(txt).foregroundColor(Color("txt_light_gray"))
    }
}

#Preview {
    MainStatsView(powerData: PowerData())
}


func formNum(num: Float) -> String {
    let formatter = NumberFormatter()
    var retval = "0"
    if (num > 1000) {
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        retval = formatter.string(from: num as NSNumber) ?? "-"
    } else if (num > 100) {
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        retval = formatter.string(from: num as NSNumber) ?? "-"
    } else {
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        retval = formatter.string(from: num as NSNumber) ?? "-"
    }
    return retval.replacingOccurrences(of: ",", with: ".")
}
