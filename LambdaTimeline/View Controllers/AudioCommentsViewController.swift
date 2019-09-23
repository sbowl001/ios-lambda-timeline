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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func recordButtonTapped(_ sender: Any) {
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
    }
    
}
