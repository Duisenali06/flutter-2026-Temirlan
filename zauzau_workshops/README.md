# ZauZau Workshops

Domain: baking workshops at the Zau Zau confectionery (title, category, start time, place or link, seats, list of guests).
"Sign up" adds your profile name to a workshop; "Cancel spot" removes it.

## Screenshots

Add three screenshots before the defence (R41):

- `docs/phone_light.png`
- `docs/phone_dark.png`
- `docs/tablet_grid.png`

## Decisions

The list of workshops and the profile live in the shell's State, because three tabs and two pushed screens all need the same data and only one widget sits above all of them. The tabs receive the data as constructor parameters and send changes up through callbacks. The detail screen takes callbacks through its route arguments because it is a separate route and cannot reach the shell's State, and the form returns a finished `Item` through `pop` so the caller decides what to do with it, and backing out changes nothing. The list is a `ListView.separated` on phones and a `GridView.builder` from 600 px; this is a `LayoutBuilder` because it measures the space the list actually gets, not the whole screen. `PopScope` compares a record of the current field values with the record taken when the form opened, so changing a value and changing it back is not "dirty". With week 9's tools I would move the list and profile out of the shell into a proper state-management layer and persist them, so the callbacks would not have to travel through every screen.

## Run

```
flutter create . --project-name zauzau_workshops   # once, generates android/ios/web
flutter pub get
flutter analyze
dart format .
flutter run
```
