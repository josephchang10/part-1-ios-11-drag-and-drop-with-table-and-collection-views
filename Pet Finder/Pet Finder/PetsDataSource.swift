//
//  PetsDataSource.swift
//  Pet Finder
//
//  Created by 张嘉夫 on 2017/6/9.
//  Copyright © 2017年 张嘉夫. All rights reserved.
//

import UIKit
import Pets
import MobileCoreServices

class PetsDataSource: NSObject, UITableViewDataSource {

  var pets: [Pet]

  init(pets: [Pet]) {
    self.pets = pets
    super.init()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pets.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "PetCell", for: indexPath)
    let pet = pets[indexPath.row]

    cell.imageView?.image = pet.image
    cell.imageView?.layer.masksToBounds = true
    cell.imageView?.layer.cornerRadius = 5
    cell.detailTextLabel?.text = pets[indexPath.row].type
    cell.textLabel?.text = pets[indexPath.row].name

    return cell
  }

  func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
    guard sourceIndex != destinationIndex else { return }

    let pet = pets[sourceIndex]
    pets.remove(at: sourceIndex)
    pets.insert(pet, at: destinationIndex)
  }

  func addPet(_ newPet: Pet, at index: Int) {
    pets.insert(newPet, at: index)
  }
    
  func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
    let pet = pets[indexPath.row]
        
    let itemProvider = NSItemProvider()
    itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypeUTF8PlainText as String, visibility: .all, loadHandler: { completion in
        
        let data = pet.name.data(using: .utf8)
        completion(data, nil)
        return nil
        
    })
    
    let dragItem = UIDragItem(itemProvider: itemProvider)
    dragItem.localObject = pet
    return [dragItem]
  }
}
