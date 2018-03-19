//
//  Pokemon.swift
//  pokedex
//
//  Created by Aleksei Degtiarev on 18/03/2018.
//  Copyright © 2018 Aleksei Degtiarev. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    private var _name: String!
    private var _pokedexId: Int!
    private var _pokemonURL: String!
    
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _nextEvolutionName: String!
    private var _nextEvolutionId: String!
    private var _nextEvolutionLevel: String!
    
    
    
    var name: String {
        return _name
    }
    
    var pokedexId: Int {
        return _pokedexId
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var type: String {
        if _type == nil {
            _type = ""
        }
        return _type
    }
    
    var defense: String {
        if _defense == nil {
            _defense = ""
        }
        return _defense
    }
    
    var height: String {
        if _height == nil {
            _height = ""
        }
        return _height
    }
    
    var weight: String {
        if _weight == nil {
            _weight = ""
        }
        return _weight
    }
    
    var attack: String {
        if _attack == nil {
            _attack = ""
        }
        return _attack
    }
    
    var nextEvolutionText: String {
        if _nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        return _nextEvolutionTxt
    }
    
    var nextEvolutionName: String {
        if _nextEvolutionName == nil {
            _nextEvolutionName = ""
        }
        return _nextEvolutionName
    }
    
    var nextEvolutionId: String {
        if _nextEvolutionId == nil {
            _nextEvolutionId = ""
        }
        return _nextEvolutionId
    }
    
    var nextEvolutionLevel: String {
        if _nextEvolutionLevel == nil {
            _nextEvolutionLevel = ""
        }
        return _nextEvolutionLevel
    }
    
    
    
    
    init(name: String, pokedexId: Int) {
        self._name = name
        self._pokedexId = pokedexId
        
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self.pokedexId)/"
    }
    
    func downloadPokemonDetails(completed: @escaping DownloadComplete) {
        Alamofire.request(_pokemonURL).responseJSON { (response) in
            
            if let dict = response.result.value as? Dictionary<String, AnyObject> {
                
                if let weight = dict["weight"] as? Int64 {
                    self._weight = "\(weight)"
                }
                
                
                if let height = dict["height"] as? Int64 {
                    self._height = "\(height)"
                }
                
                
                if let types = dict["types"] as? [Dictionary<String, AnyObject>], types.count > 0 {
                    var typesString: String = ""
                    
                    for type in types {
                        if let typeP = type["type"] as? Dictionary<String, String> {
                            if let name = typeP["name"] {
                                
                                if typesString != "" {
                                    typesString = typesString + "/"
                                }
                                
                                typesString = typesString + name.capitalized
                            }
                        }
                    }
                    
                    self._type = typesString
                    
                } // if let types = dict["types"] as? [Dictionary<String, AnyObject>], types.count > 0
                
                
                if let stats = dict["stats"] as? [Dictionary<String, AnyObject>] {
                    for statt in stats {
                        if let stat = statt["stat"] as? Dictionary<String, String> {
                            if stat["name"] == "attack" {
                                if let attack = statt["base_stat"] as? Int {
                                    self._attack = "\(attack)"
                                }
                            }
                            
                            if stat["name"] == "defense" {
                                if let defense = statt["base_stat"] as? Int {
                                    self._defense = "\(defense)"
                                }
                            }
                        }
                    } // for statt in stats {
                } //  if let stats = dict["stats"] as? [Dictionary<String, AnyObject>] {
                
                
                
                if let species = dict["species"] as? Dictionary<String, String> {
                    if let URL = species["url"] {
                        Alamofire.request(URL).responseJSON(completionHandler: { (response) in
                            
                            if let dicInternal = response.result.value as? Dictionary<String, AnyObject> {
                                
                                if let flavor_text_entries = dicInternal["flavor_text_entries"] as? [Dictionary<String, AnyObject>] {
                                    
                                    for flavor_text_entry in flavor_text_entries {
                                        
                                        if let language = flavor_text_entry["language"] as? Dictionary<String,String> {
                                            
                                            if let languageName = language["name"] {
                                                if languageName == "en" {
                                                    
                                                    if let description = flavor_text_entry["flavor_text"] as? String {
                                                        let desc = description.replacingOccurrences(of: "\n", with: " ", options: .regularExpression)
                                                        self._description = desc
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    
                                    if let evolution_chain = dicInternal["evolution_chain"] as? Dictionary<String, String> {
                                        if let evolution_chainURL = evolution_chain["url"] {
                                            
                                            Alamofire.request(evolution_chainURL).responseJSON(completionHandler: { (response) in
                                                
                                                if let dicInternalInternal = response.result.value as? Dictionary <String, AnyObject> {
                                                    if let chain = dicInternalInternal["chain"] as? Dictionary<String, AnyObject> {
                                                        self.traversingEvolution(chain: chain)
                                                    }
                                                }
                                                completed()
                                            })
                                        }
                                    } // if let evolution_chain = dicInternal["evolution_chain"] as? Dictionary<String, String> {
                                }
                            }
                            completed()
                        })
                    }
                } //  if let species = dict["species"] as? Dictionary<String, String> {
            }
            completed()
            
        }
    }
    
    
    var foundCurrent = false
    func traversingEvolution (chain: Dictionary<String, AnyObject>) {
        
        if let species = chain["species"] as? Dictionary<String, String> {
            
            if let name = species["name"] {
                
                if (!foundCurrent) {
                    if name == self._name {
                        
                        foundCurrent = true
                    }
                    
                    if let evolves_to = chain["evolves_to"] as? [Dictionary<String, AnyObject>] {
                        
                        if evolves_to.count != 0 {
                            traversingEvolution(chain: evolves_to[0])
                        }
                    }
                    
                    
                }   else    {
                    
                    self._nextEvolutionName = name.capitalized
                    
                    if let evoURL = species["url"] {
                        let start = String.Index(encodedOffset: 42)
                        let end = String.Index(encodedOffset: evoURL.count - 1)
                        let substring = String(evoURL[start..<end])
                        
                        self._nextEvolutionId = substring
                        
                    }
                    
                    if let evoDetails = chain["evolution_details"] as? [Dictionary<String, AnyObject>] {
                        if let nextLevel = evoDetails[0]["min_level"] as? Int {
                            
                            self._nextEvolutionLevel = "\(nextLevel)"
                        }
                    }
                    
                    self._nextEvolutionTxt = "Next Evolution: \(self._nextEvolutionName!) - LVL \(self.nextEvolutionLevel)"
                    
                    print(self._nextEvolutionTxt)
                }
            }
        } // if let species = chain["species"] as? Dictionary<String, String> {
        
    } // func traversingEvolution (chain: Dictionary<String, AnyObject>) {
    
    
    
    
}


