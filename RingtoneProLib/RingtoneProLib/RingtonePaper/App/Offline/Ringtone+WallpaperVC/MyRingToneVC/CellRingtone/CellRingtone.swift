//
//  CellRingtone.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/2/21.
//

import UIKit


protocol ActionRingtoneDelegate:class {
    func renameAction(cell:CellRingtone)
    func trimAction(cell:CellRingtone)
    func setAsAction(cell:CellRingtone)
    func moreAction(cell:CellRingtone)
    func clickDropDown(cell:CellRingtone)
    func didFinishTime(cell:CellRingtone)
}

class CellRingtone: UITableViewCell {
    @IBOutlet weak var lineTop: UIView!
    
    @IBOutlet weak var btnDrop: UIButton!
    
    
    @IBOutlet weak var lbNameMusic: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var vStackSlider: UIView!
    
    @IBOutlet weak var btnPlayMusic: UIButton!
    @IBOutlet weak var more: UIStackView!
    @IBOutlet weak var setAs: UIStackView!
    @IBOutlet weak var trim: UIStackView!
    @IBOutlet weak var rename: UIStackView!
    
    @IBOutlet weak var sliderAudio: UISlider!
    weak var timer:Timer?
    
    var ringtone:RingtoneModel!
    
    var isSelectedCell = false
    weak var delegate:ActionRingtoneDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTap()
       
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected{
            
            self.vStackSlider.isHidden = false
            sliderAudio.isHidden = false
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
           
            self.btnDrop.transform = CGAffineTransform(rotationAngle: .pi/2)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying) , name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            btnPlayMusic.setImage(ImageProvider.image(named: "pause"), for: .normal)
           
            contentView.layoutSubviews()
        }
        else{
            isSelectedCell = false
            timer?.invalidate()
            timer = nil
            self.vStackSlider.isHidden = true
            sliderAudio.isHidden = true
            btnPlayMusic.setImage(ImageProvider.image(named: "play"), for: .normal)
            MusicPlayer.instance.pause()
            self.btnDrop.transform = CGAffineTransform(rotationAngle: 0)
            
        }
        
        // Configure the view for the selected state
    }
    @objc func updateSlider() {
        
        
        let currentSecond = Double(MusicPlayer.instance.player.currentTime().seconds ?? 0)
        lbDescription.text = "\(currentSecond.stringFromTimeInterval())/\(ringtone.duration.stringFromTimeInterval()) - \(ringtone.size)MB - \(ringtone.type)"
        sliderAudio.value = Float(MusicPlayer.instance.player.currentTime().seconds ?? 0)
    }
    
    func setupTap(){
        
       
        let tapTrim = UITapGestureRecognizer(target: self, action: #selector(didTapTrim))
        let tapSetAs = UITapGestureRecognizer(target: self, action: #selector(didTapSetAs))
        let tapMore = UITapGestureRecognizer(target: self, action: #selector(didTapMore))
        let tapRename = UITapGestureRecognizer(target: self, action: #selector(didTapRename))
        
        trim.addGestureRecognizer(tapTrim)
        setAs.addGestureRecognizer(tapSetAs)
        more.addGestureRecognizer(tapMore)
        rename.addGestureRecognizer(tapRename)
        sliderAudio.value = 0
        sliderAudio.minimumValue = 0
        
        sliderAudio.setThumbImage(ImageProvider.image(named: "thumSlider"), for: .normal)
        
        sliderAudio.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
    }
    
    
    func bindData(ringtone:RingtoneModel){
        lbNameMusic.text = ringtone.nameOriginal
        lbDescription.text = "\(ringtone.duration.stringFromTimeInterval()) - \(ringtone.size)MB - \(ringtone.type)"
        sliderAudio.maximumValue = Float(ringtone.duration)
        self.ringtone = ringtone
    }
    
    
    @objc func playerDidFinishPlaying(){
        btnPlayMusic.setImage(ImageProvider.image(named: "play"), for: .normal)
        timer?.invalidate()
        timer = nil
        delegate?.didFinishTime(cell: self)
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                
                timer?.invalidate()
                timer = nil
                sliderAudio.setThumbImage(ImageProvider.image(named: "thumScale"), for: .normal)
                // handle drag began
            case .moved:
                
                sliderAudio.setThumbImage(ImageProvider.image(named: "thumScale"), for: .normal)
                // handle drag moved
            case .ended:
                sliderAudio.setThumbImage(ImageProvider.image(named: "thumSlider"), for: .normal)
                MusicPlayer.instance.seekToPosition(seconds: Float64(slider.value)) {
                    
                    self.timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                }
            default:
                break
            }
        }
    }
    
    @IBAction func clickDropUp(_ sender: Any) {

        delegate?.clickDropDown(cell: self)
        
    }
    
    @objc func didTapRename(){
        delegate?.renameAction(cell: self)
    }
    @objc func didTapTrim(){
        delegate?.trimAction(cell: self)
    }
    @objc func didTapSetAs(){
        delegate?.setAsAction(cell: self)
    }
    @objc func didTapMore(){
        delegate?.moreAction(cell: self)
    }
}

