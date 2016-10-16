
local string = string
if (!string) then return end

// In this file we're adding functions to the string table.
// This means you'll be able to call functions here straight from the string library
// You can even override already existing functions.

function string.Strip( text, to_be_stripped )

	return string.Replace( text, to_be_stripped, "" )

end

