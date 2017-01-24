class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def bot

  end

  def redirect
    redirect_to "https://github.com/clintonn/memento"
  end

end
