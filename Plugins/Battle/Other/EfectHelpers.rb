def singleProtectEffects()
    return [PBEffects::BanefulBunker,PBEffects::KingsShield,PBEffects::Protect,PBEffects::SpikyShield]
end

def sideProtectEffects()
    return [PBEffects::CraftyShield,PBEffects::MatBlock,PBEffects::QuickGuard,PBEffects::WideGuard]
end
  
class PokeBattle_Move
    def removeProtections(target)
        singleProtectEffects().each do |single_protect_effect|
            target.effects[single_protect_effect] = false
        end
        sideProtectEffects().each do |side_protect_effect|
            target.pbOwnSide.effects[side_protect_effect] = false
        end
    end
end