//
//  ZJLAdvertiseCollectionViewCell.swift
//  ZJLAdvertiseViewSwift
//
//  Created by ZhongZhongzhong on 16/6/22.
//  Copyright © 2016年 ZhongZhongzhong. All rights reserved.
//

import UIKit

class ZJLAdvertiseCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        sepUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sepUpViews()
    }
    
    lazy var imageView : UIImageView = {
        let imageView :UIImageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .ScaleAspectFit
        return imageView
    }()
    
    var image : UIImage! {
        didSet{
            imageView.image = image
        }
    }
}

extension ZJLAdvertiseCollectionViewCell{
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
    
    func sepUpViews() {
        addSubview(imageView)
    }
}
