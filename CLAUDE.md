# Mote

A menu bar app captures my passing thoughts into `notes/YYYY-MM-DD.md` (one line each, `- HH:MM text`). When I ask, you read them and write a reflection.

```
app/                      the Swift menu bar app (./app/build.sh builds, installs to /Applications and relaunches it)
notes/                    my notes; read-only for you (git-ignored, like reflections/)
template/reflection.html  the reflection template, reused unchanged
template/index.html       blank index, copied to reflections/ if that has none
tools/stats.py            fills the template's numbers and rhythm chart
reflections/              YYYY-MM-DD_<period>.html, plus index.html
```

## Writing a reflection

The point is to show me what I can't see from inside the period. A summary of my notes isn't that; I wrote them. What I miss is the shape across weeks: what keeps returning, what quietly disappeared, where my attention went versus where I said it should go, which ideas have been circling for months, and how this period differs from the last one.

### Reading

Read every note in the range before writing anything, then read it again with questions in mind. What recurs on separate days? What got more specific over time, and what stayed vague? What started and stopped? What changed in tone? When do I write (late at night, weekdays only), and does that mean anything? Where do two notes pull against each other? What would I expect to see that isn't there?

Weigh by evidence. A topic that shows up on eight separate days matters more than one long note, but a single note can matter if it records a decision, a turn, or something said with unusual force. The notes are fragments written in passing, so silence on a topic is worth noticing but proves nothing.

Read the previous reflection (the newest one in `reflections/`). For Resurfaced, search the whole archive, not just the range.

### The sections

Not every section earns its place every time. Leave out any that the notes don't support.

- **Headline**: the single truest sentence about the period, specific enough that it couldn't describe any other month.
- **Summary**: two to four sentences on the shape of the period.
- **Themes**: usually two to four. Name each precisely ("Second-guessing the rewrite", not "Work"). Tell its arc: when it appeared, how it moved, where it stands now. Quote the notes that carry the arc, often the first one, the turning point and the latest.
- **Resurfaced**: an older note that connects to a newer one. It's most valuable when it brings back something I've forgotten: an old idea that answers a current problem, a worry that did or didn't come true, an earlier version of a thought I'm having now. Only use connections that are really there.
- **Worth acting on**: at most three. Prefer ideas that keep returning, have grown more specific, and are small enough to start. Give a next step I could do this week. Don't invent projects the notes don't point toward.
- **Open loops**: things I said I'd do, decide, ask or check, with no follow-up. The point is to let me close them or drop them on purpose, not to scold.
- **Since last time**: what grew, faded or appeared compared with the previous reflection. Whether its ideas and loops show any follow-through in the notes. Whether the notes answer its question.
- **A question**: the one thing I most need to think about. Ground it in a specific tension in the notes. It should be hard to answer, not rhetorical, and not generic.

### Voice

Write to me as "you", plainly and directly, like a perceptive friend who has read everything and isn't trying to make me feel good or bad. Honest over flattering: name avoidance, repetition without progress, and stated priorities that got no attention. No therapy-speak, no pep talk, no advice the notes don't call for.

Ground everything in the notes. Quote verbatim, with dates, when the exact words matter. Keep interpretation recognisable as interpretation, and never fill gaps with invented detail.

Aim for about a five-minute read (~1000 words including quotes). A thin period gets a short reflection; if there's too little to say anything real, tell me instead of padding. Write in the language I mostly used in that period; quotes stay in their original language.

## Mechanics

1. **Range.** Inclusive dates; it ends today unless I name a calendar period. Slugs: `30d`, `3m`, `1y`, `2026-09`, `2026-q3`. The output is `reflections/<today>_<slug>.html`; a rerun overwrites the file and its index entry.
2. `cp template/reflection.html reflections/<file>.html`, then `python3 tools/stats.py START END reflections/<file>.html`.
3. Replace the remaining `{{PLACEHOLDERS}}` without changing anything else in the file. An empty section (or question) is hidden automatically. Escape `& < >` in note text. At the end, `grep '{{'` should find nothing.
4. Add the entry to `reflections/index.html` (copy it from `template/index.html` if missing) directly below the `ENTRIES` comment, then `open` the reflection.

| Placeholder | Content |
|---|---|
| `LANG` | `en` or `zh-CN` |
| `DATE` | today, `Oct 4, 2026` |
| `PERIOD_LABEL` | `Last 30 days`, `Last 3 months`, `September 2026`… |
| `RANGE_START`, `RANGE_END` | `Sep 5`, `Oct 4, 2026` (year on the start only if it differs) |
| `HEADLINE` | plain text |
| `SUMMARY` | `<p>`s |
| `THEMES` `RESURFACED` `IDEAS` `OPEN_LOOPS` `CHANGES` `QUESTION` | markup below |
| `PREVIOUS` | `<a href="2026-09-04_30d.html">← Last 30 days, Sep 4</a>`, or empty |

Markup the template styles (plain `<p>`, `<em>` and so on also work anywhere):

```html
<!-- a quoted note; add the year to the label if it isn't RANGE_END's year -->
<p class="note"><time datetime="2026-09-06T08:14">Sep 6 · 08:14</time>exact text</p>

<!-- THEMES: one div per theme; data-dates lists every date it came up (repeats are fine), drawn as a timeline -->
<div class="theme">
  <h3>Name</h3>
  <div class="track" data-dates="2026-09-06 2026-09-14 2026-10-01"></div>
  <p class="span">Sep 6 – Oct 1 · 9 notes</p>
  <p>…</p>  notes…
</div>

<!-- RESURFACED: earlier note, then later; the "N months later" label is added automatically -->
<div class="pair">  note  note  <p class="why">…</p></div>

<!-- IDEAS: numbered automatically -->
<div class="idea"><h3>…</h3>  notes, <p>…</p>  <p class="next"><b>Next step</b>…</p></div>

<!-- OPEN_LOOPS -->
<ul class="plain"><li>  note  <p>…</p></li></ul>

<!-- QUESTION -->
<p>The question?</p><p class="context">What prompted it.</p>
```

Index entry:

```html
<li><a href="2026-10-04_30d.html"><span class="date">Oct 4, 2026<span class="period">Last 30 days</span></span><span class="headline">HEADLINE</span></a></li>
```
