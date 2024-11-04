//
//  LibreLinkUp.swift
//  BloodGlucoseViaLibreLinkup
//
//  Created by Clive on 30/10/2024.
//

import Foundation
import SimpleKeychain

class TimerToGetData: ObservableObject {
    
    @Published var ValueStr = "---"
    @Published var email = ""
    @Published var password = ""
    
    private var token = ""
    private var patientId = ""
    private var value = Float(0)
    private var trend = Int(0)
    private let trendArrow =  ["", "↓", "↘︎", "→", "↗︎", "↑"]
    
    var timer: Timer?
    
    init() {
        
        if email.isEmpty || password.isEmpty {
            getUserDetails()
        }
        
        Task{
            await self.loadData()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { _ in
            Task{
                await self.loadData()
            }
        })
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func loadData() async {

        if token.isEmpty {
            await getToken()
        }
        if patientId.isEmpty {
            await getPatientId()
        }
        await getGlucose()
        DispatchQueue.main.async{
            self.ValueStr = String(format: "%.1f", self.value) + self.trendArrow[self.trend]
        }
    }
    
    fileprivate func setCommonHeaders(_ request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("4.7", forHTTPHeaderField: "version")
        request.setValue("llu.android", forHTTPHeaderField: "product")
    }
    
    fileprivate func setCommonHeaderBearer(_ request: inout URLRequest) {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    func getToken() async {
        let urlStr = "https://api.libreview.io/llu/auth/login"
        let body: [String: String] = ["email":"\(email)", "password":  "\(password)"]
        guard let url = URL(string: urlStr) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        setCommonHeaders(&request)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(body)
        request.httpBody = data
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let linkUpData = try JSONDecoder().decode(LinkUpLogin.self, from: data)
            token = linkUpData.data.authTicket.token
        } catch {
            print("Invalid login")
        }
    }
    
    func getPatientId() async {
        let urlStr = "https://api.libreview.io/llu/connections"
        guard let url = URL(string: urlStr) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        setCommonHeaders(&request)
        setCommonHeaderBearer(&request)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let linkUpData = try JSONDecoder().decode(LinkUpPatient.self, from: data)
            patientId = linkUpData.data.first!.patientId
        } catch {
            print("Invalid patientid")
        }
    }
    
    func getGlucose() async {
        let urlStr = "https://api.libreview.io/llu/connections/\(patientId)/graph"
        guard let url = URL(string: urlStr) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        setCommonHeaders(&request)
        setCommonHeaderBearer(&request)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            //            let str = data.prettyPrintedJSONString!
            //            debugPrint(str)
            let linkUpData = try JSONDecoder().decode(LinkUpGraph.self, from: data)
            value = linkUpData.data.connection.glucoseMeasurement.Value
            trend = linkUpData.data.connection.glucoseMeasurement.TrendArrow
        } catch {
            print("Invalid messurement")
        }
    }
    
    func resetTokenAndPatientId () {
        
        let simpleKeychain = SimpleKeychain(accessGroup: "BloodGlucose")
        do {
            try simpleKeychain.set(email, forKey: "email")
            try simpleKeychain.set(password, forKey: "password")
        }
        catch {
            print("error saving user details")
        }
        
        token = ""
        patientId = ""
        value = 0
        ValueStr = "---"
        Task {
            await loadData()
        }
    }
    
    
    func getUserDetails() {
        
        do {
            let simpleKeychain = SimpleKeychain(accessGroup: "BloodGlucose")
  
            self.email = try simpleKeychain.string(forKey: "email")
            self.password = try simpleKeychain.string(forKey: "password")

       }
        catch {
            print("error gettin user details")
        }
    }
}
