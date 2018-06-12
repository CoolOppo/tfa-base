--this presents from becoming blank
--[[
--general
TFA_GetStat(wepom,stat,value) --modify value in here, oh and you have to return
--deploy+init
TFA_SetupDataTables(wepom) --do things in here
TFA_PathStatsTable(wepom) --do things in here
TFA_PreInitialize(wepom) --do things in here
TFA_Initialize(wepom) --do things in here
TFA_PreDeploy(wepom) --do things in here
TFA_Deploy(wepom) --do things in here; return to override what the thingy returns
--holster+remove
TFA_PreHolster(wepom) --do things in here, called before we truly holster, but in the holster hook; return to override what the thingy returns
TFA_Holster(wepom) --really the finishholster func; return to override what the thingy returns
TFA_OnRemove(wepom) --return to override what the thingy returns
TFA_OnDrop(wepom) -- return to override what the thingy returns
--think
--primary fire related things
TFA_PreCanPrimaryAttack(wepom) --return to override our answer before doing base checks
TFA_CanPrimaryAttack(wepom) --return to override our answer, after TFA's checks
TFA_PrimaryAttack(wepom) --do things here; return to prevent proceeding
TFA_PostPrimaryAttack(wepom) --do things here
--secondary
TFA_SecondaryAttack(wepom) --do things here; return to override
--reload related things
TFA_PreReload(wepom,keyreleased) --called before sanity checks.  do things here; return to prevent proceeding
TFA_Reload(wepom) --called when you take ammo.  do things here; return to prevent proceeding
TFA_LoadShell(wepom) --called when insert a shotgun shell and play an animation.  This runs before that; return to do your own logic
TFA_Pump(wepom) --called when you pump the shotgun as a separate action, playing the animation.  This runs before that; return to do your own logic
TFA_CompleteReload(wepom) --the function that takes from reserve and loads into clip; return to override
TFA_CheckAmmo(wepom) --the function that fidgets when you reload with a full clip; return to override
TFA_PostReload(wepom) --do things here
--FOV
TFA_PreTranslateFOV(wepom,fov) --return a value to entirely override the fov with your own stuff, before TFA Base calcs it
TFA_TranslateFOV(wepom,fov) --return a value to modify the fov with your own stuff
--attachments
TFA_PreInitAttachments(wepom) --modify attachments here
TFA_PostInitAttachments(wepom) --runs before building attachment cache
TFA_FinalInitAttachments(wepom) --final attachment init hook
--ironsights
TFA_IronSightSounds(wepom) --called when we actually play a sound; return to prevent this
]]