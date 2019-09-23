//
//  AudioCommentsViewController.swift
//  LambdaTimeline
//
//  Created by Stephanie Bowles on 9/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation


class AudioCommentsViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    
    private var player: AVAudioPlayer?
    private var recorder: AVAudioRecorder?
    
    private var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    private var recordingURL: URL?
    private var isRecording: Bool {
        return recorder?.isRecording ?? false
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func recordButtonTapped(_ sender: Any) {
        defer {updateButtons()}
        
        guard !isRecording else {
            recorder?.stop()
            return
        }
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
            recorder = try AVAudioRecorder(url: self.newRecordingURL(), format: format)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            NSLog("Unable to start recording  \(error)")
        }
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        defer {updateButtons()}
        guard let url = self.recordingURL else {return}
        guard !isPlaying else {
            player?.stop()
            return
        }
        
        do {
          player = try AVAudioPlayer(contentsOf: url)
          player?.delegate = self
          player?.play()
            
        } catch {
            NSLog("Unable to start playing: \(error)")
        }
    }
    
    
    private func updateButtons() {
        let playButtonString = self.isPlaying ? "Stop PLaying" : "Play"
        self.playButton.setTitle(playButtonString, for: .normal)
        
        let recordButtonString = self.isRecording ? "Stop": "Record"
        self.recordButton.setTitle(recordButtonString, for: .normal)
    }
    
    private func newRecordingURL()  -> URL {
        let fm = FileManager.default
        let documentsDirector = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return
            documentsDirector.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
        self.updateButtons()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.recordingURL = recorder.url
        self.recorder = nil
        self.updateButtons()
    }
}
