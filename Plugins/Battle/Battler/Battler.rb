class PokeBattle_Battler
  OFFENSIVE_LOCK_STAT = 120
  DEFENSIVE_LOCK_STAT = 95

	def attack
		if hasActiveItem?(:POWERLOCK)
			return calcStatGlobal(OFFENSIVE_LOCK_STAT,@level,@pokemon.ev[:ATTACK])
		else
			return @attack
		end
	end
	
	def defense
		if @battle.field.effects[PBEffects::WonderRoom]>0
			if hasActiveItem?(:WILLLOCK)
				return calcStatGlobal(DEFENSIVE_LOCK_STAT,@level,@pokemon.ev[:SPECIAL_DEFENSE])
			else
				return @spdef 
			end
		else
			if hasActiveItem?(:GUARDLOCK)
				return calcStatGlobal(DEFENSIVE_LOCK_STAT,@level,@pokemon.ev[:DEFENSE])
			else
				return @defense
			end
		end
	end
	
	def spatk
		if hasActiveItem?(:ENERGYLOCK)
			return calcStatGlobal(OFFENSIVE_LOCK_STAT,@level,@pokemon.ev[:SPECIAL_ATTACK])
		else
			return @spatk
		end
	end
	
	def spdef
		if @battle.field.effects[PBEffects::WonderRoom]>0
			if hasActiveItem?(:GUARDLOCK)
				return calcStatGlobal(DEFENSIVE_LOCK_STAT,@level,@pokemon.ev[:DEFENSE])
			else
				return @defense
			end
		else
			if hasActiveItem?(:WILLLOCK)
				return calcStatGlobal(DEFENSIVE_LOCK_STAT,@level,@pokemon.ev[:SPECIAL_DEFENSE])
			else
				return @spdef 
			end
		end
	end


	def hasActiveAbility?(check_ability, ignore_fainted = false)
		return false if !abilityActive?(ignore_fainted)
		return check_ability.include?(@ability_id) if check_ability.is_a?(Array)
    return false if self.ability.nil?
		return check_ability == self.ability.id
	end
	alias hasWorkingAbility hasActiveAbility?

	def takesSandstormDamage?
		return false if !takesIndirectDamage?
		return false if pbHasType?(:GROUND) || pbHasType?(:ROCK) || pbHasType?(:STEEL)
		return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
		return false if hasActiveAbility?([:OVERCOAT,:SANDFORCE,:SANDRUSH,:SANDSHROUD,:STOUT,:DESERTSPIRIT,:BURROWER,:ARTIFICIALNOCTURNE])
		return false if hasActiveItem?(:SAFETYGOGGLES)
		return true
	  end

	def takesHailDamage?
		return false if !takesIndirectDamage?
		return false if pbHasType?(:ICE) || pbHasType?(:STEEL) || pbHasType?(:GHOST)
		return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
		return false if hasActiveAbility?([:OVERCOAT,:ICEBODY,:SNOWSHROUD,:STOUT,:SNOWWARNING,:BLIZZBOXER])
		return false if hasActiveItem?(:SAFETYGOGGLES)
		return true
	end
	
	def shiny?
		return false if boss?
		return @effects[PBEffects::Illusion].shiny? if @effects[PBEffects::Illusion]
		return @pokemon && @pokemon.shiny?
	end
	
	def pbThis(lowerCase=false)
		if opposes?
			if @battle.trainerBattle?
				return lowerCase ? _INTL("the opposing {1}",name) : _INTL("The opposing {1}",name)
			else
				if !boss?
					return lowerCase ? _INTL("the wild {1}",name) : _INTL("The wild {1}",name)
				else
					return lowerCase ? _INTL("the avatar of {1}",name) : _INTL("The avatar of {1}",name)
				end
			end
		elsif !pbOwnedByPlayer?
			return lowerCase ? _INTL("the ally {1}",name) : _INTL("The ally {1}",name)
		end
		return name
	end
	
  # Returns the active types of this Pok??mon. The array should not include the
  # same type more than once, and should not include any invalid type numbers
  # (e.g. -1).
  def pbTypes(withType3=false)
    ret = [@type1]
    ret.push(@type2) if @type2!=@type1
    # Burn Up erases the Fire-type.
    ret.delete(:FIRE) if @effects[PBEffects::BurnUp]
	# Cold Conversion erases the Ice-type.
    ret.delete(:ICE) if @effects[PBEffects::ColdConversion]
    # Roost erases the Flying-type. If there are no types left, adds the Normal-
    # type.
    if @effects[PBEffects::Roost]
      ret.delete(:FLYING)
      ret.push(:NORMAL) if ret.length == 0
    end
    # Add the third type specially.
    if withType3 && @effects[PBEffects::Type3]
      ret.push(@effects[PBEffects::Type3]) if !ret.include?(@effects[PBEffects::Type3])
    end
    return ret
  end
  
  # NOTE: Do not create any held item which affects whether a Pok??mon's ability
  #       is active. The ability Klutz affects whether a Pok??mon's item is
  #       active, and the code for the two combined would cause an infinite loop
  #       (regardless of whether any Pok??mon actualy has either the ability or
  #       the item - the code existing is enough to cause the loop).
  def abilityActive?(ignore_fainted = false)
    return false if fainted? && !ignore_fainted
	return false if @battle.field.effects[PBEffects::NeutralizingGas]
    return false if @effects[PBEffects::GastroAcid]
    return true
  end
  
  # Applies to both losing self's ability (i.e. being replaced by another) and
  # having self's ability be negated.
  def unstoppableAbility?(abil = nil)
    abil = @ability_id if !abil
    abil = GameData::Ability.try_get(abil)
    return false if !abil
    ability_blacklist = [
      # Form-changing abilities
      :BATTLEBOND,
      :DISGUISE,
#      :FLOWERGIFT,                                        # This can be stopped
#      :FORECAST,                                          # This can be stopped
      :MULTITYPE,
      :POWERCONSTRUCT,
      :SCHOOLING,
      :SHIELDSDOWN,
      :STANCECHANGE,
      :ZENMODE,
      :ICEFACE,
      # Abilities intended to be inherent properties of a certain species
      :COMATOSE,
      :RKSSYSTEM,
      :GULPMISSILE,
      :ASONEICE,
      :ASONEGHOST
    ]
    return ability_blacklist.include?(abil.id)
  end
  
  # Applies to gaining the ability.
  def ungainableAbility?(abil = nil)
    abil = @ability_id if !abil
    abil = GameData::Ability.try_get(abil)
    return false if !abil
    ability_blacklist = [
      # Form-changing abilities
      :BATTLEBOND,
      :DISGUISE,
      :FLOWERGIFT,
      :FORECAST,
      :MULTITYPE,
      :POWERCONSTRUCT,
      :SCHOOLING,
      :SHIELDSDOWN,
      :STANCECHANGE,
      :ZENMODE,
      # Appearance-changing abilities
      :ILLUSION,
      :IMPOSTER,
      # Abilities intended to be inherent properties of a certain species
      :COMATOSE,
      :RKSSYSTEM,
	  :NEUTRALIZINGGAS,
	  :HUNGERSWITCH
    ]
    return ability_blacklist.include?(abil.id)
  end
  
	def hasLevitate?
		return hasActiveAbility?([:LEVITATE, :DESERTSPIRIT])
	end
	
	def airborne?
		return false if hasActiveItem?(:IRONBALL)
		return false if @effects[PBEffects::Ingrain]
		return false if @effects[PBEffects::SmackDown]
		return false if @battle.field.effects[PBEffects::Gravity] > 0
		return true if pbHasType?(:FLYING)
		return true if hasLevitate? && !@battle.moldBreaker
		return true if hasActiveItem?(:AIRBALLOON)
		return true if @effects[PBEffects::MagnetRise] > 0
		return true if @effects[PBEffects::Telekinesis] > 0
		return false
	end
  
  # permanent is whether the item is lost even after battle. Is false for Knock
  # Off.
	def pbRemoveItem(permanent = true)
		permanent = false # Items respawn after battle always!!
		@effects[PBEffects::ChoiceBand] = nil
		@effects[PBEffects::Unburden]   = true if self.item
		setInitialItem(nil) if permanent && self.item == self.initialItem
		self.item = nil
		@battle.scene.pbRefresh()
	end
	
	def immuneToHazards?
		return true if hasActiveItem?(:HEAVYDUTYBOOTS)
		return false
	end
  
  #=============================================================================
  # Calculated properties
  #=============================================================================
  def pbSpeed
    return 1 if fainted?
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    stage = @stages[:SPEED] + 6
	  stage = 6 if stage > 6 && paralyzed?
    speed = @speed*stageMul[stage]/stageDiv[stage]
    speedMult = 1.0
    # Ability effects that alter calculated Speed
    if abilityActive?
      speedMult = BattleHandlers.triggerSpeedCalcAbility(self.ability,self,speedMult)
    end
    # Item effects that alter calculated Speed
    if itemActive?
      speedMult = BattleHandlers.triggerSpeedCalcItem(self.item,self,speedMult)
    end
    # Other effects
    speedMult *= 2 if pbOwnSide.effects[PBEffects::Tailwind]>0
    speedMult /= 2 if pbOwnSide.effects[PBEffects::Swamp]>0
    # Paralysis and Chill
    if (paralyzed? || frozen?) && !hasActiveAbility?(:QUICKFEET)
      speedMult /= (Settings::MECHANICS_GENERATION >= 7) ? 2 : 4
    end
    # Calculation
    return [(speed*speedMult).round,1].max
  end
  
  def hasActiveItem?(check_item, ignore_fainted = false)
    return false if !itemActive?(ignore_fainted)
    return check_item.include?(@item_id) if check_item.is_a?(Array)
    return check_item == @item_id
  end

  def hasHonorAura?
      return hasActiveAbility?([:HONORAURA])
  end

  def isLastAlive?
    return false if @battle.wildBattle? && opposes?
    return false if fainted?
    return @battle.pbGetOwnerFromBattlerIndex(@index).able_pokemon_count == 1
  end

end