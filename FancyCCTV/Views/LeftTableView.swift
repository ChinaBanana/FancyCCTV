//
//  LeftTableView.swift
//  ILoveCCTV
//
//  Created by Coco Wu on 2017/9/7.
//  Copyright © 2017年 cyt. All rights reserved.
//

import UIKit

protocol LeftTableViewDelegate {
    func selectedIndexpath(_ index:IndexPath) -> ()
}

class LeftTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    var selectedDelegate:LeftTableViewDelegate?
    let dataArray:Array = ["CCTV1","CCTV3","CCTV5","CCTV5P", "CCTV6", "香港卫视"]
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
        self.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
        self.separatorStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataArray[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.tintColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let aDelegate = self.selectedDelegate {
            aDelegate.selectedIndexpath(indexPath)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
}
