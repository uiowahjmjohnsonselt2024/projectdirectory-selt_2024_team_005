FactoryBot.define do
  factory :item do
    rarity { rand(1..5) }
    cost { rand(1..1000) * rarity }
    level { rand(1..50) }

    trait :weapon do
      association :itemable, factory: :weapon
    end

    trait :armor do
      association :itemable, factory: :armor
    end

    trait :potion do
      association :itemable, factory: :potion
    end
  end
end