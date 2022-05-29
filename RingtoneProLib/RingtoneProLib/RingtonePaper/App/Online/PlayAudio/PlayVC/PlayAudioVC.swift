//
//  PlayAudioVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/7/21.
//

import RxCocoa
import RxMusicPlayer
import RxSwift
import UIKit
import SDWebImage



class PlayAudioVC: BaseViewControllers {
    
    
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lbEndTime: UILabel!
    @IBOutlet weak var lbCurentTime: UILabel!
    @IBOutlet weak var sliderAudio: ProgressSlider!
    @IBOutlet weak var imvSong: UIImageView!
    @IBOutlet weak var imvFocus: UIImageView!
    
    @IBOutlet weak var lbNameAuthor: UILabel!
    @IBOutlet weak var lbNameSong: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    
    
    
    var canPlay = false
    var disposeBag = DisposeBag()
    
    var song:Song?
    
    var songs:[Song] = []{
        didSet{
            if index >= songs.count{
                index = 0
            }
            
            
            let items = songs.map({ RxMusicPlayerItem(url: URL(string: $0.filename?.queryURL ?? "")!) })
            self.player = RxMusicPlayer(items: Array(items[index ..< songs.count]))
            
        }
    }
    
    func mapArtWord(url:URL?)->UIImage?{
        let imv = UIImageView()
        var imgQ:UIImage? = ImageProvider.image(named: "songdefault")
        imv.sd_setImage(with: url) { (img, err, _, _) in
            if err != nil{
                SDWebImageDownloader.shared.requestImage(with: url, options: .lowPriority, context: nil, progress: nil) { (imgD, _, errr, _) in
                    if errr != nil{
                        imgQ = ImageProvider.image(named: "songdefault")
                    }else{
                        imgQ = imgD
                    }
                }
            }else{
                imgQ = img
            }
        }
        return imgQ
    }
    
    var index = 0
    
    var player:RxMusicPlayer?
    
    var url:URL?
    
    @IBOutlet weak var btnPlay: UIButton!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    init() {
        super.init(nibName: "PlayAudioVC", bundle: BundleProvider.bundle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        player = RxMusicPlayer(items: [])
        player = nil
        print("PlayAudioVC deinit ")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        
        
        
    }
    
    
    func setupUI(){
        
        imvFocus.applyBlurEffect()
        btnMore.layer.cornerRadius = 20
        viewShadow.layer.cornerRadius = 10
        imvSong.layer.cornerRadius = 10
        
        if index >= songs.count{
            index = 0
        }
        
        let items = songs.map({ RxMusicPlayerItem(url: URL(string: $0.filename?.queryURL ?? "")!) })
        self.player = RxMusicPlayer(items: Array(items[index ..< songs.count]))
        guard let player = player else {
            return
        }
        setupRX(player: player)
        
        
        
    }
    
    
    func setupRX(player:RxMusicPlayer){
        // 1) Create a player
        
        
        if songs.count > 0{
            self.lbNameSong.text = songs[0].name
            self.lbNameAuthor.text = songs[0].artist
        }
        
        
        
        player.rx.currentItem().drive(onNext: {[weak self] item in
            self?.url = item?.url
            self?.song = self?.songs.filter {$0.filename == item?.url.absoluteString}.first
        }, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        
        
        // 2) Control views
        player.rx.canSendCommand(cmd: .play)
            .do(onNext: { [weak self] canPlay in
                self?.canPlay = canPlay
                self?.btnPlay.setImage(canPlay ? ImageProvider.image(named: "playAudio") : ImageProvider.image(named: "pauseAudio") , for: .normal)
                MusicPlayer.instance.pauseBtn.image = canPlay ? ImageProvider.image(named: "play")?.withRenderingMode(.alwaysOriginal) : ImageProvider.image(named: "pause")?.withRenderingMode(.alwaysOriginal)
                
            })
            .drive()
            .disposed(by: disposeBag)
        
        player.rx.canSendCommand(cmd: .next)
            .drive(onNext: {[weak self] isEnable in
                self?.nextButton.isEnabled = isEnable
                MusicPlayer.instance.nextBtn.isEnabled = isEnable
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        player.rx.canSendCommand(cmd: .previous)
            .drive(prevButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        player.rx.canSendCommand(cmd: .seek(seconds: 0, shouldPlay: false))
            .drive(sliderAudio.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)
        
        player.rx.currentItemTitle()
            .drive(onNext: {[weak self] t in
                self?.lbNameSong.text = t
                self?.popupItem.title = t ?? ""
                
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        player.rx.currentItemArtist()
            .drive(lbNameAuthor.rx.text)
            .disposed(by: disposeBag)
        
        player.rx.currentItemArtwork()
            .drive(onNext: { img in
                if let img = img{
                    self.imvSong.image = img
                    self.imvFocus.image = img
                    self.popupItem.image = img
                    
                }else{
                    self.imvSong.image = ImageProvider.image(named: "songdefault")
                    self.imvFocus.image = ImageProvider.image(named: "songdefault")
                    self.popupItem.image = ImageProvider.image(named: "songdefault")
                }
                
                
                
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        player.rx.currentItemRestDurationDisplay()
            .map {
                guard let rest = $0 else { return "--:--" }
                return "-\(rest)"
            }
            .drive(lbEndTime.rx.text)
            .disposed(by: disposeBag)
        
        player.rx.currentItemTimeDisplay()
            .drive(onNext: { t in
                self.lbCurentTime.text = t
                self.popupItem.subtitle = "\(t ?? "0:00") / \(self.lbEndTime.text ?? "--:--")"
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        player.rx.currentItemDuration()
            .map { Float($0?.seconds ?? 30) }
            .do(onNext: { [weak self] in
                self?.sliderAudio.maximumValue = $0
                self?.btnMore.isEnabled = true
            })
            .drive()
            .disposed(by: disposeBag)
        
        let seekValuePass = BehaviorRelay<Bool>(value: true)
        player.rx.currentItemTime()
            .withLatestFrom(seekValuePass.asDriver()) { ($0, $1) }
            .filter { $0.1 }
            .map { Float($0.0?.seconds ?? 30) }
            .drive(sliderAudio.rx.value)
            .disposed(by: disposeBag)
        sliderAudio.rx.controlEvent(.touchDown)
            .do(onNext: {
                seekValuePass.accept(false)
            })
            .subscribe()
            .disposed(by: disposeBag)
        sliderAudio.rx.controlEvent(.touchUpInside)
            .do(onNext: {
                seekValuePass.accept(true)
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        player.rx.currentItemLoadedProgressRate()
            .drive(sliderAudio.rx.playableProgress)
            .disposed(by: disposeBag)
        
        //        player.rx.shuffleMode()
        //            .do(onNext: { [weak self] mode in
        //                self?.shuffleButton.setTitle(mode == .off ? "Shuffle" : "No Shuffle", for: .normal)
        //            })
        //            .drive()
        //            .disposed(by: disposeBag)
        
        //        player.rx.repeatMode()
        //            .do(onNext: { [weak self] mode in
        //                var title = ""
        //                switch mode {
        //                case .none: title = "Repeat"
        //                case .one: title = "Repeat(All)"
        //                case .all: title = "No Repeat"
        //                }
        //                self?.repeatButton.setTitle(title, for: .normal)
        //            })
        //            .drive()
        //            .disposed(by: disposeBag)
        
        //        player.rx.playerIndex()
        //            .do(onNext: { index in
        //                if index == player.queuedItems.count - 1 {
        //                    // You can remove the comment-out below to confirm the append().
        //                    // player.append(items: items)
        //                }
        //            })
        //            .drive()
        //            .disposed(by: disposeBag)
        
        // 3) Process the user's input
        let cmd = Driver.merge(
            MusicPlayer.clickPlay.asDriver { _ in .empty() },
            btnPlay.rx.tap.asDriver().map { [weak self] in
                guard let self = self else {return RxMusicPlayer.Command.pause}
                if self.canPlay {
                    return RxMusicPlayer.Command.play
                }
                return RxMusicPlayer.Command.pause
            },
            MusicPlayer.instance.pauseBtn.rx.tap.asDriver().map {[weak self] in
                guard let self = self else {return RxMusicPlayer.Command.pause}
                if self.canPlay {
                    return RxMusicPlayer.Command.play
                }
                return RxMusicPlayer.Command.pause
            },
            MusicPlayer.instance.nextBtn.rx.tap.asDriver().debounce(.milliseconds(500)).map { RxMusicPlayer.Command.next },
            nextButton.rx.tap.asDriver().debounce(.milliseconds(500)).map { RxMusicPlayer.Command.next },
            prevButton.rx.tap.asDriver().map { RxMusicPlayer.Command.previous },
            sliderAudio.rx.controlEvent(.valueChanged).asDriver()
                .map { [weak self] _ in
                    RxMusicPlayer.Command.seek(seconds: Int(self?.sliderAudio.value ?? 0),
                                               shouldPlay: false)
                }
                .distinctUntilChanged()
        )
        .startWith(.prefetch)
        .debug()
        
        // You can remove the comment-out below to confirm changing the current index of music items.
        // Default is 0.
        // player.playIndex = 1
        
        player.run(cmd: cmd)
            .do(onNext: { status in
                UIApplication.shared.isNetworkActivityIndicatorVisible = status == .loading
            })
            .flatMap { [weak self] status -> Driver<()> in
                guard let weakSelf = self else { return .just(()) }
                
                switch status {
                case let RxMusicPlayer.Status.failed(err: err):
                    print(err)
                    return Wireframe.promptOKAlertFor(src: weakSelf,
                                                      title: "Error",
                                                      message: err.localizedDescription)
                    
                case let RxMusicPlayer.Status.critical(err: err):
                    print(err)
                    return Wireframe.promptOKAlertFor(src: weakSelf,
                                                      title: "Critical Error",
                                                      message: err.localizedDescription)
                case .readyToPlay:
                    print("readyToPlay")
                    MusicPlayer.clickPlay.accept(.play)
                case .ready:
                    print("readyTo")
                case .paused:
                    MusicPlayer.instance.onlinePlay = false
                case .playing:
                    MusicPlayer.instance.onlinePlay = true
                default:
                    print(status)
                }
                return .just(())
            }
            .drive()
            .disposed(by: disposeBag)
        
        //        shuffleButton.rx.tap.asDriver()
        //            .drive(onNext: {
        //                switch player.shuffleMode {
        //                case .off: player.shuffleMode = .songs
        //                case .songs: player.shuffleMode = .off
        //                }
        //            })
        //            .disposed(by: disposeBag)
        
        //        repeatButton.rx.tap.asDriver()
        //            .drive(onNext: {
        //                switch player.repeatMode {
        //                case .none: player.repeatMode = .one
        //                case .one: player.repeatMode = .all
        //                case .all: player.repeatMode = .none
        //                }
        //            })
        //            .disposed(by: disposeBag)
        
        //        rateButton.rx.tap.asDriver()
        //            .flatMapLatest { [weak self] _ -> Driver<()> in
        //                guard let weakSelf = self else { return .just(()) }
        //
        //                return Wireframe.promptSimpleActionSheetFor(
        //                    src: weakSelf,
        //                    cancelAction: "Close",
        //                    actions: PlaybackRateAction.allCases.map {
        //                        ($0.rawValue, player.desiredPlaybackRate == $0.toFloat)
        //                })
        //                    .do(onNext: { [weak self] action in
        //                        if let rate = PlaybackRateAction(rawValue: action)?.toFloat {
        //                            player.desiredPlaybackRate = rate
        //                            self?.rateButton.setTitle(action, for: .normal)
        //                        }
        //                    })
        //                    .map { _ in }
        //            }
        //            .drive()
        //            .disposed(by: disposeBag)
        
        //        appendButton.rx.tap.asDriver()
        //            .do(onNext: {
        //                let newItems = Array(items[4 ..< 6])
        //                player.append(items: newItems)
        //            })
        //            .drive(onNext: { [weak self] _ in
        //                self?.appendButton.isEnabled = false
        //            })
        //            .disposed(by: disposeBag)
        
        //        changeButton.rx.tap.asObservable()
        //            .flatMapLatest { [weak self] _ -> Driver<()> in
        //                guard let weakSelf = self else { return .just(()) }
        //
        //                return Wireframe.promptSimpleActionSheetFor(
        //                    src: weakSelf,
        //                    cancelAction: "Close",
        //                    actions: items.map {
        //                        ($0.url.lastPathComponent, player.queuedItems.contains($0))
        //                })
        //                    .asObservable()
        //                    .do(onNext: { action in
        //                        if let idx = player.queuedItems.map({ $0.url.lastPathComponent }).firstIndex(of: action) {
        //                            try player.remove(at: idx)
        //                        } else if let idx = items.map({ $0.url.lastPathComponent }).firstIndex(of: action) {
        //                            for i in (0 ... idx).reversed() {
        //                                if let prev = player.queuedItems.firstIndex(of: items[i]) {
        //                                    player.insert(items[idx], at: prev + 1)
        //                                    break
        //                                }
        //                                if i == 0 {
        //                                    player.insert(items[idx], at: 0)
        //                                }
        //                            }
        //                        }
        //
        //                        self?.appendButton.isEnabled = !(player.queuedItems.contains(items[4])
        //                            || player.queuedItems.contains(items[5]))
        //                    })
        //                    .asDriver(onErrorJustReturn: "")
        //                    .map { _ in }
        //            }
        //            .asDriver(onErrorJustReturn: ())
        //            .drive()
        //            .disposed(by: disposeBag)
    }
    
    
    
    
    
    @IBAction func clickMore(_ sender: UIButton) {
        
        if UserDefaults.getPremiumUser(){
            let songsCore = CoreDataManger.shared.getListSongOff()
            if let url = self.url{
                
                let alert = UIAlertController(title: "Download", message: "Select download", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "To Ringtone", style: .default, handler: { _ in
                    
                    if url.absoluteString.contains("http"){
                        self.downloadAndConvert(url: url, sender: sender)
                    }else{
                        sender.setImage(ImageProvider.image(named: "downloading"), for: .normal)
                        sender.isEnabled = false
                        sender.progressAnimation(value: 5)
                        ConvertRingtone.convertAudio(name: url.deletingPathExtension().lastPathComponent, url: url) { _ in
                            sender.removeProgressLayer()
                            sender.setImage(ImageProvider.image(named: "downloadSong"), for: .normal)
                            sender.isEnabled = true
                        }
                    }
  
                }))
                if songsCore.count > 0{
                    
                    let songCore = songsCore.filter {$0.id == self.song?.id}.first
                    if songCore?.id == self.song?.id{
                        
                    }else{
                        alert.addAction(UIAlertAction(title: "To Downloaded", style: .default, handler: { _ in
                            self.saveToDownloaded(song: self.song, url: url, sender: sender)
                        }))
                        
                    }
                }else{
                    alert.addAction(UIAlertAction(title: "To Downloaded", style: .default, handler: { _ in
                        self.saveToDownloaded(song: self.song, url: url, sender: sender)
                    }))
                }
              
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }else{
            self.showPremium()
        }
        
    }
    
    
    func downloadAndConvert(url:URL, sender:UIButton){
        sender.setImage(ImageProvider.image(named: "downloading"), for: .normal)
        APICategoryHome.downloadMusic(url: url) { pro in
            sender.progressAnimation(value: pro)
            sender.isEnabled = false
        } completion: {[weak self] urlL in
            ConvertRingtone.convertAudio(name: self?.song?.name ?? "", url: urlL) { _ in
                sender.removeProgressLayer()
                sender.setImage(ImageProvider.image(named: "downloadSong"), for: .normal)
                sender.isEnabled = true
                NotificationCenter.default.post(Notification.init(name: Notification.Name.init("DidRingToneDownloadSuccess")))
            }
            
            
        } fail: { err in
            sender.removeProgressLayer()
            sender.setImage(ImageProvider.image(named: "downloadSong"), for: .normal)
            sender.isEnabled = true
        }
    }
    
    
    func saveToDownloaded(song:Song?, url:URL, sender:UIButton){
        
        guard let song = song else {
            return
        }
        
        sender.setImage(ImageProvider.image(named: "downloading"), for: .normal)
        APICategoryHome.downloadMusic(url: url) { pro in
            sender.progressAnimation(value: pro)
            sender.isEnabled = false
        } completion: {[weak self] urlL in
            
            guard let self = self else {return}
            CoreDataManger.shared.saveSongOffline(id: "\(song.id ?? 0)", image: self.imvSong.image?.pngData(), name: self.lbNameSong.text ?? "", artist: self.lbNameAuthor.text ?? "", album: song.album, filename: url.lastPathComponent, filesize: nil, duration: nil, idPlaylist: "\(song.id_playlist ?? 0)", type: nil) {
               
                sender.removeProgressLayer()
                sender.setImage(ImageProvider.image(named: "downloadSong"), for: .normal)
                sender.isEnabled = true
                NotificationCenter.default.post(Notification.init(name: Notification.Name.init("DidDownloadSuccess")))
                
            } failure: { err in
                sender.removeProgressLayer()
                sender.setImage(ImageProvider.image(named: "downloadSong"), for: .normal)
                sender.isEnabled = true
            }
            
        } fail: { err in
            sender.removeProgressLayer()
            sender.setImage(ImageProvider.image(named: "downloadSong"), for: .normal)
            sender.isEnabled = true
            
        }
    }
    
}
