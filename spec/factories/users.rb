FactoryBot.define do
  factory :user do
    username { Faker::Name.unique.name }
    email { Faker::Internet.email }
    password { 'Password' }
    password_confirmation { 'Password' }
  end
end
