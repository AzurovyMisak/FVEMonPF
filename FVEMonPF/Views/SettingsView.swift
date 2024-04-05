//
//  SettingsView.swift
//  FVEMonPF
//
//  Created by Majkl on 27.03.2024.
//

import SwiftUI
import Combine

struct SettingsView: View {
    
    @AppStorage("udMqttHost") var udMqttHost = ""
    @AppStorage("udMqttPort") var udMqttPort = ""
    @AppStorage("udMqttTopicLiveData") var udMqttTopicLiveData = ""
    @AppStorage("udMqttTopicStatsDay365") var udMqttTopicStatsDay365 = ""
    @AppStorage("udMqttTopicStatsMonth") var udMqttTopicStatsMonth = ""
    
    @Environment (\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding public var isSettingChanged: Bool
    
    @State private var locMqttHost: String = ""
    @State private var locMqttPort: String = ""
    @State private var locMqttTopicLiveData: String = ""
    @State private var locMqttTopicStatsDay365: String = ""
    @State private var locMqttTopicStatsMonth: String = ""
    
    //@Binding public var mqttHost: String
    //@Binding public var mqttPort: String
    //@Binding public var mqttTopicLiveData: String
    

    
    var body: some View {
        //NavigationStack() {
        ZStack() {
            VStack(alignment: .leading) {
                //*** VStack-broker address
                VStack(alignment: .leading) {
                    Text("MQTT Broker Address")
                        .foregroundColor(Color("txt_light_gray"))
                        .font(.system(size: 13))
                        .fontWeight(.heavy)
                    TextField("", text: $locMqttHost)
                        .autocapitalization(.none)
                        .padding(.horizontal, 10)//odrazeni textu uvnitr
                        .frame(height: 35)
                        .background(Color("theme_gray_7").opacity(0.5))
                        .foregroundColor(Color("theme_gray_3"))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 10)
                .padding(.top, 20)
                //END-VStack-broker address
                
                //***VStack-broker Port
                VStack(alignment: .leading) {
                    Text("MQTT Broker Port")
                        .foregroundColor(Color("txt_light_gray"))
                        .font(.system(size: 13))
                        .fontWeight(.heavy)
                    //.padding()
                    TextField("", text: $locMqttPort)
                        .autocapitalization(.none)
                        .keyboardType(.numberPad)
                        .onReceive(Just(locMqttPort)) { newValue in
                            let filtered = newValue.filter {"0123456789".contains($0)}
                            if filtered != newValue {
                                self.locMqttPort = filtered
                            }
                            
                        }
                        .padding(.horizontal, 10)//odrazeni textu uvnitr
                        .frame(height: 35)
                        .background(Color("theme_gray_7").opacity(0.5))
                        .foregroundColor(Color("theme_gray_3"))
                        .cornerRadius(8)
                }                
                .padding(.horizontal, 10)
                .padding(.top, 5)
                //END-VStack-broker port
                
                //***VStack-Topic Live Data
                VStack(alignment: .leading) {
                    Text("Topic for Live Data")
                        .foregroundColor(Color("txt_light_gray"))
                        .font(.system(size: 13))
                        .fontWeight(.heavy)
                    TextField("", text: $locMqttTopicLiveData)
                        .autocapitalization(.none)
                        .padding(.horizontal, 10)//odrazeni textu uvnitr
                        .frame(height: 35)
                        .background(Color("theme_gray_7").opacity(0.5))
                        .foregroundColor(Color("theme_gray_3"))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 10)
                .padding(.top, 5)
                //END-VStack-Topic Live Data
                
                //***VStack-Topic denni statistiky
                VStack(alignment: .leading) {
                    Text("Topic for Daily Statistics")
                        .foregroundColor(Color("txt_light_gray"))
                        .font(.system(size: 13))
                        .fontWeight(.heavy)
                    TextField("", text: $locMqttTopicStatsDay365)
                        .autocapitalization(.none)
                        .padding(.horizontal, 10)//odrazeni textu uvnitr
                        .frame(height: 35)
                        .background(Color("theme_gray_7").opacity(0.5))
                        .foregroundColor(Color("theme_gray_3"))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 10)
                .padding(.top, 5)
                //END-VStack-Topic denni statistiky
                
                //***VStack-Topic mesicni statistiky
                VStack(alignment: .leading) {
                    Text("Topic for Monthly Statistics")
                        .foregroundColor(Color("txt_light_gray"))
                        .font(.system(size: 13))
                        .fontWeight(.heavy)
                    TextField("", text: $locMqttTopicStatsMonth)
                        .autocapitalization(.none)
                        .padding(.horizontal, 10)//odrazeni textu uvnitr
                        .frame(height: 35)
                        .background(Color("theme_gray_7").opacity(0.5))
                        .foregroundColor(Color("theme_gray_3"))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 10)
                .padding(.top, 5)
                //END-VStack-Topic mesicni statistiky
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color("theme_gray_9"))
            .clipShape(RoundedRectangle(cornerRadius: 0.0))//jinak je panel pres celou obrazovku
            //*** NAVIGACE
            .navigationTitle("Settings")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button(action : {
                    isSettingChanged = false
                    self.presentationMode.wrappedValue.dismiss()
                }) { Text("Cancel")},
                trailing: Button(action: {
                    // nastaveni bylo ulozeno, nastav true -> klient bude odpojen
                    isSettingChanged = true
                    
                    
                    
                    // uloz nastaveni do userDefaults
                    //UserDefaults.standard.set(locMqttBrokerAddress, forKey: "udMqttBroker")
                    //debug
                    //let debVal = UserDefaults.standard.string(forKey: "udMqttBroker") ?? "nic"
                    //NSLog("poulozeni-\(debVal)")
                    //
                    //UserDefaults.standard.set(locMqttBrokerPort, forKey: "udMqttPort")
                    //UserDefaults.standard.set(locMqttTopicLiveData, forKey: "udMqttTopicLiveData")
                    udMqttHost = locMqttHost
                    udMqttPort = locMqttPort
                    udMqttTopicLiveData = locMqttTopicLiveData
                    udMqttTopicStatsDay365 = locMqttTopicStatsDay365
                    udMqttTopicStatsMonth = locMqttTopicStatsMonth
                    // uloz nastaveni do Shared variables
                    //mqttHost = locMqttHost
                    //mqttPort = locMqttPort
                    //mqttTopicLiveData = locMqttTopicLiveData
                    
                    self.presentationMode.wrappedValue.dismiss()
                }) { Text("Save")}
            )
            //END-NAVIGACE
            //END Hlavni VStack cela obrazovka
            
            //}
        }.onAppear {
            
            locMqttHost = udMqttHost
            locMqttPort = udMqttPort
            locMqttTopicLiveData = udMqttTopicLiveData
            locMqttTopicStatsDay365 = udMqttTopicStatsDay365
            locMqttTopicStatsMonth = udMqttTopicStatsMonth
        }
    }

    
}

#Preview {
    SettingsView(
        isSettingChanged: .constant(false)
        //mqttHost: .constant("broker.hivemq.com"),
        //mqttPort: .constant("1883"),
        //mqttTopicLiveData: .constant("solar/data")
    )
}
