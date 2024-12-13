FactoryBot.define do
  factory :character do
    sequence(:character_name) { |n| "character_#{n}" }
    username { "test_user" }
    level { 1 }
    grid_id { create(:grid).grid_id }
    cell_id { create(:cell, grid_id: grid_id).cell_id }
    inv_id { create(:inventory).inv_id }
  end
end
