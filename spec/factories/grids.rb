FactoryBot.define do
  factory :grid do
    sequence(:name) { |n| "Grid #{n}" }
    created_at { Time.current }
    updated_at { Time.current }
  end
end
