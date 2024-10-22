# Feature document for Rested

## Resize

Thanks a lot for this neat addon :D
Would you mind add a resizing handle at the botton of the window so we can resized it to display more toons at the same time?

There is a scroll handle, but it is not working (default camera zoom keys are bypassing it and it can't be handled too).

Thanks in advance for your help.
Best regards.

## GreatVault

Add a report and track how many possible rewards are in the great vault.

-- Figure out how to determine if the great vault rewards are claimed.

Events:
WEEKLY_REWARDS_UPDATE
WEEKLY_REWARDS_ITEM_CHANGED
WEEKLY_REWARDS_HIDE

Possible requirement:
LoadAddOn("Blizzard_WeeklyRewards")

Possible methods:
C_WeeklyRewards.GetActivities(activityType);
C_WeeklyRewards.GetActivityEncounterInfo(activityType, activity.index);
C_WeeklyRewards.GetExampleRewardItemHyperlinks(activity.id);


## NoNag

A bit like Ignore, but just for the nag report.

## Ignore

Chars ignored for a LONG time, will have the date / time instead of # of days in the ignore report.
* How many is too many days?  (90?)  -- Set this as an option.


Extend the system to allow to ignore a toon for any amount of time.
The ignore time is then set as the default.

Re-ignoring a toon will reset the ignore time.

## Help report

Use the dispaly to show the help.

## Offline

Create an offline report.

## Auctions

Track auctions

https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentation#C_AuctionHouse.GetBrowseResults

-- Research
[ ] Figure out the set duration of the auction
[ ] Determine if the auction is still active
	* remove it before the expire date if it is not.

## Nag

Expand the Nag report.
Also show rested toons who are rested to end of level.
Show resting toons who are now full for 3 days.
Don't show toons who were fully rested when logging out.

## Profession CDs

### What I can get from the system:
Scanning of the TradeSkill window can provide what recipes have a CD.
This CD seems to be the number of seconds till CD.
In practice, this seems to report seconds till midnight on that server.

Getting the link for the recipe item returns the item created, but this can be an incomplete link ([name]).
Using the link as a key is probably just really bad.

Many recipes can share CDs.
Tracking all the CDs might not be the best idea.

### What do I want to track:
It seems that knowing that [bleh] has a CD might not be important.
Only that 'char' has a CD.

Knowing too many recipes leads to an awkward report.

tradeCD.Alchemy[ts] = <count>

tradeCD[ts].Alchemy = <count>
tradeCD[ts].Leatherworking = <count>

tradeCD_ts_Alchemy = 5

tradeCD_Alchemy_count = 5
tradeCD_Alchemy_TS = #####

tradeCD.Alchemy = { ["count"] = 5, ["TS"] = ##### }
tradeCD.LeatherWorking = { ["count"] = 2, ["TS"] = ##### }


tradeCD.Alchemy = ts
tradeCD.LeatherWorking = ts




### What would be helpful?
The intention of this addon is to be reminded of toons that should be visited, for one reason or another.

Knowing that a toon has a profession CD that is ready to be used is what I'm looking for.
If I can figure out how to get the profession of the CDs, I could report the number of CDs for that profession.

[Alchemy - realm-name : 5   |    ]
[Leatherworking |- realm-name : 2]

### Heavy usage of the alert system might be best here.
'realm-name has 5 cooldowns ready in Alchemy'
'realm-name has 2 cooldowns ready in Leatherworking'







## Reminder system

The reminder system allows this addon to register reminders to be displayed to the user.

The format of the generated reminder structure is:
```lua
Rested.reminders[ TimeStamp ] = { "<string to display>", "<string to display>", ... }
```

The display portion of this loops over the TimeStamp keys, looks for any that are less than now, and prints the strings.
It also then removes those from the structure.

This reminder structure is only generated at ADDON_LOADED.
It takes structures like:
```lua
{}[<matched value>] = "formatted str"
```

The current system is very limited in what can be a reminder.
Adding a new reminder means that the function that creates the structure has to be modified.

To make this as generic as possible, either have a callback registration system for functions to call, or create a data structure to register.
I think the callback system may be most flexible at this point.

The callback function would take a realm, name, and player data table.
It would return a table:
```lua
{}[ TimeStemp ] = { "<string to display>", "<string to display>", ... }
```

### Command line

The command line should:
* Allow '/rested' with no extra parameter
* '/rested' should show the help list the first time it is used alone
* '/rested' should show the default report
* '/rested' should show toggle the last report

* Always show the report associated with the given parameter
	* IE  '/rested all' will always show that report, even if it is the current report




## Rep info
Track rep for toons, allow to search for rep name.



## guildInfo

┌─────────────────────────────────────────────────────┐
│<Guild Standing> :: <realm-name>                     │
└─────────────────────────────────────────────────────┘

## Track Building creation and updating
http://wowprogramming.com/utils/xmlbrowser/test/AddOns/Blizzard_GarrisonUI/Blizzard_GarrisonBuildingUI.lua


local plots = C_Garrison.GetPlots();

## Track Building Progress

## Expand Mission info

G <time> 0/0 <name>
F <time> 0/0 <name>

----  No.  Too much extra lines, too much stuff all over the place.


http://wowprogramming.com/utils/xmlbrowser/test/AddOns/Blizzard_GarrisonUI/Blizzard_GarrisonMissionUI.lua
local location, xp, environment, environmentDesc, environmentTexture, locPrefix, isExhausting, enemies = C_Garrison.GetMissionInfo(missionID);



https://www.townlong-yak.com/framexml/20173
https://us.battle.net/support/en/article/download-the-world-of-warcraft-interface-addon-kit

