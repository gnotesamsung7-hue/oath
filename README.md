# The Oath of the Last Survivors: Act I

A narrative JRPG built in Godot 4.3 (GDScript, portrait, Android-first).
All characters, beasts, maps, cutscene drawings and UI are made in code, so there are no image assets to manage.

## What's playable
- **Chapter 1: The Lantern Night.** The festival in Hollowmere, then the Syndicate raid. Find and name the four heroes, take Brannoc's shield, and escape the drainage tunnels past Sgt. Kess.
- **Chapter 2: The First Fire.** The Oath scene, then your first camp.
- **Chapter 3: The Reach.** An open wild area with roaming enemies, camps, caches, Rook's ambush and the Wandering Bazaar (Tamsin's shop). The optional Ashwolf Alpha in the north woods can be tamed.

## Systems
- Tap to walk. The party follows the leader. Enemies are visible on the map: touch them from behind for a first strike. Weak groups are auto-won.
- Battles use a turn timeline (next 8 turns), timed hits and parries (or Auto timing), Mark's intercept prompt, morale and Break, the shared Vow Shield, the Resonance Gauge with all six Chain Arts, and the Ashwolf call once tamed.
- Camp gives 3 evening actions: bond talks (12 sibling vignettes that strengthen Chain Arts) or cooking (3-battle buffs). Resting heals and saves.
- Cutscenes are Leonardo-style notebook pages that ink themselves in, with mirror-written margin notes.
- Autosave on area change and after battles. Settings: timing, battle speed, story marker.

## Build the APK with GitHub
1. Upload every file in this folder to the top level of your repo (`project.godot` must sit at the top, next to `scripts`).
2. If `.github/workflows/build-apk.yml` didn't upload, create it with **Add file → Create new file** and paste its contents.
3. Open **Actions** and run "Build Android APK". Download `oath-of-the-last-survivors-apk` when it turns green.

## Where to edit
- `scripts/data.gd`: heroes, skills, Chain Arts, enemies, items, quest text and bond talks.
- `scripts/main.gd`: the Act I story script, map contents and encounters.
- `scripts/battle.gd`: the battle system.
- `scripts/maps.gd`: map layouts. `scripts/art.gd`: character art. `scripts/cutscene.gd`: notebook pages.
