class Book < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :price, presence: true
  validates :published_date, presence: true
end
