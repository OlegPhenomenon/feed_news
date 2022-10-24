FactoryBot.define do
  factory :pin do
    association :user, factory: :user
    association :post, factory: :post
    position { 0 }
    bg_color { '#74b9ff' }
  end
end
