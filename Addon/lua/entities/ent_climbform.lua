--Made by MrRangerLP
--Shared
AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "Climbgame"
ENT.Category = "Fun + Games"
ENT.Author = "MrRangerLP"
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.DisableDuplicator = true

local function DevCheat(ply, func)
	if ply:SteamID() == "STEAM_0:0:41001543" or (aowl and aowl.CheckUserGroupLevel(ply, "developers") or ply:IsAdmin()) then
		if ply:KeyDown(IN_USE) or ply:KeyDown(IN_RELOAD) then
			func()
		end
	end
end

if SERVER then
	resource.AddFile("materials/vgui/entities/ent_climbform.vmt")
	resource.AddFile("materials/vgui/entities/ent_climbform.vtf")

	function ENT:Initialize()
		self:SetModel("models/props_junk/wood_crate001a.mdl")
		self:SetPos(self:GetPos() + Vector(0, 0, 25))
		self:SetAngles(Angle(0, 0, 0))
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:EnableMotion(false)
		end

		self.BoxSize = 41
		self.CenterToEdge = (self.BoxSize / 2)
		self.GameFinished = false
		self.ClimbCount = 0
		self.Fell = false
		self.Gamer = nil
		self.BoxTable = {}
		self.LastBox = self
		self.DirectionVec = nil
		self.LastDirectionVec = nil
		self.Grenade = nil
		self.Headcrabs = {}
		self.DuckEnt = nil
		self.IdleTime = CurTime()
		self.MotivationalSounds = {
			"vo/eli_lab/al_buildastack.wav",
			"vo/eli_lab/al_giveittry.wav",
			"vo/eli_lab/al_havefun.wav",
			"vo/k_lab/al_letsdoit.wav",
			"vo/k_lab/al_moveon01.wav",
			"vo/k_lab/al_moveon02.wav",
			"vo/k_lab/ba_pissinmeoff.wav"
		}
		self.CPPIExists = false
		local meta = FindMetaTable("Entity")
		if meta.CPPISetOwner then
			self.CPPIExists = true
		end

		self.TraceCenterToEdge = (self.CenterToEdge + 8)
		self.StepCenterToEdge = (self.CenterToEdge - 10)
		self.StepCenterToEdgeUp = (self.CenterToEdge + 1)
		self.Boundaries = {
			Vector(self.TraceCenterToEdge, self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(self.TraceCenterToEdge, self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge, -self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(-self.TraceCenterToEdge, -self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge, self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(-self.TraceCenterToEdge, self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge, -self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(self.TraceCenterToEdge, -self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge, 0, -self.TraceCenterToEdge), Vector(self.TraceCenterToEdge, 0, self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge, 0, -self.TraceCenterToEdge), Vector(-self.TraceCenterToEdge, 0, self.TraceCenterToEdge),
			Vector(0, self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(0, self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(0, -self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(0, -self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge, -self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(self.TraceCenterToEdge, -self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge, -self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(-self.TraceCenterToEdge, -self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge, self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(-self.TraceCenterToEdge, self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge, self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(self.TraceCenterToEdge, self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge, -self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(-self.TraceCenterToEdge, self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge, self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(-self.TraceCenterToEdge, -self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge, self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(self.TraceCenterToEdge, -self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge, -self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(self.TraceCenterToEdge, self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge, -self.TraceCenterToEdge, self.TraceCenterToEdge), Vector(-self.TraceCenterToEdge, self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge, self.TraceCenterToEdge, self.TraceCenterToEdge), Vector(self.TraceCenterToEdge, -self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge, -self.TraceCenterToEdge, self.TraceCenterToEdge), Vector(self.TraceCenterToEdge, -self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge, self.TraceCenterToEdge, self.TraceCenterToEdge), Vector(-self.TraceCenterToEdge, self.TraceCenterToEdge, self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge, -self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(-self.TraceCenterToEdge, self.TraceCenterToEdge, -self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge, self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(self.TraceCenterToEdge, -self.TraceCenterToEdge, -self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge, -self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(self.TraceCenterToEdge, -self.TraceCenterToEdge, -self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge, self.TraceCenterToEdge, -self.TraceCenterToEdge), Vector(-self.TraceCenterToEdge, self.TraceCenterToEdge, -self.TraceCenterToEdge)
		}
		self.OnBoxBoundaries = {
			Vector(-self.StepCenterToEdge, 0, self.StepCenterToEdgeUp), Vector(0, self.StepCenterToEdge, self.StepCenterToEdgeUp),
			Vector(-self.StepCenterToEdge, 0, self.StepCenterToEdgeUp), Vector(0, -self.StepCenterToEdge, self.StepCenterToEdgeUp),
			Vector(self.StepCenterToEdge, 0, self.StepCenterToEdgeUp), Vector(0, -self.StepCenterToEdge, self.StepCenterToEdgeUp),
			Vector(self.StepCenterToEdge, 0, self.StepCenterToEdgeUp), Vector(0, self.StepCenterToEdge, self.StepCenterToEdgeUp)
		}
	end

	function ENT:CheckBoundaries(NewDirVec, Type)
		local Trace = util.TraceLine({
			start = self.LastBox:GetPos(),
			endpos = (self.LastBox:GetPos() + NewDirVec + Vector(0, 0, (NewDirVec.z * 2))),
			filter = {self.LastBox, self.Gamer}
		})

		if Type == 1 then
			local Obstructed = false

			for k = 1, #self.Boundaries, 2 do
				local T = util.TraceLine({
					start = ((self.LastBox:GetPos() + NewDirVec) + self.Boundaries[k]),
					endpos = ((self.LastBox:GetPos() + NewDirVec) + self.Boundaries[k + 1]),
					filter = {self, self.LastBox}
				})

				if T.Hit or T.StartSolid then
					Obstructed = true
					break
				end
			end

			return Trace.StartSolid or Obstructed or false
		elseif Type == 2 then
			return Trace.HitWorld or Trace.HitSky or false
		end
	end

	function ENT:CheckStepZone()
		for k = 1, #self.OnBoxBoundaries, 2 do
			if not self.LastBox:IsValid() then return false end

			local T = util.TraceLine({
				start = (self.LastBox:GetPos() + self.OnBoxBoundaries[k]),
				endpos = (self.LastBox:GetPos() + self.OnBoxBoundaries[k + 1]),
				filter = {self, self.LastBox},
				ignoreworld = true
			})

			if T.Entity == self.Gamer then return true end
		end

		return false
	end

	function ENT:SafeEmitSound(Path, Volume, Pitch, IDK, Channel)
		if not IsValid(self.Gamer) then return end

		self.Gamer:EmitSound(Path, Volume, Pitch, IDK, Channel)
	end

	function ENT:OnRemove()
		for k, v in pairs(self.BoxTable) do
			if v:IsValid() then
				v:Remove()
			end
		end

		for k, v in pairs(self.Headcrabs) do
			if v:IsValid() then
				v:Remove()
			end
		end

		if IsValid(self.Grenade) then
			self.Grenade:Remove()
		end

		if IsValid(self.DuckEnt) then
			self.DuckEnt:Remove()
		end

		self:EmitSound("physics/wood/wood_crate_break" .. math.random(1, 5) .. ".wav", 75, 100, 1, CHAN_AUTO)
		self:Remove()
	end

	function ENT:CallError()
		self:SafeEmitSound("vo/k_lab/kl_ohdear.wav", 75, 100, 1, CHAN_AUTO)
		self:OnRemove()
	end

	function ENT:SpawnBox(Pos)
		local Box = ents.Create("ent_climbform_box")
		Box:SetPos(Pos)
		Box:SetAngles(Angle(0, 0, 0))
		Box.Owner = self.Gamer
		Box.CPPIExists = self.CPPIExists
		Box:Spawn()

		if Box:IsValid() then
			local phys = Box:GetPhysicsObject()

			if IsValid(phys) then
				phys:EnableMotion(false)
				Box:EmitSound("physics/wood/wood_box_impact_hard" .. math.random(1, 3) .. ".wav", 75, 100, 1, CHAN_AUTO)

				if #self.BoxTable >= 10 then
					if self.BoxTable[1]:IsValid() then
						self.BoxTable[1]:Remove()
						table.remove(self.BoxTable, 1)
					end
				end

				table.insert(self.BoxTable, Box)

				return Box
			else
				self:CallError()
			end
		else
			self:CallError()
		end
	end

	function ENT:GenDir()
		local RandDir = math.random(1, 4)

		if RandDir == 1 then
			self.DirectionVec = self.LastBox:GetForward() * self.BoxSize + ((self.LastBox:GetUp()) * self.BoxSize)
			self.LastDirectionVec = self.LastBox:GetForward()
		elseif RandDir == 2 then
			self.DirectionVec = -(self.LastBox:GetForward()) * self.BoxSize + ((self.LastBox:GetUp()) * self.BoxSize)
			self.LastDirectionVec = -self.LastBox:GetForward()
		elseif RandDir == 3 then
			self.DirectionVec = self.LastBox:GetRight() * self.BoxSize + ((self.LastBox:GetUp()) * self.BoxSize)
			self.LastDirectionVec = self.LastBox:GetRight()
		elseif RandDir == 4 then
			self.DirectionVec = -(self.LastBox:GetRight()) * self.BoxSize + ((self.LastBox:GetUp()) * self.BoxSize)
			self.LastDirectionVec = -self.LastBox:GetRight()
		end
	end

	function ENT:CallStack()
		if self.GameFinished then return end

		if not IsValid(self.Gamer) then
			self:OnRemove()

			return
		end

		self:GenDir()

		if self.DirectionVec then
			if self:CheckBoundaries(self.DirectionVec, 1) then
				local FailSafe = 0
				repeat
					self:GenDir()
					FailSafe = (FailSafe + 1)
				until not self:CheckBoundaries(self.DirectionVec, 1) or (FailSafe > 50)
				if FailSafe >= 50 then return end
			end

			if not self:CheckBoundaries(self.DirectionVec, 2) then
				self:SafeEmitSound("buttons/button17.wav", 90, 100, 1, CHAN_AUTO)
				self.LastBox:SetColor(Color(0, 200, 0, 255))
				self.ClimbCount = (self.ClimbCount + 1)

				if self.ClimbCount == 1 then
					self:SafeEmitSound("vo/npc/barney/ba_letsdoit.wav", 90, 100, 1, CHAN_AUTO)
				end

				if self.ClimbCount == 10 then
					self:SafeEmitSound("vo/eli_lab/al_allright01.wav", 90, 100, 1, CHAN_AUTO)
				end

				if self.ClimbCount == 20 then
					self:SafeEmitSound("vo/eli_lab/al_awesome.wav", 90, 100, 1, CHAN_AUTO)
				end

				if self.ClimbCount == 50 then
					self:SafeEmitSound("vo/eli_lab/al_sweet.wav", 90, 100, 1, CHAN_AUTO)
				end

				--Random Events
				local HeadcrabBool = false

				if self.ClimbCount % 5 == 0 and self.ClimbCount % 10 ~= 0 and self.ClimbCount > 15 then
					local RandN = math.random(1, 100)

					if RandN > 60 then
						local RandNE = math.random(1, 3)

						-- Grenade event
						if RandNE == 1 then
							self:SafeEmitSound("vo/npc/barney/ba_grenade02.wav", 75, 100, 1, CHAN_AUTO)
							self.Grenade = ents.Create("npc_grenade_frag")
							self.Grenade:SetPos(self.LastBox:GetPos() + Vector(0, 0, 500))
							self.Grenade:SetAngles(Angle(1, 0, 0))
							self.Grenade:Spawn()
							self.Grenade:Input("SetTimer", nil, nil, 3)
						elseif RandNE == 2 then
							-- Headcrab event
							self:SafeEmitSound("vo/npc/barney/ba_headhumpers.wav", 75, 100, 1, CHAN_AUTO)
							HeadcrabBool = true
						elseif RandNE == 3 then
							-- Flying WashingMachine event
							self:SafeEmitSound("vo/npc/barney/ba_duck.wav", 90, 100, 1, CHAN_AUTO)

							timer.Simple(3, function()
								if IsValid(self.DuckEnt) then
									self.DuckEnt:Remove()
								end

								self.DuckEnt = ents.Create("prop_physics")
								self.DuckEnt:SetModel("models/props_c17/FurnitureWashingmachine001a.mdl")
								self.DuckEnt:SetPos(self.LastBox:GetPos() + ((self.LastDirectionVec * 400) + Vector(0, 0, 50)))
								self.DuckEnt:SetAngles(Angle(0, 0, 0))
								self.DuckEnt:Spawn()

								if self.DuckEnt:IsValid() then
									local phys = self.DuckEnt:GetPhysicsObject()

									if IsValid(phys) then
										phys:EnableMotion(true)
										phys:SetVelocity(-(self.LastDirectionVec * 50000))
									end

									--Make sure the prop can't collide with the player when autoclimbing
									DevCheat(self.Gamer, function()
										self.DuckEnt:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
									end)

									self.DuckEnt:Ignite(5)
									self.DuckEnt:EmitSound("npc/zombie/zombie_voice_idle" .. math.random(1, 14) .. ".wav", 90, 100, 1, CHAN_AUTO)
								end

								timer.Simple(3, function()
									if IsValid(self) then
										if self.DuckEnt:IsValid() then
											self.DuckEnt:Remove()
										end
									end
								end)
							end)
						end
					end
				end

				self.LastBox = self:SpawnBox(self.LastBox:GetPos() + self.DirectionVec)
				self:SetNWInt("Climbcount", self.ClimbCount)

				--The creator and developers can autoclimb
				DevCheat(self.Gamer, function()
					timer.Simple(0.1, function()
						self.Gamer:SetPos(self.LastBox:GetPos() + Vector(0, 0, CenterToEdge))
					end)
					--For some reason this has to run in a timer or else the setpos won't work sometimes.
				end)

				if HeadcrabBool then
					local Headcrab = ents.Create("npc_headcrab")
					Headcrab:SetPos(self.LastBox:GetPos() + Vector(0, 0, self.CenterToEdge + 10))
					Headcrab:Spawn()
					Headcrab.SpawnPos = Headcrab:GetPos()
					table.insert(self.Headcrabs, Headcrab)
				end
			else
				for k, v in pairs(self.BoxTable) do
					v:SetColor(Color(200, 200, 0, 255))
				end

				self:SetColor(Color(200, 200, 0, 255))
				self:SafeEmitSound("vo/npc/barney/ba_ohyeah.wav", 90, 100, 1, CHAN_AUTO)
				self:SetNWBool("GameFinished", true)
				self:SetNWInt("Climbcount", self.ClimbCount)
				self.GameFinished = true
			end
		end
	end

	function ENT:Think()
		local plyValid = IsValid(self.Gamer)

		if not self.Fell and not self.LastBox:IsValid() then
			self:CallError()
		end

		if self:IsValid() then
			self:SetAngles(Angle(0, 0, 0))
		end

		for k = #self.Headcrabs, 1, -1 do
			if self.Headcrabs[k]:IsValid() then
				if self.Headcrabs[k]:GetPos():Distance(self.Headcrabs[k].SpawnPos) > 250 then
					self.Headcrabs[k]:Remove()
					table.remove(self.Headcrabs, k)
				end
			else
				table.remove(self.Headcrabs, k)
			end
		end

		for k, v in pairs(self.BoxTable) do
			if not v:IsValid() then
				self:CallError()
				break
			end
		end

		if plyValid and not self.Fell and self.LastBox:IsValid() then
			if self.Gamer:GetPos():Distance(self.LastBox:GetPos()) > (self.BoxSize * 4) or (self.Gamer:GetMoveType() == MOVETYPE_NOCLIP) then
				self:SafeEmitSound("vo/npc/barney/ba_downyougo.wav", 75, 100, 1, CHAN_AUTO)
				self.Fell = true
				self:SetNWBool("Fell", true)
				self:SetNWInt("Climbcount", self.ClimbCount)

				timer.Create("DestroyBoxes", 0.1, #self.BoxTable, function()
					if not self.BoxTable then return end

					if #self.BoxTable <= 1 then
						self:OnRemove()

						return
					end

					if not IsValid(self.BoxTable[#self.BoxTable]) then return end
					self.BoxTable[#self.BoxTable]:Remove()
					table.remove(self.BoxTable, #self.BoxTable)
				end)
			end
		elseif not plyValid then
			if CurTime() > (self.IdleTime + 30) then
				self:EmitSound(self.MotivationalSounds[math.random(1, #self.MotivationalSounds)], 75, 100, 1, CHAN_AUTO)
				self.IdleTime = CurTime()
			end
		end

		if not self.Fell then
			if not plyValid then
				for k, v in pairs(ents.FindInSphere((self.LastBox:GetPos() + Vector(0, 0, 19)), 1)) do
					if v:IsPlayer() then
						self:SetNWEntity("SharedOwner", v)
						self.Gamer = v
						break
					end
				end
			else
				if self:CheckStepZone() and not self.Gamer:Crouching() then
					self:CallStack()
				end
			end
		end
	end

	function ENT:EntityTakeDamage()
		return true
	end
end

if CLIENT then
	function ENT:TextPosInit()
		self.TextPosAngles = {
			(self:GetPos() + (self:GetUp() * 1) + (self:GetForward() * -21)),
			(self:GetAngles() + Angle(-180, 90, -90)),
			(self:GetPos() + (self:GetUp() * 1) + (self:GetForward() * 21)),
			(self:GetAngles() + Angle(-180, -90, -90)),
			(self:GetPos() + (self:GetUp() * 1) + (self:GetRight() * -21)),
			(self:GetAngles() + Angle(0, -180, 90)),
			(self:GetPos() + (self:GetUp() * 1) + (self:GetRight() * 21)),
			(self:GetAngles() + Angle(0, 0, 90))
		}
	end

	function ENT:Initialize()
		self:TextPosInit()
		self.ClimbcountAnnounced = false
		self.Text = "Climbgame"
	end

	function ENT:OnRemove()
	end

	local UndecorateNick = UndecorateNick or function(x) return x end
	function ENT:Draw()
		self.BaseClass.Draw(self)
		self.SharedOwner = self:GetNWEntity("SharedOwner")
		self.ClimbCountC = self:GetNWInt("Climbcount")

		for k = 1, #self.TextPosAngles, 2 do
			cam.Start3D2D(self.TextPosAngles[k], self.TextPosAngles[k + 1], 0.1)
				--Update the table when the box is moved.
				if self.TextPosAngles[1] ~= (self:GetPos() + (self:GetUp() * 1) + (self:GetForward() * -21)) then
					self:TextPosInit()
				end

				if IsValid(self.SharedOwner) then
					self.Text = UndecorateNick(self.SharedOwner:Nick())

					draw.SimpleText("User: ", "DermaLarge", 0, -30, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				draw.SimpleText(self.Text, "DermaLarge", 0, 0, Color(255, 223, 127, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				if self.ClimbCountC > 0 then
					local DynText = "box" .. (self.ClimbCountC > 1 and "es" or "")

					draw.SimpleText("Progress: " .. tostring(self.ClimbCountC) .. " " .. DynText, "DermaLarge", 0, 30, Color(33, 200, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

			cam.End3D2D()
		end
	end

	function ENT:Think()
		if IsValid(self.SharedOwner) and self.SharedOwner == LocalPlayer() and not self.ClimbcountAnnounced then
			if self:GetNWBool("Fell") then
				chat.AddText(Color(255, 255, 255), "[", Color(200, 200, 50), "Climbgame", Color(255, 255, 255), "]: You managed to climb ", Color(200, 200, 0), tostring(self:GetNWInt("Climbcount")), Color(255, 255, 255), " Boxes!")
				self.ClimbcountAnnounced = true
			end

			if self:GetNWBool("GameFinished") then
				chat.AddText(Color(255, 255, 255), "[", Color(200, 200, 50), "Climbgame", Color(255, 255, 255), "]: You made it to the top in ", Color(200, 200, 0), tostring(self:GetNWInt("Climbcount")), Color(255, 255, 255), " Boxes!")
				self.ClimbcountAnnounced = true
			end
		end
	end
end