module Faker
  class Armor
    ARMOR_NAMES = [
      "Ironclad Breastplate", "Dragon Scale Armor", "Mithril Cuirass",
      "Steel Plate Mail", "Woolen Tunic", "Leather Vest",
      "Elven Chainmail", "Golden Brigandine", "Darksteel Shield",
      "Silvered Armor", "Reinforced Hide Armor", "Wicked Witch Robes"
    ]

    def self.name
      ARMOR_NAMES.sample
    end
  end
end
