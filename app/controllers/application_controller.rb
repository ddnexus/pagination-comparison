class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from Pagy::OverflowError, :with => :redirect_to_page_20

  private

  def redirect_to_page_20
    redirect_to url_for(page: 20), notice: %(Page ##{params[:page]} is a page out of range. Showing page #20 instead.)
  end

end
