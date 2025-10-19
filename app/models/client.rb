class Client < ApplicationRecord
  validates :name, presence: true
  validates :identification, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
