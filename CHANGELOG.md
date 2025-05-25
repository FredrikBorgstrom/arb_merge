# Changelog

## 1.2.1

* **BUGFIX**: Fixed null pointer exception in `Options.createDefaultValues()` when `sources` field is null
* Improved null safety handling for configuration parsing
* Added proper validation for sources configuration from pubspec.yaml

## 1.2.0

* **NEW**: Added comprehensive library API for programmatic usage
* Added `ArbMerge.create()` factory constructor for simplified usage
* Added `merge()` method to get merged content without writing files
* Added `getMergedContentForLocale()` method for specific locale access
* Added `getAvailableLocales()` method to discover available languages
* Added `ArbMergeResult` class to encapsulate merge results
* Added `writeFiles()` method for custom file writing logic
* Improved user experience by eliminating the need to manually create output directories
* Enhanced documentation with comprehensive library usage examples

## 1.1.0

* Added automatic creation of destination directory if it doesn't exist

## 1.0.0

* initial release.

## 1.0.1

* updated formatting and description