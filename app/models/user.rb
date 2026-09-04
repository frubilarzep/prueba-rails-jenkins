class User < ApplicationRecord
  has_secure_password

  before_validation :normalize_email

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  def as_json(options = nil)
    super({ only: %i[id email] }.merge(options || {}))
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
