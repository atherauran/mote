import Foundation

struct Note: Identifiable {
    let id: Int
    let time: String
    let text: String
}

struct NoteDay: Identifiable {
    let id: String  // YYYY-MM-DD
    let date: Date
    let notes: [Note]
}

enum NoteStore {
    /// `<project>/notes`, resolved from this source file's location (<project>/app/Sources/Mote/).
    static let directory = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent("notes", isDirectory: true)

    private static let dayFormat = formatter("yyyy-MM-dd")
    private static let timeFormat = formatter("HH:mm")

    private static func formatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = format
        return f
    }

    static func append(_ text: String, at date: Date = .now) throws {
        let flat = text.split(whereSeparator: \.isNewline).joined(separator: " ")
        var line = Data("- \(timeFormat.string(from: date)) \(flat)\n".utf8)
        let url = directory.appendingPathComponent(dayFormat.string(from: date) + ".md")

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        guard FileManager.default.fileExists(atPath: url.path) else {
            try line.write(to: url)
            return
        }
        let handle = try FileHandle(forUpdating: url)
        defer { try? handle.close() }
        let end = try handle.seekToEnd()
        if end > 0 {
            try handle.seek(toOffset: end - 1)
            if try handle.read(upToCount: 1) != Data("\n".utf8) { line.insert(0x0A, at: 0) }
        }
        try handle.write(contentsOf: line)
    }

    /// All days, newest first.
    static func loadDays() -> [NoteDay] {
        let names = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
        return names.compactMap { name -> NoteDay? in
            guard name.hasSuffix(".md") else { return nil }
            let stem = String(name.dropLast(3))
            guard let date = dayFormat.date(from: stem),
                  let content = try? String(contentsOf: directory.appendingPathComponent(name), encoding: .utf8)
            else { return nil }
            let notes = content.split(whereSeparator: \.isNewline).enumerated().compactMap { parse($1, id: $0) }
            return notes.isEmpty ? nil : NoteDay(id: stem, date: date, notes: notes)
        }
        .sorted { $0.id > $1.id }
    }

    /// Parses `- HH:MM text`; any other non-empty line is kept as untimed text.
    private static func parse(_ line: Substring, id: Int) -> Note? {
        var body = line.trimmingCharacters(in: .whitespaces)
        if body.hasPrefix("- ") { body.removeFirst(2) }
        guard !body.isEmpty else { return nil }
        if let match = body.wholeMatch(of: #/(\d{2}:\d{2})\s+(.*)/#) {
            return Note(id: id, time: String(match.1), text: String(match.2))
        }
        return Note(id: id, time: "", text: body)
    }
}
