FactoryBot.define do
  factory :weapon do
    name { Faker::Weapon.name }
    atk_bonus { rand(1..10) }
  end
end