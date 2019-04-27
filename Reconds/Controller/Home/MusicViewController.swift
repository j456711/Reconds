//
//  MusicViewController.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/20.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView

class MusicViewController: UIViewController {

    enum MusicFiles: String, CaseIterable {
        
        // swiftlint:disable identifier_name
        
//        case NoMusic = "No Music"
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
    
    var videoUrl: URL?
    
    lazy var audioUrl: URL? = nil
    
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
        
        if let videoUrl = videoUrl {
            
            rcVideoPlayer.setUpAVPlayer(with: videoView, videoUrl: videoUrl, videoGravity: .resizeAspect)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let exportVC = segue.destination as? ExportViewController else { return }
        
        exportVC.videoUrl = videoUrl
        exportVC.audioUrl = audioUrl
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
        
        guard let cell = tableView.cellForRow(at: indexPath) as? MusicTableViewCell else { return }
        
        guard let bundlePath = createBundlePath() else { return }
        
        var stringArray = musicFilesArray.map({ "\($0)" })
        
        let urlString = bundlePath.absoluteString + stringArray[indexPath.row] + ".mp3"
        
        guard let audioUrl = URL(string: urlString) else { return }
        
        guard let duration = rcVideoPlayer.avPlayer.currentItem?.asset.duration else { return }
        
        let second = CMTimeGetSeconds(duration)
        
        do {
            
            cell.indicatorView.startAnimating()
            
            player = try AVAudioPlayer(contentsOf: audioUrl)
            player.play()
            player.setVolume(0, fadeDuration: second)
            
            self.audioUrl = audioUrl
            
        } catch {
            
            print(error)
        }
     
//        cell.indicatorView.stopAnimating()
        
        rcVideoPlayer.avPlayer.seek(to: CMTime.zero)
        rcVideoPlayer.mute(true)
        rcVideoPlayer.play()
    }
}
