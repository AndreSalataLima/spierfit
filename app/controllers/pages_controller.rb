class PagesController < ApplicationController
  layout 'welcome', only: [:welcome]

  def welcome
  end

end
