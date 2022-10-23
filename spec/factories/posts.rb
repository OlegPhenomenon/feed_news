FactoryBot.define do
  factory :post do
    status { 0 }
    published_at { nil }
    title { Faker::Food.dish }
    content { Faker::Lorem.sentence(word_count: rand(100..300)).chomp('.') }
    association :user, factory: :user
  end
end
