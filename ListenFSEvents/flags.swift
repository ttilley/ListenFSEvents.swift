import CoreServices
import Foundation


public struct ListenFSEventsCreateFlags: OptionSet {
  public let rawValue: FSEventStreamCreateFlags
  public init(rawValue: FSEventStreamCreateFlags) { self.rawValue = rawValue }
  init(rawValue: Int) { self.rawValue = FSEventStreamCreateFlags(extendingOrTruncating: rawValue) }

  static let None = ListenFSEventsCreateFlags(rawValue: 0x00000000)

  /*
   * The framework will invoke your callback function with CF types
   * rather than raw C types (i.e., a CFArrayRef of CFStringRefs,
   * rather than a raw C array of raw C string pointers). See
   * FSEventStreamCallback.
   */
  static let UseCFTypes = ListenFSEventsCreateFlags(rawValue: 0x00000001)

  /*
   * Affects the meaning of the latency parameter. If you specify this
   * flag and more than latency seconds have elapsed since the last
   * event, your app will receive the event immediately. The delivery
   * of the event resets the latency timer and any further events will
   * be delivered after latency seconds have elapsed. This flag is
   * useful for apps that are interactive and want to react immediately
   * to changes but avoid getting swamped by notifications when changes
   * are occurringin rapid succession. If you do not specify this flag,
   * then when an event occurs after a period of no events, the latency
   * timer is started. Any events that occur during the next latency
   * seconds will be delivered as one group (including that first
   * event). The delivery of the group of events resets the latency
   * timer and any further events will be delivered after latency
   * seconds. This is the default behavior and is more appropriate for
   * background, daemon or batch processing apps.
   */
  static let NoDefer = ListenFSEventsCreateFlags(rawValue: 0x00000002)

  /*
   * Request notifications of changes along the path to the path(s)
   * you're watching. For example, with this flag, if you watch
   * "/foo/bar" and it is renamed to "/foo/bar.old", you would receive
   * a RootChanged event. The same is true if the directory "/foo" were
   * renamed. The event you receive is a special event: the path for
   * the event is the original path you specified, the flag
   * kFSEventStreamEventFlagRootChanged is set and event ID is zero.
   * RootChanged events are useful to indicate that you should rescan a
   * particular hierarchy because it changed completely (as opposed to
   * the things inside of it changing). If you want to track the
   * current location of a directory, it is best to open the directory
   * before creating the stream so that you have a file descriptor for
   * it and can issue an F_GETPATH fcntl() to find the current path.
   */
  static let WatchRoot = ListenFSEventsCreateFlags(rawValue: 0x00000004)

  /*
   * Don't send events that were triggered by the current process. This
   * is useful for reducing the volume of events that are sent. It is
   * only useful if your process might modify the file system hierarchy
   * beneath the path(s) being monitored. Note: this has no effect on
   * historical events, i.e., those delivered before the HistoryDone
   * sentinel event.  Also, this does not apply to RootChanged events
   * because the WatchRoot feature uses a separate mechanism that is
   * unable to provide information about the responsible process.
   */
  //  @available(macOS, introduced: 10.6)
  //  @available(iOS, introduced: 6.0)
  static let IgnoreSelf = ListenFSEventsCreateFlags(rawValue: 0x00000008)

  /*
   * Request file-level notifications.  Your stream will receive events
   * about individual files in the hierarchy you're watching instead of
   * only receiving directory level notifications.  Use this flag with
   * care as it will generate significantly more events than without it.
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let FileEvents = ListenFSEventsCreateFlags(rawValue: 0x00000010)

  /*
   * Tag events that were triggered by the current process with the "OwnEvent" flag.
   * This is only useful if your process might modify the file system hierarchy
   * beneath the path(s) being monitored and you wish to know which events were
   * triggered by your process. Note: this has no effect on historical events, i.e.,
   * those delivered before the HistoryDone sentinel event.
   */
  //  @available(macOS, introduced: 10.9)
  //  @available(iOS, introduced: 7.0)
  static let MarkSelf = ListenFSEventsCreateFlags(rawValue: 0x00000020)

  /*
   * Requires kFSEventStreamCreateFlagUseCFTypes and instructs the
   * framework to invoke your callback function with CF types but,
   * instead of passing it a CFArrayRef of CFStringRefs, a CFArrayRef of
   * CFDictionaryRefs is passed.  Each dictionary will contain the event
   * path and possibly other "extended data" about the event.  See the
   * kFSEventStreamEventExtendedData*Key definitions for the set of keys
   * that may be set in the dictionary.  (See also FSEventStreamCallback.)
   */
  //  @available(macOS, introduced: 10.13)
  //  @available(iOS, introduced: 11.0)
  static let UseExtendedData = ListenFSEventsCreateFlags(rawValue: 0x00000040)

  static let defaults : ListenFSEventsCreateFlags = [.UseCFTypes, .WatchRoot, .FileEvents, .MarkSelf]
}

extension ListenFSEventsCreateFlags: Hashable, CustomStringConvertible, LosslessStringConvertible {
  public var hashValue: Int { return rawValue.hashValue }

  public static func getNameMapping() -> [ListenFSEventsCreateFlags: String] {
    return [
      .None:                "None",
      .UseCFTypes:          "UseCFTypes",
      .NoDefer:             "NoDefer",
      .WatchRoot:           "WatchRoot",
      .IgnoreSelf:          "IgnoreSelf",
      .FileEvents:          "FileEvents",
      .MarkSelf:            "MarkSelf",
      .UseExtendedData:     "UseExtendedData"
    ]
  }

  public var description: String {
    let nameMap : Dictionary<ListenFSEventsCreateFlags, String> = ListenFSEventsCreateFlags.getNameMapping()
    let mapped = nameMap.filter({ contains($0.key) }).map({ $0.value })
    return "[\(mapped.joined(separator: ","))]"
  }

  public init?(_ description: String) {
    var result : ListenFSEventsCreateFlags = .None
    let nameMap : Dictionary<ListenFSEventsCreateFlags, String> = ListenFSEventsCreateFlags.getNameMapping()
    var desc : String = description
    desc.remove(at: desc.startIndex)
    desc.remove(at: desc.index(before: desc.endIndex))
    let names: [String] = desc.components(separatedBy: ",")
    let flags = nameMap.filter({ names.contains($0.value) }).map({ $0.key })
    flags.forEach { (flag) in result.insert(flag) }
    self.init(rawValue: result.rawValue)
  }
}

public struct ListenFSEventsEventFlags: OptionSet {
  public let rawValue: FSEventStreamEventFlags
  public init(rawValue: FSEventStreamEventFlags) { self.rawValue = rawValue }
  init(rawValue: Int) { self.rawValue = FSEventStreamEventFlags(extendingOrTruncating: rawValue) }

  static let None = ListenFSEventsEventFlags(rawValue: 0x00000000)

  /*
   * Your application must rescan not just the directory given in the
   * event, but all its children, recursively. This can happen if there
   * was a problem whereby events were coalesced hierarchically. For
   * example, an event in /Users/jsmith/Music and an event in
   * /Users/jsmith/Pictures might be coalesced into an event with this
   * flag set and path=/Users/jsmith. If this flag is set you may be
   * able to get an idea of whether the bottleneck happened in the
   * kernel (less likely) or in your client (more likely) by checking
   * for the presence of the informational flags
   * kFSEventStreamEventFlagUserDropped or
   * kFSEventStreamEventFlagKernelDropped.
   */
  static let MustScanSubDirs = ListenFSEventsEventFlags(rawValue: 0x00000001)

  /*
   * The kFSEventStreamEventFlagUserDropped or
   * kFSEventStreamEventFlagKernelDropped flags may be set in addition
   * to the kFSEventStreamEventFlagMustScanSubDirs flag to indicate
   * that a problem occurred in buffering the events (the particular
   * flag set indicates where the problem occurred) and that the client
   * must do a full scan of any directories (and their subdirectories,
   * recursively) being monitored by this stream. If you asked to
   * monitor multiple paths with this stream then you will be notified
   * about all of them. Your code need only check for the
   * kFSEventStreamEventFlagMustScanSubDirs flag; these flags (if
   * present) only provide information to help you diagnose the problem.
   */
  static let UserDropped = ListenFSEventsEventFlags(rawValue: 0x00000002)
  static let KernelDropped = ListenFSEventsEventFlags(rawValue: 0x00000004)

  /*
   * If kFSEventStreamEventFlagEventIdsWrapped is set, it means the
   * 64-bit event ID counter wrapped around. As a result,
   * previously-issued event ID's are no longer valid arguments for the
   * sinceWhen parameter of the FSEventStreamCreate...() functions.
   */
  static let EventIDsWrapped = ListenFSEventsEventFlags(rawValue: 0x00000008)

  /*
   * Denotes a sentinel event sent to mark the end of the "historical"
   * events sent as a result of specifying a sinceWhen value in the
   * FSEventStreamCreate...() call that created this event stream. (It
   * will not be sent if kFSEventStreamEventIdSinceNow was passed for
   * sinceWhen.) After invoking the client's callback with all the
   * "historical" events that occurred before now, the client's
   * callback will be invoked with an event where the
   * kFSEventStreamEventFlagHistoryDone flag is set. The client should
   * ignore the path supplied in this callback.
   */
  static let HistoryDone = ListenFSEventsEventFlags(rawValue: 0x00000010)

  /*
   * Denotes a special event sent when there is a change to one of the
   * directories along the path to one of the directories you asked to
   * watch. When this flag is set, the event ID is zero and the path
   * corresponds to one of the paths you asked to watch (specifically,
   * the one that changed). The path may no longer exist because it or
   * one of its parents was deleted or renamed. Events with this flag
   * set will only be sent if you passed the flag
   * kFSEventStreamCreateFlagWatchRoot to FSEventStreamCreate...() when
   * you created the stream.
   */
  static let RootChanged = ListenFSEventsEventFlags(rawValue: 0x00000020)

  /*
   * Denotes a special event sent when a volume is mounted underneath
   * one of the paths being monitored. The path in the event is the
   * path to the newly-mounted volume. You will receive one of these
   * notifications for every volume mount event inside the kernel
   * (independent of DiskArbitration). Beware that a newly-mounted
   * volume could contain an arbitrarily large directory hierarchy.
   * Avoid pitfalls like triggering a recursive scan of a non-local
   * filesystem, which you can detect by checking for the absence of
   * the MNT_LOCAL flag in the f_flags returned by statfs(). Also be
   * aware of the MNT_DONTBROWSE flag that is set for volumes which
   * should not be displayed by user interface elements.
   */
  static let Mount = ListenFSEventsEventFlags(rawValue: 0x00000040)

  /*
   * Denotes a special event sent when a volume is unmounted underneath
   * one of the paths being monitored. The path in the event is the
   * path to the directory from which the volume was unmounted. You
   * will receive one of these notifications for every volume unmount
   * event inside the kernel. This is not a substitute for the
   * notifications provided by the DiskArbitration framework; you only
   * get notified after the unmount has occurred. Beware that
   * unmounting a volume could uncover an arbitrarily large directory
   * hierarchy, although Mac OS X never does that.
   */
  static let Unmount = ListenFSEventsEventFlags(rawValue: 0x00000080)

  /*
   * A file system object was created at the specific path supplied in this event.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let ItemCreated = ListenFSEventsEventFlags(rawValue: 0x00000100)

  /*
   * A file system object was removed at the specific path supplied in this event.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let ItemRemoved = ListenFSEventsEventFlags(rawValue: 0x00000200)

  /*
   * A file system object at the specific path supplied in this event had its metadata modified.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let InodeMetaMod = ListenFSEventsEventFlags(rawValue: 0x00000400)

  /*
   * A file system object was renamed at the specific path supplied in this event.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let ItemRenamed = ListenFSEventsEventFlags(rawValue: 0x00000800)

  /*
   * A file system object at the specific path supplied in this event had its data modified.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let ItemModified = ListenFSEventsEventFlags(rawValue: 0x00001000)

  /*
   * A file system object at the specific path supplied in this event had its FinderInfo data modified.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let ItemFinderInfoMod = ListenFSEventsEventFlags(rawValue: 0x00002000)

  /*
   * A file system object at the specific path supplied in this event had its ownership changed.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let ItemChangeOwner = ListenFSEventsEventFlags(rawValue: 0x00004000)

  /*
   * A file system object at the specific path supplied in this event had its extended attributes modified.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let ItemXattrMod = ListenFSEventsEventFlags(rawValue: 0x00008000)

  /*
   * The file system object at the specific path supplied in this event is a regular file.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let ItemIsFile = ListenFSEventsEventFlags(rawValue: 0x00010000)

  /*
   * The file system object at the specific path supplied in this event is a directory.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let ItemIsDir = ListenFSEventsEventFlags(rawValue: 0x00020000)

  /*
   * The file system object at the specific path supplied in this event is a symbolic link.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let ItemIsSymlink = ListenFSEventsEventFlags(rawValue: 0x00040000)

  /*
   * Indicates the event was triggered by the current process.
   * (This flag is only ever set if you specified the MarkSelf flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.7)
  //  @available(iOS, introduced: 6.0)
  static let OwnEvent = ListenFSEventsEventFlags(rawValue: 0x00080000)

  /*
   * Indicates the object at the specified path supplied in this event is a hard link.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.10)
  //  @available(iOS, introduced: 9.0)
  static let ItemIsHardlink = ListenFSEventsEventFlags(rawValue: 0x00100000)

  /* Indicates the object at the specific path supplied in this event was the last hard link.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.10)
  //  @available(iOS, introduced: 9.0)
  static let ItemIsLastHardlink = ListenFSEventsEventFlags(rawValue: 0x00200000)

  /*
   * The file system object at the specific path supplied in this event is a clone or was cloned.
   * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
   */
  //  @available(macOS, introduced: 10.13)
  //  @available(iOS, introduced: 11.0)
  static let ItemCloned = ListenFSEventsEventFlags(rawValue: 0x00400000)
}

extension ListenFSEventsEventFlags: Hashable, CustomStringConvertible, LosslessStringConvertible {
  public var hashValue: Int { return rawValue.hashValue }

  public static func getNameMapping() -> [ListenFSEventsEventFlags: String] {
    return [
      .None:                    "None",
      .MustScanSubDirs:         "MustScanSubDirs",
      .UserDropped:             "UserDropped",
      .KernelDropped:           "KernelDropped",
      .EventIDsWrapped:         "EventIDsWrapped",
      .HistoryDone:             "HistoryDone",
      .RootChanged:             "RootChanged",
      .Mount:                   "Mount",
      .Unmount:                 "Unmount",
      .ItemCreated:             "ItemCreated",
      .ItemRemoved:             "ItemRemoved",
      .InodeMetaMod:            "InodeMetaMod",
      .ItemRenamed:             "ItemRenamed",
      .ItemModified:            "ItemModified",
      .ItemFinderInfoMod:       "ItemFinderInfoMod",
      .ItemChangeOwner:         "ItemChangeOwner",
      .ItemXattrMod:            "ItemXattrMod",
      .ItemIsFile:              "ItemIsFile",
      .ItemIsDir:               "ItemIsDir",
      .ItemIsSymlink:           "ItemIsSymlink",
      .OwnEvent:                "OwnEvent",
      .ItemIsHardlink:          "ItemIsHardlink",
      .ItemIsLastHardlink:      "ItemIsLastHardlink",
      .ItemCloned:              "ItemCloned"
    ]
  }

  public var description: String {
    let nameMap = ListenFSEventsEventFlags.getNameMapping()
    let mapped = nameMap.filter({ contains($0.key) }).map({ $0.value })
    return "[\(mapped.joined(separator: ","))]"
  }

  public init?(_ description: String) {
    var result : ListenFSEventsEventFlags = .None
    let nameMap : Dictionary<ListenFSEventsEventFlags, String> = ListenFSEventsEventFlags.getNameMapping()
    var desc : String = description
    desc.remove(at: desc.startIndex)
    desc.remove(at: desc.index(before: desc.endIndex))
    let names: [String] = desc.components(separatedBy: ",")
    let flags = nameMap.filter({ names.contains($0.value) }).map({ $0.key })
    flags.forEach { (flag) in result.insert(flag) }
    self.init(rawValue: result.rawValue)
  }
}

extension ListenFSEventsEventFlags: OTNetStringConvertable {
  var OTNetString: String {
    let nameMap = ListenFSEventsEventFlags.getNameMapping()
    let mapped = nameMap.filter({ contains($0.key) }).map({ $0.value }).OTNetString
    let cflag = self.rawValue.OTNetString
    let netstrings = "\("cflag".OTNetString)\(cflag)\("named".OTNetString)\(mapped)"
    let len = netstrings.lengthOfBytes(using: String.Encoding.utf8)
    return "\(len){\(netstrings.utf8)"
  }
}

