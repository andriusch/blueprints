---
layout: application
title: Changelog
---

Most notable changes will per minor/major version will be listed here.

## Version 1.0.x
- Dropped support for Rails/ActiveRecord 2.x.
- Blueprints are now evaluated in same context as spec/test is run in. This means you can access local/instance variables and call methods of that spec/test.
- Added ability to [infer name of blueprint](/blueprints/inferring).
- Added ability to [use different strategies in same blueprint](/blueprints/strategies).
- Added ability to [set default blueprint for namespace](/blueprints/namespaces#default_blueprint).
- Added ability to [define blueprint with regexp name](/blueprints/blueprint).
- Showing trace of built blueprints when error happens while building one of them.
- Building blueprints that have no block but have dependencies will set build result to array of dependencies build results.
- Various bugfixes and cleanup.

## Version 0.9.x
- Added ability to get most used blueprints.
- More powerful attributes and dependencies using contexts.
- Inferring names of blueprints.
- Added support for most popular ORMs.
- `build! 5, :user` now builds 5 users.
- Documentation.

## Version 0.8.x
- Removed features deprecated in 0.7.x.
- [Demolish method](/blueprints/update_demolish) now works on single blueprints not the whole table.
- Removed warning when building blueprint with options but it was already built. It now updates already built blueprints.
- A more powerful [d method](/blueprints/dependencies) that now allows passing options, changing instance variable name and calling
methods on instance variable.
- Build method for describe block which allows rewriting `before { build :xxx }` blocks to `build :xxx`
- Automatic detection of ORM, easier extending your own classes with .blueprint methods.
- Deprecated :@variables in favor of d method.

## Version 0.7.x
- Deprecated enable_blueprints in favor of Blueprints.enable.
- Added ability to not use transactions.
- Using DatabaseCleaner for database cleanups so it should be easier to use blueprints with ORMs other than ActiveRecord.
- First steps for fixture converter which allows to migrate from using fixtures to blueprints.

## Version 0.6.x
- Added ability to set attributes per blueprint and then later get them using [build_attributes](/blueprints/attributes).
- Added warning when trying to build blueprint with options but it was already built. Added warning when overwriting
blueprint with same name.
- Added build! method which build blueprint even if it was built previously.
- Added method 'd' for creating blueprints with Class.blueprint, when associated instance variable has same name as blueprint.
So `Class.blueprint :column => d(:hello)` is same as `Class.blueprint(:column => :@hello).depends_on(:hello)`

## Version 0.5.x

- Changed passing options syntax from `build :blueprint, :option => 'value'` to `build :blueprint => {:option => 'value'}`.
This also means that each blueprint gains it's own separate options hash when building.
- Added ability to [extend blueprints](/blueprints/extending).
- Demolishing and and rebuilding blueprint now correctly resets instance variables.

## Version 0.4.x

- Blueprint method on active record object to update it's attributes
- You can now pass options hash when building blueprint. It will be accessible in blueprint block (note that when using
shorthand of defining blueprints with ARClass.blueprint, options are automatically merged to objects attributes).
