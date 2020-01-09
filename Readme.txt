Parse Json format data with Lua.

function parsejsoncontent
Argument: 
t: table to keep parsed data
content: original json format data

Return value:
nil: represent some error when parsing (return errormsg as well)
true/false: if json data is just true/false
number: if json data is just a number
nil: if json data is just null
string: if json data is just a regular string
t: if json data is wrapped up with "[]" or "{}"



