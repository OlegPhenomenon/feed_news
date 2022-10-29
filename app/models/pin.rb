class Pin < ApplicationRecord
  include Moveable

  belongs_to :user
  belongs_to :post

  validates_uniqueness_of :user_id, scope: :post_id, message: I18n.t('pins.errors.duplicate_pin')
end
