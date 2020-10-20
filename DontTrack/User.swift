//
//  User.swift
//  testMaps
//
//  Created by Kseniya Lukoshkina on 06.10.2020.
//

import Foundation
import RealmSwift

class UserEntity: Object {
    @objc dynamic var login: String? = ""
    @objc dynamic var password: String? = ""
    
    override static func primaryKey() -> String? {
        return "login"
    }
}
