-- luacheck: globals ACT_VM_FIDGET_EMPTY ACT_VM_FIDGET_SILENCED ACT_VM_BLOWBACK ACT_VM_HOLSTER_SILENCED
TFA.Enum.ANIMATION_ACT = 0
TFA.Enum.ANIMATION_SEQ = 1
ACT_VM_FIDGET_EMPTY = ACT_VM_FIDGET_EMPTY or ACT_CROSSBOW_FIDGET_UNLOADED
ACT_VM_FIDGET_SILENCED = ACT_VM_FIDGET_SILENCED or ACT_RPG_FIDGET_UNLOADED
ACT_VM_HOLSTER_SILENCED = ACT_VM_HOLSTER_SILENCED or ACT_CROSSBOW_HOLSTER_UNLOADED
ACT_VM_BLOWBACK = ACT_VM_BLOWBACK or -2