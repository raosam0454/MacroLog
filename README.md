# MacroLog

A low-GI nutrition and symptom companion for women managing PCOS.

MacroLog helps someone who has been advised to manage insulin resistance through
a low-glycaemic-index diet keep track of what she eats, how she feels, and where
she is in her cycle, and then shows her the one thing those three streams are
meant to reveal together: whether her symptoms line up with the days she goes
over her low-GI budget.

## Domain context

Polycystic ovary syndrome is driven in large part by insulin resistance, and the
frontline, everyday management is dietary: a low-GI eating pattern that keeps
blood glucose steady. In practice that advice is often handed over with little
structured support, and the day-to-day work of connecting meals to symptoms and
to an irregular cycle is left to memory. MacroLog gives that work a home.

The app is built around the vocabulary of the domain. A day of eating is a
`NourishmentDay` that owns its `Meal`s; each meal carries a `GlycaemicIndexBand`
and a carbohydrate amount, from which it computes its own `GlycaemicLoad`. The
day is measured against a `DailyNourishmentTarget`. Alongside food, the woman
records a `SymptomObservation` (kind and severity) and a `CycleMarker` (period
started or ended, spotting).

## Architecture

MacroLog follows a layered, domain-centred design. Each layer depends only on
the one beneath it, and nothing above the repository knows the database exists.

```
SwiftUI Views            TodayView, LogMealView, SymptomsView, CycleView,
   │                     HistoryView, DailyTargetView, MealDetailView
   ▼
ViewModels (MVVM)        @MainActor @Observable, one per screen
   │
   ▼
Use Cases                LogMeal, SetDailyTarget, RemoveMeal, RecordSymptom,
   │                     MarkCycleEvent, SummariseRecentPatterns
   ▼                     (each enforces a rule and defines a typed error)
NourishmentRepository    a protocol: the only API the app above it sees
   │
   ├── CoreDataNourishmentRepository   (production, the only file that imports CoreData)
   └── InMemoryNourishmentRepository   (used by tests and SwiftUI previews)
         │
         ▼
      Core Data          MealEntity, NourishmentDayEntity, SymptomEntity, CycleMarkerEntity
```

Semantic domain models are plain, framework-free value types. Business
operations live in Use Case structs, each enforcing a domain rule and defining a
typed error written for the person, not the developer. The repository is a
protocol so the real Core Data implementation can be swapped for an in-memory
one in tests.

## Extensions

**Home and Lock Screen widget.** Before she eats, the woman wants to see how much
low-GI budget she has left today without unlocking her phone and opening the app.
The widget shows exactly that, in three families: a Home Screen small and medium
tile and a Lock Screen rectangle. It reads a small snapshot the app publishes to
the shared App Group container, and the app calls `WidgetCenter.reloadAllTimelines()`
whenever the day changes, so the widget stays current.

**Share Extension.** When she finds a recipe or a packaged food's nutrition
information in Safari, she can share it straight into MacroLog instead of
retyping it. The extension appears in the share sheet for web links and text,
saves the shared content to the App Group inbox, and always completes its
request so the sheet dismisses cleanly. Back in the app, the shared item appears
on the Today screen as something to log, and tapping it opens the meal form
pre-filled.

Both extensions communicate with the app only through the shared App Group
container: the app writes a today snapshot and reads the share inbox; the widget
reads the snapshot; the share extension writes to the inbox.

## Database

MacroLog uses **Core Data**, not CloudKit. The data is personal reproductive and
dietary health information, so it should stay private and on-device by default
rather than syncing to the cloud. It also has to be available offline, since
meals are logged wherever the woman happens to be eating, and it must be fast to
read on the main thread and from the widget. Core Data, with its store placed in
the shared App Group container, meets all three. CloudKit would add
cross-device sync at the cost of putting sensitive health data in the cloud,
which is not a trade this app wants to make.

The store lives in the App Group container so the widget can read the same
database the app writes.

## App Group identifier

```
group.com.sam.macrolog
```

Used by the app, the widget extension, and the share extension.

## Getting started

Requirements: Xcode 16 or later, iOS 17 or later.

1. Open `MacroLog.xcodeproj`.
2. In **Signing & Capabilities**, set your development team for all three
   targets: `MacroLog`, `MacroLogWidgetExtension`, and `MacroLogShare`.
3. Confirm the **App Groups** capability lists `group.com.sam.macrolog` on all
   three targets, for both Debug and Release.
4. Select the `MacroLog` scheme and run on an iOS Simulator.
5. To see the widget, log a meal in the app, then add the MacroLog widget from
   the Home Screen or Lock Screen widget gallery.
6. To test the share flow, open a page in Safari, tap Share, and choose MacroLog.

## Testing

Tests run against the in-memory repository, never the Core Data stack, so they
are fast and leave nothing behind. Run them with `Cmd + U`. Coverage spans the
use cases and the repository layer, including happy paths, boundary conditions,
and domain error cases.

## Project structure

```
MacroLog/
  Domain/         semantic domain models (value types, no frameworks)
  Data/           repository protocol, Core Data + in-memory implementations, mappings
  UseCases/       business operations with typed domain errors
  Presentation/   SwiftUI screens and their view models, by feature
  Support/        app group identifier, shared snapshot and inbox stores
MacroLogWidget/   WidgetKit widget
MacroLogShare/    Share Extension
MacroLogTests/    unit tests
```
