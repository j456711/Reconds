//
//  MusicViewController.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/20.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import AVFoundation

class MusicViewController: UIViewController {

    enum MusicFiles: String, CaseIterable {
        
        // swiftlint:disable identifier_name
        
        case AcousticRock = "Acoustic Rock"
        case Ambler
        case CheeryMonday = "Cheery Monday"
        case HappyAlley = "Happy Alley"
        case MemoryLane = "Memory Lane"
        case OffToOsaka = "Off To Osaka"
        case RadioRock = "Radio Rock"
        case Serenity
        case ThereItIs = "There It Is"
        case Words
        
        // swiftlint:enable identifier_name
    }
    
    let rcVideoPlayer = RCVideoPlayer()
    
    var player: AVAudioPlayer!
    
    var outputUrl: URL?
    
    var musicFilesArray = MusicFiles.allCases
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rcVideoPlayer.setUpAVPlayer(with: videoView, videoUrl: outputUrl!, videoGravity: .resizeAspect)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        rcVideoPlayer.play()
    }
    
    func createBundlePath() -> URL? {
        
        if let musicBundleUrl = Bundle.main.url(forResource: "Reconds-Music",
                                                withExtension: "bundle") {
        
            return musicBundleUrl
        }
        
        return nil
    }
    
}

extension MusicViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return musicFilesArray.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MusicTableViewCell.self),
                                                 for: indexPath)
        
        guard let musicCell = cell as? MusicTableViewCell else { return cell }
        
        let titleArray = musicFilesArray.map({ $0.rawValue })

        musicCell.titleLabel.text = titleArray[indexPath.row]

        return musicCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let bundlePath = createBundlePath() {
            
            let stringArray = musicFilesArray.map({ "\($0)" })
            
            let urlString = bundlePath.absoluteString + stringArray[indexPath.row] + ".mp3"
            
            guard let url = URL(string: urlString) else { return }
            
            do {
                
                player = try AVAudioPlayer(contentsOf: url)
                player.play()
                
            } catch {
                
                print(error)
            }
        }
        
    }
}
