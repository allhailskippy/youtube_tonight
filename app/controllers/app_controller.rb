class AppController < ApplicationController
  def index
    authorize :app, :index?
  end
end
