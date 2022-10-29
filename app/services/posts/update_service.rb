module Posts
  class UpdateService
    include BaseService
    include CanCan::Ability

    attr_reader :params, :post

    def initialize(params:, post:)
      @params = params
      @post = post
    end

    def self.call(params:, post:)
      new(params: params, post: post).call
    end

    def call
      params[:published_at] = Time.zone.now if published?

      if post.update(params.to_h)
        struct_object(success: true, instance: post)
      else
        struct_object(success: false, errors: post.errors.full_messages.join('; '))
      end
    end

    private

    def published?
      params[:status] == 'published' && post.published_at.nil?
    end

    # def determine_type
    #   if post.attachable_post?
    #     'AttachablePost'
    #   elsif post.article_post?
    #     'ArticlePost'
    #   elsif post.message_post?
    #     'MessagePost'
    #   end
    # end
  end
end
