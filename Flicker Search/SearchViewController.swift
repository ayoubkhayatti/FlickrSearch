//
//  ViewController.swift
//  Flicker Search
//
//  Created by Ayoub Khayatti on 28/03/16.
//  Copyright © 2016 Ayoub Khayati. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UIScrollViewDelegate,
    UISearchBarDelegate,
    UISearchResultsUpdating
{
    let cellId  = "photoCell"
    let segueId = "showImageSegue"
    
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var dataSource = [FlickrPhoto]()
    var page: Int = 0;
    var loadingStatus = false

    override func viewWillLayoutSubviews() {
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.searchController = initializeSearch()
    }
    
    //MARK: TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellId, forIndexPath: indexPath) as! PhotoTableViewCell
        
        let photo = self.dataSource[indexPath.row]
        cell.titleLabel.text = photo.title
        cell.ownerLabel.text = photo.owner
        
        Service.getImage(photo.photoUrl) { (response) in
            if let image = response{
                image.af_inflate()
                cell.photoImageView.image = image;
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let photo = self.dataSource[indexPath.row]
        self.searchController.searchBar.resignFirstResponder()
        self.performSegueWithIdentifier(segueId, sender: photo)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins  = UIEdgeInsetsZero
    }
    
    //MARK: ScrollView Delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView){
        self.searchController.searchBar.resignFirstResponder()
        
        //reaching the end
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 100 {
            loadMorePhotos()
        }
    }

    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueId {
            if let photo = sender as? FlickrPhoto {
                let photoViewController = segue.destinationViewController as! PhotoViewController
                photoViewController.selectedPhoto = photo
            }
        }
    }
    
    //MARK: Search
    
    func initializeSearch()-> UISearchController{
        //search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search photo here..."
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true

        let searchBarView = UIView.init(frame: searchController.searchBar.frame)
        searchBarView.addSubview(searchController.searchBar)
        searchBarView.backgroundColor = UIColor.redColor()
        self.tableView.tableHeaderView = searchBarView
        
        //search bar colors
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])
            .tintColor = UIColor.pickledBluewoodColor()
        
        searchController.searchBar.barTintColor = UIColor.pickledBluewoodColor()
        searchController.searchBar.searchBarStyle = .Minimal
        searchController.searchBar.backgroundColor = UIColor.whiteColor()

        if let textField = searchBarTextField(searchController.searchBar){
            textField.textColor = UIColor.pickledBluewoodColor()
            textField.backgroundColor = UIColor.whiteColor()
        }
        
        return searchController
    }
    
    func searchBarTextField(searchBar: UISearchBar) -> UITextField? {
        let searchBarView = searchBar.subviews[0]
        for subview in searchBarView.subviews {
            if subview is UITextField {
                return subview as? UITextField
            }
        }
        return nil
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController){
        NSObject.cancelPreviousPerformRequestsWithTarget(self,
                                                         selector: #selector(SearchViewController.retrievePhotos(_:)),
                                                         object: searchController)
        self.performSelector(#selector(SearchViewController.retrievePhotos(_:)),
                             withObject: searchController,
                             afterDelay: 0.5)
    }
    
    func retrievePhotos(searchController: UISearchController){
        self.dataSource.removeAll()
        self.tableView.reloadData()
        self.page = 0
        let text = searchController.searchBar.text!
        if text.isEmpty {
            return
        }
        Service.search(text, page: self.page) { (result, error) in
            if let photos = result {
                print("results count = \(photos.count)")
                self.dataSource.appendContentsOf(photos)
                self.tableView.reloadData()
            }
        }
    }
    
    func loadMorePhotos() {
        if loadingStatus == false && self.dataSource.count != 0 {
            if let text = self.searchController.searchBar.text {
                self.loadingStatus = true
                self.page += 1
                addInfiniteScrollViewInFooter()
                Service.search(text, page: self.page) { (result, error) in
                    self.removeInfiniteScrollViewInFooter()
                    if let photos = result {
                        self.dataSource.appendContentsOf(photos)
                        self.tableView.reloadData()
                    }
                    self.loadingStatus = false
                }
            }
        }
    }

    //MARK: Infinite scroll
    
    func addInfiniteScrollViewInFooter() {
        
        let bounds = UIScreen.mainScreen().bounds
        let width = bounds.size.width
        
        let footerView = UIView(frame: CGRectMake(0, 0, width, 44))
        footerView.backgroundColor = UIColor.whiteColor()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.center = footerView.center
        activityIndicator.color = UIColor.pickledBluewoodColor()
        
        footerView.addSubview(activityIndicator)
        activityIndicator.startAnimating();
        self.tableView.tableFooterView = footerView;
    }
    
    func removeInfiniteScrollViewInFooter(){
        self.tableView.tableFooterView = nil;
    }
    
    //MARK: Appearance
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
}

extension UIColor {
    class func lightOrangeColor() -> UIColor {
        return UIColor(red: 253.0 / 255.0, green: 189.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
    }
    
    class func peachColor() -> UIColor {
        return UIColor(red: 238.0 / 255.0, green: 103.0 / 255.0, blue: 35.0 / 255.0, alpha: 1.0)
    }
    
    class func pickledBluewoodColor() -> UIColor{
        return UIColor(red: 44.0 / 255.0, green: 62.0 / 255.0, blue:80.0 / 255.0, alpha: 1.0)
    }
}
