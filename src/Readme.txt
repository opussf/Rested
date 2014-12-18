Welcome to Rested

Rested shows the rested status of your alts.

How to use:
Install the addon for any alt you wish to track. Log into that alt.
Type '/rested' to see a list of alts and their rested status.



Rested shows:
Character level    - What level the character is was at when last seen.
Resting status     - + means resting, - means not resting
Rested % / 150     - Total expected rested amount.  This is green if the
                   - rested will take the alt into the next level.
Time till rested   - Amount of time till the character is fully rested
Realm : Char Name  - The realm and name of the character.
(Rested % / 100)   - Total rested amount scaled to 100% - This is the rested bar.

This list is filtered to not show alts at max level, and not to show alts that
were last seen with full rested status.

Alts can be removed from the list, at least until the next time they are seen, by using
'/rested -name'. 'name' will be removed from the list of alts being tracked.

Commands:
/rested             -> Rested Report
/rested -name       -> Removes name from tracking
/rested max         -> Shows list of max level characters - (shows older than nagtime, but less than stale time)
/rested status      -> Shows status message
/rested stale       -> Shows characters older than stale
/rested nagtime #   -> Sets nagtime for max level characters
/rested ignore name -> Ignores the named player for 5 days
					   (Excellent way to get the player off the nag list if you don't want to play them)

Examples:
=====
/rested
Toon Rested Report:
 7+ 92% 3 Days 20 Hr: Moon Guard:Player2
 6+ 123% 1 Day 19 Hr: Sen'jin:Player3
 35+ Fully Rested: Moon Guard:Player4

-- Player2 is resting with 92% (~18 bars) and will be fully rested in a little under 4 days.
-- Player4 should be fully rested
=====
/rested -Player2
Rested Reporter> Removing Moon Guard:Player2 from the rested list
=====
/rested max
Max Level toons:
 7 Days 3 Hr: Hyjal:Maxtoon

-- Maxtoon has not been played in about 7 days.
-- Use the nagtime to change the lower range
=====
/rested stale
Toons not seen in 10 days.
 35 :: 10 Days 14 Hr : Moon Guard:OldPlayer




Change Log:
2.6     - Bringing the version numbers back into sync
        - Garrison Cache (gcache) tracking
2.5     - Messed up versions with git tags
        - Garrison Mission tracking
2.4     - Gender
2.3     - New layout - shrunk search bar, and moved dropdown up next to it
        - right click menu
2.2     - Changed the ALL report to show: Level (Expected Rested) Name
2.1     - Some clean ups
2.0     - adding UI interface

1.4     - added dynamic maxLevel value based on account type
1.3     - updated for Cataclysm
        - added the find function.
1.2     - added a function to show the time since level 80's have been seen.
        - inits cutoff value at 7 days.
		- /rested nagtime # sets cutoff value
		- status massage shows character and realm count
		- stale value set to 10 days
		- stale report
1.1		- changed output to show time till fully rested.


Done:
- Resize - Option in the config screen

To do:
- Right click menu
- Mini Map button
- Transparency
----  Need to define
- percent options




- Show time until rested to next level
--
- alerts in chat log for characters
  a) 1 day of resting remain
  b) 12 hours of resting remain
  c) 8 hours of resting remain
  d) 4 hours of resting remain
  e) 2 hours
  f) 1 hour
  g) is now fully rested
  -- process from lowest to highest, setting flags for all higher

  -- Use a Crontab sort of style internal data structure for this.
  -- On load:
	 - for each alt tracked that is resting not being current toon, or being ignored:
		- Compute when the character will be (or was fully rested).
		- Compute timestamp backwards for each alert value
		- Insert timestamp into table
  -- On each second update:
     - check current timestamp against table
		- print reminders

  -- Table structure:
reminders = {
	[1277372992] = {
		{
			[msg] = "1 hour until r:n is fully rested",
		}, -- [1]
		{
			[msg] = "2 hours until r2:n2 is fully rested",
		}, -- [2]
	},
	[1277372993] = {
		{
			[msg] = "1 hour until r2:n2 is fully rested",
		},  -- [1]
		{
			[msg] = "r:n is now fully rested",
		},
	},
}