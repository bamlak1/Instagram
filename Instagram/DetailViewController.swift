//
//  DetailViewController.swift
//  Instagram
//
//  Created by Bamlak Gessessew on 6/29/17.
//  Copyright © 2017 Bamlak Gessessew. All rights reserved.
//

import UIKit
import Parse

class DetailViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    var post: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.width / 2;
        profilePicImageView.clipsToBounds = true;
        
        if let post = post {
            let user = post["author"] as! PFUser
            usernameLabel.text = user.username //send over the username
            captionLabel.text = post["caption"] as? String
            if let date = post["timestamp"]{
                timestampLabel.text = date as? String
            } else {
                timestampLabel.text = "No Date"
            }
            let photo = post["media"] as! PFFile
            photo.getDataInBackground { (imageData: Data!, error: Error?) in
                self.photoImageView.image = UIImage(data:imageData)
            }
        }
    }
    
    
    @IBAction func didPressBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
