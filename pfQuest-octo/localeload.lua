-- Load ONLY this client's locale data, on demand.
--
-- The pack used to list every locale's XML in its .toc, so all six were parsed
-- into Lua tables at every login and reload. That cost is paid before any addon
-- code can run, which makes it invisible to the usual fixes: base pfQuest's
-- freelocales() reclaims its own unused locales, but it iterates pfDB.locales
-- whose keys are plain codes ("deDE"), so it never saw this pack's
-- "deDE-turtle" keys -- they stayed resident for the entire session.
--
-- Each locale is now its own LoadOnDemand addon (pfQuest-octo-<locale>), and
-- only the matching one is pulled in here. enUS stays in the main addon because
-- patchtable.lua falls back to "enUS-turtle" when a locale has no pack data.
--
-- This file must run BEFORE patchtable.lua so the tables exist when the merge
-- loop looks for them; the .toc order guarantees that.

local loc = GetLocale()

if loc and loc ~= "enUS" and LoadAddOn then
  local name = "pfQuest-octo-" .. loc
  -- A locale with no pack data simply is not installed; that is not an error,
  -- the merge falls back to enUS-turtle on its own.
  if IsAddOnLoadOnDemand and IsAddOnLoadOnDemand(name) then
    local loaded, reason = LoadAddOn(name)
    if not loaded and reason and reason ~= "MISSING" and reason ~= "DISABLED" then
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccpf|cffffffffQuest |cffcccccc[Octo DB]|r: "
        .. "could not load " .. name .. " (" .. reason .. ") - quest text stays English.")
    end
  end
end
