class Post < ApplicationRecord
  belongs_to :user
  alias_attribute :author, :user

  has_many_attached :images
  has_rich_text :content
  has_many :pins, dependent: :destroy

  enum status: %i[draft hidden published]

  scope :with_user_draft, ->(user) { where(user_id: user.id, status: 0) }
  scope :with_user_hidden, ->(user) { where(user_id: user.id, status: 1) }
  scope :with_published, -> { where(status: 2) }

  scope :with_no_user_draft, lambda { |user, hide_draft|
    return if user.nil?
    return unless hide_draft.present?

    where.not(user_id: user.id, status: 0)
  }

  scope :with_no_user_hidden, lambda { |user, hide_hidden|
    return if user.nil?
    return unless hide_hidden.present?

    where.not(user_id: user.id, status: 1)
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

  before_create :assign_published_at
  before_update :assign_published_at

  validate :title_mandatory, on: %i[create update]
  validate :body_mandatory, on: %i[create update]

  def title_mandatory
    return if title.empty? && body_text_contain_validator

    errors.add(:base, I18n.t('posts.errors.title_mandatory')) if title.empty? && content.body.attachables.present?
  end

  def body_mandatory
    return if content.body.attachables.any? { |f| f.class.name == 'Youtube' }

    errors.add(:base, I18n.t('posts.errors.body_mandatory')) if title.empty? && !content?
  end

  def body_text_contain_validator
    attachables_objects = content.body.attachables.map do |f|
      next if f.class.name == 'Youtube'

      "[#{f.filename}]"
    end

    pure_text = content.to_plain_text.gsub(attachables_objects.join, '').strip
    pure_text.size.positive?
  end

  def assign_published_at
    if status == 'published' && published_at.nil?
      self.published_at = Time.zone.now
    end
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
