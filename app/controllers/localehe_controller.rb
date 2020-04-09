require 'rest_client'
require 'json'
require 'csv'

#SMU4810180000000000001
#SMU48101800000000001

class LocaleheController < ApplicationController
  def index
    if params.has_key?(:year)
      generated_id = "SMU" + params[:state_code]
      generated_id = generated_id + params[:area_code]
      #generated_id = generated_id + params[:supersector]
      #puts generated_id, generated_id.length
      generated_id = generated_id + params[:industry]
      generated_id = generated_id + params[:data_type]
      @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
      parsed_json = JSON(@manager.apiCall(generated_id, 2010, 2020))
      @reply = parsed_json
      IO.write("csv_files/temp.csv", parsed_json)

      session[:state_code] = params[:state_code]
      session[:area_code] = params[:area_code]
      session[:supersector] = params[:supersector]
      session[:industry] = params[:industry]
      session[:data_type] = params[:data_type]
    end

    @state_codes = CSV.read('csv_files/localehe/state_codes.csv')[1..]
    @area_codes = CSV.read('csv_files/localehe/area_codes.csv')[1..]
    @supersectors = CSV.read('csv_files/localehe/supersector_codes.csv')[1..]
    @industries = CSV.read('csv_files/localehe/industry_codes.csv')[1..]
    @data_types = CSV.read('csv_files/localehe/data_type_codes.csv')[1..]
    @state_initials = CSV.read('csv_files/localehe/state_initials.csv')[1..]
    @state_initials.to_h

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
    for supersector in @supersectors do
      tmp = supersector[0]
      supersector[0] = supersector[1]
      supersector[1] = tmp
    end
    for state_code in @state_codes do
      tmp = state_code[0]
      state_code[0] = state_code[1]
      state_code[1] = tmp
    end
  end
  def download_csv
    @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
    generated_id = "SMU" + session[:state_code] + session[:area_code] + session[:supersector] + session[:industry] + session[:data_type]
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
