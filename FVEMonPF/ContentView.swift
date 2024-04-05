//
//  ContentView.swift
//  FVEMonPF
//
//  Created by Majkl on 12.03.2024.
//

import SwiftUI
import CocoaMQTT
import SwiftyJSON

class PowerData: ObservableObject {
    @Published var lstDenniVykony: [DataStatItem] = []
    @Published var rocniVykony: DataStatsYearItem = DataStatsYearItem()
    @Published var lstMesicniVykony: [DataStatItem] = []
}


struct ContentView: View {
    
    //Hlavni instance PowerData, do dalsich Views se musi propadovat tato instance !!!!!
    // v subview je to definovano jako @ObservedObject var data: PowerData
    @StateObject var powerData = PowerData()
    
    
    
    @AppStorage("udMqttHost") var udMqttHost = ""
    @AppStorage("udMqttPort") var udMqttPort = ""
    @AppStorage("udMqttTopicLiveData") var udMqttTopicLiveData = ""
        //"solar/data"
    @AppStorage("udMqttTopicStatsDay365") var udMqttTopicStatsDay365 = "" //"solar/data/android/powers/day365"
    @AppStorage("udMqttTopicStatsMonth") var udMqttTopicStatsMonth = "" //"solar/data/android/powers/month"
    
    @State public var debugMessage: String = "ZATIM NIC"
    @State public var isMqttConnected: Bool = false
    
    @State public var isSettingChanged: Bool = false
    
    @State public var txtPV1Power: String = "0 W"
    @State public var txtPV1Voltage: String = "0 V"
    @State public var txtPV1Current: String = "0 A"
    @State public var txtPV2Power: String = "0 W"
    @State public var txtPV2Voltage: String = "0 V"
    @State public var txtPV2Current: String = "0 A"
    @State public var txtPVPowerTotal: String = "0 W"
    
    @State public var txtHomePowerTotal: String = "0 W"
    @State public var txtHomePowerL1: String = "0 W"
    @State public var txtHomePowerL2: String = "0 W"
    @State public var txtHomePowerL3: String = "0 W"
    
    @State public var txtBatSOC: String = "0 %"
    @State public var txtBatPower: String = "0 W"
    @State public var txtBatSOH: String = "0 %"
    @State public var txtBatVoltage: String = "0 V"
    @State public var txtBatCurrent: String = "0 A"
    @State public var batCharge: Double = 0.0
    @State public var imgBatState: String = "arrow-stop"
    
    @State public var imgGridL1State: String = "square"
    @State public var imgGridL2State: String = "square"
    @State public var imgGridL3State: String = "square"
    @State public var txtGridL1: String = "0 W"
    @State public var txtGridL2: String = "0 W"
    @State public var txtGridL3: String = "0 W"
    @State public var txtGridIn: String = "0 W"
    @State public var txtGridOut: String = "0 W"
    
    @State public var animTopLeft: Int = 0 // 0=no anim, 1=In, 2=Out
    @State public var animTopRight: Int = 0
    @State public var animBottomLeft: Int = 0
    @State public var animBottomRight: Int = 0
    
    @State public var animFlash = false
    
    @State public var txtConnectionStatus: String = "Disconnected"
    @State public var colConnectionStatus: Color = Color("conn-red")
    
    //pouziva se pro reset animace dratu, pokazde kdyz se vrati navigace zpatky na hlavni
    //obrazovku, tak se cislo zvysi o jednicku a animace se vyresetuje
    @State public var animationID  = 0
    
    //@State public var mqttHost: String = ""
    //@State public var mqttPort: String = ""
    //@State public var mqttTopicLiveData: String = ""
    
    @State private var deb: String = "_"
    
    /*let mqttclient = CocoaMQTT(
        clientID: "pavelfor",
        host: "broker.hivemq.com",
        port: 1883)*/
    
    
    
    //let liveDataTopic = "solar/data"
    

    private var mqttclient = CocoaMQTT(clientID: "pavelfor")
        
    init() {
        
        // sem dej inicializaci MQTT
        self.mqttclient.keepAlive = 60
        self.mqttclient.autoReconnect = true
        
    }
    
    private func animLiveOprationFlash() {
        self.animFlash.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
            withAnimation(.easeIn(duration: 5)) {
                self.animFlash.toggle()
            }
        })
    }
    
    var body: some View {
        //Hlavni kontejner kvuli menu. Modifier je na konci
        NavigationStack() {
            //Hlavni Zstack - musi byt kvuli plovoucimu tlacitku
            ZStack (alignment: .bottomTrailing){
                //Color("theme_gray_9")
                
                
                
                //VStack-Hlavni Panel v ZStacku
                VStack(alignment: .leading) {
                    
                    //***VStack-Status Bar
                    VStack(alignment: .center) {
                        Text(txtConnectionStatus)
                            .bold()
                            .foregroundColor(colConnectionStatus)
                        
                        
                    }.frame(width: UIScreen.main.bounds.width - 20, height: 25, alignment: .center)
                        .background(Color("theme_gray_8"))
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                        .padding(.horizontal, 10)
                        .padding(.top, 15)
                    //END-VStack Status Bar
                    
                    //*** VStack-LiveData Animace
                    VStack(spacing: 0) {
                        
                        HStack {//-Nadpis Live Date
                            RoundedRectangle(cornerRadius: 3.0)
                                .fill(animFlash ? Color("lightGreen") : Color("theme_gray_9"))
                                .frame(width: 15, height: 7, alignment: .center)
                                .clipShape(RoundedRectangle(cornerRadius: 3.0))
                            //.border(Color("theme_gray_7"))
                            Text("Live operation")
                                .foregroundColor(Color("theme_gray_6"))
                                .fontWeight(.bold)
                            
                        }
                        
                        HlavniPanel(
                            
                            animationID: $animationID,
                            
                            animTopLeft: $animTopLeft,
                            animTopRight: $animTopRight,
                            animBottomLeft: $animBottomLeft,
                            animBottomRight: $animBottomRight,
                            
                            txtHomePowerTotal: $txtHomePowerTotal,
                            txtHomePowerL1: $txtHomePowerL1,
                            txtHomePowerL2: $txtHomePowerL2,
                            txtHomePowerL3: $txtHomePowerL3,
                            
                            txtPV1Power: $txtPV1Power,
                            txtPV1Voltage: $txtPV1Voltage,
                            txtPV1Current: $txtPV1Current,
                            
                            txtPV2Power: $txtPV2Power,
                            txtPV2Voltage: $txtPV2Voltage,
                            txtPV2Current: $txtPV2Current,
                            
                            txtPVPowerTotal: $txtPVPowerTotal,
                            
                            imgGridL1State: $imgGridL1State,
                            imgGridL2State: $imgGridL2State,
                            imgGridL3State: $imgGridL3State,
                            txtGridL1: $txtGridL1,
                            txtGridL2: $txtGridL2,
                            txtGridL3: $txtGridL3,
                            txtGridIn: $txtGridIn,
                            txtGridOut: $txtGridOut,
                            
                            txtBatSOC: $txtBatSOC,
                            txtBatPower: $txtBatPower,
                            txtBatSOH: $txtBatSOH,
                            txtBatVoltage: $txtBatVoltage,
                            txtBatCurrent: $txtBatCurrent,
                            batCharge: $batCharge
                            
                            
                            
                        )
                        .padding(.bottom, 8)
                        //.border(Color.cyan, width: 2)
                        
                    }
                    .frame(width: UIScreen.main.bounds.width - 20, height: 310, alignment: .bottom)
                    .background(Color("theme_gray_8"))
                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                    .padding(.horizontal, 10)
                    //END-VStack-LiveData Animace
                    
                    
                    VStack() {

                        MainStatsView(powerData: powerData)
                    }.padding(.horizontal, 10)
                    
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                //.border(Color.red)
                    .background(Color("theme_gray_9"))
                    .padding(0)
                    .clipShape(RoundedRectangle(cornerRadius: 0.0))//jinak je panel pres celej telefon
                //END-Hlavni VStack v hlavnim ZStacku
                
                /*
                //DEBUG Zprava
                VStack() {
                    Text("Debug").foregroundStyle(.white)
                    Text("Datumod: \(powerData.rocniVykony.datumod)").foregroundStyle(.white)
                    Text("spotreba: \(powerData.rocniVykony.spotreba)").foregroundStyle(.white)
                    Text("vyrobenocelkem: \(powerData.rocniVykony.vyrobenoCelkem)").foregroundStyle(.white)
                    Text("vyrobenokespotrebe: \(powerData.rocniVykony.vyrobenoKeSpotrebe)").foregroundStyle(.white)
                    Text("nakupcelkem: \(powerData.rocniVykony.nakupCelkem)").foregroundStyle(.white)
                    Text("nakupcez: \(powerData.rocniVykony.nakupCEZ)").foregroundStyle(.white)
                    Text("pretokcelkem: \(powerData.rocniVykony.pretokCelkem)").foregroundStyle(.white)
                    Text("pretokvraceny: \(powerData.rocniVykony.pretokVraceny)").foregroundStyle(.white)
                    Text("pretokprebytek: \(powerData.rocniVykony.pretokPrebytek)").foregroundStyle(.white)
                }.frame(maxWidth: .infinity, alignment: .topLeading)
                //END-DEBUG Zprava
                 */
                
                //Tlacitko pripojeni-plave v hlavnim ZSTacku
                Button(action: {
                    if(!self.isMqttConnected) {
                        if (udMqttHost != "" && udMqttPort != "" && udMqttTopicLiveData != "") {
                            self.mqttclient.host = udMqttHost
                            self.mqttclient.port = UInt16(udMqttPort) ?? 0
                            
                            txtConnectionStatus = "Connecting to //\(mqttclient.host):\(mqttclient.port)"
                            colConnectionStatus = Color("conn-yellow")
                            _ = self.mqttclient.connect()
                            
                            self.mqttclient.didConnectAck = {mqtt, ack in
                                
                                if (ack == CocoaMQTTConnAck.accept) {
                                    NSLog("mydebug - \(ack)")
                                    txtConnectionStatus = "Connected"
                                    colConnectionStatus = Color("conn-green")
                                    self.isMqttConnected = true
                                    //self.mqttclient.subscribe("misakpecky/solar/data")
                                    self.mqttclient.subscribe([
                                        (udMqttTopicLiveData, .qos0),
                                        (udMqttTopicStatsDay365, .qos0),
                                        (udMqttTopicStatsMonth, .qos0)
                                    ])
                                    
                                    self.mqttclient.didReceiveMessage = {mqtt, msg, id in
                                        if(msg.string != nil) {
                                            //NSLog("\(msg.string ?? "NOVAL")")
                                            fnParsujZpravu(topic: msg.topic, msg: msg.string!)
                                        }
                                    }
                                } else {
                                    txtConnectionStatus = String(ack.rawValue)
                                    colConnectionStatus = Color("conn-red")
                                }
                            }
                        } else {
                            txtConnectionStatus = "Configure Connection in Settings"
                            colConnectionStatus = Color("conn-red")
                        }
                    } else {
                        self.mqttclient.disconnect()
                        self.mqttclient.didDisconnect = {mqtt, err in
                            txtConnectionStatus = "Disconnected"
                            colConnectionStatus = Color("conn-red")
                            self.isMqttConnected = false
                            vynulujHodnoty()
                        }
                    }
                }, label: {
                    Image(systemName: "personalhotspot.circle")
                        .resizable()
                        .frame(width:60, height: 60)
                        .foregroundColor(self.isMqttConnected ? .green : .red)
                        .background(.white)
                        .clipShape(Circle())
                        .padding(20)
                })//END-Tlacitko na poipojeni
        
                
            }
            .toolbar(content: {

                Menu(content: {

                    NavigationLink(value: "mnuSettings", label: {
                        HStack {
                            Text("Settings")
                            Image(systemName: "wrench.and.screwdriver")
                        }.background(Color.green)
                    })
                    NavigationLink(value: "mnuAbout", label: {
                        HStack() {
                            Text("About")
                            Image(systemName: "info.square")
                        }
                    })
                }, label: {
                    Image(systemName: "ellipsis.circle")
                }).navigationDestination(for: String.self) { value in
                    if (value == "mnuSettings") {
                        SettingsView(
                            isSettingChanged: $isSettingChanged
                            //mqttHost: $mqttHost,
                            //mqttPort: $mqttPort,
                            //mqttTopicLiveData: $mqttTopicLiveData
                            
                            
    //                            mqttBrokerAddress: $mqttBrokerAddress
                        )
                    } else if (value == "mnuAbout") {
                        AboutView()
                    }
                      
                }
                
            })//END-Toolbar a NavigationLinky
            .onChange(of: isSettingChanged) {newValue in
                self.isSettingChanged = newValue
                if (newValue == true) {
                    //nastaveni bylo ulozeno->odpoj klienta
                    self.mqttclient.disconnect()
                    self.mqttclient.didDisconnect = {mqtt, err in
                        txtConnectionStatus = "Disconnected"
                        colConnectionStatus = Color("conn-red")
                        self.isMqttConnected = false
                        vynulujHodnoty()
                    }
                    NSLog("Disconnect called")
                    self.isSettingChanged = false
                }
                
            }
            .onAppear {
                // zvysi cislo animID, takze se vyresetuji animace, jinak kulicky litaly zmatene
                // kdyz se vratilo z jine obrazovky
                animationID += 1
            }
            .onDisappear {
                //apka zavrena, odpoj a vznuluj
                /*self.mqttclient.disconnect()
                self.mqttclient.didDisconnect = {mqtt, err in
                    txtConnectionStatus = "Disconnected"
                    colConnectionStatus = Color("conn-red")
                    self.isMqttConnected = false
                    vynulujHodnoty()
                }*/
            }
            
            
            
            //END-Hlavni ZStack
        }
        //END-NavigationView - Hlavni view celeho screenu
        
        
        
        
    }//END-body
    
    func fnParsujZpravu(topic: String, msg: String) {
        
        //debugMessage = topic
        NSLog(topic)
        switch topic {
        case udMqttTopicLiveData:
            self.animLiveOprationFlash()
        
            if let data = msg.data(using: .utf8) {
                if let json = try? JSON(data: data) {
                    //debugMessage = json["Timestamp"].stringValue
                    
                    let PVPowerTotal = json["Power_PV1"].doubleValue + json["Power_PV2"].doubleValue
                    //let PVVoltage = json["Voltage_PV1"].doubleValue + json["Voltage_PV2"].doubleValue
                    //let PVCurrent = json["Current_PV1"].doubleValue + json["Current_PV2"].doubleValue
                    txtPVPowerTotal = fnDejKilo(value: PVPowerTotal, units: "W")
                    txtPV1Voltage = fnDejKilo(value: json["Voltage_PV1"].doubleValue, units: "V")
                    txtPV1Current = fnDejKilo(value: json["Current_PV1"].doubleValue, units: "A")
                    txtPV1Power = fnDejKilo(value: json["Power_PV1"].doubleValue, units: "W", decimals: 1)
                    
                    txtPV2Voltage = fnDejKilo(value: json["Voltage_PV2"].doubleValue, units: "V")
                    txtPV2Current = fnDejKilo(value: json["Current_PV2"].doubleValue, units: "A")
                    txtPV2Power = fnDejKilo(value: json["Power_PV2"].doubleValue, units: "W", decimals: 1)
                    
                    animTopLeft = (PVPowerTotal > 50) ? 1 : 0
                    
                    
                    
                    txtHomePowerTotal = fnDejKilo(value: json["Load_Power_Total"].doubleValue,units: "W")
                    
                    let homeL1 = json["Load_Power_L1"].doubleValue
                    let homeL2 = json["Load_Power_L2"].doubleValue
                    let homeL3 = json["Load_Power_L3"].doubleValue
                    let homeTotal = homeL1 + homeL2 + homeL3
                    if (homeTotal > 50.0) {
                        animTopRight = 2
                    } else {
                        animTopRight = 0
                    }
                    txtHomePowerL1 = fnDejKilo(value: json["Load_Power_L1"].doubleValue, units: "W")
                    txtHomePowerL2 = fnDejKilo(value: json["Load_Power_L2"].doubleValue, units: "W")
                    txtHomePowerL3 = fnDejKilo(value: json["Load_Power_L3"].doubleValue, units: "W")
                    
                    txtBatVoltage = fnDejKilo(value: json["Battery_U"].doubleValue / 10.0, units: "V")
                    txtBatCurrent = fnDejKilo(value: abs(json["Battery_I"].doubleValue), units: "A")
                    let batP = json["Battery_P"].doubleValue
                    txtBatPower = fnDejKilo(value: abs(batP), units: "W")
                    self.imgBatState = "arrow-right"
                    if (abs(batP) > 50) {
                        if (batP > 0) {
                            // baterka se vybiji, sipka doprava
                            animBottomLeft = 1
                            //self.imgBatState = "arrow-right"
                        } else {
                            self.imgBatState = "arrow-left"
                            animBottomLeft = 2
                            // baterka se vybiji, sipka doleva
                        }
                        
                    }else {
                        // baterka nic nedela, smaz obrazek
                        //self.imgBatState = "arrow-stop"
                        animBottomLeft = 0
                    }
                    batCharge = json["Battery_SOC"].doubleValue
                    txtBatSOC = String(json["Battery_SOC"].intValue) + " %"
                    txtBatSOH = String(json["Battery_SOH"].intValue) + " %"
                    
                    let gridPowerL1 = json["MT_Active_Power_L1"].intValue
                    let gridPowerL2 = json["MT_Active_Power_L2"].intValue
                    let gridPowerL3 = json["MT_Active_Power_L3"].intValue
                    
                    txtGridL1 = fnDejKilo(value: abs(Double(gridPowerL1)), units: "W")
                    txtGridL2 = fnDejKilo(value: abs(Double(gridPowerL2)), units: "W")
                    txtGridL3 = fnDejKilo(value: abs(Double(gridPowerL3)), units: "W")
                    
                    imgGridL1State = gridPowerL1 >= 0 ? "arrowtriangle.right" : "arrowtriangle.left"
                    imgGridL2State = gridPowerL2 >= 0 ? "arrowtriangle.right" : "arrowtriangle.left"
                    imgGridL3State = gridPowerL3 >= 0 ? "arrowtriangle.right" : "arrowtriangle.left"
                    
                    var nZaporny = 0
                    var nKladny = 0
                    
                    if (gridPowerL1 > 0) {
                        nKladny += gridPowerL1
                    } else {
                        nZaporny += abs(gridPowerL1)
                    }
                    
                    if (gridPowerL2 > 0) {
                        nKladny += gridPowerL2
                    } else {
                        nZaporny += abs(gridPowerL2)
                    }
                    
                    if (gridPowerL3 > 0) {
                        nKladny += gridPowerL3
                    } else {
                        nZaporny += abs(gridPowerL3)
                    }
                    
                    if (nZaporny > nKladny) {
                        // kupuju, animace dovnitr
                        animBottomRight = 1
                    } else {
                        //prodavam, animace ven
                        animBottomRight = 2
                    }
                    
                    txtGridOut = fnDejKilo(value: Double(nZaporny), units: "W")
                    txtGridIn = fnDejKilo(value: Double(nKladny), units: "W")
                }
            }
        case udMqttTopicStatsDay365:
            // napln data do pole lstDenniVykony
            if let data = msg.data(using: .utf8) {
                if let json = try? JSON(data: data) {
                    //debugMessage = json["timestamp"].stringValue
                    //NSLog(debugMessage)
                    // vsechno vynuluj, prisla nova zprava
                    powerData.lstDenniVykony.removeAll()
                    powerData.rocniVykony.spotreba = 0.0
                    powerData.rocniVykony.vyrobenoCelkem = 0.0
                    powerData.rocniVykony.vyrobenoKeSpotrebe = 0.0
                    powerData.rocniVykony.nakupCelkem = 0.0
                    powerData.rocniVykony.nakupCEZ = 0.0
                    powerData.rocniVykony.pretokCelkem = 0.0
                    powerData.rocniVykony.pretokVraceny = 0.0
                    powerData.rocniVykony.pretokPrebytek = 0.0
                    
                    for powerItem in json["data"].arrayValue
                    {
                        powerData.lstDenniVykony.append(DataStatItem(
                            datum: powerItem["den"].stringValue,
                            spotreba: powerItem["spotreba"].floatValue,
                            vyroba: powerItem["vyroba"].floatValue,
                                nakup: powerItem["nakup"].floatValue,
                                prodej: powerItem["prodej"].floatValue,
                                soc: powerItem["soc"].intValue
                        ))
                    }
                    NSLog("Items: \(powerData.lstDenniVykony.count)")
                    // vse mam v poli lstDenniVykony, aktualizuj rocni statistiky
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                    let pomoc = (powerData.lstDenniVykony.last?.datum ?? "1970-01-01") + " 00:00"
                    powerData.rocniVykony.datumod = formatter.date(from: pomoc) ?? Date()
                    for den in powerData.lstDenniVykony {
                        powerData.rocniVykony.spotreba += den.spotreba
                        powerData.rocniVykony.vyrobenoCelkem += den.vyroba
                        powerData.rocniVykony.nakupCelkem += den.nakup
                        powerData.rocniVykony.pretokCelkem += den.prodej
                    }
                    let nakupCEZ = powerData.rocniVykony.nakupCelkem - powerData.rocniVykony.pretokCelkem
                    
                    if (nakupCEZ > 0) {
                        // nakup je vetsi nez pretok, kupuju od CEZu
                        powerData.rocniVykony.nakupCEZ = nakupCEZ
                        powerData.rocniVykony.pretokPrebytek = 0.0
                    } else {
                        // nakup CEZ je mensi, mam vice pretoku
                        powerData.rocniVykony.nakupCEZ = 0.0
                        powerData.rocniVykony.pretokPrebytek = abs(nakupCEZ)
                    }
                    // vyrobeno k okamzite spotrebe = vyroba - prodej (vsechno co jsem vzrobil minus vsechnoco jsem prodal se okamzite spotrebovalo)
                    powerData.rocniVykony.vyrobenoKeSpotrebe = powerData.rocniVykony.vyrobenoCelkem - powerData.rocniVykony.pretokCelkem
                    //kolik z celkoveho pretoku jsem zatim vzal zpet ke spotrebe domu. Pokud mam vyrobu > spotrebu, tak to bude nakup, jinak prodej
                    powerData.rocniVykony.pretokVraceny = (powerData.rocniVykony.vyrobenoCelkem > powerData.rocniVykony.spotreba) ? powerData.rocniVykony.nakupCelkem : powerData.rocniVykony.pretokCelkem
                    
                    
                    
                    
                    //NSLog(formatter.string(from: powerData.dataStatsYear.datumod))
                    //powerData.dataStatsYear.datumod =
                }
            }
        case udMqttTopicStatsMonth:
            if let data = msg.data(using: .utf8) {
                if let json = try? JSON(data: data) {

                    powerData.lstMesicniVykony.removeAll()
                    for powerItem in json["data"].arrayValue {
                        powerData.lstMesicniVykony.append(
                            DataStatItem(
                                datum: powerItem["mesic"].stringValue,
                                spotreba: powerItem["spotreba"].floatValue,
                                vyroba: powerItem["vyroba"].floatValue,
                                nakup: powerItem["nakup"].floatValue,
                                prodej: powerItem["prodej"].floatValue,
                                soc: 0
                            )
                        )
                    }
                    
                }
            }
        
        default: break
        }
    }
    
    func fnDejKilo(value: Double, units: String, decimals: Int = 2) -> String {
        var retval = ""
        if (value <= 999) {
            retval = String(format: "%.0f", value) + " " + units
        } else {
            retval = String(format: "%.\(decimals)f",value / 1000.0) + " k" + units
            //retval = String(format: "%.2f", (round(value / 1000))) + " k" + units
        }
        return retval
    }

    
    func vynulujHodnoty() {
        debugMessage = "ZATIM NIC"
        isMqttConnected = false
        txtPV1Power = "0 W"
        txtPV1Voltage = "0 V"
        txtPV1Current = "0 A"
        
        txtPV2Power = "0 W"
        txtPV2Voltage = "0 V"
        txtPV2Current = "0 A"
        
        txtPVPowerTotal = "0 W"
        
        txtHomePowerTotal = "0 W"
        txtHomePowerL1 = "0 W"
        txtHomePowerL2 = "0 W"
        txtHomePowerL3 = "0 W"
        
        txtBatSOC = "0 %"
        txtBatPower = "0 W"
        txtBatSOH = "0 %"
        txtBatVoltage = "0 V"
        txtBatCurrent = "0 A"
        batCharge = 0.0
        imgBatState = "arrow-stop"
        
        imgGridL1State = "square"
        imgGridL2State = "square"
        imgGridL3State = "square"
        txtGridL1 = "0 W"
        txtGridL2 = "0 W"
        txtGridL3 = "0 W"
        txtGridIn = "0 W"
        txtGridOut = "0 W"
        
        animTopLeft = 0
        animBottomLeft = 0
        animTopRight = 0
        animBottomRight = 0
        
        animFlash = false
        
        powerData.lstDenniVykony.removeAll()
        powerData.lstMesicniVykony.removeAll()
        powerData.rocniVykony.datumod = Date()
        
        powerData.rocniVykony.spotreba = 0.0
        powerData.rocniVykony.vyrobenoCelkem = 0.0
        powerData.rocniVykony.vyrobenoKeSpotrebe = 0.0
        powerData.rocniVykony.nakupCelkem = 0.0
        powerData.rocniVykony.nakupCEZ = 0.0
        powerData.rocniVykony.pretokCelkem = 0.0 
        powerData.rocniVykony.pretokVraceny = 0.0
        powerData.rocniVykony.pretokPrebytek = 0.0
        
    }
    
    /*func fnReadUserDefault(keyName: String) -> String {
        var keyValue = ""
        let preferences = UserDefaults.standard
        
        if preferences.object(forKey: keyName) == nil {
            keyValue = ""
            NSLog("mujDebug-klic \(keyName) neexistuje")
        } else {
            keyValue = preferences.string(forKey: keyName) ?? ""
        }
        return keyValue
    }*/
    
    /*func fnSavleUserDefault(keyName: String, keyValue: String) {
        let preferences = UserDefaults.standard
        preferences.set(keyValue, forKey: keyName)
    }*/
    
}

struct HlavniPanel: View {
    
    var iconSize: CGFloat = 75
    
    //animationID se zvysuje po jednicce aby se vyresetovala animace
    @Binding public var animationID: Int
    
    //@Binding public var solPanelPower: Float
    @Binding public var animTopLeft: Int
    @Binding public var animTopRight: Int
    @Binding public var animBottomLeft: Int
    @Binding public var animBottomRight: Int
    
    //Hodnoty DUM
    @Binding public var txtHomePowerTotal: String
    @Binding public var txtHomePowerL1: String
    @Binding public var txtHomePowerL2: String
    @Binding public var txtHomePowerL3: String
    
    //Hodnoty panel
    @Binding public var txtPV1Power: String
    @Binding public var txtPV1Voltage: String
    @Binding public var txtPV1Current: String
    @Binding public var txtPV2Power: String
    @Binding public var txtPV2Voltage: String
    @Binding public var txtPV2Current: String
    @Binding public var txtPVPowerTotal: String
    
    //Hodnoty grid
    @Binding public var imgGridL1State: String
    @Binding public var imgGridL2State: String
    @Binding public var imgGridL3State: String
    @Binding public var txtGridL1: String
    @Binding public var txtGridL2: String
    @Binding public var txtGridL3: String
    @Binding public var txtGridIn: String
    @Binding public var txtGridOut: String
    
    //Hodnoty Baterka
    @Binding public var txtBatSOC: String
    @Binding public var txtBatPower: String
    @Binding public var txtBatSOH: String
    @Binding public var txtBatVoltage: String
    @Binding public var txtBatCurrent: String
    @Binding public var batCharge: Double
    
    var body: some View {
        //Hlavni frame HSTACK pres celou obrazovku, variable vyska
        HStack(spacing: 0) {
            //Prvni sloupec ikona panelu a baterie
            VStack(spacing: 0) {
                
                //vypln - abych mohl mit dole pod baterkou dva radky
                VStack {
                    Text(" ")
                }
                
                //Ikona panelu
                VStack(spacing: 0) {
                    Image("solar-panel")
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(Color("fve_icon"))
                        .background(
                            RadialGradient(gradient: Gradient(colors: [.white, Color("fve_icon")]), center: .center, startRadius: 1, endRadius: 60))
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                }.padding(0)
                //END-ikona panelu
                
                //panel vykon
                VStack(spacing: 0) {
                    Text(txtPVPowerTotal)
                        .foregroundColor(Color("txt_light_gray"))
                        .font(.system(size: 15))
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 5)
                    
                }
                .frame(width: 75, height: 70,  alignment: .top)
                //.border(Color.yellow)
                .padding(.top, 0)
                //END-vypln pouzita pro watty solar panelu
                
                //Ikona baterky
                VStack(spacing: 0) {
                    ZStack {
                        Image("solar-battery")
                            .resizable()
                            .frame(width: iconSize, height: iconSize)
                            .foregroundColor(Color("fve_icon"))
                            .background(
                                RadialGradient(gradient: Gradient(colors: [.white, Color("fve_icon")]), center: .center, startRadius: 1, endRadius: 60))
                            .clipShape(RoundedRectangle(cornerRadius: 5.0))
                            .offset(x:0, y:-10)
                        
                        //var batCharge = 10.0
                        let batFill : Double = (38 / 100) * batCharge
                        let batOffset : Double = batFill / 2
                        
                        Rectangle()
                            .fill(Color("fve_icon"))
                            //.offset(x:0, y: -7)
                            //.frame(width: 15, height: 38, alignment: .bottom)
                            
                            .frame(width: 15, height: CGFloat(batFill), alignment: .bottom)
                            .offset(x: 0, y: 12 - CGFloat(batOffset ))
                        
                    }
                }
                .padding(0)
                
                //baterka procenta
                VStack(spacing: 0) {
                    Text(txtBatPower)
                        .foregroundColor(Color("txt_light_gray"))
                        .font(.system(size: 15))
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity, alignment: .center)
                        //.padding(.top, 5)
                }.offset(x: 0, y: -5)
                    .frame(width: 75,  alignment: .top)
                
                //baterka vykon
                VStack(spacing: 0) {
                    Text(txtBatSOC)
                        .foregroundColor(Color("txt_light_gray"))
                        .font(.system(size: 15))
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity, alignment: .center)
                }.offset(x: 0, y: -5)
                    .frame(width: 75,  alignment: .top)
                
            }//.border(Color.red)
            //konec Prvni sloupec ikona panelu a baterie
            
            //druhy sloupec hodnoty a draty
            VStack(spacing: 0) {
                
                
                HStack(spacing: 0){
                    //hodnoty pro panel - levy horni zarovnani
                    VStack(spacing: 0) {
                        HStack() {
                            //** PV2
                            VStack() {
                                Text("PV1")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(Color("txt_light_gray"))
                                    .font(.system(size: 13))
                                    .fontWeight(.heavy)
                                    
                                
                                Text(txtPV1Voltage)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(Color("txt_light_gray"))
                                    .font(.system(size: 13))
                                Text(txtPV1Current)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(Color("txt_light_gray"))
                                    .font(.system(size: 13))
                                Text(txtPV1Power)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(Color("txt_light_gray"))
                                    .font(.system(size: 13))
                            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                //.border(.red)
                            
                            //*** PV1
                            VStack() {
                                Text("PV2")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(Color("txt_light_gray"))
                                    .font(.system(size: 13))
                                    .fontWeight(.heavy)
                                
                                Text(txtPV2Voltage)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(Color("txt_light_gray"))
                                    .font(.system(size: 13))
                                Text(txtPV2Current)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(Color("txt_light_gray"))
                                    .font(.system(size: 13))
                                Text(txtPV2Power)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(Color("txt_light_gray"))
                                    .font(.system(size: 13))
                            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                //.border(.red)
                            //END-PV1
                            
                        }
                    }.frame(maxWidth: 110, maxHeight: 70, alignment: .topLeading)
                        //.border(Color.blue)
                        .padding(.leading, 5)
                        
                    
                    
                    //hodnoty pro barak
                    VStack(spacing: 0) {
                        Text("L1: \(txtHomePowerL1)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("txt_light_gray"))
                            .font(.system(size: 13))
                        Text("L2: \(txtHomePowerL2)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("txt_light_gray"))
                            .font(.system(size: 13))
                        Text("L3: \(txtHomePowerL3)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("txt_light_gray"))
                            .font(.system(size: 13))
                    }.frame(maxWidth: 110, maxHeight: 70, alignment: .topLeading)
                        //.border(Color.red)
                        .padding(.leading, 30)
                        .padding(.top, 5)
                }.frame(maxWidth: .infinity, maxHeight: 70)//.border(Color.brown)
                //END-hodnoty pro panel - levy horni zarovnani
                
                // **** DRATY *****
                ZStack() {
                    HStack(spacing: 0) {
                        
                        //DRATY-leva cast
                        VStack(spacing: 0) {
                            //DRAT-Leva Horni
                            VStack() {
                                if (animTopLeft == 1) {
                                    //ANIM TO CENTER
                                    AnimTopLeftIn().id(animationID)
                                } else if (animTopLeft == 2) {
                                    //ANIM FROM CENTER
                                    AnimTopLeftOut().id(animationID)
                                } else {
                                    //NO ANIMATION
                                    AnimTopLeftNo()
                                }
                            }.frame(width: 105, height: 45)//.border(Color.brown)
                            
                            //DRAT-Leva Dolni
                            VStack() {
                                if (animBottomLeft == 1) {
                                    //ANIM TO CENTER
                                    AnimBottomLeftIn().id(animationID)
                                } else if(animBottomLeft == 2) {
                                    //ANIM FROM CENTER
                                    AnimBottomLeftOut().id(animationID)
                                } else {
                                    //NO ANIMATION
                                    AnimBottomLeftNo()
                                }
                            }.frame(width: 105, height: 45)//.border(Color.brown)
                                                
                            
                        }.frame(maxWidth: .infinity)//.border(Color.red)
                        //END-DRATY-leva cast
                        
                        //DRATY-prava cast
                        VStack(spacing: 0 ) {
                            //DRAT-Prava Horni
                            VStack() {
                                if(animTopRight == 1) {
                                    //ANIM TO CENTER
                                    AnimTopRightIn().id(animationID)
                                } else if(animTopRight == 2) {
                                    //ANIM FROM CENTER
                                    AnimTopRightOut().id(animationID)
                                } else {
                                    AnimTopRightNo()
                                }
                                
                            }.frame(width: 105, height: 45)//.border(Color.brown)
                            
                            //DRAT-Prava Dolni
                            VStack() {
                                if (animBottomRight == 1) {
                                    //ANIM TO CENTER
                                    AnimBottomRightIn().id(animationID)
                                } else if (animBottomRight == 2) {
                                    //ANIM FROM CENTER
                                    AnimBottomRightOut().id(animationID)
                                } else {
                                    AnimBottomRightNo()
                                }
                            }.frame(width: 105, height: 45)//.border(Color.brown)
                            
                        }.frame(maxWidth: .infinity)//.border(Color.blue)
                        
                    }.frame(width: 200, height: 90)//.border(Color.cyan)
                    
                    //Stridac uprostred
                    Image(systemName: "rectangle.fill")
                        .resizable()
                        .foregroundColor(Color("wire-gradient-dark"))
                        .frame( width: 30, height: 30)
                        .offset(x: 0, y:-7)
                    //blesk na stridaci
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 15, height: 20)
                        .offset(x: 0, y: -7)
                    
                    
                }
                //END-draty
                
                //**** hodnoty pro baterku a grid ****
                HStack(spacing: 0){
                    //***Baterka Napeti a Proud
                    VStack(spacing: 0) {
                        Text(txtBatVoltage)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("txt_light_gray"))
                            .font(.system(size: 13))
                        Text(txtBatCurrent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("txt_light_gray"))
                            .font(.system(size: 13))
                        Text("SOH: \(txtBatSOH)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("txt_light_gray"))
                            .font(.system(size: 13))
                    }
                    .frame(maxWidth: 110, maxHeight: 70, alignment: .bottomLeading)
                    .offset(x:5, y:-22)
                    //.border(Color.blue)
                    //END-Baterka Napeti a Proud
                    
                    //***GRID Faze
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Image(systemName: imgGridL1State)
                                .resizable()
                                .frame(width: 8, height: 8)
                                .foregroundColor(Color("fve_icon"))
                            Text("L1: \(txtGridL1)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color("txt_light_gray"))
                                .font(.system(size: 13))
                                .padding(.leading, 5)
                        }
                        HStack(spacing: 0) {
                            Image(systemName: imgGridL2State)
                                .resizable()
                                .frame(width: 8, height: 8)
                                .foregroundColor(Color("fve_icon"))
                            Text("L2: \(txtGridL2)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color("txt_light_gray"))
                                .font(.system(size: 13))
                                .padding(.leading, 5)
                        }
                        HStack(spacing: 0) {
                            Image(systemName: imgGridL3State)
                                .resizable()
                                .frame(width: 8, height: 8)
                                .foregroundColor(Color("fve_icon"))
                            Text("L3: \(txtGridL3)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color("txt_light_gray"))
                                .font(.system(size: 13))
                                .padding(.leading, 5)
                        }
                    }
                    .frame(maxWidth: 110, maxHeight: 70, alignment: .topLeading)
                    //.border(Color.red)
                    .padding(.leading,20)
                    //END-GRID Faze
                    
                }.frame(maxWidth: .infinity, maxHeight: 70, alignment: .bottom)//.border(Color.brown)
                //END-hodnoty pro baterku a grid
                                
                // tohle je vypln spodku prostredniho sloupce, prezdny text
                VStack(spacing: 0) {
                    Text(" ")
                }
                
            }
            .frame(width: 210)
            //.border(Color.orange)
            .padding(0)
            //END-druhy sloupec hodnoty a draty
            
            //treti sloupec ikona domek a sit
            VStack(spacing: 0) {
                
                //vypln - abych mohl mit dole pod gridem dva radky
                VStack {
                    Text(" ")
                }
                
                VStack(spacing: 0) {//ikona domku
                    Image("solar-home")
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(Color("fve_icon"))
                        .background(
                            RadialGradient(gradient: Gradient(colors: [.white, Color("fve_icon")]), center: .center, startRadius: 1, endRadius: 60))
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                }.padding(0)
                
                VStack(spacing: 0) {
                    Text(txtHomePowerTotal)
                        .foregroundColor(Color("txt_light_gray"))
                        .font(.system(size: 15))
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 5)
                }
                .frame(width: 75, height: 70,  alignment: .top)
                //.border(Color.yellow)
                .padding(0)
                
                
                VStack(spacing: 0) {
                    Image("solar-grid")
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(Color("fve_icon"))
                        .background(
                            RadialGradient(gradient: Gradient(colors: [.white, Color("fve_icon")]), center: .center, startRadius: 1, endRadius: 60))
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                        .offset(x:0, y:-10)
                }
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Image(systemName: "arrowtriangle.left")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color("fve_icon"))
                        Text(txtGridOut)
                            .foregroundColor(Color("txt_light_gray"))
                            .font(.system(size: 15))
                            .fontWeight(.heavy)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }.offset(x:0, y:-5)
                    .frame(width: 75,  alignment: .top)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Image(systemName: "arrowtriangle.right")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color("fve_icon"))
                        Text(txtGridIn)
                            .foregroundColor(Color("txt_light_gray"))
                            .font(.system(size: 15))
                            .fontWeight(.heavy)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }.offset(x:0, y:-5)
                    .frame(width: 75,  alignment: .top)
  
                
            }//.border(Color.green).padding(0)
            //konec treti sloupec ikona domek a sit
            
            
        }.frame(maxWidth: .infinity).padding(0)
        //END-Hlavni HStack pres celou obrazovku
    }//END-body
}//END-Hlavni Panel

/*
struct WireTopRight: Shape {
    func path(in rect: CGRect) -> Path {
        return WireTopRight.kresliDrat(in: rect)
    }
    
    static func kresliDrat(in rect: CGRect) -> Path {
        _ = rect.size.height
        let sirka = rect.size.width
        let corner: CGFloat = 20
        var cesta = Path()
        
        cesta.move(to: CGPoint(x: sirka, y: 0))
        cesta.addLine(to: CGPoint(x: corner, y: 0))
        cesta.addCurve(to: CGPoint(x: 0, y: corner),
                       control1: CGPoint(x: 0, y: 0),
                       control2: CGPoint(x: 0, y: corner))
        
        return cesta
    }
    
}

struct AnimTopRightIn : View {
    @State private var flag : Bool = false
    @State private var dim: Bool = false
    var body: some View {
        WireTopRight()
            .stroke(
                Color.red,
                style: StrokeStyle(
                    lineWidth: 2,
                    lineCap: .round,
                    lineJoin: .miter))
            .foregroundColor(.blue)
            .frame(width: 105, height: 35)
            
        Image(systemName: "oval.fill")
            .resizable()
            .foregroundColor(Color.red)
            .frame(width: 8, height: 8).offset(x: -3, y: -4)
            //.scaleEffect(dim ? 1.0 : 0.7)
            //.opacity(dim ? 1 : 0.5)
            .modifier(FollowEffect(
                pct: self.flag ? 1 : 0,
                path: WireTopRight.kresliDrat(
                    in: CGRect(
                        x: 0,
                        y: 0,
                        width: 105,
                        height: 35)).offsetBy(dx: -49, dy: -43.3),
                rotate: false))
            .onAppear {
                withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    self.flag.toggle()
                }
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    self.dim.toggle()
                }
            }
    }
}*/




#Preview {
    ContentView()
}
