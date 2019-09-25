//
//  AudioCellTableViewCell.swift
//  LambdaTimeline
//
//  Created by Stephanie Bowles on 9/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioCommentTableViewCellDelegate: class {
    func playRecording(for cell: AudioCellTableViewCell)
}
class AudioCellTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    
    var comment: Comment! {
        didSet {
            updateViews()
        }
    }
    var audioData: Data! {
        didSet {
            playButton.isEnabled = audioData != nil
        }
    }
    weak var delegate: AudioCommentTableViewCellDelegate?
    
    func updateViews() {
        guard let comment = comment else { return }
        nameLabel.text = comment.author.displayName
    }
    @IBAction func playButtonTapped(_ sender: Any) {
        delegate?.playRecording(for: self)
    }
}
