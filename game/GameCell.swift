//
//  GameCell.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/27.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
class GameCell:UICollectionViewCell {
    @IBOutlet weak var likeImageView:UIImageView!
    @IBOutlet weak var bannerImageView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    private let subject = PublishSubject<Bool>()
    private var dispose:Disposable?
    func configureCell(gameDto:GameDto){
        likeImageView.image =  likeImageView.image?.blendedByColor(gameDto.isLiked ? Themes.secondaryRed : Themes.grayLight)
        titleLabel.text = gameDto.gameName
        bannerImageView.sdLoad(with: URL(string: gameDto.images ?? ""))
    }
    
    func rxLike() -> Observable<Void> {
        return likeImageView.rx.click.throttle(1, scheduler: MainScheduler.instance)
    }
    
}
