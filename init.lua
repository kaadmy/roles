
--
-- Roles mod
-- By KaadmY
--

roles = {}

roles.registered_roles = {}

roles.default_privs = {}

-- Registering a role definition

function roles.register_role(name, def)
   local new_def = {
      name = def.name or name,
      color = def.color or "#ffffff",
      default_privs = def.default_privs or true,
      privs = def.privs or {},
   }

   roles.registered_roles[name] = new_def
end

-- Getting the role definition

function roles.get_def(role)
   return roles.registered_roles[role]
end

-- Getting a player's current role

function roles.get_role(player)
   if type(player) == "string" then
      player = minetest.get_player_by_name(player)
   end

   if player then
      return player:get_attribute("role")
   end
end

-- Updating the player's nametag

function roles.update_nametag(player)
   if type(player) == "string" then
      player = minetest.get_player_by_name(player)
   end

   if not player then
      return
   end

   local def = roles.get_def(roles.get_role(player))

   local name = player:get_player_name()

   if def then
      player:set_nametag_attributes(
         {
            text = name .. " / " .. minetest.colorize(def.color, def.name)
      })
   else
      player:set_nametag_attributes(
         {
            text = name
      })
   end
end

-- Updating the player's privileges

function roles.update_privs(name)
   if type(name) ~= "string" then
      name = name:get_player_name()
   end

   local def = roles.get_def(roles.get_role(name))

   if (not def) or (def and not def.privs) then
      return
   end

   local privs = minetest.get_player_privs(name)

   for priv, _ in pairs(privs) do
      privs[priv] = false
   end

   minetest.set_player_privs(name, privs) -- Disable all privs
   minetest.set_player_privs(name, roles.default_privs) -- Enable default privs
   minetest.set_player_privs(name, def.privs) -- Enable role privs
end

-- Setting or clearing a player's role

function roles.set_role(player, role)
   if type(player) == "string" then
      player = minetest.get_player_by_name(player)
   end

   if not player then
      return false
   end

   if not role then
      player:set_attribute("role", nil)

      minetest.chat_send_player(
         player:get_player_name(),
         minetest.colorize("#f00", "Your role has been cleared")
      )

      roles.update_nametag(player)
      roles.update_privs(player)

      return true
   end

   local def = roles.get_def(role)

   if not def then
      return false
   end

   player:set_attribute("role", role)

   minetest.chat_send_player(
      player:get_player_name(),
      "Your role is now " .. minetest.colorize(def.color, def.name)
   )

   roles.update_nametag(player)
   roles.update_privs(player)

   return true
end

-- Privilege

minetest.register_privilege(
   "roles",
   {
      description = "Allow usage of the /setrole commands",
      give_to_singleplayer = false
})

-- Chat commands

minetest.register_chatcommand(
   "setrole",
   {
      params = "<player> <role>",
      description = "Sets the player's role",
      privs = {roles = true},

      func = function(name, param)
         local params = param:split(" ")

         if #params < 2 then
            return false, "Invalid usage (see /help roles)"
         end

         local player = minetest.get_player_by_name(name)

         if not player then
            return false, "Invalid player \"" .. params[1] .. "\""
         end

         if not roles.registered_roles[params[2]] then
            return false, "Nonexistant role \"" .. params[2] .. "\""
         end

         if params[2] == "clear" then
            params[2] = nil
         end

         roles.set_role(params[1], params[2])

         return true
      end
})

minetest.register_chatcommand(
   "role",
   {
      params = "[player]",
      description = "Gets the player's role. Your name will be used if none is specified.",

      func = function(name, param)
         -- Strip param

         param = param:gsub("^%s*(.-)%s*$", "%1")

         if param == "" then
            param = name
         end

         local def = roles.get_def(roles.get_role(name))

         if not def then
            minetest.chat_send_player(name, name .. " has no role")

            return true
         end

         minetest.chat_send_player(
            name,
            name .. "'s role is " .. minetest.colorize(def.color, def.name)
         )
         return true
      end
})

-- Get basic privilege list

minetest.after(
   0,
   function()
      local priv_string = minetest.settings:get("basic_privs")

      if roles.default_privs == {} then
         roles.default_privs = minetest.string_to_privs(priv_string)
      end
end)

-- Update nametags on joining

minetest.register_on_joinplayer(
   function(player)
      roles.update_nametag(player)
      roles.update_privs(player)
end)

-- Override chat to show role

minetest.register_on_chat_message(
   function(name, message)
      local def = roles.get_def(roles.get_role(name))

      local color = "#ffffff"

      if def then
         color = def.color
      end

      minetest.chat_send_all(
         "<" .. minetest.colorize(color, name) .. "> " .. message
      )

      return true
end)

-- Default roles

dofile(minetest.get_modpath("roles") .. "/roles.lua")
