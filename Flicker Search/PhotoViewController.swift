//
//  PhotoViewController.swift
//  Flicker Search
//
//  Created by Ayoub Khayatti on 04/04/16.
//  Copyright © 2016 Ayoub Khayati. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var selectedPhoto : FlickrPhoto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedPhoto != nil {
            Service.getImage(selectedPhoto!.photoLargeUrl, completion: { (response) in
                self.photoImageView.image = response
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
}
