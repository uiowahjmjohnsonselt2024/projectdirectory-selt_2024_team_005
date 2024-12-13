FactoryBot.define do
  factory :inventory do
    items { [] }
    created_at { Time.current }
    updated_at { Time.current }
  end
end
