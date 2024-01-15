import Test
import Stream
import FileSystem
import DCompression

test("tar archive") {
    let path = try Path(#filePath)
        .deletingLastComponent
        .appending("archive.tgz")

    let stream = try File(at: path).open().inputStream
    let items = try await TAR.decode(from: stream, compression: .gzip)

    guard items.count == 3 else {
        fail("invalid items count")
        return
    }

    expect(items[0].name == "folder/")
    expect(items[0].typeflag == .directory)
    expect(items[0].size == 0)

    expect(items[1].name == "folder/file2")
    expect(items[1].typeflag == .file)
    expect(items[1].size == 16)

    expect(items[2].name == "folder/file1")
    expect(items[2].typeflag == .file)
    expect(items[2].size == 8)
}

await run()
