<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Acta
A tool for application management that captures events and errors in a structured and extensible way.

## Features

- Automatic capture of custom events and errors  
- Event severity tracking (info, warning, error, critical)  
- Support for multiple reporters (console, MongoDB, Elasticsearch, local database)  
- Flexible configuration via `HandlerOptions`  
- Easy integration into any Dart or Flutter application


## Roadmap

Planned improvements and upcoming features for future releases:

### 🧱 Core & Architecture
- [✅] Main core of package, system callback, reports, breadcums and metadata 
- [🚧] Isolate the reporting system to improve performance and safety
- [  ] Split package into smaller subpackages (e.g. `acta_core`, `acta_reporters`)
- [  ] Reduce internal dependencies for better modularization

### ⚙️ Extensibility
- [✅] Make `Event` fully extensible and customizable
- [✅] Make `Report` fully extensible and customizable
- [🚧] Make `Severity` fully extensible and customizable

### ☁️ Integrations
- [✅] Add `ElasticReporter` for advanced query and analytics
- [✅] Add `MongoReporter` for local or hybrid setups
- [  ] Add `FirebaseReporter` for cloud-based event tracking
- [  ] Add `SentryReporter` for production error monitoring

### 📶 Offline & Reliability
- [🚧] Implement offline-first mode with local queue
- [  ] Add automatic flusher to resend events when back online
- [  ] Retry queue for failed reports
- [  ] Local cache and sync

### 🧪 Tooling & Developer Experience
- [✅] Provide built-in adapters for Flutter’s error handling system for Android
- [  ] Provide built-in adapters for Flutter’s error handling system for IOS
- [🚧] Add examples and samples
- [  ] Improve test coverage and provide example-driven docs
- [  ] Add command-line utilities for debugging and inspection

---

💡 *This roadmap is subject to change as the package evolves.  
Contributions and feature suggestions are welcome!*

## Getting started

Add `acta` as a dependency in your `pubspec.yaml`:
```yaml
dependencies:
  acta: ^0.0.2
```

## Usage

Basic example of package initialization:
```dart
ActaJournal.initialize(
    reporters: [
      ConsoleReporter(),
    ],
    options: const HandlerOptions(
      catchAsyncErrors: true,
      logFlutterErrors: true,
      logPlatformErrors: true,
      minSeverity: Severity.info,
      maxBreadcrumbs: 50,
    ),
    initialContext: {'appVersion': '1.0.0', 'build': 1, 'env': 'dev'},
    beforeSend: (report) {
      return report;
    },
    appRunner: () => runApp(const MyApp()),
);
```
Basic example of reporting an event:
```dart
ActaJournal.addBreadcrumb('Pressed INFO');
ActaJournal.report(
    event: BaseEvent(
        message: 'User pressed info',
        severity: Severity.info,
        metadata: {'screen': 'home'},
    ),
);
```
## Additional information


