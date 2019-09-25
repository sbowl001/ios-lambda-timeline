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
        
        session = AVAudioSession.sharedInstance()
        
        do {
            //to ask for permission
            try session.setCategory(.playAndRecord, mode: .default, options: [])
            try session.setActive(true)
            session.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                    } else {
                        self.presentInformationalAlertController(title: "Unable to record audio", message: "Audio recording permissions not granted")
                    }
                }
            }
        } catch {
            NSLog("Error with audio record permissions: \(error)")
            self.presentInformationalAlertController(title: "Unable to record audio", message: "Audio recording failed. Try again.")
        }
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
    @IBAction func doneButtonTapped(_ sender: Any) {
        
       guard let recordingURL = self.recordingURL,
            let data = try? Data(contentsOf: recordingURL),
        let post = post  else {return}
    
       self.postController.addComment(with: data, to: post)
    
        self.dismiss(animated: true, completion: nil)
      
        
        
        
        //            guard let recordingURL = self.recordingURL else {return}
        //            self.postController.addAudio(with: recordingURL, to: &self.post)
        //            self.dismiss(animated: true)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: .audioVCPopoverDismissed, object: nil)
    }
    var postController: PostController!
    var post: Post!
    var session: AVAudioSession!
}
