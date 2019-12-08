--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

-----------------------
--  EXISTENCE FUNCTIONS
-----------------------

function titleCase(s)
	return string.gsub(s, "(%a)([%w_']*)", titleCase2);
end

function titleCase2(sFirst, sRemaining)
	return string.upper(sFirst)..string.lower(sRemaining);
end
