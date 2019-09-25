//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePostDetailTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, AudioCommentTableViewCellDelegate, AVAudioPlayerDelegate {
    func playRecording(for cell: AudioCellTableViewCell) {
        guard let data = cache.value(for: cell.comment) else { return }
        
        do {
            player = try AVAudioPlayer(data: data)
            player.delegate = self
            player.prepareToPlay()
            player.play()
        } catch {
            NSLog("Error playing recording: \(error)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
         NotificationCenter.default.addObserver(self, selector: #selector(refreshViews), name: .audioVCPopoverDismissed, object: nil)    }
 


@objc func refreshViews(notification: Notification) {
    self.tableView.reloadData()
}
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }  // Need to add this for the popover to be adaptive
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
        var commentTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
            
            guard let commentText = commentTextField?.text else { return }
            
            self.postController.addComment(with: commentText, to: &self.post!)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAudioAction = UIAlertAction(title: "Add Audio", style: .default) { (_) in
            DispatchQueue.main.async {
//                let sb = UIStoryboard(name: "AudioCommentsViewController", bundle: nil)
//                let popup = sb.instantiateViewController(withIdentifier: "AudioCommentsViewController")
//                self.present(popup, animated: true)
                
                self.performSegue(withIdentifier: "toAudio", sender: nil)
            }
        }
        
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)
        alert.addAction(addAudioAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row + 1]
        
//        cell.textLabel?.text = comment?.text
//        cell.detailTextLabel?.text = comment?.author.displayName
//
//        return cell
     
        if comment?.audioURL == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            
            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author.displayName
            
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as? AudioCellTableViewCell else { return AudioCellTableViewCell()}
            
            cell.comment = comment
            cell.delegate = self
            
            loadAudio(for: cell, forItemAt: indexPath)
            //            cell.nameLabel =
            //            loadAudio(for: cell, forItemAt: indexPath)
            //            cell.delegate = self
            
            return cell
        }
   
    }
    //How does this work?
    func loadAudio(for cell: AudioCellTableViewCell, forItemAt indexPath: IndexPath) {
        guard let comment = cell.comment else { return }
        
        if let audioData = cache.value(for: comment) {
            cell.audioData = audioData
            return
        }
        
        let fetchAudioOp = FetchAudioOperation(comment: comment, postController: postController)
        
        let cacheOp = BlockOperation {
            if let audioData = fetchAudioOp.audioData {
                self.cache.cache(value: audioData, for: comment)
                DispatchQueue.main.async {
                    cell.audioData = audioData
                }
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: comment) }
            
            if let currentIndexPath = self.tableView?.indexPath(for: cell),
                currentIndexPath != indexPath {
                print("Got image for now-reused cell")
                return
            }
            
            if let audioData = fetchAudioOp.audioData {
                cell.audioData = audioData
            }
        }
        
        cacheOp.addDependency(fetchAudioOp)
        completionOp.addDependency(fetchAudioOp)
        
        audioFetchQueue.addOperation(fetchAudioOp)
        audioFetchQueue.addOperation(cacheOp)
        
        OperationQueue.main.addOperation(completionOp)
        //why do we need to use operations?
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    var player: AVAudioPlayer!
    
    private let audioFetchQueue = OperationQueue()
    private var operations = [Comment: Operation]()
    private let cache = Cache<Comment, Data>()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAudio" {
            guard let vc = segue.destination as? AudioCommentsViewController else { return }
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.delegate = self
            vc.postController = postController
            vc.post = post
        }
    }
}
