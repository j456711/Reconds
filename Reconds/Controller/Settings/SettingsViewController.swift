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
    
//    let appSettingsSection = ["配樂試聽", "影片輸出後存入相簿", "管理權限"]
    
    let appSettingsSection = ["管理權限"]
    
    let aboutSection = ["評價 Reconds"]
    
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
            
        case 0: return appSettingsSection.count
            
        case 1: return aboutSection.count
            
        case 2: return creditsSection.count
            
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            
        case 0: return "設定"
            
        case 1: return "關於"
            
        case 2: return "來源"
            
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        
        headerView.textLabel?.textColor = UIColor.lightGray
        headerView.textLabel?.font = UIFont(name: "PingFang TC", size: 17)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTableViewCell.self),
                                                 for: indexPath)
        
        guard let settingsCell = cell as? SettingsTableViewCell else { return cell }
        
        switch indexPath.section {
            
        case 0:
            settingsCell.titleLabel.text = appSettingsSection[indexPath.row]
//
//            if indexPath.row == 0 || indexPath.row == 1 {
//
//                settingsCell.switcher.isHidden = false
//
//            } else if indexPath.row == 2 {
            
            settingsCell.descriptionLabel.isHidden = false
//            }
            
        case 1:
            settingsCell.titleLabel.text = aboutSection[indexPath.row]
            
        case 2:
            settingsCell.titleLabel.text = creditsSection[indexPath.row]
            
        default: return cell
        }
        
        return settingsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? SettingsTableViewCell else { return }
        
        switch indexPath.section {
            
        case 0:
            selectedCell.didSelectedAppSettingsSection(at: indexPath)
            
        case 1:
            selectedCell.didSelectedAboutSection(at: indexPath)
            
        case 2:
            performSegue(withIdentifier: Segue.showSettingsDetailVC, sender: indexPath)
            
        default: break
        }
    }
}
