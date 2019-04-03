//
//  ViewController.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/1.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func addVideoButtonPressed(_ sender: UIBarButtonItem) {
        
        createProjectNameAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func createProjectNameAlert() {
        
        let alert = UIAlertController(title: "請輸入影片名稱", message: "命名後仍可更改，若未輸入名稱將預設為「未命名」。", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in
            
            textField.placeholder = "未命名"
        })
        
        let confirmAction = UIAlertAction(title: "確定", style: .default) { (_) in
            
            guard let textField = alert.textFields?.first,
                  let text = textField.text else { return }
            
            if text.isEmpty {
                
                self.navigationItem.title = textField.placeholder
                
            } else {
                
                self.navigationItem.title = text
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

}

