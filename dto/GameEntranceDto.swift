//
//  GameEntranceDto.swift
//  PreBetLead
//
//  Created by Andy Chen on 2019/5/21.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit
class GameEntranceDto {
    let title:String
    let image:String
    let icon:String
    let blackImage:UIImage?
    init(title:String, image:String, icon:String){
        self.title = title
        self.image = image
        self.icon = icon
        self.blackImage = nil
//        self.blackImage = UIImage(named: image)?.withGrayscale
    }
}
