import ServiceManagement
import SwiftUI

struct NotesView: View {
    let days: [NoteDay]
    let onNewNote: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if days.isEmpty {
                Text("No notes yet. Press ⌥Space to capture one.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        ForEach(days) { day in
                            DaySection(day: day)
                        }
                    }
                    .padding(16)
                }
            }
            Divider()
            footer
        }
        .frame(width: 380, height: 480)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button(action: onNewNote) { Image(systemName: "square.and.pencil") }
                .help("New note (⌥Space)")
            Button { NSWorkspace.shared.open(NoteStore.directory) } label: { Image(systemName: "folder") }
                .help("Open notes folder")
            Spacer()
            Menu {
                Toggle("Open at Login", isOn: Binding(
                    get: { SMAppService.mainApp.status == .enabled },
                    set: { on in try? on ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister() }
                ))
                Divider()
                Button("Quit Mote") { NSApp.terminate(nil) }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
    }
}

private struct DaySection: View {
    let day: NoteDay

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(day.notes.reversed()) { note in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(note.time)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .frame(width: 38, alignment: .leading)
                    Text(note.text)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var title: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(day.date) { return "Today" }
        if calendar.isDateInYesterday(day.date) { return "Yesterday" }
        if calendar.isDate(day.date, equalTo: .now, toGranularity: .year) {
            return day.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        }
        return day.date.formatted(.dateTime.month(.abbreviated).day().year())
    }
}
