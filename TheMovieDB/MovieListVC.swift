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
    
    var movieLists = [NetworkAPIEndpoint:MovieList]()
    var currentMovieListType: NetworkAPIEndpoint = .nowPlaying
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovieLists()
        
        // Hide empty cells in the table
        movieTable.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Movie API interaction
    
    func loadMovieLists() {
        NetworkAPI.getMoviesFromAPI(listType: currentMovieListType) {
            [weak self](movieList, httpResponse, error) in
            if let movies = movieList, error == nil, self != nil {
                self!.movieLists[self!.currentMovieListType] = movies
                self!.movieTable.reloadData()
            }
        }
    }
    
    // MARK: Table delegate functions
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableCell
        
        if let movie = movieLists[currentMovieListType]?.results?[indexPath.row] {
            cell.movieTitle.text = movie.title
            cell.movieOverview.text = movie.overview
            cell.posterImagePath = movie.posterPath
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieLists[currentMovieListType]?.results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: Movie table cell
class MovieTableCell: UITableViewCell {
    
    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    
    // TODO: Cache previously fetched poster images
    
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup ()
    }
    
    func setup() {
        // Style customizations here, if any
    }
    
}


