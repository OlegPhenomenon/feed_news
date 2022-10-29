class Post < ApplicationRecord
  belongs_to :user
  alias_attribute :author, :user

  has_many_attached :images
  has_rich_text :content
  has_many :pins, dependent: :destroy

  enum :status, { draft: 0, hidden: 1, published: 2 }

  def self.types
    %w[AttachablePost ArticlePost MessagePost]
  end

  attr_accessor :disable_edit

  scope :with_published, -> { published }
  scope :with_no_user_draft, lambda { |user, hide_draft|
    return if user.nil?
    return unless hide_draft.present?

    not_draft
  }
  scope :with_no_user_hidden, lambda { |user, hide_hidden|
    return if user.nil?
    return unless hide_hidden.present?

    not_hidden
  }

  scope :with_list, lambda { |user|
    return with_published if user.nil?

    where(user_id: user.id, status: [0, 1]).or(with_published)
  }

  scope :without_user_pins, lambda { |user|
    return unless user.present?

    pin_post_ids = user.pins.pluck(:post_id)

    where.not(id: pin_post_ids)
  }

  scope :with_title, lambda { |title|
    return unless title.present?

    where('title ilike ?', "%#{title}%")
  }

  validates :title, presence: true, if: :attachable_post?
  validates :title, presence: true, if: :article_post?
  validates :content, presence: true, if: :message_post?

  before_create :assign_published_at
  before_update :assign_published_at

  def attachable_post?
    content&.body&.attachables&.present? && !contain_plain_text?
  end

  def article_post?
    content.body.attachables.present? && contain_plain_text?
  end

  def message_post?
    contain_plain_text? && content.body.attachables.empty?
  end

  def contain_plain_text?
    attachables_objects = content.body.attachables.map do |f|
      next if f.instance_of?(::Youtube)

      "[#{f.filename}]"
    end

    pure_text = content.to_plain_text.gsub(attachables_objects.join, '').strip
    pure_text.size.positive?
  end

  def assign_published_at
    self.published_at = Time.zone.now if status == 'published' && published_at.nil?
  end

  def self.search(user, params = {})
    without_user_pins(user)
      .with_title(params[:title])
      .with_list(user)
      .with_no_user_draft(user, params[:hide_draft])
      .with_no_user_hidden(user, params[:hide_hidden])
      .order(sort_column(params) => sort_direction(params))
  end

  def self.sort_column(params)
    return :published_at if params[:sort_by] == 'published_at_asc' || params[:sort_by] == 'published_at_desc'

    :id
  end

  def self.sort_direction(params)
    return :desc if params[:sort_by] == 'published_at_desc'

    :asc
  end
end
