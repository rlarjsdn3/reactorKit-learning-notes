//
//  BaseService.swift
//  HelloWorld
//
//  Created by 김건우 on 11/28/23.
//

import Foundation

class BaseService {
    // ⭐️ 각 서비스가 다른 서비스와 커뮤니케이션을 하게 만들어줌.
    unowned let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
}
