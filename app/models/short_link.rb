class ShortLink < ApplicationRecord
  CHARSET = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.freeze
  BASE = CHARSET.length.freeze
  MAX_LINK_LENGTH = 6.freeze

  # This is the smallest admin link length
  # that will cover all possible number of
  # short links
  #
  # e.g.
  # 62^6 ~ 56 billion possible short urls
  # 64^4 ~ 16 million possible admin urls
  # 64^5 ~ 1 billion possible admin urls
  # 64^6 ~ 68 billion possible admin urls
  #
  # The length of a base-64 encoded is 
  #
  #   4 * ceil(n / 3)
  #
  # where n is the length of the decoded string.
  #
  # Therefore, the minimum length encoded string
  # we can get by with is 8 characters.
  # That's with padding.  We want these to be
  # url-safe so we'll only get 6 or 7 characters,
  # which is still enough.
  #
  # Now we have to decide which value to choose
  # for n.  4, 5, and 6 will all satisfy the equation.
  #
  # 4 bytes -> 2^32 ~ 4 billion possible values to encode
  # Not enough for 56 billion ShortLinks!
  # 5 bytes -> 2^40 ~ 1 trillion possible values to encode
  # That ought to be enough.
  # So we need 5 random bytes, which will give us
  # 7 base-64 digits without padding.
  MIN_RANDOM_BYTES = 5.freeze
  ADMIN_LINK_LENGTH = (4 * (MIN_RANDOM_BYTES.to_f/3).ceil - 1).freeze

  validates :original_url, :view_count, :admin_url, presence: true
  validates :original_url, format: { with: /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix }
  validates :view_count, numericality: { only_integer: true }
  validates :admin_url,
            length: { is: ADMIN_LINK_LENGTH },
            uniqueness: true
  validates :expired, inclusion: { in: [true, false] }

  validate :admin_url_must_be_base64_urlsafe, unless: ->(r) { r.admin_url.nil? }

  def short_url
    n = id
    url_chars = []

    while n > 0
      url_chars.insert(0, CHARSET[n % BASE])
      n /= BASE
    end

    url_chars.join
  end

  def self.id_from_short_url(s)
    chars = s.chars
    length = chars.length
    n = 0

    if length > MAX_LINK_LENGTH || chars.any? { |c| CHARSET.index(c).nil? }
      raise ArgumentError, "Invalid URL."
    end
    
    chars.each_with_index do |c, i|
      place = (length-1) - i 
      n += CHARSET.index(c) * BASE ** place
    end

    n
  end

  def self.generate_admin_url
    SecureRandom.urlsafe_base64(MIN_RANDOM_BYTES)
  end

  def admin_url_must_be_base64_urlsafe
    begin
      Base64.urlsafe_decode64(admin_url)
    rescue ArgumentError
      errors.add(:admin_url, "is not valid url-safe base64")
    end
  end
end
