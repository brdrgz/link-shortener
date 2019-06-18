class ShortLinksController < ApplicationController
  def index
    short_url = params.require(:short_url)

    begin
      id = ShortLink.id_from_short_url(short_url)
    rescue ArgumentError
      render plain: "Not a valid URL!", status: :bad_request and return
    end

    short_link = ShortLink.find(id)
    
    if !short_link.expired?
      short_link.view_count += 1
      short_link.save
      redirect_to short_link.original_url, status: :found and return
    else
      render plain: "That link has expired!", status: :not_found and return
    end
  end

  def new
    @short_link = ShortLink.new
  end

  def create
    shortened_url = ShortLink.new
    shortened_url.original_url = short_link_params[:original_url]
    shortened_url.admin_url = ShortLink.generate_admin_url
    
    if shortened_url.save
      redirect_to(shortened_url)
    else
      render plain: "That's not a valid URL!", status: :bad_request
    end
  end

  def show
    @short_link = ShortLink.find(params.require(:id))
  end

  def edit
    admin_url = params.require(:admin_url)
    @short_link = ShortLink.find_by_admin_url!(admin_url)
  end

  def update
    @short_link = ShortLink.find(params.require(:id))

    begin
      @short_link.update(expired: short_link_params[:expired])
    rescue ActionController::ParameterMissing
      @short_link.update(expired: false)
    end

    redirect_to admin_path(@short_link.admin_url)
  end

  private

  def short_link_params
    params.require(:short_link).permit(:original_url, :id, :expired)
  end
end
