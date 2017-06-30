//
//  profileViewController.swift
//  Instagram
//
//  Created by Bamlak Gessessew on 6/27/17.
//  Copyright © 2017 Bamlak Gessessew. All rights reserved.
//

import UIKit
import Parse

class profileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    var myPosts: [PFObject]?
    var newProfPic: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //the next few lines lay out the items in the collection view nicely
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        let numCellsPerLine: CGFloat = 3
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (numCellsPerLine - 1)
        let width = collectionView.frame.size.width / numCellsPerLine - interItemSpacingTotal / numCellsPerLine
        layout.itemSize = CGSize(width: width, height: width)
        
        fetchMyPosts()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        fetchMyPosts()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myPosts?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! PhotoCollectionCell
        
        let post = myPosts![indexPath.item]
        let photo = post["media"] as! PFFile
        
        //set the photo image
        photo.getDataInBackground { (imageData: Data!, error: Error?) in
            cell.photoImageView.image = UIImage(data:imageData)
        }
        
        return cell
    }
    
    //====== GET THE DATA FROM THE CLOUD =======
    func fetchMyPosts() {
        // construct query
        let query = PFQuery(className: "Post")
        query.addDescendingOrder("createdAt")
        query.includeKey("author")
        query.whereKey("author", equalTo: PFUser.current()!)
        
        // fetch data asynchronously
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                // do something with the array of object returned by the call
                self.myPosts = posts
                self.collectionView.reloadData()
            } else {
                print(error?.localizedDescription)
            }
        }
        
    }
    
    //====== SEGUE TO DETAIL VIEW =======
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        if let indexPath = collectionView.indexPath(for: cell) {//get this to find the actual post
            let post = myPosts![indexPath.item] //get the current post
            let detailViewController = segue.destination as! DetailViewController //tell it its destination
            detailViewController.post = post
        }
    }
    
    //====== FOR HEADER THING =======
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let ProfileCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ProfileCollectionReusableView", for: indexPath) as! ProfileCollectionReusableView
        
        ProfileCollectionReusableView.nameLabel.text = PFUser.current()?.username
        //make profile pic circular
        ProfileCollectionReusableView.profilePicImageView.layer.cornerRadius = ProfileCollectionReusableView.profilePicImageView.frame.size.width / 2;
        ProfileCollectionReusableView.profilePicImageView.clipsToBounds = true;
        if(newProfPic != nil){
            ProfileCollectionReusableView.profilePicImageView.image = newProfPic
        }
        ProfileCollectionReusableView.numPostsLabel.text = String(describing: myPosts?.count ?? 0)
        
        return ProfileCollectionReusableView
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapProfilePic(_ sender: Any) {
        choosePhoto()
    }
    @IBAction func didPressLogOut(_ sender: Any) {
        PFUser.logOutInBackground { (error: Error?) in
        }
        NotificationCenter.default.post(name: NSNotification.Name("logoutNotification"), object: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        newProfPic = editedImage
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didPressProfilePic(_ sender: Any) {
        choosePhoto()
    }
    
    func choosePhoto() {
        // Instantiate a UIImagePickerController
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        // Check that the camera is indeed supported on the device before trying to present it
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }
        
        // Present the camera or photo library
        self.present(vc, animated: true, completion: nil)
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
