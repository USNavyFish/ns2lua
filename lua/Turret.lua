class 'Turret' (Actor)

Turret.modelName  = "models/temp/sentry/sentry.model"
Turret.spawnSound = "sound/ns2.fev/marine/structures/armory_open"
Turret.dieSound   = "sound/ns2.fev/marine/common/health"

Shared.PrecacheModel(Turret.modelName)

Shared.PrecacheSound(Turret.spawnSound)
Shared.PrecacheSound(Turret.dieSound)

Turret.State = enum { 'Idle', 'Firing' }

Turret.thinkInterval = 0.15
Turret.attackRadius = 10

Turret.PiOverTwo = math.pi/2.0

function Turret:OnInit()
    Actor.OnInit(self)
       
    if (Client) then    
        // Don't collide with the player (once we're physically simulated)
        // since the simulation is different on the server and client.
        self.physicsGroup = 1
    end
    
    if (Server) then      
        self:SetNextThink(Turret.thinkInterval)
    end
    
end

function Turret:OnLoad()
    Actor.OnLoad(self)
end

function Turret:Popup()
    self:SetModel(self.modelName)
    self:SetAnimation( "popup" )
    
    self:PlaySound(self.spawnSound)
  
end

if (Server) then

    function Turret:OnThink()
        Actor.OnThink(self)
        
        local player = Server.FindEntityWithClassnameInRadius("player", self:GetOrigin(), self.attackRadius, nil)
        
        if (player ~= nil) then
        	// Trigger a popup in the future (with the mean being the specfied delay).
            //self.popupTime = time + Shared.GetRandomFloat(0, self.popupDelay * 2)
            
            local target = Vector(player:GetOrigin())
            local mypos = Vector(self:GetOrigin())
            
            local vec = target - mypos

			local angles =  Angles(0,0,0)
			
			angles.yaw = math.atan2(vec.x, vec.z) - Turret.PiOverTwo
			angles.roll = math.sin(vec.y)
			//Note that the current sentry model is rotated 90, hence needing to roll it instead of pitching it.
			
            self:SetAngles(angles)
			
			//Shared.Message("p " .. angles.pitch .. " y " .. angles.yaw .. " r " .. angles.roll)
            
        end
        
        self:SetNextThink(Turret.thinkInterval)
    end
    
end


Shared.LinkClassToMap("Turret", "turret")
