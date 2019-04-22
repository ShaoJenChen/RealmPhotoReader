//
//  User.swift
//  RealmPhotoReader
//
//  Created by 陳劭任 on 2018/9/27.
//  Copyright © 2018 陳劭任. All rights reserved.
//

import RealmSwift

class User: Object {

    @objc dynamic var uuid: String = ""
    
    @objc dynamic var pictures: String = ""
    
    @objc dynamic var info: UserInfo?
    
    @objc dynamic var itvid: Int = 0
    
}
