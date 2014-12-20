local AuthList = {"user","user2","user3","user4"} --[[Table of users who you wish to use the script.]]
local User = string.lower(GetUser()) --[[Calls the GetUser() function once for better performance.]]
function Auth()
for i, users in pairs(AuthList) do --[[For loop to compare the usernames.]]
if string.lower(users) == User then --[[Checks if the usernames match.]]
return true --[[Authenticates the user if the usernames match.]]
end
end
return false --[[If the usernames don't match after the for loop is completed, the script doesn't authenticate you.]]
end
if not Auth() then print("Not Authenticated") return end --[[Tells the user that they can't use the script.]]
print("Authenticated as "..User) --[[Tells the user know that they can use the script.]]
--[[Place your script code here.]]
