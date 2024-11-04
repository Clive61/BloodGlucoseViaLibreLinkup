//
//  LinkUpLogin.swift
//  BloodGlucoseViaLibreLinkup
//
//  Created by Clive on 30/10/2024.
//


struct LinkUpLogin: Codable  {
    var data: LinkUpLoginAuth
}
struct LinkUpLoginAuth: Codable {
    var authTicket: LinkUpLoginToken
}
struct LinkUpLoginToken: Codable  {
    var token: String
}

struct LinkUpPatient: Codable {
    var data: [Connection]
}
struct Connection: Codable {
    var patientId: String
}

struct LinkUpGraph: Codable {
    var data: LinkUpGraphConnection
}
struct LinkUpGraphConnection: Codable {
    var connection: LinkUpGraphConnectionMeasurement
}
struct LinkUpGraphConnectionMeasurement: Codable {
    var id: String
    var glucoseMeasurement: LinkUpGraphConnectionMeasurementValue
}
struct LinkUpGraphConnectionMeasurementValue: Codable {
    var Value: Float
    var TrendArrow: Int
}
