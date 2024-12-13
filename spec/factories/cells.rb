FactoryBot.define do
  factory :cell do
    sequence(:cell_loc) { |n| "Location #{n}" }
    mons_prob { rand(0.0..1.0) }
    disaster_prob { rand(0.0..1.0) }
    weather { %w[Sunny Rainy Snowy Windy].sample }
    terrain { %w[Grassland Forest Mountain Desert].sample }
    has_store { [ true, false ].sample }
    association :grid
    created_at { Time.current }
    updated_at { Time.current }
  end
end
