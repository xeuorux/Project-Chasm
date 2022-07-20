##############################################
# GENERATION REWARDS
##############################################

gen1Rewards = [:POKEBALL,:POKEBALL,:GREATBALL,:GREATBALL,:ULTRABALL,[:ULTRABALL,2]]
gen1Thresholds = [14,23,36,58,94,151]

gen2Rewards = [:POKEBALL,:POKEBALL,:GREATBALL,:GREATBALL,:ULTRABALL]
gen2Thresholds = [15,25,40,65,100]

gen3Rewards = gen1Rewards
gen3Thresholds = [12,20,32,52,84,135]

gen4Rewards = gen2Rewards
gen4Thresholds = [16,26,41,66,107]

gen5Rewards = gen1Rewards
gen5Thresholds = [15,25,40,60,100,156]

gen6Rewards = [:POKEBALL,:POKEBALL,:GREATBALL,:GREATBALL]
gen6Thresholds = [17,28,45,72]

generationRewardsHash = {
    gen1Thresholds => gen1Rewards,
    gen2Thresholds => gen2Rewards,
    gen3Thresholds => gen3Rewards,
    gen4Thresholds => gen4Rewards,
    gen5Thresholds => gen5Rewards,
    gen6Thresholds => gen6Rewards,
}

generationRewardsHash.each_with_index do |kvp,generationIndex|
    generationThresholds    = kvp[0]
    generationRewards       = kvp[1]
    realGeneration          = generationIndex + 1
    generationThresholds.each_with_index do |threshold,thresholdIndex|
        id = ("GEN" + realGeneration.to_s + "AWARD" + thresholdIndex.to_s).to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                next generationReward(realGeneration,threshold,generationRewards[thresholdIndex])
            }
        )
    end
end

##############################################
# TYPE REWARDS
##############################################
typeThreshold = [10,25,50]
typeRewards = [:EXPCANDYM,:EXPCANDYL,:EXPCANDYXL]

PokEstate::LoadDataDependentAwards += proc {
    # For every type, create three award event subscribers at different thresholds
    GameData::Type.each do |type|
        next if type.pseudo_type 
        typeThreshold.each_with_index do |threshold,thresholdIndex|
            id = ("TYPE" + type.id.to_s + "AWARD" + thresholdIndex.to_s).to_sym
            PokEstate::GrantAwards.add(id,
                proc { |pokedex|
                    next typeReward(type.id,threshold,typeRewards[thresholdIndex])
                }
            )
        end
    end
}