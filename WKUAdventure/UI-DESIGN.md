# WKU sitcom visual-novel UI direction

## Visual target

The game uses a compact sitcom stage on a 960x540 logical canvas. Campus pixel-art backgrounds remain full bleed. Four character sprites occupy stable positions, each with a visible name and job tag. A dark dialogue band protects text contrast without hiding the location. Paper white, coral, teal, gold, brick, blue, and green are functional accents rather than a one-hue theme.

## Screen hierarchy

1. Title: campus location, series title, the four-person premise, and new/load actions.
2. Viewpoint casting: four centered cards with portrait, name, job, current task, and one-line personality hook; a white double glow marks the selected viewpoint.
3. Save slots: three stable rows with empty, overwrite, and resume states.
4. Episode hub: four plot nodes showing the opening, two mutually exclusive investigations, and the convergent finale; people and signal albums remain available here.
5. Story: full-screen background, all four named actors, compact toolbar, dialogue surface, and a two-choice menu.
6. Character album: four stable identity cards so a first-time player can recover names and relationships without leaving the story.
7. Signal reveal: one centered item image, its scene source, description, and explicit clue meaning; it interrupts the script only on first collection.
8. Signal album: four stable slots that reveal the image and clue after collection.
9. Chapter summary: records progress and offers the next unlocked episode.
10. Final truth: names writer, accidental publisher, and recipient; it offers replay rather than implying an unfinished next episode.
11. Backlog: recent dialogue review without leaving the current script checkpoint.

## Interaction and motion

- Selecting a cast card immediately moves the white double outline; character names remain canonical so every line and clue refers to the same person.
- Clicking an incomplete line reveals it; clicking again advances.
- The current speaker stays fully opaque while the other three actors recede.
- Auto mode advances completed lines after a readable delay. Skip accelerates lines seen in the current session.
- Escape or controller Back accepts an active signal reveal before advancing, so the interpreter never remains parked on a hidden signal statement.
- Buttons and fixed-format cards use stable dimensions and explicit normal, selected, and disabled states.

## Responsive contract

The Dora `Camera2D` uses the smaller viewport ratio as a uniform contain/letterbox zoom. Text size never scales with viewport width. Casting cards, actor tags, dialogue controls, signal cards, choices, and save rows remain inside the 960x540 safe area.

