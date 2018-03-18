//
//  PokeCell.swift
//  pokedex
//
//  Created by Aleksei Degtiarev on 18/03/2018.
//  Copyright © 2018 Aleksei Degtiarev. All rights reserved.
//

import UIKit

class PokeCell: UICollectionViewCell {

    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    var pokemon: Pokemon!
    
    func configureCell(pokemon: Pokemon) {
        self.pokemon = pokemon
        nameLabel.text = self.pokemon.Name.capitalized
        thumbImage.image = UIImage(named: "\(self.pokemon.pokedexId)")
    }

}
