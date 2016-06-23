//
//  ViewController.swift
//  ZJLAdvertiseViewSwift
//
//  Created by ZhongZhongzhong on 16/6/22.
//  Copyright © 2016年 ZhongZhongzhong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

   
    @IBOutlet weak var advertiseView: ZJLAdvertiseView!{
        didSet{
            advertiseView.backgroundColor = UIColor.whiteColor()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        advertiseView.changeInterval = 2
        advertiseView.imageURLs = ["http://img.article.pchome.net/00/43/41/54/pic_lib/wm/3.jpg",
                                    "http://f.hiphotos.baidu.com/image/h%3D200/sign=658bab6a553d269731d30f5d65fab24f/0dd7912397dda1446853fa12b6b7d0a20cf4863c.jpg",
                                     "http://img.shu163.com/uploadfiles/wallpaper/2010/6/2010073106154112.jpg",
                                      "http://c.hiphotos.bdimg.com/album/w%3D2048/sign=a3a806ef6609c93d07f209f7ab05fadc/d50735fae6cd7b89f4ee76620e2442a7d8330e54.jpg",
                                       "http://h.hiphotos.baidu.com/image/pic/item/8694a4c27d1ed21b61797af2ae6eddc451da3f70.jpg"]
        advertiseView.startDownloadImageClosure = { [unowned self] in
            self.title = "loading..."
        }
        advertiseView.endDownloadImageClosure = { [unowned self] in
            self.title = "finished"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

