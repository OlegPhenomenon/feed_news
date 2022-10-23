3.times do |_i|
  User.create(
    email: Faker::Internet.email,
    username: Faker::Name.unique.name,
    password: '123456',
    password_confirmation: '123456'
  )
end

# published posts
10.times do |_i|
  Post.create(
    status: 2,
    published_at: Time.zone.now,
    title: Faker::Food.fruits,
    body: Faker::Lorem.sentence(word_count: rand(300..1000)).chomp('.'),
    user_id: User.pluck(:id).sample
  )
end
