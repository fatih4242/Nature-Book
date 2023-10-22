//
//  DatabaseHelper.swift
//  NatureBook
//
//  Created by Fatih Toker on 19.10.2023.
//

import Foundation

struct DatabaseHelper{
    
    struct Gallery {
        static let entityName = "Gallery"
        static let id = "id"
        static let name = "name"
        static let place = "place"
        static let image = "image"
        static let year = "year"
    }
    
    struct GalleryModel {
        var id: UUID
        var name: String
        var place: String
        var image: Data
        var year: Int
    }
    
}
