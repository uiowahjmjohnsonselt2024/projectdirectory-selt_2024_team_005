module Faker
  class Potion
    POTION_NAMES = [
      'Health Potion', 'Healing Elixir', 'Potion of Vitality', 'Elixir of Life',
      'Minor Health Potion', 'Healing Brew', 'Restorative Tonic', 'Essence of Life',
      'Greater Healing Potion', 'Potion of Recovery', 'Revitalization Potion'
    ]

    def self.name
      POTION_NAMES.sample
    end
  end
end