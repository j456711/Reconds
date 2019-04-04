//
//  HomeViewController.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/1.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.isHidden = true
        }
    }
    
    @IBAction func addVideoButtonPressed(_ sender: UIBarButtonItem) {
        
        if collectionView.isHidden == true {
            
            createProjectNameAlert()
            
        } else {
            
            let alert = UIAlertController(title: "無法新增影片", message: "尚未開放一次可編輯多支影片的功能，敬請期待！", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "確定", style: .default, handler: nil)
            
            alert.addAction(confirmAction)
            
            present(alert, animated: true, completion: nil)
        }
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
            
                self.collectionView.isHidden = false
                
                self.navigationItem.title = textField.placeholder
                
            } else {
                
                self.collectionView.isHidden = false
                
                self.navigationItem.title = text
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HomeCollectionViewCell.self), for: indexPath)
        
        guard let homeCell = cell as? HomeCollectionViewCell else { return cell }
        
        
        return homeCell
    }

}
