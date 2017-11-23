DEFINE_BASECLASS("tfa_gun_base")

SWEP.MuzzleFlashEffect = ""
SWEP.data 				= {}
SWEP.data.ironsights			= 0

SWEP.Delay = 0.1 -- Delay to fire entity
SWEP.Ent = "" -- Nade Entity
SWEP.Velocity = 550 -- Entity Velocity

function SWEP:Initialize()
	self.ProjectileEntity = self.ProjectileEntity or self.Primary.Round --Entity to shoot
	self.ProjectileVelocity = self.Velocity and self.Velocity or 550 --Entity to shoot's velocity
	self.ProjectileModel = nil --Entity to shoot's model
	self:SetNW2Bool("Charging", false)
	self:SetNW2Bool("Ready", false)
	self:SetNW2Bool("Underhanded", false)
	self.VElements = {}
	BaseClass.Initialize(self)
end

function SWEP:Deploy()
	if self:Clip1() <= 0 then
		if self:Ammo1() <= 0 then
			timer.Simple(0, function()
				if IsValid(self) and self:OwnerIsValid() and SERVER then
					self.Owner:StripWeapon(self:GetClass())
				end
			end)
		else
			self:TakePrimaryAmmo(1,true)
			self:SetClip1(1)
		end
	end

	self:SetNW2Bool("Charging", false)
	self:SetNW2Bool("Ready", false)
	self:SetNW2Bool("Underhanded", false)
	self.oldang = self.Owner:EyeAngles()
	self.anga = Angle()
	self.angb = Angle()
	self.angc = Angle()
	self:CleanParticles()
	BaseClass.Deploy(self)
end

function SWEP:ChoosePullAnim()
	if not self:OwnerIsValid() then return end

	self.Owner:SetAnimation(PLAYER_RELOAD)
	--self:ResetEvents()
	local tanim = ACT_VM_PULLPIN
	local success = true
	self:SendViewModelAnim(ACT_VM_PULLPIN)

	if game.SinglePlayer() then
		self:CallOnClient("AnimForce", tanim)
	end

	self.lastact = tanim

	return success, tanim
end

function SWEP:ChooseShootAnim()
	if not self:OwnerIsValid() then return end

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendViewModelAnim(ACT_VM_THROW)

	if game.SinglePlayer() then
		self:CallOnClient("AnimForce", tanim)
	end

	self.lastact = tanim

	return success, tanim
end

function SWEP:ThrowStart()
	if self:Clip1() > 0 then
		self:ChooseShootAnim()
		self:SetNW2Bool("Ready", false)

		timer.Simple(self.Delay, function()
			if IsValid(self) and self:OwnerIsValid() then
				self:Throw()
			end
		end)
	end
end

function SWEP:Throw()
	if self:Clip1() > 0 then
		self.ProjectileVelocity = self.Velocity and self.Velocity or 550 --Entity to shoot's velocity
		self:TakePrimaryAmmo(1)
		self:ShootBulletInformation()
		self:DoAmmoCheck()
	end
end

function SWEP:DoAmmoCheck()
	if IsValid(self) and SERVER then
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end
		local delay = vm:SequenceDuration()
		delay = delay * 1 - math.Clamp(vm:GetCycle(), 0, 1)

		timer.Simple(delay, function()
			if IsValid(self) then
				self:Deploy()
			end
		end)
	end
end

function SWEP:Think2()
	if not self:GetNW2Bool("Charging", false) and self:GetNW2Bool("Ready", true) and  self:OwnerIsValid() and not self.Owner:KeyDown(IN_ATTACK2) and not self.Owner:KeyDown(IN_ATTACK) then
		self:ThrowStart()
	end
	BaseClass.Think2(self)
end

function SWEP:PrimaryAttack()
	if self:Clip1() > 0 and self:OwnerIsValid() and self:CanFire() then
		self:ChoosePullAnim()
		self:SetStatus(TFA.Enum.STATUS_SHOOTING)
		self:SetStatusEnd( CurTime() + (self.SequenceLengthOverride[tanim] or self.OwnerViewModel:SequenceDuration()) )
		self:SetNW2Bool("Charging", true)

		if IsFirstTimePredicted() then
			timer.Simple(self.Owner:GetViewModel():SequenceDuration(), function()
				if IsValid(self) then
					self:SetNW2Bool("Charging", false)
					self:SetNW2Bool("Ready", true)
				end
			end)
		end
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack( true )
end

function SWEP:Reload()
	if self:Clip1() <= 0 and self:OwnerIsValid() and self:CanFire() then
		self:Deploy()
	end
end

function SWEP:CanFire()
	if not self:OwnerIsValid() then return false end
	local vm = self.Owner:GetViewModel()
	local seq = vm:GetSequence()
	local act = vm:GetSequenceActivity(seq)
	if not (act == ACT_VM_DRAW or act == ACT_VM_IDLE) then return false end
	if act == ACT_VM_DRAW and vm:GetCycle() < 0.99 then return false end

	return not (self:GetNW2Bool("Charging") or self:GetNW2Bool("Ready"))
end

function SWEP:ChooseIdleAnim( ... )
	if self:GetNW2Bool("Charging") or self:GetNW2Bool("Ready") then return end
	BaseClass.ChooseIdleAnim(self,...)
end