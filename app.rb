require 'sinatra'

class CutSheets < Sinatra::Base
  get '/' do
    erb :index
  end
end 