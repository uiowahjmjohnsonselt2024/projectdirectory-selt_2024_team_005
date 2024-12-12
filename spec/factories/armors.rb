FactoryBot.define do
  factory :armor do
    name { Faker::Armor.name }
    def_bonus { rand(1..10) }
  end
end