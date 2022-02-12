//
//  ViewController.swift
//  WGIdenticon
//
//  Created by Mark Morrill on 2017/04/19.
//  Copyright © 2017 WeGame Corp. All rights reserved.
//

import UIKit

class Cell : UICollectionViewCell {
    static let identifier = "Cell_ID"
    @IBOutlet weak var image : UIImageView!
}


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath)
        
        if let cell = cell as? Cell {
//            cell.image.image = Identicon().icon(from: arc4random_uniform(UInt32.max), size: CGSize(width: 200, height: 200))
            cell.image.image = WGIdenticon().icon(from: arc4random_uniform(UInt32.max), size: CGSize(width: 200, height: 200))
        }
        
        return cell
    }
}

