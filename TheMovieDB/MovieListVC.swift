//
//  MovieListVC.swift
//  TheMovieDB
//
//  Created by Greg Anderson on 3/15/18.
//  Copyright © 2018 Planet Beagle. All rights reserved.
//

import UIKit

class MovieListVC: UIViewController,
                   UITabBarDelegate,
                   UITableViewDelegate,
                   UITableViewDataSource {
    
    @IBOutlet weak var movieTable: UITableView!
    @IBOutlet weak var mainTabBar: UITabBar!
    
    // Data model: An array of movie lists, one for each type of list available from
    // four API endpoints, as defined here:
    let allMovieListTypes:[NetworkAPIEndpoint] =
        [.nowPlaying, .popular, .topRated, .upcoming]
    var movieLists = [NetworkAPIEndpoint:MovieList]()
    // This is the list type we're currently viewing
    var currentMovieListType: NetworkAPIEndpoint = .nowPlaying
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load up the first movie list, corresponding to the left-most tab
        loadCurrentMovieList()
        
        // Select the left-most tab
        mainTabBar.delegate = self
        mainTabBar.selectedItem = mainTabBar.items?[0]
        
        // Hide empty cells in the table
        movieTable.tableFooterView = UIView(frame: .zero)
    }

    // MARK: Movie API interaction
    
    // Grab the movie list for the currently selected movie list type.
    // Set the loaded movie data into the table view.
    func loadCurrentMovieList() {
        NetworkAPI.getMoviesFromAPI(listType: currentMovieListType) {
            [weak self](movieList, httpResponse, error) in
            if let movies = movieList, error == nil, self != nil {
                self!.movieLists[self!.currentMovieListType] = movies
                self!.movieTable.reloadData()
            }
        }
    }
    
    // MARK: Tab bar functions
    
    // User tapped on the tab bar
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let indexOfTab = tabBar.items?.index(of: item) ?? 0
        // TODO: Should we check if the tab has changed to avoid reload?
        // Maybe not!  Right now that updates the list.
        if indexOfTab < allMovieListTypes.count {
            currentMovieListType = allMovieListTypes[indexOfTab]
            loadCurrentMovieList()
        }
    }
    
    // MARK: Table delegate functions

    // Produce a new table cell for the given row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableCell
        
        if let movie = movieLists[currentMovieListType]?.results?[indexPath.row] {
            cell.movieTitle.text = movie.title
            cell.movieOverview.text = movie.overview
            cell.posterImagePath = movie.posterPath
        }
        return cell
    }
    
    // Only using one table section at the moment.
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    // We have the same number of rows as we have elements in the current movie list
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieLists[currentMovieListType]?.results?.count ?? 0
    }
    
    // Does this still speed up the table drawing?
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: Movie table cell
class MovieTableCell: UITableViewCell {
    
    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    
    // TODO: Cache previously fetched poster images.  Right an image is loaded fresh
    // whenever a given movie appears on the screen.
    
    // This is the partial URL path the the poster image.  When set, we download the
    // image asynchronously and add it to the cell.
    var posterImagePath: String? {
        didSet {
            if let path = posterImagePath {
                NetworkAPI.getPosterImageFromAPI(posterPath: path) {
                    [weak self](image, httpResponse, error) in
                    if let posterImage = image, self != nil {
                        self!.moviePosterImage.image = posterImage
                    }
                }
            }
        }
    }
}
