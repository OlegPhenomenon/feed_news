module Posts
  class CreateService
    include BaseService
    include CanCan::Ability

    attr_reader :user, :params

    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def self.call(user:, params:)
      new(user: user, params: params).call
    end

    def call
      @post = Post.new params.to_h
      @post.user = user
      @post.type = determine_type
      @post.published_at = Time.zone.now if published?

      if @post.save
        struct_object(success: true, instance: @post)
      else
        struct_object(success: false, errors: @post.errors.full_messages.join('; '))
      end
    end

    private

    def published?
      params[:status] == 'published'
    end

    def determine_type
      if @post.attachable_post?
        'AttachablePost'
      elsif @post.article_post?
        'ArticlePost'
      elsif @post.message_post?
        'MessagePost'
      end
    end
  end
end
