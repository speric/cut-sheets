require 'sinatra'
require 'csv'
require './lib/quickpen_fabricator'

get '/' do
  erb :index
end

post '/parse' do
  if params[:csv_from_quickpen].nil?
  	"Please upload a CSV"
  else
  	fabrication = QuickpenFabricator.new(import_file: params[:csv_from_quickpen][:tempfile].read)
    headers "Content-Disposition" => "attachment;filename=cut-sheets.csv", "Content-Type" => "text/csv"
    fabrication.generate_cut_sheets_csv_data
  end
end