"""Fill the data placeholders of a reflection in place.

usage: python3 tools/stats.py START END reflections/<file>.html   (dates as YYYY-MM-DD, inclusive)
Fills START_ISO, END_ISO, NOTE_COUNT, ACTIVE_DAYS, TOTAL_DAYS, LONGEST_GAP, PULSE, AXIS_START, AXIS_END.
"""
import datetime as dt
import pathlib
import sys

root = pathlib.Path(__file__).resolve().parent.parent
start, end = (dt.date.fromisoformat(a) for a in sys.argv[1:3])
out = pathlib.Path(sys.argv[3])

days = [start + dt.timedelta(n) for n in range((end - start).days + 1)]
counts = []
for day in days:
    path = root / "notes" / f"{day}.md"
    counts.append(sum(1 for line in path.read_text().splitlines() if line.strip()) if path.exists() else 0)

longest_gap = run = 0
for n in counts:
    run = run + 1 if n == 0 else 0
    longest_gap = max(longest_gap, run)

# One bar per day, or per week when the range is long.
size = 1 if len(days) <= 120 else 7
bars = [(days[i], days[min(i + size, len(days)) - 1], sum(counts[i:i + size])) for i in range(0, len(days), size)]
peak = max(n for _, _, n in bars) or 1

def label(a, b, n):
    when = f"{a}" if a == b else f"{a} – {b}"
    return f'{when} · {n} note{"" if n == 1 else "s"}'

values = {
    "START_ISO": str(start),
    "END_ISO": str(end),
    "NOTE_COUNT": str(sum(counts)),
    "ACTIVE_DAYS": str(sum(n > 0 for n in counts)),
    "TOTAL_DAYS": str(len(days)),
    "LONGEST_GAP": str(longest_gap),
    "PULSE": "".join(f'<i style="--h:{n / peak:.3g};" title="{label(a, b, n)}"></i>' for a, b, n in bars),
    "AXIS_START": start.strftime("%b %-d"),
    "AXIS_END": end.strftime("%b %-d"),
}
html = out.read_text()
for key, value in values.items():
    html = html.replace("{{" + key + "}}", value)
out.write_text(html)
print(f"notes={values['NOTE_COUNT']} active_days={values['ACTIVE_DAYS']} "
      f"total_days={values['TOTAL_DAYS']} longest_gap={longest_gap}")
