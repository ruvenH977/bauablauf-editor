# Bauablauf Editor

Interactive tool for producing branded construction-timeline pages for client projects.
Left pane is the form, right pane is a live preview; the finished timeline exports as a
standalone HTML file or a PDF.

**Live tool:** https://ruvenH977.github.io/bauablauf-editor/

## What it does

- Two brand skins: **MDH** (dark / copper) and **freshhaus** (light / lime), switchable at any time.
- Milestones (Werkvertrag, Bestätigung, Planversand, Baubeginn) positioned by calendar week + year.
- **Bemusterungstage** as either a single KW or a KW range.
- Automatic "Heute" indicator, year-change marker, and phase durations calculated from the dates.
- Fine positioning sliders for the Bemusterungstage and year-marker labels, for the cases where
  a label would otherwise collide with a milestone card.
- Export as **HTML** (self-contained, keeps the animations, works offline) or **PDF**
  (single page, sized to the timeline's own proportions).

## Client data

This repository is public. **No client data belongs in it.**

The defaults in the editor are deliberately generic ("Musterprojekt", "Familie Muster") —
please keep them that way. Real project names, addresses and schedules are entered in the
browser at the time you build a timeline; nothing you type is sent anywhere or stored in the
repo. Exported files land in your Downloads folder and are covered by `.gitignore` in case
one ever gets saved in here by accident.

## Usage

Open the live tool (link above), fill in the form, and use the export buttons at the bottom
of the left pane. Nothing is installed and nothing is uploaded — everything runs in your browser.

The exported HTML file is fully self-contained: send it to a client, open it offline, or put it
anywhere. The PDF is intended for print and for attaching to correspondence.

## Local development

The whole tool is a single file, `index.html`, with no build step and no dependencies to install.

To work on it, serve the folder over HTTP rather than opening the file directly — the PDF export
renders through an iframe, which browsers restrict on `file://` URLs:

```bash
python3 -m http.server 8000
# then open http://localhost:8000
```

Edit `index.html` and reload. Structure inside the file:

- `RUNTIME_JS` — the JavaScript embedded into every generated timeline (drag-scroll, keyboard
  navigation, "Heute" dot, marker positioning).
- `MARKER_CSS` / `MARKER_CSS_MOBILE` — marker styling shared by both skins.
- `buildMDH()` / `buildFH()` — the two skins; each returns a complete standalone document.
- `buildTimelineBody()` — the shared timeline markup both skins use.
- The editor's own wiring (`state`, `readForm()`, `render()`) is at the bottom.

Two external libraries are loaded from cdnjs for the PDF export only — `html2canvas` and `jsPDF`.
The rest, including both logos, is inline, so a generated timeline has no runtime dependency
on this repo or on any CDN.

### A note on editing `RUNTIME_JS`

That block is a JavaScript template literal that gets written into the generated file inside a
`<script>` tag. Any literal `</script>` inside it would terminate the tag early and truncate the
output, so closing tags in there are written escaped, as `<\/script>`. Keep it that way.

## Deployment

GitHub Pages serves this repository directly from the default branch — there is no build
pipeline. Push to `main` and the change is live within a minute or so.

Settings → Pages → Source: *Deploy from a branch*, branch `main`, folder `/ (root)`.

### Publishing a change

Double-click **`publish.cmd`**. It stages everything, asks for a commit message (Enter
accepts a default), and pushes. It adds the `origin` remote by itself the first time, and
uses `-u` on the first push so later ones need no arguments. VS Code's Sync button in the
Source Control panel does the same job.

The very first push must happen from Windows so that Git Credential Manager can store your
GitHub credentials; every push after that runs without prompting.
