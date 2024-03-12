//
//  ContentView.swift
//  FVEMonPF
//
//  Created by Majkl on 12.03.2024.
//

import SwiftUI
import CocoaMQTT
import SwiftyJSON




/*struct ContentView: View {
    
    @State public var debugMessage: String = ""
    @State public var isMqttConnected: Bool = false
    @State public var txtPVPower: String = "0 W"
    @State public var txtPVVoltage: String = "0 V"
    @State public var txtPVCurrent: String = "0 A"
    
    let mqttClient = CocoaMQTT(
        clientID: "pffvemon",
        host: "broker.hivemq.com",
        port: 1883
    )
    
    init() {
        self.mqttClient.keepAlive = 60
        self.mqttClient.autoReconnect = true
    }
    
    func fnParsujZpravu(topic: String, msg: String) {
        debugMessage = msg
        
        
        
    }
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading) {
                /*Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                 */
            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .top)
            
            VStack() {
                Text(self.debugMessage)
            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 250, alignment: .topLeading)
            
        }.onAppear() {
            if(!isMqttConnected) {
                _ = mqttClient.connect()
                self.mqttClient.didConnectAck = { mqtt, ack in
                    self.isMqttConnected.toggle()
                    self.mqttClient.subscribe("misakpecky/solar/data")
                    self.mqttClient.didReceiveMessage = {mqtt, message, id in
                        if (message.string != nil) {
                            fnParsujZpravu(topic: message.topic, msg: message.string!)
                        }
                    }
                    
                }
            }
        }.onDisappear() {
            self.mqttClient.disconnect()
            self.isMqttConnected.toggle()
        }
    }
}*/

struct ContentView: View {
    
    @State public var debugMessage: String = "ZATIM NIC"
    @State public var isMqttConnected: Bool = false
    
    
    @State public var txtPVPower: String = "0 W"
    @State public var txtPVVoltage: String = "0 V"
    @State public var txtPVCurrent: String = "0 A"
    
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
        
    
    /*let mqttclient = CocoaMQTT(
        clientID: "pavelfor",
        host: "broker.hivemq.com",
        port: 1883)*/
    
    let mqttclient = CocoaMQTT(
        clientID: "pavelfor",
        host: "192.168.0.11",
        port: 1883)
    
    let liveDataTopic = "solar/data"
    
    /*let mqttclient = CocoaMQTT(
        clientID: "pavelfor",
        host: "f4d76108051e48c8820f0a9cb3736e7b.s2.eu.hivemq.cloud",
        port: 8883
    )*/
    
    
    
    
    init() {
        // sem dej inicializaci MQTT
        self.mqttclient.keepAlive = 60
        self.mqttclient.autoReconnect = true
        
        /*self.mqttclient.enableSSL = true
// pdoprdele proc to nejde
        self.mqttclient.allowUntrustCACertificate = false
        self.mqttclient.logLevel = CocoaMQTTLoggerLevel.debug
        */
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
        
        ZStack (alignment: .bottomTrailing){
            Color("theme_gray_9")
            
            //VStack-Hlavni Panel v ZStacku
            VStack(alignment: .leading) {
                
                /* // Prni radek tlacitko na pripojeni
                 HStack() {
                 Button(action: {
                 if (!isMqttConnected) {
                 _ = mqttclient.connect()
                 self.mqttclient.didConnectAck = { mqtt, ack in
                 self.isMqttConnected.toggle()
                 self.mqttclient.subscribe("misakpecky/solar/data")
                 self.mqttclient.didReceiveMessage = {mqtt, message, id in
                 if (message.string != nil) {
                 fnParsujZpravu(msg: message.string!)
                 }
                 }
                 }
                 
                 } else {
                 self.mqttclient.disconnect()
                 self.isMqttConnected.toggle()
                 }
                 }, label: {
                 Text(isMqttConnected ? "Disconnect" : "Connect")
                 })
                 }.frame(maxWidth: .infinity, maxHeight: 30, alignment: .trailing)
                 */ // end prvni radek tlacitko na pripojeni
                
                
                //*** VStack-LiveData Animace
                VStack(spacing: 0) {
                    HlavniPanel(
                        animTopLeft: $animTopLeft,
                        animTopRight: $animTopRight,
                        animBottomLeft: $animBottomLeft,
                        animBottomRight: $animBottomRight,
                        
                        txtHomePowerTotal: $txtHomePowerTotal,
                        txtHomePowerL1: $txtHomePowerL1,
                        txtHomePowerL2: $txtHomePowerL2,
                        txtHomePowerL3: $txtHomePowerL3,
                        
                        txtPVPower: $txtPVPower,
                        txtPVVoltage: $txtPVVoltage,
                        txtPVCurrent: $txtPVCurrent,
                        
                        imgGridL1State: $imgGridL1State,
                        imgGridL2State: $imgGridL2State,
                        imgGridL3State: $imgGridL3State,
                        txtGridL1: $txtGridL1,
                        txtGridL2: $txtGridL2,
                        txtGridL3: $txtGridL3,
                        txtGridIn: $txtGridIn,
                        txtGridOut: $txtGridOut
                        
                        
                        
                    )
                    .padding(.bottom, 8)
                    //.border(Color.cyan, width: 2)
                    
                }
                .frame(width: UIScreen.main.bounds.width - 20, height: 300, alignment: .bottom)
                .background(Color("theme_gray_8"))
                .clipShape(RoundedRectangle(cornerRadius: 5.0))
                .padding(10)
                //END-VStack-LiveData Animace
                
                //tlacitko na nastaveni animace - pak smazat
                Button(action: {
                    if(animTopLeft == 0) {
                        animTopLeft = 1
                        animBottomLeft = 1
                        animTopRight = 1
                        animBottomRight = 1
                    } else if (animTopLeft == 1) {
                        animTopLeft = 2
                        animBottomLeft = 2
                        animTopRight = 2
                        animBottomRight = 2
                    } else {
                        animTopLeft = 0
                        animBottomLeft = 0
                        animTopRight = 0
                        animBottomRight = 0
                    }
                }, label: {
                    Text("OTOC")
                })
                //END-tlacitko na nastaveni animace-pak smazat
                
                //VStack-Live Data Panel
                VStack(spacing: 10){
                    
                    HStack {//-Nadpis Live Date
                        RoundedRectangle(cornerRadius: 3.0)
                            .fill(animFlash ? Color("lightGreen") : Color("theme_gray_8"))
                            .frame(width: 15, height: 7, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 3.0))
                        //.border(Color("theme_gray_7"))
                        Text("Live operation")
                            .foregroundColor(Color("theme_gray_6"))
                            .fontWeight(.bold)
                        
                    }
                    HStack{//Radek PV+HOME
                        HStack{//Levy Horni panel
                            VStack(alignment: .leading, spacing: 5){
                                
                                Image("solar-panel")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color("fve_icon"))
                                    .background(
                                        RadialGradient(gradient: Gradient(colors: [.white, Color("fve_icon")]), center: .center, startRadius: 1, endRadius: 60))
                                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                                
                            }
                            VStack(alignment: .leading, spacing: 1){
                                Text(txtPVPower).fontWeight(.bold).foregroundColor(Color("txt_light_gray"))
                                Text(txtPVVoltage)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color("txt_light_gray"))
                                Text(txtPVCurrent)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color("txt_light_gray"))
                            }
                        }.frame(
                            width:UIScreen.main.bounds.width/2-40,
                            height: 100,
                            alignment: .leading)
                        .padding(.leading, 10)
                        .background(Color("theme_gray_6"))
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                        //End Levy Horni Panel
                        
                        //Pravy Horni Panel
                        HStack{
                            VStack(alignment: .trailing, spacing: 1){
                                Text(txtHomePowerTotal).fontWeight(.bold).foregroundColor(Color("txt_light_gray"))
                                Text("L1: " + txtHomePowerL1).font(.system(size: 12)).foregroundColor(Color("txt_light_gray"))
                                Text("L2: " + txtHomePowerL2).font(.system(size: 12)).foregroundColor(Color("txt_light_gray"))
                                
                                Text("L3: " + txtHomePowerL3).font(.system(size: 12)).foregroundColor(Color("txt_light_gray"))
                            }
                            VStack {
                                Image("solar-home")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color("fve_icon"))
                                    .background(
                                        RadialGradient(gradient: Gradient(colors: [.white, Color("fve_icon")]), center: .center, startRadius: 1, endRadius: 60))
                                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                                
                            }
                        }.frame(width:UIScreen.main.bounds.width/2-40, height: 100, alignment: .trailing)
                            .padding(.trailing, 10)
                            .background(Color("theme_gray_6"))
                            .clipShape(RoundedRectangle(cornerRadius: 5.0))
                        //End Pravy Horni
                    }//End radek PV+HOME
                    
                    HStack{//**radek Bat+Grid
                        HStack(alignment: .top){//**HStack-Levy Dolni panel (BAT)
                            VStack(alignment: .center, spacing: 0){
                                ZStack {//**Obrazek baterky
                                    Image("solar-battery")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Color("fve_icon"))
                                        .background(
                                            RadialGradient(gradient: Gradient(colors: [.white, Color("fve_icon")]), center: .center, startRadius: 1, endRadius: 60))
                                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                                    
                                    //var batCharge = 97.0
                                    let batFill : Double = (35 / 100) * batCharge
                                    let batOffset : Double = batFill / 2
                                    
                                    Rectangle()
                                        .fill(Color("fve_icon"))
                                        .frame(width: 20, height: CGFloat(batFill), alignment: .bottom)
                                        .offset(x: 0, y: 20 - CGFloat(batOffset ))
                                }//**End-Zstack-obrazek baterky
                                
                                Text(txtBatPower).fontWeight(.bold).foregroundColor(Color("txt_light_gray"))
                                    .padding(.top, 4)
                                Text(txtBatSOC).fontWeight(.bold).foregroundColor(Color("txt_light_gray"))
                            }//.border(Color.blue)
                            
                            //** VStack-battery-SOH,A,V,direction image
                            VStack(alignment: .leading, spacing: 0){
                                VStack(alignment: .leading) {
                                    Text("SOH: " + txtBatSOH)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color("txt_light_gray"))
                                    Text(txtBatVoltage)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color("txt_light_gray"))
                                    Text(txtBatCurrent)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color("txt_light_gray"))
                                }//.border(Color.pink)
                                Spacer()
                                HStack(){//**image-battery-direction
                                    Spacer()
                                    Image(self.imgBatState)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color("fve_icon"))                                    //Text(">>")
                                }//.border(Color.green)
                                
                            }.padding(.leading, 5)
                            //.border(Color.black)
                            //**End-Vstack-battery-SOH,A,V,direction image
                            
                        }.frame(
                            width:UIScreen.main.bounds.width/2-50,
                            height: 106,
                            alignment: .topLeading)
                        .padding(10)
                        .background(Color("theme_gray_6"))
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                        //.border(Color.red)
                        //**End-HStack-Levy Dolni Panel (BAT)
                        
                        
                        //**HStack-Pravy Dolni Panel (GRID)
                        VStack(alignment: .trailing, spacing: 0){
                            HStack(alignment: .top) {
                                //**VStack-Sloupecek Gridu L1-L3
                                VStack(alignment: .leading, spacing:-1){
                                    HStack(){
                                        Image(self.imgGridL1State)
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color("fve_icon"))
                                        
                                        Text(self.txtGridL1).font(.system(size: 12))
                                            .foregroundColor(Color("txt_light_gray"))
                                        
                                    }//.border(Color.pink)
                                    HStack(){
                                        Image(self.imgGridL2State)
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color("fve_icon"))
                                        Text(self.txtGridL2).font(.system(size: 12))
                                            .foregroundColor(Color("txt_light_gray"))
                                        
                                    }//.border(Color.black)
                                    HStack(){
                                        Image(self.imgGridL3State)
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color("fve_icon"))
                                        Text(self.txtGridL3).font(.system(size: 12))
                                            .foregroundColor(Color("txt_light_gray"))
                                        
                                    }//.border(Color.yellow)
                                }
                                //.border(Color.green)
                                //**End-VStack-Sloupecek Gridu L1-L3
                                //**VStack-Sloupecek s ikonou Gridu
                                VStack(alignment: .trailing, spacing: 0){
                                    Image("solar-grid")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Color("fve_icon"))
                                        .background(
                                            RadialGradient(gradient: Gradient(colors: [.white, Color("fve_icon")]), center: .center, startRadius: 1, endRadius: 60))
                                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                                }//.border(Color.orange)
                                //**End-VStack-Sloupcecek s ikonou Gridu
                            }//.border(Color.yellow)
                            //**VStack-Grid-Texty s dodavkou a odberem
                            VStack(alignment: .trailing, spacing: -10){
                                HStack(){
                                    Image("arrow-left")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color("fve_icon"))
                                    Text(self.txtGridOut).fontWeight(.bold).foregroundColor(Color("txt_light_gray"))
                                    
                                }//.border(Color.blue)
                                
                                HStack(){
                                    Image("arrow-right")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color("fve_icon"))
                                    Text(self.txtGridIn).fontWeight(.bold).foregroundColor(Color("txt_light_gray"))
                                    
                                }//.border(Color.blue)
                            }.frame(alignment: .trailing)
                            //.border(Color.purple)
                            //**END-Vstack-Grid-Texty s dodavkou a odberem
                            
                        }.frame(
                            width:UIScreen.main.bounds.width/2-50,
                            height: 106,
                            alignment: .topTrailing)
                        .padding(10)
                        .background(Color("theme_gray_6"))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        //.border(Color.red)
                        //**End-HStack-Pravy Dolni Panel (GRID)
                        
                    }//END HStack radek Bat+Grid
                    
                    
                    
                }.frame(width: UIScreen.main.bounds.width - 20, height: 290, alignment: .center)
                    .background(Color("theme_gray_7"))
                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                    .padding(10)
                //.padding(.leading, 10)
                //.padding(.trailing, 10)
                //.border(Color.blue)
                //END-Live Data Panel
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            //.border(Color.red)
                .background(Color("theme_gray_9"))
                .padding(0)
                .clipShape(RoundedRectangle(cornerRadius: 0.0))//jinak je panel pres celej telefon
            //END-VStack v hlavnim ZStacku
            
            //DEBUG Zprava
            VStack() {
                Text(self.debugMessage).foregroundStyle(.white)
            }.frame(maxWidth: .infinity, alignment: .topLeading)
            //END-DEBUG Zprava
            
            //Tlacitko pripojeni-plave v hlavnim ZSTacku
            Button(action: {
                if(!self.isMqttConnected) {
                    
                    _ = self.mqttclient.connect()
                    
                    
                    //self.mqttclient.didReceiveTrust
                    
                    //self.mqttclient.didChangeState = {mqtt, stav in
                    //    NSLog("pica \(stav)")
                    //}
                    
                   
                    
                    self.mqttclient.didConnectAck = {mqtt, ack in
                        
                        if (ack == CocoaMQTTConnAck.accept) {
                            NSLog("mydebug - \(ack)")
                            
                            self.isMqttConnected = true
                            //self.mqttclient.subscribe("misakpecky/solar/data")
                            self.mqttclient.subscribe(liveDataTopic)
                            self.mqttclient.didReceiveMessage = {mqtt, msg, id in
                                if(msg.string != nil) {
                                    NSLog("\(msg.string ?? "NOVAL")")
                                    fnParsujZpravu(topic: msg.topic, msg: msg.string!)
                                }
                            }
                        }
                    }
                } else {
                    self.mqttclient.disconnect()
                    self.mqttclient.didDisconnect = {mqtt, err in
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
 
        }.onAppear {
            /*if (!self.isMqttConnected) {
                _ = self.mqttclient.connect()
                self.mqttclient.didConnectAck = { mqtt, ack in
                    self.isMqttConnected.toggle()
                    self.mqttclient.subscribe("misakpecky/solar/data")
                    self.mqttclient.didReceiveMessage = {mqtt, message, id in
                        if (message.string != nil) {
                            fnParsujZpravu(topic: message.topic, msg: message.string!)
                        }
                    }
                }
            }*/
            
        }.onDisappear {
            /*self.mqttclient.disconnect()
            self.isMqttConnected.toggle()*/
        }
        //END-Hlavni ZStack
        
        
    }//END-body
    
    func fnParsujZpravu(topic: String, msg: String) {
        
        //debugMessage = topic
        
        switch topic {
        case liveDataTopic:
            self.animLiveOprationFlash()
        
            if let data = msg.data(using: .utf8) {
                if let json = try? JSON(data: data) {
                    debugMessage = json["Timestamp"].stringValue
                    let PVPower = json["Power_PV1"].doubleValue + json["Power_PV2"].doubleValue
                    let PVVoltage = json["Voltage_PV1"].doubleValue + json["Voltage_PV2"].doubleValue
                    let PVCurrent = json["Current_PV1"].doubleValue + json["Current_PV2"].doubleValue
                    txtPVPower = fnDejKilo(value: PVPower, units: "W")
                    txtPVVoltage = fnDejKilo(value: PVVoltage, units: "V")
                    txtPVCurrent = fnDejKilo(value: PVCurrent, units: "A")
                    
                    animTopLeft = (PVPower > 50) ? 1 : 0
                    
                    
                    
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
                    
                    txtBatVoltage = fnDejKilo(value: json["Battery_U"].doubleValue, units: "V")
                    txtBatCurrent = fnDejKilo(value: abs(json["Battery_I"].doubleValue), units: "A")
                    let batP = json["Battery_P"].doubleValue
                    txtBatPower = fnDejKilo(value: abs(batP), units: "W")
                    self.imgBatState = "arrow-right"
                    if (abs(batP) > 50) {
                        if (batP > 0) {
                            // baterka se vybiji, sipka doprava
                            self.imgBatState = "arrow-right"
                        } else {
                            self.imgBatState = "arrow-left"
                            // baterka se vybiji, sipka doleva
                        }
                        
                    }else {
                        // baterka nic nedela, smaz obrazek
                        self.imgBatState = "arrow-stop"
                    }
                    batCharge = json["Battery_SOC"].doubleValue
                    txtBatSOC = String(json["Battery_SOC"].intValue) + " %"
                    
                    
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
                    
                    txtGridOut = fnDejKilo(value: Double(nZaporny), units: "W")
                    txtGridIn = fnDejKilo(value: Double(nKladny), units: "W")
                }
            }
        default: break
        }
    }
    
    func fnDejKilo(value: Double, units: String) -> String {
        var retval = ""
        if (value <= 999) {
            retval = String(format: "%.0f", value) + " " + units
        } else {
            retval = String(format: "%.2f",value / 1000.0) + " k" + units
            //retval = String(format: "%.2f", (round(value / 1000))) + " k" + units
        }
        return retval
    }

    
    func vynulujHodnoty() {
        debugMessage = "ZATIM NIC"
        isMqttConnected = false
        txtPVPower = "0 W"
        txtPVVoltage = "0 V"
        txtPVCurrent = "0 A"
        
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
    }
    //test
}

struct HlavniPanel: View {
    
    var iconSize: CGFloat = 75
    
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
    @Binding public var txtPVPower: String
    @Binding public var txtPVVoltage: String
    @Binding public var txtPVCurrent: String
    
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
    
    //Hodnoty Grid
    
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
                    Text(txtPVPower)
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
                        
                        var batCharge = 70.0
                        let batFill : Double = (38 / 100) * batCharge
                        let batOffset : Double = batFill / 2
                        
                        Rectangle()
                            .fill(Color(.red))
                            //.offset(x:0, y: -7)
                            //.frame(width: 15, height: 38, alignment: .bottom)
                            
                            .frame(width: 15, height: CGFloat(batFill), alignment: .bottom)
                            .offset(x: 0, y: 12 - CGFloat(batOffset ))
                        
                    }
                }
                .padding(0)
                
                //baterka procenta
                VStack(spacing: 0) {
                    Text("9.99 kW")
                        .foregroundColor(Color("txt_light_gray"))
                        .font(.system(size: 15))
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity, alignment: .center)
                        //.padding(.top, 5)
                }.offset(x: 0, y: -5)
                    .frame(width: 75,  alignment: .top)
                
                //baterka vykon
                VStack(spacing: 0) {
                    Text("100 %")
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
                        
                        
                        Text(txtPVVoltage)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("txt_light_gray"))
                            .font(.system(size: 13))
                        Text(txtPVCurrent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("txt_light_gray"))
                            .font(.system(size: 13))
                        
                        
                    }.frame(maxWidth: 110, maxHeight: 70, alignment: .topLeading)
                        //.border(Color.blue)
                        .padding(.leading, 5)
                        .padding(.top, 5)
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
                                    AnimTopLeftIn()
                                } else if (animTopLeft == 2) {
                                    //ANIM FROM CENTER
                                    AnimTopLeftOut()
                                } else {
                                    //NO ANIMATION
                                    WireTopLeft()
                                        .stroke(
                                            LinearGradient(gradient: Gradient(colors: [Color("wire-gradient-light"),Color("wire-gradient-dark")]), startPoint: .leading, endPoint: .trailing),
                                            style: StrokeStyle(
                                                lineWidth: 2,
                                                lineCap: .round,
                                                lineJoin: .miter))
                                        .foregroundColor(.blue)
                                        .frame(width: 105, height: 50)
                                }
                            }.frame(width: 105, height: 45)//.border(Color.brown)
                            
                            //DRAT-Leva Dolni
                            VStack() {
                                if (animBottomLeft == 1) {
                                    //ANIM TO CENTER
                                    AnimBottomLeftIn()
                                } else if(animBottomLeft == 2) {
                                    //ANIM FROM CENTER
                                    AnimBottomLeftOut()
                                } else {
                                    //NO ANIMATION
                                    WireBottomLeft()
                                        .stroke(
                                            LinearGradient(gradient: Gradient(colors: [Color("wire-gradient-light"),Color("wire-gradient-dark")]), startPoint: .leading, endPoint: .trailing),
                                            style: StrokeStyle(
                                                lineWidth: 2,
                                                lineCap: .round,
                                                lineJoin: .miter))
                                        .foregroundColor(.blue)
                                        .frame(width: 105, height: 30)
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
                                    AnimTopRightIn()
                                } else if(animTopRight == 2) {
                                    //ANIM FROM CENTER
                                    AnimTopRightOut()
                                } else {
                                    WireTopRight()
                                        .stroke(
                                            LinearGradient(gradient: Gradient(colors: [Color("wire-gradient-light"),Color("wire-gradient-dark")]), startPoint: .trailing, endPoint: .leading),
                                            style: StrokeStyle(
                                                lineWidth: 2,
                                                lineCap: .round,
                                                lineJoin: .miter))
                                        .foregroundColor(.blue)
                                        .frame(width: 105, height: 50)
                                }
                                
                            }.frame(width: 105, height: 45)//.border(Color.brown)
                            
                            //DRAT-Prava Dolni
                            VStack() {
                                if (animBottomRight == 1) {
                                    //ANIM TO CENTER
                                    AnimBottomRightIn()
                                } else if (animBottomRight == 2) {
                                    //ANIM FROM CENTER
                                    AnimBottomRightOut()
                                } else {
                                    WireBottomRight()
                                        .stroke(
                                            LinearGradient(gradient: Gradient(colors: [Color("wire-gradient-light"),Color("wire-gradient-dark")]), startPoint: .trailing, endPoint: .leading),
                                            style: StrokeStyle(
                                                lineWidth: 2,
                                                lineCap: .round,
                                                lineJoin: .miter))
                                        .foregroundColor(.blue)
                                        .frame(width: 105, height: 30)
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
                        Text("800V")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("txt_light_gray"))
                            .font(.system(size: 13))
                        Text("5A")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("txt_light_gray"))
                            .font(.system(size: 13))
                    }
                    .frame(maxWidth: 110, maxHeight: 70, alignment: .bottomLeading)
                    .offset(x:5, y:-20)
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
                        Image(systemName: "arrowtriangle.left.fill")
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
                        Image(systemName: "arrowtriangle.right.fill")
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
