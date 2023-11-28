//
//  ServiceProvider.swift
//  HelloWorld
//
//  Created by 김건우 on 11/28/23.
//

import Foundation

protocol ServiceProviderProtocol: AnyObject {
    var userService: UserServiceProtocol { get }
    var alertService: AlertServiceProtocol { get }
}

final class ServiceProvider: ServiceProviderProtocol {
    lazy var userService: UserServiceProtocol = UserService(provider: self)
    lazy var alertService: AlertServiceProtocol = AlertService(provider: self)
}
