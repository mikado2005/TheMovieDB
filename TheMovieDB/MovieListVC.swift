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
        
        // Hide empty cells in the table
        movieTable.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Movie API interaction
    
    func loadMovieLists() {
        
    }
    
    // MARK: Table delegate functions
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableCell
        
        if let movie = movieLists[currentMovieListType]?.results?[indexPath.row] {
//            cell.movieTitle.text = "Airplane!"
//            cell.movieOverview.text = "Absolutely the funniest movie ever made, Airplane! is a rockin' spoof of airline disaster movies."
            cell.movieTitle.text = movie.title
            cell.movieOverview.text = movie.overview
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
        return 60
    }
}

// MARK: Movie table cell
class MovieTableCell: UITableViewCell {
    
    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
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


