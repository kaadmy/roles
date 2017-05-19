
--
-- Roles
--

roles.register_role(
   "survur",
   {
      name = "Survur",
      color = "#ff00ff",
      privs = {
         interact = true,
         kick = true,
         ban = true,
         server = true,
         give = true -- Gimme dedotated wam for my survur
      }
})

roles.register_role(
   "administrator",
   {
      name = "Administrator",
      color = "#ff0000",
      privs = {
         interact = true,
         kick = true,
         ban = true
      }
})

roles.register_role(
   "moderator",
   {
      name = "Moderator",
      color = "#ff7f00",
      privs = {
         interact = true,
         kick = true
      }
})

roles.register_role(
   "guardian",
   {
      name = "Guardian",
      color = "#ffff00",
      privs = {
         interact = true
      }
})
