import Foundation


// safe wrapper around a path and file descriptor that always closes the FD when no longer in use
// uses fcntl with F_GETPATH to get the new path for an FD that has been moved or renamed
public class ListenFSEventsPath {
  internal var pathURL: URL?
  internal var fd: Int32?


  public var path: String { return self.pathURL!.path }
  public var pathComponents: [String] { return self.pathURL!.pathComponents }
  public var cPath: [CChar] { return self.pathURL!.path.cString(using: String.Encoding.utf8)! }

  public var exists: Bool { return (self.fd != -1 && self.fd != nil) }
  public var isDirectory: Bool { return (self.pathURL?.hasDirectoryPath)! }


  deinit { if (self.fd != -1 && self.fd != nil) {close(self.fd!)} }


  public init(withString inpath: String) throws {
    guard !inpath.isEmpty else { throw ErrNo.EINVAL }

    self.pathURL = nil
    self.fd = nil

    try self.initializeFromPathString(inpath)
  }

  internal func initializeFromPathString(_ inpath: String) throws {
    self.pathURL = URL.init(fileURLWithPath: inpath).standardized
    if (try self.pathURL!.checkResourceIsReachable()) {
      var inPathC = self.pathURL!.path.cString(using: String.Encoding.utf8)!
      self.fd = open(&inPathC, O_EVTONLY)
      if (self.fd == -1) { throw ErrNo(rawValue: errno)! }
    }
  }

  public func updatePath() throws {
    guard let fd = self.fd else { return }
    if (fd == -1) { return }

    var buf = [CChar](repeating: 0, count: Int(MAXPATHLEN))

    if (fcntl(fd, F_GETPATH, &buf)) == -1 {
      throw ErrNo(rawValue: errno)!
    } else {
      let path = String(cString: &buf)
      self.pathURL = URL.init(fileURLWithPath: path).standardized
    }
  }
}
