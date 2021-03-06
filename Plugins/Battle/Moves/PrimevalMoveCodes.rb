module EmpoweredMove
	def isEmpowered?; return true; end
	
	def pbMoveFailed?(user,targets); return false; end
	def pbFailsAgainstTarget?(user,target); return false; end
	
	def transformType(user,type)
		user.pbChangeTypes(type)
		typeName = GameData::Type.get(type).name
		@battle.pbDisplay(_INTL("{1} transformed into the {2} type!",user.pbThis,typeName))
	end
end

# Empowered Heal Bell
class PokeBattle_Move_600 < PokeBattle_Move_019
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		super
		@battle.eachSameSideBattler(user) do |b|
			b.pbRecoverHP((b.totalhp/4.0).round)
		end
		transformType(user,:NORMAL)
	end
end

# Empowered Sunny Day
class PokeBattle_Move_601 < PokeBattle_Move_0FF
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		user.pbRaiseStatStage(:ATTACK,1,user)
		user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
		transformType(user,:FIRE)
	end
end

# Empowered Rain Dance
class PokeBattle_Move_602 < PokeBattle_Move_100
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		user.effects[PBEffects::AquaRing] = true
		@battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",user.pbThis))
		transformType(user,:WATER)
	end
end

# Empowered Leech Seed
class PokeBattle_Move_603 < PokeBattle_Move_0DC
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		transformType(user,:GRASS)
	end
end

# Empowered Lightning Dance
class PokeBattle_Move_604 < PokeBattle_MultiStatUpMove
	include EmpoweredMove
	
	def initialize(battle,move)
		super
		@statUp = [:SPECIAL_ATTACK,2,:SPEED,2]
	end
	
	def pbEffectGeneral(user)
		super
		transformType(user,:ELECTRIC)
	end
end 

# Empowered Hail
class PokeBattle_Move_605 < PokeBattle_Move_102
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			next unless b.pbCanFreeze?(user,true,self)
			b.pbFreeze()
	    end
		transformType(user,:ICE)
	end
end

# Empowered Bulk Up
class PokeBattle_Move_606 < PokeBattle_Move_024
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		@battle.pbDisplay(_INTL("{1} gained a massive amount of mass!",user.pbThis))
		user.effects[PBEffects::WeightChange] += 1000
		transformType(user,:FIGHTING)
	end
end

# Empowered Spikes
class PokeBattle_Move_607 < PokeBattle_Move_103
	include EmpoweredMove

	def pbEffectGeneral(user)
		user.pbOpposingSide.effects[PBEffects::Spikes] = 3
		@battle.pbDisplay(_INTL("3 layers of spikes were scattered all around {1}'s feet!",
		   user.pbOpposingTeam(true)))
		transformType(user,:GROUND)
	end
end

# Empowered Tailwind
class PokeBattle_Move_608 < PokeBattle_Move_05B
  include EmpoweredMove

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::Tailwind] = 99999
	@battle.pbDisplay(_INTL("A permanent Tailwind blew from behind {1}!",user.pbTeam(true)))
	@battle.numBossOnlyTurns += 1
	@battle.eachSameSideBattler(user) do |b|
		@battle.pbDisplay(_INTL("{1} gained an extra attack!",user.pbThis))
	end
	transformType(user,:FLYING)
  end
end

# Empowered Calm Mind
class PokeBattle_Move_609 < PokeBattle_Move_02C
	 include EmpoweredMove

	def pbEffectGeneral(user)
		GameData::Stat.each_battle { |s| user.stages[s.id] = 0 if user.stages[s.id] < 0 }
		@battle.pbDisplay(_INTL("{1}'s negative stat changes were eliminated!", user.pbThis))
		super
		transformType(user,:PSYCHIC)
	end
end

# Empowered String Shot
class PokeBattle_Move_610 < PokeBattle_TargetMultiStatDownMove
	include EmpoweredMove

	def initialize(battle,move)
		super
		@statDown = [:SPEED,2,:ATTACK,2,:SPECIAL_ATTACK,2]
	end
	
	def pbEffectGeneral(user)
		transformType(user,:BUG)
	end
end

# Empowered Sandstorm
class PokeBattle_Move_611 < PokeBattle_Move_101
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		user.pbRaiseStatStage(:DEFENSE,1,user)
		user.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
		transformType(user,:ROCK)
	end
end

# Empowered Curse
class PokeBattle_Move_612 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			@battle.pbDisplay(_INTL("{1} laid a curse on {2}!",user.pbThis,b.pbThis(true)))
			b.effects[PBEffects::Curse] = true
	    end
		transformType(user,:GHOST)
	end
end

# Empowered Dragon Dance
class PokeBattle_Move_613 < PokeBattle_MultiStatUpMove
	include EmpoweredMove
	
	def initialize(battle,move)
		super
		@statUp = [:ATTACK,2,:SPEED,2]
	end
	
	def pbEffectGeneral(user)
		super
		transformType(user,:DRAGON)
	end
end

# Empowered Torment
class PokeBattle_Move_614 < PokeBattle_Move_0B7
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		transformType(user,:DARK)
	end
	
	def pbEffectAgainstTarget(user,target)
		target.effects[PBEffects::Torment] = true
		@battle.pbDisplay(_INTL("{1} was subjected to torment!",target.pbThis))
		target.pbItemStatusCureCheck
		target.pbLowerStatStage(:ATTACK,1,user)
		target.pbLowerStatStage(:SPECIAL_ATTACK,1,user)
	 end
end

# Empowered Laser Focus
class PokeBattle_Move_615 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		user.effects[PBEffects::EmpoweredLaserFocus] = true
		@battle.pbDisplay(_INTL("{1} concentrated with extreme intensity!",user.pbThis))
		transformType(user,:STEEL)
	end
end

# Empowered Moonlight
class PokeBattle_Move_616 < PokeBattle_Move
	include EmpoweredMove
	
	def healingMove?;       return true; end
	
	def pbEffectGeneral(user)
		user.pbRecoverHP((user.totalhp/4.0).round)
		@battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
		
		user.attack,user.spatk = user.spatk,user.attack
		@battle.pbDisplay(_INTL("{1} switched its Attack and Sp. Atk!",user.pbThis))
		
		user.defense,user.spdef = user.spdef,user.defense
		@battle.pbDisplay(_INTL("{1} switched its Defense and Sp. Def!",user.pbThis))
		user.effects[PBEffects::EmpoweredMoonlight] = !user.effects[PBEffects::EmpoweredMoonlight]
		
		transformType(user,:FAIRY)
	end
end

# Empowered Poison Gas
class PokeBattle_Move_617 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			next unless b.pbCanPoison?(user,true,self)
			b.pbPoison(user)
	    end
		transformType(user,:POISON)
	end
end

# Empowered Endure
class PokeBattle_Move_618 < PokeBattle_Move
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		@battle.pbDisplay(_INTL("{1} braced itself!",user.pbThis))
		@battle.pbDisplay(_INTL("It will endure the next 3 hits which would faint it!",user.pbThis))
		user.effects[PBEffects::EmpoweredEndure] = 3
		transformType(user,:NORMAL)
	end
end
	
# Empowered Ignite
class PokeBattle_Move_619 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			next unless b.pbCanBurn?(user,true,self)
			b.pbBurn(user)
	    end
		transformType(user,:FIRE)
	end
end

# Empowered Ignite
class PokeBattle_Move_619 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			next unless b.pbCanBurn?(user,true,self)
			b.pbBurn(user)
	    end
		transformType(user,:FIRE)
	end
end

# Empowered Flow State
class PokeBattle_Move_620 < PokeBattle_MultiStatUpMove
	include EmpoweredMove
	
	def initialize(battle,move)
		super
		@statUp = [:ATTACK,1,:SPECIAL_DEFENSE,1]
	end
	
	def pbEffectGeneral(user)
		# TO DO
		super
		transformType(user,:WATER)
	end
end

# Empowered Grassy Terrain
class PokeBattle_Move_621 < PokeBattle_Move_155
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		# TO DO
		super
		transformType(user,:GRASS)
	end
end

# Empowered Electric Terrain
class PokeBattle_Move_622 < PokeBattle_Move_154
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		# TO DO
		super
		transformType(user,:ELECTRIC)
	end
end

# Empowered Heal Order
class PokeBattle_Move_623 < PokeBattle_Move
	include EmpoweredMove
	
	def healingMove?;       return true; end
	
	def pbEffectGeneral(user)
		user.pbRecoverHP((user.totalhp/4.0).round)
		@battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
		
		@battle.addAvatarBattler(:COMBEE,battler.level)
		
		transformType(user,:BUG)
	end
end
