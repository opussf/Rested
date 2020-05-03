# How to add a new feature to Rested.

Making new reports / data tracking modular is the reason for this rewrite.

The basics are:
* Recording function
* Init function
* Events
* Report
* Reminders
* Commands


## Recording function
Create a function to record the data.
The function is passed all paramers that the event is given.
Example:
```lua
function Rested.f( ... )```

Store the data in
```lua
Rested_restedState[Rested.realm][Rested.name].<var>```

## Init function
Create a function that performs an init.
Register the function with ```Rested.InitCallback( functionRef )```.
This is called once during the ```ADDON_LOADED``` event.

## Events
Register the function with an event.
```Rested.EventCallback( "EVENT_NAME", Rested.f )```

## Report
Create a function to populate the report.

## Reminders


## Commands



