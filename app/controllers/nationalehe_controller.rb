require 'rest_client'
require 'json'
require 'csv'

#SMU4810180000000000001
#SMU48101800000000001
class NationaleheController < ApplicationController
  def index
    if params.has_key?(:year)
      generated_id = "CEU" + params[:industry]
      puts generated_id, generated_id.length
      generated_id = generated_id + params[:data_type]
      puts generated_id, generated_id.length
      @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
      parsed_json = JSON(@manager.apiCall(generated_id, 2010, 2020))
      @reply = parsed_json
      session[:supersector] = params[:supersector]
      session[:industry] = params[:industry]
      session[:data_type] = params[:data_type]
    end

    @supersectors = CSV.read('csv_files/nationalehe/supersector_codes.csv')[1..]
    @industries = CSV.read('csv_files/nationalehe/industry_codes.csv')[1..]
    @data_types = CSV.read('csv_files/nationalehe/data_type_codes.csv')[1..]
    @state_initials.to_h

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
    for supersector in @supersectors do
      tmp = supersector[0]
      supersector[0] = supersector[1]
      supersector[1] = tmp
    end
  end
  def download_csv
    @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
    generated_id = "CEU" + session[:industry] + session[:data_type]
    puts generated_id
    parsed_json = JSON(@manager.apiCall(:generated_id, 2010, 2020))
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
