//
//  BloodGlucoseViaLibreLinkupApp.swift
//  BloodGlucoseViaLibreLinkup
//
//  Created by Clive on 25/10/2024.
//
import Foundation
import SwiftUI

@main
struct BloodGlucoseViaLibreLinkupApp: App {
    
    @StateObject var store = TimerToGetData()
    @State var isMenuPresented: Bool = false
    
    var body: some Scene {
        MenuBarExtra("\(store.ValueStr)") {
            VStack {
                VStack {
                    HStack {
                        Text("Email:")
                            .padding(.trailing, 25)
                        TextField("", text: $store.email)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(.systemGray), lineWidth: 1)
                        )
                    }
                    HStack {
                        Text("Password:")
                        ObscuredTextField("Password", text: $store.password)
                    }
                }.padding(10)
                HStack {
                    Button("Save") {
                        store.resetTokenAndPatientId()
                    }
                    .keyboardShortcut("s")
                    .padding(10)
                    
                    Button("Quit") {
                        quit()
                    }
                    .keyboardShortcut("q")
                    .padding(10)
                }
            }
        }.menuBarExtraStyle(.window)
        
    }
    
    // Terminate app
    private func quit() {
        NSApp.terminate(nil)
    }

}




