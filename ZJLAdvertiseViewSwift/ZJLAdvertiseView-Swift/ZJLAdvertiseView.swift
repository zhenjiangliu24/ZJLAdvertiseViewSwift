//
//  ZJLAdvertiseView.swift
//  ZJLAdvertiseViewSwift
//
//  Created by ZhongZhongzhong on 16/6/22.
//  Copyright © 2016年 ZhongZhongzhong. All rights reserved.
//

import UIKit
import SwiftyTimer
import AlamofireImage

private struct Constants{
    static let reuseCollectionViewCellIdentifier = "ZJLCollectionViewCell"
    
}

public class ZJLAdvertiseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpViews()
    }
    
    public typealias SelectClosure = (index : Int) -> Void
    public typealias NormalClosure = () -> Void
    
    public var imageDidSelectedClousure : SelectClosure?
    public var startDownloadImageClosure : NormalClosure?{
        didSet{
            if isDownloading {
                startDownloadImageClosure?()
            }
        }
    }
    public var endDownloadImageClosure : NormalClosure?
    
    public var changeInterval : NSTimeInterval = 0
    public var pageScale: CGFloat! {
        didSet {
            pageControl.transform = CGAffineTransformMakeScale(pageScale, pageScale)
        }
    }
    
    public var images : [UIImage] = [UIImage](){
        didSet{
            pageControl.numberOfPages = images.count
            if images.count<=1 {
                pageControl.hidden = true
            }else{
                pageControl.hidden = false
                images.insert(images.last!, atIndex: 0)
                images.insert(images[1], atIndex: images.count)
                
            }
            collectionView.reloadData()
            startTimer()
        }
    }
    
    public var imageURLs : [String] = []{
        didSet{
            startDownloadImages()
        }
    }
    
    private var imageDownloader = ImageDownloader()
    private var isDownloading : Bool = false
    private var timer : NSTimer!
    private lazy var pageControl : UIPageControl = {
        let pageControl : UIPageControl = UIPageControl()
        return pageControl
    }()
    private lazy var layout : UICollectionViewFlowLayout = {
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsetsZero
        return layout
    }()
    private lazy var collectionView : UICollectionView = {
        let collectionView : UICollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.pagingEnabled = true
        collectionView.registerClass(ZJLAdvertiseCollectionViewCell.self, forCellWithReuseIdentifier: Constants.reuseCollectionViewCellIdentifier)
        collectionView.contentInset = UIEdgeInsetsZero
        collectionView.backgroundColor = UIColor.whiteColor()
        
        return collectionView
    }()
}

extension ZJLAdvertiseView{
    func setUpViews() {
        addSubview(collectionView)
        addSubview(pageControl)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds
        layout.itemSize = collectionView.frame.size
        layout.estimatedItemSize = collectionView.frame.size
        
        pageControl.center = CGPoint(x: bounds.size.width/2, y:bounds.size.height-20)
        if images.count>1 {
            collectionView.contentOffset = CGPoint(x: collectionView.frame.size.width, y: 0)
        }
    }
    
    func startDownloadImages() {
        guard imageURLs.count != 0 else{
            return
        }
        isDownloading = true
        startDownloadImageClosure?()
        
        var stringImageDic : [String:UIImage] = [:]
        imageURLs.forEach { (url) in
            let request = NSURLRequest(URL: NSURL(string: url)!)
            imageDownloader.downloadImage(URLRequest: request, completion: {[weak self] (response) in
                guard let strongSelf = self else{
                    return
                }
                strongSelf.isDownloading = false
                if case .Success(let image) = response.result{
                    let urlString = response.response!.URL!.absoluteString
                    stringImageDic[urlString] = image
                }else if case .Failure(let error) = response.result {
                    print(error)
                }
                if stringImageDic.count == strongSelf.imageURLs.count{
                    strongSelf.endDownloadImageClosure?()
                    strongSelf.images = strongSelf.imageURLs.map({ (urlString:String) -> UIImage in
                        stringImageDic[urlString]!
                    })
                }
            })
        }
    }
    
    func startTimer() {
        guard images.count>1 else{
            return
        }
        timer?.invalidate()
        if changeInterval != 0 {
            newTimer()
        }
    }
    
    func newTimer() {
        timer = NSTimer.new(every: changeInterval, { [weak self] in
            guard let strongSelf = self else{
                return
            }
            let offsetX = strongSelf.collectionView.contentOffset.x
            let width = strongSelf.collectionView.bounds.size.width
            let index = offsetX/width
            
            strongSelf.collectionView.setContentOffset(CGPoint(x: strongSelf.collectionView.bounds.width * CGFloat(index + 1), y: 0), animated: true)
        })
        timer?.start(modes: NSRunLoopCommonModes)
    }
    
    func adjustImagePosition() {
        
        let offsetX = collectionView.contentOffset.x
        let width = collectionView.bounds.size.width
        let index = offsetX/width
        
        if index >= CGFloat(images.count - 1) {
            collectionView.setContentOffset(CGPoint(x: width, y: 0), animated: false)
        } else if index < 1 {
            collectionView.setContentOffset(CGPoint(x: width * CGFloat(images.count - 2), y: 0), animated: false)
        }
    }
}

extension ZJLAdvertiseView:UICollectionViewDelegate,UICollectionViewDataSource{
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.reuseCollectionViewCellIdentifier, forIndexPath: indexPath) as! ZJLAdvertiseCollectionViewCell
        cell.image = images[indexPath.row]
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var indexNum = indexPath.row - 1
        if images.count <= 1 {
            indexNum += 1
        }
        imageDidSelectedClousure?(index: indexNum)
    }
}

extension ZJLAdvertiseView:UIScrollViewDelegate{
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        adjustImagePosition()
        
        if changeInterval != 0 {
            startTimer()
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        adjustImagePosition()
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if changeInterval != 0 {
            timer?.invalidate()
        }
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if images.count<=1 {
            return
        }
        layoutIfNeeded()
        let offsetX = collectionView.contentOffset.x
        let width = collectionView.bounds.size.width
        let floatIndex = Float(offsetX/width)
        var index = Int(offsetX/width)
        
        if index == images.count - 1 {
            index = 1
        } else if index == 0 {
            index = images.count - 1
        }
        
        pageControl.currentPage = Int(round(floatIndex)) - 1
        let a = Float(0.5)
        let b = Float(images.count - 2) + 0.5
        
        if floatIndex >= b {
            pageControl.currentPage = 0
        } else if floatIndex <= a {
            pageControl.currentPage = Int(b - 0.5)
        }
    }
}
