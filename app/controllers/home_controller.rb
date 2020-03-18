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
