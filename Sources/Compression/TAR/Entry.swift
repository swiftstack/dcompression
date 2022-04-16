extension TAR {
    public struct Entry {
        public let name: String
        public let mode: Int
        public let uid: Int
        public let gid: Int
        public let size: Int
        public let mtime: String
        public let chksum: String
        public let typeflag: Kind
        public let linkname: String
        public let magic: [UInt8]
        public let version: [UInt8]
        public let uname: [UInt8]
        public let gname: [UInt8]
        public let devmajor: [UInt8]
        public let devminor: [UInt8]
        public let prefix: [UInt8]
        public let descriptor: [UInt8]

        public let data: [UInt8]
    }
}
