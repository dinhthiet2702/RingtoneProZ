//
//  MediaPlay.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/3/21.
//

import AVKit
import MediaPlayer
import RxCocoa
import RxMusicPlayer
import RxSwift



class MusicPlayer:NSObject {
    public static var instance = MusicPlayer()
    
    static var controller:PlayAudioVC?
    
    static let clickPlay = PublishRelay<RxMusicPlayer.Command>()
    
    let pauseBtn = UIBarButtonItem(image: ImageProvider.image(named: "pause")?.withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
    let nextBtn = UIBarButtonItem(image: ImageProvider.image(named: "nextMiniView")?.withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
    
    var player = AVPlayer()
    
    var onlinePlay = false
    
    func initURLRingtone(url:String){
        guard let url = URL(string: url) else { return }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        playAudioBackground()
        play()
        
    }
    
    
    func playAudioBackground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.mixWithOthers, .allowAirPlay, .defaultToSpeaker])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
    }
    
    func seekToPosition(seconds:Float64, completion:@escaping ()->Void) {
        
        //        self.pause()
        if let timeScale = player.currentItem?.asset.duration.timescale {
            player.pause()
            player.seek(to: CMTimeMakeWithSeconds(seconds, preferredTimescale: timeScale), completionHandler: {
                (complete) in
                self.play()
                completion()
                
            })
            
        }
        
    }
    
    func pause(){
        player.pause()
        
    }
    
    func play() {
        
        player.play()
    }
    
    
    static func showMiniPlayer(tabBarController:UITabBarController?, indexPath:IndexPath?, songs:[Song]?, tbv:UITableView?){
        
        clickPlay.accept(.pause)
        clickPlay.accept(.stop)
        controller?.disposeBag = DisposeBag()
        
        controller =  PlayAudioVC()
        
        guard let controller = controller else {
            return
        }
        controller.popupItem.leadingBarButtonItems = [MusicPlayer.instance.pauseBtn, MusicPlayer.instance.nextBtn]
        
        controller.songs = songs ?? []
        controller.popupItem.title = songs?[0].name
        if let indexPath = indexPath, let cell = tbv?.cellForRow(at: indexPath) as? CellDetailPlayList{
            controller.popupItem.image = cell.imvSong.image
        }else{
            controller.popupItem.image = ImageProvider.image(named: "songdefault")
        }
        
        controller.popupItem.subtitle = "0:00 / --:--"
        
        controller.index = indexPath?.row ?? 0
        
        tabBarController?.popupInteractionStyle = .drag
        tabBarController?.presentPopupBar(withContentViewController: controller, animated: true, completion: nil)
        
    }
    
    
    
}
