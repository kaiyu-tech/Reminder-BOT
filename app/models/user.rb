require 'base64'

class User < ApplicationRecord
  has_many :events, dependent: :destroy

  validates :line_id_digest, presence: true, uniqueness: true, length: { maximum: 255 } # U[0-9a-f]{32}
  validates :line_name, presence: true, length: { maximum: 255 }
  validates :admin, inclusion: { in: [true, false] }
  validates :activate, inclusion: { in: [true, false] }

  # validates :expires_in
  validates :notify_token_encrypt, length: { maximum: 255 }
  # validates :reminded_at

  def self.encrypt(notify_token)
    len = ActiveSupport::MessageEncryptor.key_len
    salt = SecureRandom.hex(len)
    encrypted = User.crypt(salt, len).encrypt_and_sign(notify_token)
    "#{len}$#{salt}$#{encrypted}"
  end

  def notify_token
    return nil if self.notify_token_encrypt.nil?

    len, salt, encrypted = self.notify_token_encrypt.split("$")
    User.crypt(salt, len.to_i).decrypt_and_verify(encrypted)
  end

  def self.digest(line_id)
    salt = Rails.env.test? ? ENV['HASH_SALT_TEST'] : ENV['HASH_SALT']
    BCrypt::Engine.hash_secret(line_id, salt).slice(-31, 31)
  end

  def self.register(line_id, line_name, admin = false, activate = false)
    return false if User.search(line_id, false).present?
    User.create!(line_id_digest: User.digest(line_id), line_name: line_name, admin: admin, activate: activate)
  end

  def self.search(line_id, valid_user = true)
    if valid_user
      user = User.valid_users.find_by(line_id_digest: User.digest(line_id))
    else
      user = User.find_by(line_id_digest: User.digest(line_id))
    end
    user
  end

  def self.valid_users
    User.where('expires_in >= ? OR expires_in IS NULL', Time.zone.now)
  end

  def compare?(line_id)
    self.line_id_digest == User.digest(line_id)
  end

  private

    def self.crypt(salt, len)
      pepper = ENV['ENCRYPTION_PEPPER']
      key = ActiveSupport::KeyGenerator.new(pepper).generate_key(salt, len)
      ActiveSupport::MessageEncryptor.new(key)
    end
end