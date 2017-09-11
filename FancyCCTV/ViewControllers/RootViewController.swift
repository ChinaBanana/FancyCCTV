//
//  RootViewController.swift
//  ILoveCCTV
//
//  Created by Coco Wu on 2017/9/6.
//  Copyright © 2017年 cyt. All rights reserved.
//

import UIKit
import IJKMediaFramework

let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height
let limitScale:CGFloat = 0.8

let channelKey = "UserdefaultChannelKey"

class RootViewController: UIViewController, LeftTableViewDelegate {
    
    let cctv1:String = "http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8"
    
    let channelArray:Array = [
        "http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8", // cctv1
        "http://ivi.bupt.edu.cn/hls/cctv3hd.m3u8", // cctv3
        "http://ivi.bupt.edu.cn/hls/cctv5hd.m3u8", // cctv5
        "http://ivi.bupt.edu.cn/hls/cctv5phd.m3u8", // cctv5高清
        "http://ivi.bupt.edu.cn/hls/cctv6hd.m3u8", // cctv6
        "rtmp://live.hkstv.hk.lxdns.com/live/hks" // 香港卫视
    ]
    
    var leftView:LeftTableView!
    var player: IJKFFMoviePlayerController!
    let changeBtn:UIButton = UIButton.init()
    let backgroundImageView = UIImageView.init()
    var activityView:UIActivityIndicatorView!
    let shadowView = UIView()
    
    var pan:UIPanGestureRecognizer!
    var tap:UITapGestureRecognizer!
    var doubleTap:UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.layer.shadowColor = UIColor.init(white: 0.4, alpha: 0.5).cgColor
        view.layer.shadowOpacity = 5
        view.layer.shadowOffset = CGSize.init(width: -5, height: 5)
        
        let url:String? = UserDefaults.standard.object(forKey: channelKey) as? String
        
        if let urlStr = url {
            player = IJKFFMoviePlayerController.init(contentURLString: urlStr, with: IJKFFOptions.byDefault())
        }else {
            player = IJKFFMoviePlayerController.init(contentURLString: cctv1, with: IJKFFOptions.byDefault())
        }
        player.prepareToPlay()
        player.view.frame = view.bounds
        player.view.autoresizingMask = UIViewAutoresizing.flexibleHeight
        player.scalingMode = IJKMPMovieScalingMode.aspectFit
        player.shouldAutoplay = true
        player.view.backgroundColor = UIColor.clear
        registerNotifications(player)
        
        view.addSubview(player.view)
        view.autoresizesSubviews = true
        
        backgroundImageView.frame = view.bounds
        backgroundImageView.image = #imageLiteral(resourceName: "backgroundImage")
        shadowView.frame = view.bounds
        shadowView.backgroundColor = UIColor.init(white: 0, alpha: 0.8  )
        backgroundImageView.addSubview(shadowView)
        
        UIApplication.shared.keyWindow?.insertSubview(backgroundImageView, at: 0)
        
        leftView = LeftTableView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth * 0.6, height: 300), style: .grouped)
        leftView.transform = CGAffineTransform.init(scaleX: limitScale, y: limitScale)
        leftView.selectedDelegate = self
        leftView.center = CGPoint.init(x: leftView.center.x, y: kScreenHeight / 2)
        UIApplication.shared.keyWindow?.insertSubview(leftView, at: 1)
        
        activityView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        activityView.center = view.center
        view.addSubview(activityView)
        activityView.startAnimating()
        
        pan = UIPanGestureRecognizer.init(target: self, action: #selector(pan(_:)))
        view.addGestureRecognizer(pan)
        
        tap = UITapGestureRecognizer.init(target: self, action: #selector(tap(_:)))
        view.addGestureRecognizer(tap)
        
        doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(doublepTapHandler(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        player.stop()
    }
    
    // 代理方法
    func selectedIndexpath(_ index: IndexPath) {
        let url = channelArray[index.row]
        UserDefaults.standard.set(url, forKey: channelKey)
        player.shutdown()
        activityView.startAnimating()
        
        let newPlayer = IJKFFMoviePlayerController.init(contentURLString: url, with: IJKFFOptions.byDefault())
        newPlayer?.prepareToPlay()
        newPlayer?.view.autoresizingMask = UIViewAutoresizing.flexibleHeight
        newPlayer?.scalingMode = IJKMPMovieScalingMode.aspectFit
        newPlayer?.shouldAutoplay = true
        view.addSubview((newPlayer?.view)!)
        
        player.view.removeFromSuperview()
        unregisterNotifications(player)
        registerNotifications(newPlayer!)
        player = newPlayer
        hideLeftView()
    }
    
    // 注册通知
    fileprivate func registerNotifications(_ aplayer: IJKFFMoviePlayerController) {
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange(_:)), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: aplayer)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayerDidFinish(_:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: aplayer)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPrepareToPlayDidChange(_:)), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: aplayer)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackDidChange(_:)), name: Notification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: aplayer)
    }
    
    fileprivate func unregisterNotifications(_ aplayer: IJKFFMoviePlayerController) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: aplayer)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: aplayer)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: aplayer)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: aplayer)
    }
    
    @objc func doublepTapHandler(_ sender:UITapGestureRecognizer) {
        if player.view.transform.isIdentity {
            player.view.frame = CGRect.init(x: 0, y: 0, width: kScreenHeight, height: kScreenWidth)
            player.view.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi / 2)
            player.view.center = CGPoint.init(x: kScreenWidth / 2, y: kScreenHeight / 2)            
        }else{
            player.view.transform = CGAffineTransform.identity
            player.view.frame = view.bounds
        }
    }
    
    @objc func tap(_ sender:UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.2) { 
            self.hideLeftView()
        }
    }
    
    @objc func pan(_ sender:UIPanGestureRecognizer) {
        let transPosition = sender.translation(in: sender.view)
        let transform = sender.view?.transform
        if var tx = transform?.tx {
            tx += transPosition.x
            if tx < 0 {
                tx = 0
            }
            if tx > kScreenWidth * (1 - limitScale) {
                tx = kScreenWidth * (1 - limitScale)
            }
            
            let scale = (kScreenWidth - tx) / kScreenWidth
            var newTransform = CGAffineTransform.init(scaleX: scale, y: scale)
            newTransform.tx = tx
            sender.view?.transform = newTransform
            
            let leftTransform = CGAffineTransform.init(scaleX: (1 + limitScale - scale), y: (1 + limitScale - scale))
            leftView.transform = leftTransform
            leftView.center = CGPoint.init(x: leftView.bounds.size.width * (1 + limitScale - scale) / 2, y: kScreenHeight / 2)
            
            shadowView.alpha = (scale - limitScale) * 4
        }
        sender.setTranslation(CGPoint.zero, in: sender.view)
        
        if sender.state == .ended {
            if view.transform.tx < kScreenWidth * (1 - limitScale) / 2 {
                hideLeftView()
            }else {
                showLeftView()
            }
        }
    }
    
    fileprivate func showLeftView() {
        UIView.animate(withDuration: 0.2) { 
            self.view.transform = CGAffineTransform.init(scaleX: limitScale, y: limitScale)
            self.view.transform.tx = kScreenWidth * (1 - limitScale)
            self.leftView.transform = CGAffineTransform.identity
            self.leftView.center = CGPoint.init(x: self.leftView.bounds.size.width / 2, y: kScreenHeight / 2)
            self.shadowView.alpha = 0
        }
    }
    
    fileprivate func hideLeftView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.transform = CGAffineTransform.identity
            self.leftView.transform = CGAffineTransform.init(scaleX: limitScale, y: limitScale)
            self.shadowView.alpha = 0.8
        })
    }
    
    @objc func loadStateDidChange(_ notify:NSNotification) {
        switch player.playbackState {
        case .paused:
            
            break
        case .playing:
            activityView.stopAnimating()
            break
        case .stopped:
            debugPrint("The player stoped: \(NSDate.init())")
            break
            
        default:
            break
        }
    }
    
    @objc func moviePlayerDidFinish(_ notify:NSNotification) {
        debugPrint(notify)
    }
    
    @objc func mediaIsPrepareToPlayDidChange(_ notify:NSNotification) {
        debugPrint(notify)
    }
    
    @objc func moviePlayBackDidChange(_ notify:NSNotification) {
        debugPrint(notify)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
