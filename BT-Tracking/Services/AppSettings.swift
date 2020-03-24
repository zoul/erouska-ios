//
//  AppSettings.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct AppSettings {

    static var BUID: String? {
        get {
            return UserDefaults.standard.string(forKey: "BUID")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "BUID")
        }
    }

    static var lastUploadDate: Date {
        get {
            let rawValue = UserDefaults.standard.double(forKey: "UploadDate")
            let time = TimeInterval(rawValue)
            return Date(timeIntervalSince1970: time)
        }
        set {
            UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "UploadDate")
        }
    }

}
