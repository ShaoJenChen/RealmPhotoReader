//
//  UserInfo.swift
//  RealmPhotoReader
//
//  Created by 陳劭任 on 2018/9/27.
//  Copyright © 2018 陳劭任. All rights reserved.
//

import RealmSwift

class UserInfo: Object {

    @objc dynamic var name: String = ""
    
    @objc dynamic var organization: String = ""
    
    @objc dynamic var group: String = ""
    
}
