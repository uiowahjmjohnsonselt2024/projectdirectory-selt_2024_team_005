module Faker
  class Weapon
    WEAPON_NAMES = [
      "Excalibur", "Silver Sword", "Dagger of Shadows", "Greatsword of the Ancients",
      "Gleaming Longsword", "Battle Axe", "Stormbreaker", "Dragon’s Claw",
      "Steel Katana", "Warhammer", "Bloodletter", "Falchion"
    ]

    def self.name
      WEAPON_NAMES.sample
    end
  end
end
