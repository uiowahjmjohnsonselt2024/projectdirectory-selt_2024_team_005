FactoryBot.define do
  factory :potion do
    name { Faker::Potion.name }
    hp_regen { rand(10..50) }
  end
end
