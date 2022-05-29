//
//  TrimmingVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/10/21.
//

import UIKit
import SoundWave
import AVKit


class TrimmingVC: BaseViewControllers {
    
    
    @IBOutlet weak var visualizationView: AudioVisualizationView!
    
    @IBOutlet weak var rangeSlider: ABVideoRangeSlider!
    
    @IBOutlet weak var lbStart: UILabel!
    @IBOutlet weak var lbEnd: UILabel!
    @IBOutlet weak var vStackEnd: UIStackView!
    @IBOutlet weak var vStackStart: UIStackView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var timeLine: UISlider!
    var ringtone:RingtoneModel?
    
    var isPlay = true{
        didSet{
            isPlay ? (btnPlay.setImage(ImageProvider.image(named: "pauseTrim"), for: .normal)) : (btnPlay.setImage(ImageProvider.image(named: "playTrim"), for: .normal))
        }
    }
    var timer: Timer?
    
    
    init(ringtone:RingtoneModel?) {
        self.ringtone = ringtone
        super.init(nibName: "TrimmingVC", bundle: BundleProvider.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var startTime:Double = 0
    var endTime:Double = 0
    
    deinit {
        print("did deint trim")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        clearPlay()
        
        ringtone = nil
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        
    }
    
    func setupUI(){
        
        
        if let ringtone = ringtone{
            rangeSlider.setVideoURL(videoURL: ringtone.url)
            
            rangeSlider.delegate = self
            rangeSlider.setStartIndicatorImage(image: ImageProvider.image(named: "startSlider") ?? UIImage())
            rangeSlider.setEndIndicatorImage(image: ImageProvider.image(named: "endSlider") ?? UIImage())
            rangeSlider.setBorderImage(image: ImageProvider.image(named: "thumScale") ?? UIImage())
            
            btnPlay.layer.borderWidth = 0.5
            btnPlay.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            btnPlay.layer.cornerRadius = 35
            vStackEnd.layer.cornerRadius = 10
            vStackEnd.clipsToBounds = true
            vStackStart.layer.cornerRadius = 10
            vStackStart.clipsToBounds = true
            startTime = 0
            endTime = ringtone.duration
            
            timeLine.minimumValue = 0
            timeLine.maximumValue = Float(ringtone.duration)
            timeLine.minimumTrackTintColor = .clear
            timeLine.maximumTrackTintColor = .clear
            timeLine.setThumbImage(ImageProvider.image(named: "timeLine"), for: .normal)
            rangeSlider.minSpace = 10
            if endTime >= 30{
                rangeSlider.maxSpace = 30
                endTime = 30
                rangeSlider.setEndPosition(seconds: 30)
            }
            
            rangeSlider.backgroundColor = .clear
            lbEnd.text = endTime.stringFromTimeInterval()
            lbStart.text = startTime.stringFromTimeInterval()
            setUpWaveSoundTrimming(url: ringtone.url)
        }
        
        
        
        changeLeftButton(image: ImageProvider.image(named: "backTrim"))
        changeRightButton(title: "Done", color: #colorLiteral(red: 0.06274509804, green: 0.8039215686, blue: 0.05882352941, alpha: 1))
        self.navigationItem.title = ringtone?.nameOriginal
        
    }
    
    func setUpWaveSoundTrimming(url:URL) {
        
        self.visualizationView.reset()
        self.visualizationView.audioVisualizationMode = .read
        self.visualizationView.meteringLevelBarWidth = 2
        self.visualizationView.meteringLevelBarCornerRadius = 2
        self.visualizationView.meteringLevelBarInterItem = 3
        self.visualizationView.gradientStartColor = .gray
        self.visualizationView.gradientEndColor = .green
        
        AudioSetupContex.load(fromAudioURL: url) { [weak self] audioContext in
            guard let self = self, let audioContext = audioContext else {
                fatalError("Couldn't create the audioContext")
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.visualizationView.meteringLevels = audioContext.render(targetSamples: 100)
                self.visualizationView.play(for: TimeInterval(CMTimeGetSeconds(audioContext.asset.duration)))
                MusicPlayer.instance.initURLRingtone(url: url.absoluteString)
                self.startTimer()
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying) , name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            }
            
        }
        
    }
    
    @objc func playerDidFinishPlaying(){
        clearPlay()
    }
    
    @objc func checkTime() {
        
        if MusicPlayer.instance.player.currentTime().seconds >= endTime{
            clearPlay()
        }else{
            self.timeLine.value = Float(MusicPlayer.instance.player.currentTime().seconds)
        }
        
        
         
    }
    
    override func clickLeft(sender: UIButton) {
        self.dismissVC()
    }
    
    override func clickRight() {
        
        let saveVC = BaseNavVC(rootViewController: SaveRingToneVC(ringtone: ringtone, startTime: startTime, endTime: endTime))
        
        
        self.present(saveVC, animated: true, completion: nil)
        
        
    }
    @IBAction func clickPlay(_ sender: Any) {
        isPlay = !isPlay
        if isPlay{
            continuePlay()
        }
        else{
            clearPlay()
        }
        
    }
    
    //MARK: - minus and plus time
    
    @IBAction func plusEnd(_ sender: Any) {
        if let ringtone = ringtone{
            if endTime == ringtone.duration{
                endTime = ringtone.duration
            }
            else{
                endTime += 1
                startTime += 1
            }
            lbStart.text = startTime.stringFromTimeInterval()
            lbEnd.text = endTime.stringFromTimeInterval()
        }
        rangeSlider.setStartPosition(seconds: Float(startTime))
        rangeSlider.setEndPosition(seconds: Float(endTime))
        continuePlay()
    }
    
    
    @IBAction func minusEnd(_ sender: Any) {
        
        if endTime == startTime+10{
            endTime =  startTime+10
        }
        else{
            
            if startTime <= 0{
                startTime = 0
            }else{
                endTime -= 1
                startTime -= 1
            }
            
            
            
        }
        lbStart.text = startTime.stringFromTimeInterval()
        lbEnd.text = endTime.stringFromTimeInterval()
        rangeSlider.setStartPosition(seconds: Float(startTime))
        rangeSlider.setEndPosition(seconds: Float(endTime))
        continuePlay()
    }
    
    @IBAction func plusStart(_ sender: Any) {
        if startTime == endTime-10{
            startTime = endTime-10
        }
        else{
            
            if endTime == ringtone?.duration{
                endTime = ringtone?.duration ?? 0
            }else{
                startTime += 1
                endTime += 1
            }
            
        }
        lbStart.text = startTime.stringFromTimeInterval()
        lbEnd.text = endTime.stringFromTimeInterval()
        rangeSlider.setStartPosition(seconds: Float(startTime))
        rangeSlider.setEndPosition(seconds: Float(endTime))
        continuePlay()
    }
    
    @IBAction func minusStart(_ sender: Any) {
        if startTime == 0{
            startTime = 0
        }
        else{
            startTime -= 1
            endTime -= 1
        }
        lbStart.text = startTime.stringFromTimeInterval()
        lbEnd.text = endTime.stringFromTimeInterval()
        rangeSlider.setStartPosition(seconds: Float(startTime))
        rangeSlider.setEndPosition(seconds: Float(endTime))
        continuePlay()
    }
    
    
    
}
extension TrimmingVC:ABVideoRangeSliderDelegate{
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
        
    }
    
    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {

        
        if (endTime - startTime) >= 30{
            self.startTime = Double(startTime)
            self.endTime = Double(startTime+30)
        }else{
            self.startTime = Double(startTime)
            self.endTime = Double(endTime)
        }
        rangeSlider.setStartPosition(seconds: Float(self.startTime))
        rangeSlider.setEndPosition(seconds: Float(self.endTime))
        lbStart.text = self.startTime.stringFromTimeInterval()
        lbEnd.text = self.endTime.stringFromTimeInterval()
        continuePlay()
        
    }
    
    func clearPlay(){
        
        MusicPlayer.instance.pause()
        stopTimer()
        
    }
    
    func startTimer(){
      if timer == nil {
        self.timer = Timer.scheduledTimer(timeInterval: 0.00001, target: self, selector: #selector(self.checkTime), userInfo: nil, repeats: true)
        isPlay = true
      }
    }
    func stopTimer(){
      if timer != nil {
        timer!.invalidate()
        timer = nil
        isPlay = false
      }
    }
    
    
    func continuePlay(){
        MusicPlayer.instance.pause()
        
        timeLine.value = Float(startTime)
        
        
        MusicPlayer.instance.seekToPosition(seconds: Float64(startTime), completion: {
            MusicPlayer.instance.play()
            self.startTimer()
        })
        
    }
    
    
    
}
