import Foundation


protocol OTNetStringConvertable { var OTNetString: String { get } }


extension String: OTNetStringConvertable {
  var OTNetString: String {
    let len = self.lengthOfBytes(using: String.Encoding.utf8)
    return "\(len),\(self.utf8)"
  }
}

extension Int: OTNetStringConvertable {
  var OTNetString: String {
    let strnum = "\(self)"
    let len = strnum.lengthOfBytes(using: String.Encoding.utf8)
    return "\(len)#\(strnum.utf8)"
  }
}

extension UInt: OTNetStringConvertable {
  var OTNetString: String {
    let strnum = "\(self)"
    let len = strnum.lengthOfBytes(using: String.Encoding.utf8)
    return "\(len)#\(strnum.utf8)"
  }
}

extension UInt32: OTNetStringConvertable {
  var OTNetString: String {
    let strnum = "\(self)"
    let len = strnum.lengthOfBytes(using: String.Encoding.utf8)
    return "\(len)#\(strnum.utf8)"
  }
}

extension UInt64: OTNetStringConvertable {
  var OTNetString: String {
    let strnum = "\(self)"
    let len = strnum.lengthOfBytes(using: String.Encoding.utf8)
    return "\(len)#\(strnum.utf8)"
  }
}

extension Bool: OTNetStringConvertable {
  var OTNetString: String {
    if self == true {
      return "4!true"
    } else {
      return "5!false"
    }
  }
}

extension Array where Iterator.Element: OTNetStringConvertable {
  var OTNetString: String {
    let netstrings: String = self.map { $0.OTNetString }.joined(separator: "")
    let len = netstrings.lengthOfBytes(using: String.Encoding.utf8)
    return "\(len)[\(netstrings.utf8)"
  }
}

extension Dictionary where Key: OTNetStringConvertable, Value: OTNetStringConvertable {
  var OTNetString: String {
    var netstrings: String = ""
    for (key, value) in self {
      netstrings += key.OTNetString
      netstrings += value.OTNetString
    }
    let len = netstrings.lengthOfBytes(using: String.Encoding.utf8)
    return "\(len){\(netstrings)"
  }
}

