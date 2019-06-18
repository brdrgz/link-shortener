require 'rails_helper'

RSpec.describe ShortLink, type: :model do
  describe "validations" do
    it "is not valid without an original_url" do
      short_link = ShortLink.new(
        original_url: nil,
        admin_url: "Omd7Uec",
        view_count: 0,
        expired: false
      )
      expect(short_link).to_not be_valid
    end

    it "is not valid without a valid original_url" do
      short_link = ShortLink.new(
        original_url: "test",
        admin_url: "Omd7Uec",
        view_count: 0,
        expired: false
      )
      expect(short_link).to_not be_valid
    end

    it "is not valid without a view_count" do
      short_link = ShortLink.new(
        original_url: "http://test.com",
        admin_url: "Omd7Uec",
        view_count: nil,
        expired: false
      )
      expect(short_link).to_not be_valid
    end

    it "is not valid with a nonsense view_count" do
      short_link = ShortLink.new(
        original_url: "http://test.com",
        admin_url: "Omd7Uec",
        view_count: 2.5,
        expired: false
      )
      expect(short_link).to_not be_valid
    end
    
    it "is not valid without an admin_url" do
      short_link = ShortLink.new(
        original_url: "http://test.com",
        admin_url: nil,
        view_count: 0,
        expired: false
      )
      expect(short_link).to_not be_valid
    end

    it "is not valid with an admin_url that's too short" do
      short_link = ShortLink.new(
        original_url: "http://test.com",
        admin_url: "507zXg",
        view_count: 0,
        expired: false
      )
      expect(short_link).to_not be_valid
    end

    it "is not valid with an admin_url that's too long" do
      short_link = ShortLink.new(
        original_url: "http://test.com",
        admin_url: "GVVxX_Fv",
        view_count: 0,
        expired: false
      )
      expect(short_link).to_not be_valid
    end

    it "is not valid with an admin_url that's not base64" do
      short_link = ShortLink.new(
        original_url: "http://test.com",
        admin_url: "123@567",
        view_count: 0,
        expired: false
      )
      expect(short_link).to_not be_valid
    end

    it "is not valid with a duplicate admin_url" do
      short_link = ShortLink.new(
        original_url: "http://test.com",
        admin_url: "Omd7Uec",
        view_count: 0,
        expired: false
      )

      short_link.save

      new_short_link = ShortLink.new(
        original_url: "http://test2.com",
        admin_url: "Omd7Uec",
        view_count: 1,
        expired: true
      )
      expect(new_short_link).to_not be_valid
    end

    it "is not valid without an expired flag" do
      short_link = ShortLink.new(
        original_url: "http://test.com",
        admin_url: "Omd7Uec",
        view_count: 0,
        expired: nil
      )
      expect(short_link).to_not be_valid
    end

    it "is valid when valid parameters are given" do
      short_link = ShortLink.new(
        original_url: "http://test.com",
        admin_url: "Omd7Uec",
        view_count: 0,
        expired: false
      )
      expect(short_link).to be_valid
    end
  end

  describe "id_from_short_url" do
    it "raises an error when short_url is not base62" do
      expect {
        ShortLink.id_from_short_url('aAb_01')
      }.to raise_error(ArgumentError)
    end

    it "raises an error when short_url is too long" do
      expect {
        ShortLink.id_from_short_url('aAbB012')
      }.to raise_error(ArgumentError)
    end

    it "converts a base62 value to base10 integer" do
      expect(ShortLink.id_from_short_url('a')).to eq(0)
      expect(ShortLink.id_from_short_url('xYz123')).to eq(21_816_037_271)
    end
  end

  describe "short_url" do
    it "converts record id to short_url (base62 value)" do
      short_link = ShortLink.new(
        id: 259_388,
        original_url: "http://test.com",
        admin_url: "Omd7Uec",
        view_count: 0,
        expired: false
      )
      short_link.save

      expect(short_link.short_url).to eq('bfDQ')
    end
  end
end
