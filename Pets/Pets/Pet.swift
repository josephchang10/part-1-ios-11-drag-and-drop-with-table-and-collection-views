//
//  Pets.swift
//  Pets
//
//  Created by 张嘉夫 on 2017/6/9.
//  Copyright © 2017年 张嘉夫. All rights reserved.
//

import MobileCoreServices
import UIKit

private enum Key {
  static let name = "name"
  static let type = "type"
  static let image = "image"
}

enum EncodingError: Error {
  case invalidData
}

public class Pet : NSObject, NSCoding {

  public var name: String
  public var type: String
  public var image: UIImage?

  public init(name: String, type: String, image: UIImage?) {
    self.name = name
    self.type = type
    self.image = image
    super.init()
  }

  required public convenience init?(coder: NSCoder) {
    guard let name = coder.decodeObject(forKey: Key.name) as? String,
      let type = coder.decodeObject(forKey: Key.type) as? String,
      let image = (coder.decodeObject(forKey: Key.image) as? Data).flatMap(UIImage.init)
    else {
      return nil
    }
    self.init(name: name, type: type, image: image)
  }

  public func encode(with coder: NSCoder) {
    coder.encode(name, forKey: Key.name)
    coder.encode(type, forKey: Key.type)
    if let image = image {
      coder.encode(UIImagePNGRepresentation(image), forKey: Key.image)
    }
  }
    
    public static func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

}




