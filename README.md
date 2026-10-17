# The Oath of the Last Survivors: Chapter 1 slice

A playable vertical slice built in Godot 4.3 (GDScript, landscape, Android-first).

## What's in this slice
- **Title**, then an **opening cutscene** in a Leonardo da Vinci notebook style (the drawings ink themselves in).
- **Hero naming**: Mark, Jhona, Nelson, and Rachel are the defaults, and the player can rename them.
- **Tunnel battle** against Raiders, a Brute, and Sgt. Kess:
  - A turn-order timeline (the next 8 turns are shown).
  - Timed actions: tap when the ring meets the circle for bonus damage or a parry. Auto timing is available as a toggle.
  - **Intercept**: when a low-HP ally is attacked, Mark can leap in.
  - **Morale and Break**: break an enemy's will for double damage. Broken raiders may surrender.
  - **Shared Vow Shield** and **Resonance Gauge**, which unlocks six pair **Chain Arts**.
- **The First Fire**: the Oath cutscene blooms into colour.
- **Camp**: the Bond Tether, plus three sibling bond talks. Bonds strengthen Chain Arts.

## Build the APK with GitHub (no PC tools needed)
1. Create a new GitHub repo (for example `oath-of-the-last-survivors`) and upload every file from this folder.
   - If the `.github` folder doesn't upload, go to **Add file → Create new file** and name the file
     `.github/workflows/build-apk.yml`, then paste in its contents.
2. Open the **Actions** tab. The "Build Android APK" job runs on every push. You can also run it with **Run workflow**.
3. When it turns green, open the run and download **oath-of-the-last-survivors-apk**. Unzip it and install the APK on your phone. You'll need to allow installs from unknown sources.

You can also open the folder in the Godot 4.3 editor (desktop or the Android editor app) and press Play.

## Project layout
- `scripts/main.gd`: the scene flow and all cutscene text.
- `scripts/battle.gd`: the battle system (stats, skills, Chain Arts, and enemies are all near the top).
- `scripts/sketches.gd`: the procedural Da Vinci-style drawings. Swap these for painted art later.
- `scripts/camp.gd`: the camp, tether, and bond talks.
