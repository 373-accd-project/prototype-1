require 'rest_client'
require 'json'
require 'csv'
# require '../services/json_manager'
class HomeController < ApplicationController
  def index
    if params.has_key?(:series_id)
      @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
      parsed_json = JSON(@manager.apiCall(params[:series_id], 2010, 2020))
      @reply = parsed_json
      session[:series_id] = params[:series_id]
    end

    @area_codes = CSV.read('csv_files/area_titles.csv')[1..]
    @data_types = CSV.read('csv_files/datatype_titles.csv')[1..]
    @industries = CSV.read('csv_files/industry_titles.csv')[1..]
    @ownership = CSV.read('csv_files/ownership_titles.csv')[1..]
    @sizes = CSV.read('csv_files/size_titles.csv')[1..]
    for area_code in @area_codes do
      tmp = area_code[0]
      area_code[0] = area_code[1]
      area_code[1] = tmp
    end
    for data_type in @data_types do
      tmp = data_type[0]
      data_type[0] = data_type[1]
      data_type[1] = tmp
    end
    for industry in @industries do
      tmp = industry[0]
      industry[0] = industry[1]
      industry[1] = tmp
    end
    for ownership in @ownership do
      tmp = ownership[0]
      ownership[0] = ownership[1]
      ownership[1] = tmp
    end
    for size in @sizes do
      tmp = size[0]
      size[0] = size[1]
      size[1] = tmp
    end
  end
  def download_csv
    @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
    parsed_json = JSON(@manager.apiCall(session[:series_id], 2010, 2020))
    @reply = parsed_json['Results']['series'][0]['data']
    file = CSV.generate do |csv|
      @reply.each do |hash|
        csv << hash.values
      end
    end
    # p "Hello!"
    # p file
    # send_data('Hello, pretty world :(', :type => 'text/plain', :disposition => 'attachment', :filename => 'hello.txt')
    send_data file, :type => 'text/csv; charset=iso-8859-1; header=present', :filename => "data.csv"
  end
end
