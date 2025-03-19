//
//  ServiceNames.swift
//  sbm-smart-ios
//
//  Created by Varun on 31/01/24.
//

import Foundation

struct ServiceNames {
    private static let HOST_URL = "\(EnvManager.hostName)/api"
    private static let USER_SLUG = "/user"
    private static let USER_AUTH_SLUG = "\(USER_SLUG)/auth"
    static let USER_TOKEN = "\(HOST_URL)\(USER_SLUG)/token"
    static let AUTH_VERIFY = "\(HOST_URL)\(USER_AUTH_SLUG)/verify"
    static let AUTH_RESEND = "\(HOST_URL)\(USER_AUTH_SLUG)/resend"
    static let PHONE_AUTH = "\(HOST_URL)\(USER_AUTH_SLUG)/phone"
    static let EMAIL_AUTH = "\(HOST_URL)\(USER_AUTH_SLUG)/email"
    static let FILES = "\(HOST_URL)/files"
    static let USER = "\(HOST_URL)\(USER_SLUG)"
    static let BANK_ENV = "\(HOST_URL)/global/bank"
}
