class HomeController < ApplicationController
  def index
  end

  def about
    @title = "About"
    @description = "This is the about page of our application."
  end
end
