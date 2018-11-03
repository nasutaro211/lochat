//
//  HighlightsViewController.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/03.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit

class HighlightsViewController: BaseViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navigationBar: UINavigationBar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUICongig()
        // Do any additional setup after loading the view.
    }
}



//UIのセットアップ
extension HighlightsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    func setUICongig(){
        setTableView()
    }
    
    func setTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "HighlightsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HighlightsTableViewCell")
    }
    
    func setNavbar(){
    }
}
