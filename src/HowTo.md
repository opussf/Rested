# How To Write your own modules.

Writing your own tracking module can be done in a few easy steps.

First thing to do is to determine what you want to track.
Then figure out how to capture the data, and how to store the data.
Should it be

* Create a new LUA file.
* Write a function to be called to init the data.
	- Either to init the data structure
	- Or to call code after VARIABLES_LOADED event is fired.
	- The data should be stored in the table ```Rested.me```
* Assign the function to the InitCallback
	- ```Rested.InitCallback( Rested.<FunctionName> )```
* Write a function to update the data. This can be called at events
* Assign the update function to an event
	- ```Rested.EventCallback( "EVENT", Rested.<FunctionName> )```
	- Note that the callback function will be given all of the event payload
* Write a function to create reminders
	- The function will be given 3 parameters ( realm, name, struct )
	- struct is the table where all the gathered data for realm-name has been stored
	- For each struct returned, return a table:
		```{ [timestamp] = { "msg1", "msg2", "msg3"}, [timestamp2] = { "msg4"}. ...}```
	- reminder messages will be posted once the timestamp key has passed
* Register the function to be called for creating reminders
	- ```Rested.ReminderCallback( Rested.<functionName> )```




index 09daca0..4aac12c 100644