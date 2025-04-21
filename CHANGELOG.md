# Changelog

## v0.8.1

* fix: Support for Rails `8.0.x`

## v0.8.0

* Use `ActiveModel::Attributes`
* Allow usage in Rails `7.1` and `7.2`
* Drop usage in Rails `< 7.0`

## v0.7.0

* Measure HTTP request duration
  * Print the request time in debug log-level
* Cache authentication between requests
  * Keep the returned SessionID for 60 minutes in memory

## v0.6.0

* Add support for `Actor.find_by!(ain:)` and `Actor#reload`

## v0.5.0

* Unify on/off interface
  * Provides `#active?` and `#toggle!` methods
  * Adds new functionality to `Switch`
  * Replacing own implementation in `Lightbulb`

## v0.4.0

* Add support for Fritz!DECT lightbulbs

## v0.3.0

* Use generic Actor class for unrecognised device
* Allow usage in rails up to 7.1.x
* Use ruby 3.1.x in development
* Update a other dependencies

## v0.2.0

**Attention**: This release contains breaking changes! Check [README](README.md) for new interface.

* Add support for more actors types: switches and smoke detector
* Extract heater specific attributes and logic to own class

## v0.1.3

* avoid nil error in actors:all smart devices request

## v0.1.2

* support rails 6.1

## v0.1.1

* support rails 6.0

## v0.1.0

* Initial release
