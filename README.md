# Sirius: CTU Time management API

[![Build Status](https://travis-ci.org/cvut/sirius.svg?branch=master)](https://travis-ci.org/cvut/sirius)
[![Code Climate](https://img.shields.io/codeclimate/github/cvut/sirius.svg)](https://codeclimate.com/github/cvut/sirius)
[![Coverage Status](https://coveralls.io/repos/cvut/sirius/badge.svg?branch=master&service=github)](https://coveralls.io/github/cvut/sirius?branch=master)
[![Inline docs](http://inch-ci.org/github/cvut/sirius.svg)](http://inch-ci.org/github/cvut/sirius)
[![Dependency Status](https://gemnasium.com/cvut/sirius.svg)](https://gemnasium.com/cvut/sirius)


Sirius is a Timetable management API, which is used at [CTU FIT](http://fit.cvut.cz/) to transform regular timetables
into accurate calendars. Main Sirius output are calendar events and their collections (calendars). Same events can be
viewed from different perspectives, creating different calendar types (personal, room or course calendar).

Main timetable data source is KOS IS, which is accessed via [KOSapi](https://kosapi.fit.cvut.cz/). Timetables from KOS
are then converted to events according to scheduling rules and exceptions stored in local Sirius database.
Currently supported output data formats are JSON (for client apps) and iCalendar (for users).

## API documentation

Documentation of resources which Sirius provides is currently available [here](http://cvut.github.io/sirius/docs/api-v1.html).

# Looking for help?

If you need help with adding you personal calendar to the calendar software you are using, check out our
[wiki tutorial page](https://github.com/cvut/sirius/wiki/Nastaven%C3%AD-kalend%C3%A1%C5%99e).

If you have an issue with your personal calendar or any other problems, feel free to use
[project issues on Github](https://github.com/cvut/sirius/issues) or you could just message us directly.

# Suggestions, ideas and contributions

We are welcome to suggestions and ideas about this project. Please use [project issues](https://github.com/cvut/sirius/issues)
to discuss it if you have one.

If you feel you could improve project in some way, you can fork this repo and send a pull request with your change.
If you consider adding a new feature or significantly changing behaviour of an existing one, it would be nice
to discuss it with project maintainers beforehand, otherwise there is a possibility that your pull request might not get accepted.

# Setup

After cloning this repo, run `script/setup` to bootstrap your configuration. This will create `.env` file in project root
with reasonable defaults that you can change after that.

## Prerequisites

* Ruby/MRI 2.1+
* PostgreSQL 9.3+
* ElasticSearch 1.6+ (not mandatory, used only for `/search` resource)

## Environment variables

Variables put into `.env` file will be automatically loaded by Foreman.

You will need a KOSapi OAuth credentials from the [Apps Manager](https://auth.fit.cvut.cz/manager/) and local PostgreSQL database and ElasticSearch.
If you don’t need the `/search` resource, then you can omit ElasticSearch (just put any URI into `ELASTIC_URL` to pass check).

```
DATABASE_URL=postgres://localhost:5432/sirius-development
ELASTIC_URL=http://localhost:9200
KOSAPI_OAUTH_CLIENT_ID=xxx-xxxx-xxxx
KOSAPI_OAUTH_CLIENT_SECRET=yyyyyyyyy
```

## Running server and rake tasks

To start the API server, just run `foreman start`. If everything is configured properly, server should start and be
accessible on port 5000 by default.

To load parallels from KOSapi and and schedule them, call `foreman run rake sirius:events`. Or you can call individual tasks:

* `sirius:events:import` - fetches parallels from KOSapi to local database
* `sirius:events:import_students` - fetches students assigned to stored parallels
* `sirius:events:plan` - plans stored parallels
* `sirius:events:assign_people` - assigns people (students and teachers) to planned events
