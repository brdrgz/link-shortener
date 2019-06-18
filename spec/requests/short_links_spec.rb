require "rails_helper"

RSpec.describe "Short Links", type: :request do
  # TODO: expand coverage or split out into feature spec
  it "shows the new form on homepage" do
    get "/"

    expect(response).to be_successful
    expect(response.body).to include("Paste a url")
  end

  it "redirects nonsensical paths to homepage" do
    get "/asdf980721309847"

    expect(response).to be_successful
    expect(response.body).to include("Paste a url")
  end

  it "404s when requesting nonexistent resources" do
    get "/short_links/1"

    expect(response).to be_not_found
    expect(response.body).to include("doesn't exist")
  end

  it "404s when an expired link is requested" do
    short_link = ShortLink.new(
      original_url: "http://google.com",
      admin_url: ShortLink.generate_admin_url,
      expired: true
    )
    short_link.save

    get "/s/#{short_link.short_url}"

    expect(response).to be_not_found
    expect(response.body).to include("expired")
  end

  it "redirects when a valid link is requested" do
    short_link = ShortLink.new(
      original_url: "http://google.com",
      admin_url: ShortLink.generate_admin_url
    )
    short_link.save

    get "/s/#{short_link.short_url}"

    expect(response).to redirect_to("http://google.com")
  end

  it "increments view count when a valid link is requested" do
    short_link = ShortLink.new(
      original_url: "http://google.com",
      admin_url: ShortLink.generate_admin_url
    )
    short_link.save

    get "/s/#{short_link.short_url}"

    expect(response).to redirect_to("http://google.com")
    expect(short_link.reload.view_count).to eq(1)
  end

  it "400s when an invalid short url is requested" do
    get "/s/a2E4S6l8"

    expect(response).to be_bad_request
    expect(response.body).to include("Not a valid URL")
  end

  it "redirects to show on successful link creation" do
    post "/short_links", params: { short_link: { original_url: "http://google.com" } }

    expect(response).to redirect_to(ShortLink.last)
    follow_redirect!
    expect(response.body).to include("Shortened URL")
    expect(response.body).to include(ShortLink.last.short_url)
    expect(response.body).to include("Admin URL")
    expect(response.body).to include(ShortLink.last.admin_url)
  end

  it "400s on unsuccessful link creation" do
    post "/short_links", params: { short_link: { original_url: "google" } }

    expect(response).to be_bad_request
    expect(response.body).to include("not a valid URL")
  end

  it "renders edit form when given valid admin url" do
    short_link = ShortLink.new(
      original_url: "http://google.com",
      admin_url: ShortLink.generate_admin_url
    )
    short_link.save

    get "/e/#{short_link.admin_url}"

    expect(response).to be_successful
    expect(response.body).to include("Original URL")
    expect(response.body).to include(short_link.original_url)
    expect(response.body).to include("Shortened URL")
    expect(response.body).to include(short_link.short_url)
    expect(response.body).to include("View count")
    expect(response.body).to include(short_link.view_count.to_s)
    expect(response.body).to include("Expired?")
    expect(response.body).to include("Save")
  end

  it "404s when given nonexistent admin url" do
    get "/e/abcdefg"

    expect(response).to be_not_found
    expect(response.body).to include("doesn't exist")
  end

  it "redirects back to edit on update" do
    short_link = ShortLink.new(
      original_url: "http://google.com",
      admin_url: ShortLink.generate_admin_url
    )
    short_link.save
    id = short_link.reload.id

    put "/short_links/#{id}", params: { short_link: { expired: true } }

    expect(response).to redirect_to(admin_path(short_link.admin_url))
    follow_redirect!
    expect(response.body).to include("Original URL")
    expect(response.body).to include(short_link.original_url)
    expect(response.body).to include("Shortened URL")
    expect(response.body).to include(short_link.short_url)
    expect(response.body).to include("View count")
    expect(response.body).to include(short_link.view_count.to_s)
    expect(response.body).to include("Expired?")
    expect(response.body).to include("Save")
  end
end
