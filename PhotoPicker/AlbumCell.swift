//
//  AlbumCell.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/25.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

class AlbumCell: UITableViewCell {

    @IBOutlet weak var albumCover1: UIImageView!
    @IBOutlet weak var albumCover2: UIImageView!
    @IBOutlet weak var albumCover3: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var borderWidth: CGFloat = 0.0 {
        didSet {
            albumCover1.layer.borderColor = AlbumCoverBorderColor
            albumCover2.layer.borderColor = AlbumCoverBorderColor
            albumCover3.layer.borderColor = AlbumCoverBorderColor
            
            albumCover1.layer.borderWidth = borderWidth
            albumCover2.layer.borderWidth = borderWidth
            albumCover3.layer.borderWidth = borderWidth
        }
    }
}
