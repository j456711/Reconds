//
//  SettingsViewController.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/2.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    private struct Segue {
        
        static let showSettingsDetailVC = "showSettingsDetailVC"
    }
    
    let authorizationSection = ["配樂試聽", "影片輸出後存入相簿", "管理權限"]
    
    let aboutSection = ["評分鼓勵", "與好友分享 Reconds"]
    
    let creditsSection = ["素材來源"]
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let settingsDetailVC = segue.destination as? SettingsDetailViewController else { return }
        
        if let indexPath = sender as? IndexPath {
            
            settingsDetailVC.navigationItem.title = creditsSection[indexPath.row]
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 0: return authorizationSection.count
            
        case 1: return aboutSection.count
            
        case 2: return creditsSection.count
            
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            
        case 0: return "權限設定"
            
        case 1: return "關於"
            
        case 2: return "來源"
            
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTableViewCell.self),
                                                 for: indexPath)
        
        guard let settingsCell = cell as? SettingsTableViewCell else { return cell }
        
        if indexPath.section == 0 {
            
            settingsCell.titleLabel.text = authorizationSection[indexPath.row]
            
        } else if indexPath.section == 1 {
            
            settingsCell.titleLabel.text = aboutSection[indexPath.row]
            
        } else if indexPath.section == 2 {
            
            settingsCell.titleLabel.text = creditsSection[indexPath.row]
        }
        
        return settingsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            
            
        } else if indexPath.section == 1 {
            
            
        } else if indexPath.section == 2 {
            
            performSegue(withIdentifier: Segue.showSettingsDetailVC, sender: indexPath)
        }
    }
}
