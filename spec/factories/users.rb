FactoryBot.define do
  factory :user do
    username { "test_user" }
    email { "test_user@example.com" }
    password_digest { BCrypt::Password.create("password123") }
    shard_balance { 0 }
    created_at { Time.current }
    updated_at { Time.current }
  end
end
