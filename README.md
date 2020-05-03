[![Build Status](https://travis-ci.org/opussf/Rested.svg?branch=master)](https://travis-ci.org/opussf/Rested)

# Rested

# Features

## rewrite

Rewrite to make this more modular.

Things to make this happen:
* Base code handles:
	* UI
	* Options
	* process init for all modules
	* create event function, calls each module's code for that event
	* handle reminders
* Each module handles:
	* provide an init function
	* provide a function to call for each event
	* provide a function to populate the table needed for display

* How to handle?
	* export of data

