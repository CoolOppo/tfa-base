# This is an archive of changelog messages from `tfa_loader.lua`. For proper changes list refer to the Git history.

## 4.5.8.0
* Added material proxy for tinting envmaps with ambient lighting (TFA_CubemapTint)
* Added option to debug currently playing anination (Admin-only)

## 4.5.7.1
* Fixed networked menu not working in Local/P2P servers

## 4.5.7.0
* Added localization support. English and Russian locales are bundled by default.
* Fixed weapons not spawning in TTT (by Anairkoen Schno)
* Blocked new ammo pickups (SMG grenades) from being pocketed in DarkRP

## 4.5.6.0
* Added ammo entities for SMG grenades (1 and 5 grenades for small and large pickups)
* Server settings menu now work in multiplayer (rewritten to use networked controls)

## 4.5.5.1
* Fixed non-ballistics bullet tracers for akimbo weapons
* Added bash damage display to inspection screen (when available)

## 4.5.5.0
* Added TFA_BulletPenetration hook, called when bullet hits/penetrates a surface
* Reverted ironsights FOV compensation changes - new compensation only applies to viewmodels now
* Exposed more variables to stat cache (various sounds, sck elements bodygroups)
* Fixed performance degradation when player holds a non-TFA weapon in singleplayer
* Added muzzleflash smoke toggle convar (Q -> Options -> Performance -> Use Muzzle Flash Smoke)

## 4.5.4.0
* Started work on new RT scope attachment base
* Fixed silenced weapon shaking when Siminov's SWEP packs are installed
* Added toggle for melee door destruction
* Fixed customization keybind not opening the menu
* Fixed viewmodel floating away with low MoveSpeed values
* Fixed ironsights FOV compensation to be more consistent on all FOV values
* Added SWEP.IronViewModelFOV parameter - SWEP.ViewModelFOV will be set to this when aiming down the sights

## 4.5.3.1
* Added icons for ammo entities

## 4.5.3.0
* Fixed presets in settings menu not working
* Various Lua animation fixes
* Added customization menu idle animation (and transitions) support

## 4.5.2.0
* Added keybinds! (Menu can be found at Q -> Options -> Keybinds)
* Added looping fire support
* Fixed shell casings scrape sounds (huge thanks to gmod_silent material for not working properly!)

## 4.5.1.1
* Fixed bugs with level transition and for bullets fired after player's death
* Fixed looped fire sounds not working properly in P2P/listen servers

## 4.5.1.0
* Flashlights rework: added support for QC attachments of SCK elements and custom on/off sounds
* Added TFA.AddSound function (simple wrapper for sound.Add)
* Looping fire sound now updates correctly if changed while playing

## 4.5.0.3
* Fixed resetting viewmodel skin after switching weapon
* Fixed Ironsights DoF blurring whole screen for 2D-scoped weapons
* Fixed ballistics ConVars (dev branch is now safe to use again)

## 4.5.0.2
* Fixed the bug with first spawned weapon after map load not working

## 4.5.0.1
* Inspection VGUI now doesn't block the screen with mat_dxlevel < 90
* Ironsights convar now works properly again
* Base explosives now can have custom bounce sound (ENT.BounceSound)
* Crysis-like triangular crosshair, can be enabled in the "HUD / Crosshair" section

## 4.5.0.0
* Weapons can now have a working flashlight
* Changed laser dot to appear as projected texture
* Added attachment callbacks
* Safety position is now separated from sprint one
* Melee blocking works again
* Base explosives now properly damage helicopters and gunships
* Added jamming mechanics
* Added CS:GO-like low ammo sound effect
* Added bodygroup names support
* Attachments can now have their own attach/detach sound
* Added walk animations support (similar to sprint animations)
* Bonemods are now working properly with blowback enabled
* Fixed laser drawing behing worldmodel
* Looped gunfire sound support added (Experimental)

## 4.4.2.1
* Changelog can be toggled off with sv_tfa_changelog

## 4.4.2.0
* New laser dots
* Better ejection effects
* AI melee support

## 4.4.1.0
* Patch: New smoke effects on muzzles and shells, which should hopefully eat less fps and look better

## 4.4.0.0
* Entire base linted
* Fewer global variables
* TFA attachment table moved to TFA.Attachments.Atts -- this will need an update to autopatching mods

## 4.3.8.1
* PATCH - Exploit regarding new C-Menu fix, viewmodel viewpunch made into a cvar ( it'll go down with recoil if disabled )

## 4.3.8.0
* Reticules/lasers now colorable in context menu
* Hold E as you hit your inspection key to access the context menu as normal

## 4.3.7.0
* Attachment UI now allows rows to affect the same category, and will break apart exceedingly large rows
* Legacy attachment UI removed

## 4.3.6.0
* Muzzles + smoke updated, the latter taken from CS:GO

## 4.3.5.2
* Fixed shells networking
* Fixed RT scope resolution autodetect
* Added RT scope material proxy

## 4.3.5.1
* Fixed weapon bounce in new viewbob, increased intensity, smooth eye focus

## 4.3.5.0
* Cancelling an empty reload on a closed bolt weapon will play the first deploy and cock the gun upon next draw

## 4.3.4.1
* Fixed console spam with dropped weapons
* Added ability to disable door destruction (thanks to Ralph)

## 4.3.4.0
* Viewbob tweaks

## 4.3.2.3
* More violent shell ejection; shell angle determined by eye angles

## 4.3.2.2
* Shells resized AGAIN and double-checked for accuracy this time using OBBMaxs()-OBBMins()

## 4.3.2.1
* SWEP.LuaShellEffect = "" disables the new tfa_shell stuff
* Shells resized using actual math

## 4.3.2.0
* Added ability to override new shell effects
* Fixed serverside modules/external files loader
* Fixed LookupAttachment error for externally registered weapons
* Fixed scope background blur working in thirdperson

## 4.3.1.0
* Shell hotfixes
* Weapons no longer have airboat damage type, finally fixing ragdolls

## 4.3.0.0
* New shell ejection effects
* New shell models (Soldier11's)
* RT Scope Blur
* New clientside options on the performance and scope panels

## 4.2.8.0
* Numerous bugfixes
* Notably: FOV fixed in overlay-style scopes + shotgun timing fixes

## 4.2.7.9
* Inspection panel tweaks and performance fixes
* New font for ammo hud and inspection panel
* Fixed ironsight sway direction for flipped viewmodels

## 4.2.7.8
* Unload functions added

## 4.2.7.4
* ERROR SPAM HOTFIX

## 4.2.7.3
* Silenced inspection added ( ACT_VM_FIDGET_SILENCED = ACT_VM_FIDGET_SILENCED or ACT_RPG_FIDGET_UNLOADED )
* Have a one-time invitation to my Discord: https://discord.gg/Gxqx67n

## 4.2.6.5
* Added laser-dot trail convar ( thanks Yura )

## 4.2.6.4
* Fixed Yura's crosshair nitpick

## 4.2.6.2
* Melee base prediction fixes

## 4.2.6.1
* Knife prediction improvements ( general melee to follow )

## 4.1.7.0
* Bind detection system added

## 4.0.1.0
* TFA Base Rewrite
* Numerous hotfixes, including ADS, sprint anims, etc.
* DarkRP "fp" table no longer overwritten
* External status support added
* Reload sounds added

## 3.05.2.0
* Doors fixed for DarkRP ( probably )
* Silenced weapon inspection fixed
* Idle animation timing improved
* C-Key inspection fixed
* Weapon stripping fixed
* CVAR sv_tfa_door_respawn added

## 3.05.0.0
* Basic GMDUSK integration
* Shotgun door-bust tweaked, improved, and fixed for DarkRP (hopefully)
* Scopes fixed for DarkRP ( hopefully )

## 3.01.2.0
* New group prompt added
* Introduced bare-basics multilanguage support
* Migrated global functions to a table
* Miscelaneous quality of life improvements

## 3.01.1.0
* Added new cvars of mp_tfa_precach.  Enable these to increase loading times but reduce lag and weapon spawn time.
* Use console autocomplete instead of bothering me for the exact names!
* Bugfix in setupmove fixed
* Conflict message improved, displaying exact filepath for a conflicting tfa_loader
* Lua particle handling fixed on invalid viewmodels
* Other misc. bugfixes

## 3.0.0.1
* Shock damage no longer removes props
* Fixed rendertargets
* Further improved performance

## 3.0.0.0
* Entire TFA Base linted and micro-optimized
* Performance holding a TFA Base gun is better compared to a HL2 gun 

## 2.88.0.0
* Added SWEP.Primary.AmmoConsumption
* Added extra revolver ejecteffect
* Misc. bugfixes