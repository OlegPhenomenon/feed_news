require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }

  describe 'scopes' do
    let(:second_user) { create(:user) }

    describe 'draft scope' do
      let(:post) { create(:post) }

      it 'returns user draft posts' do
        post.update(user: user)
        post.reload
        expect(post.draft?).to be_truthy

        result = Post.with_user_draft(user)
        expect(result.count).to be 1
      end

      it 'should not return author draft posts for another user' do
        post.update(user: user)
        post.reload
        expect(post.draft?).to be_truthy

        result = Post.with_user_draft(second_user)
        expect(result.count).to be 0
      end
    end

    describe 'hidden scope' do
      let(:post) { create(:post) }

      it 'returns user hidden posts' do
        post.update(user: user, status: 1)
        post.reload
        expect(post.hidden?).to be_truthy

        result = Post.with_user_hidden(user)
        expect(result.count).to be 1
      end

      it 'should not return author hidden posts for another user' do
        post.update(user: user, status: 1)
        post.reload
        expect(post.hidden?).to be_truthy

        result = Post.with_user_hidden(second_user)
        expect(result.count).to be 0
      end
    end

    describe 'published scope' do
      let(:post) { create(:post) }

      it 'should return published posts' do
        post.update(status: 2)

        expect(post.published?).to be_truthy

        result = Post.with_published
        expect(result.count).to be 1
      end
    end

    describe 'list of posts' do
      let(:published_post) { create(:post, status: 2, user: user) }
      let(:hidden_post) { create(:post, status: 1, user: user) }
      let(:draft_post) { create(:post, status: 0, user: user) }

      before(:each) do
        published_post.reload
        hidden_post.reload
        draft_post.reload
        user.reload
      end

      it 'should return all users posts' do
        expect(Post.with_list(user).count).to eq 3
      end

      it 'should return only published posts for guests' do
        expect(Post.with_list(nil).count).to eq 1
      end

      it 'should return only published posts for another user' do
        expect(Post.with_list(second_user).count).to eq 1
      end
    end

    describe 'without pins' do
      let(:published_post1) { create(:post, status: 2, user: user) }
      let(:published_post2) { create(:post, status: 2, user: user) }
      let(:published_post3) { create(:post, status: 2, user: user) }
      let(:pin) { build(:pin) }

      before(:each) do
        published_post1.reload
        published_post2.reload
        published_post3.reload
        user.reload
      end

      it 'should return list of posts what not were added as pin' do
        pin.user_id = user.id
        pin.post_id = published_post1.id
        pin.position = 0
        pin.save

        expect(Post.without_user_pins(user).count).to eq 2
      end
    end
  end

  describe 'search' do
    params = {}
    let(:published_post1) { create(:post, status: 2, user: user) }
    let(:published_post2) { create(:post, status: 2, user: user) }
    let(:published_post3) { create(:post, status: 2, user: user) }
    let(:second_user) { create(:user) }

    before(:each) do
      published_post1.reload
      published_post2.reload
      published_post3.reload
      user.reload
      second_user.reload
    end

    it 'should return published posts by title' do
      title = published_post1.title
      params[:title] = title

      result = Post.search(user, params)

      expect(result.last).to eq published_post1
    end

    it 'should not return author hidden posts for another user' do
      published_post1.update(status: 1)
      title = published_post1.title
      params[:title] = title

      expect(published_post1.hidden?).to be_truthy
      expect(published_post1.user).to eq user

      result = Post.search(second_user, params)

      expect(result).to be_empty
    end

    # it 'should not return author draft posts for another user' do
    #   published_post1.update(status: 0)
    #   title = published_post1.title
    #   params[:title] = title

    #   expect(published_post1.draft?).to be_truthy
    #   expect(published_post1.user).to eq user

    #   result = Post.search(second_user, params)

    #   expect(result).to be_empty
    # end
  end

  describe 'callbacks' do
    let(:draft_post1) { create(:post, status: 0, user: user) }
    let(:draft_post2) { build(:post, status: 0, user: user) }

    it 'published_at should be nil if status not published during create' do
      draft_post2.save

      expect(draft_post2.published_at).to be_nil
    end

    it 'published_at should be nil if status not published during update' do
      draft_post1.update(status: 1)

      expect(draft_post1.published_at).to be_nil
    end

    it 'should set published_at if post created as published' do
      draft_post2.status = 2
      draft_post2.save

      expect(draft_post2.published_at).not_to be_nil
    end

    it 'should set published_at if post updated as published' do
      draft_post1.update(status: 2)

      expect(draft_post1.published_at).not_to be_nil
    end

    it 'should keep published_at value from the first time' do
      draft_post1.update(status: 2)

      expect(draft_post1.published_at).not_to be_nil
      published_timestap = draft_post1.published_at

      draft_post1.update(status: 1)
      draft_post1.update(status: 2)

      expect(draft_post1.published_at).to be published_timestap
    end
  end

  describe 'validations' do
    let(:draft_post) { build(:post, status: 0, user: user) }

    it 'should create post without title, but with content' do
      draft_post.title = ''
      draft_post.content = '<p>Hello, World!</p>'
      expect(draft_post).to be_valid
      expect(draft_post.save).to be true
    end

    it 'shoud return an error if content and title are empty' do
      draft_post.title = ''
      draft_post.content = ''

      expect(draft_post).to_not be_valid
      expect(draft_post.errors.messages[:base]).to include(I18n.t('posts.errors.body_mandatory'))
    end

    # it 'shoud not return attaches post without title' do
    #   # p.content.body.attachments
    #   # file = Rails.root.join('spec', 'support', 'assets', 'shipment_item', 'wine-box.jpeg')
    #   # image = ActiveStorage::Blob.create_after_upload!( io: File.open(file, 'rb'),  filename: 'wine-box.jpeg',  content_type: 'image/jpeg' 
    #   # Or figure it out from `name` if you have non-JPEGs).signed_id  shipment_item = ShipmentItem.new(image: image)  expect(shipment_item.valid?).to eq true

    #    #<ActionText::Attachment attachable=#<ActiveStorage::Blob id: 50, key: "kuwnim8qtpozrfe9p7ijcr9kpgaq", filename: "22.jpg", content_type: "image/jpeg", metadata: {"identified"=>true, "width"=>6016, "height"=>4016, "analyzed"=>true}, service_name: "local", byte_size: 2729023, checksum: "mJx1s+fx76lHxWzpMsZtCQ==", created_at: "2022-10-23 08:09:02.323994000 +0000">>] 

    #   file = Rails.root.join('spec', 'support', 'assets', 'default_image.png')
    #   image = ActiveStorage::Blob.create_and_upload!(io: File.open(file, 'rb'), filename: 'defalt_image.png', content_type: 'image/jpepng')
    #   draft_post.content = ''
    #   draft_post.content.body.attachables.grep(image).uniq
    #   draft_post.save
    #   p '----'
    #   p draft_post.errors
    #   p draft_post.content.body.attachments
    #   p '----'
    #   p draft_post.content.to_plain_text
    # end
  end
end
