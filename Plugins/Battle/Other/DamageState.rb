class PokeBattle_DamageState
	attr_accessor :iceface         # Ice Face ability used
	attr_accessor :displayedDamage
	
	def resetPerHit
		@missed        		= false
		@calcDamage    		= 0
		@hpLost       	 	= 0
		@displayedDamage 	= 0
		@critical      		= false
		@substitute    		= false
		@focusBand     		= false
		@focusSash     		= false
		@sturdy        		= false
		@disguise      		= false
		@endured       		= false
		@berryWeakened 		= false
		@iceface       		= false
	end
end