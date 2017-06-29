import CoreServices
import Foundation


public struct ListenFSEventsEventID: Hashable {
  public let rawValue: FSEventStreamEventId

  public init(rawValue: FSEventStreamEventId) { self.rawValue = rawValue }
  public init(rawValue: Int) { self.rawValue = FSEventStreamEventId(rawValue) }
  public init(rawValue: UInt) { self.rawValue = FSEventStreamEventId(rawValue) }

  public var hashValue: Int { return rawValue.hashValue }
}

public func == (a: ListenFSEventsEventID, b: ListenFSEventsEventID) -> Bool {
  return a.rawValue == b.rawValue
}

extension ListenFSEventsEventID {
  // magic number that always means now when passed as an argument
  public static var now: ListenFSEventsEventID {
    return ListenFSEventsEventID(rawValue: kFSEventStreamEventIdSinceNow)
  }

  // actual current (global) event ID
  public static var current: ListenFSEventsEventID {
    return ListenFSEventsEventID(rawValue: FSEventsGetCurrentEventId())
  }
}

extension ListenFSEventsEventID: OTNetStringConvertable {
  var OTNetString: String { return self.rawValue.OTNetString }
}


public struct ListenFSEventsEvent {
  public var path: String
  public var id: ListenFSEventsEventID
  public var flags: ListenFSEventsEventFlags

  public init(path: String, id: FSEventStreamEventId, flags: FSEventStreamEventFlags) {
    self.path = path
    self.id = ListenFSEventsEventID(rawValue: id)
    self.flags = ListenFSEventsEventFlags(rawValue: flags)
  }
}

extension ListenFSEventsEvent: OTNetStringConvertable {
  var OTNetString: String {
    let netstrings =  "\("path".OTNetString)\(self.path.OTNetString)" +
                      "\("id".OTNetString)\(self.id.OTNetString)" +
                      "\("flags".OTNetString)\(self.flags.OTNetString)"
    let len = netstrings.lengthOfBytes(using: String.Encoding.utf8)
    return "\(len){\(netstrings.utf8)"
  }
}
