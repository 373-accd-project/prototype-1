require 'rest_client'
require 'json'
require 'csv'

class OesController < ApplicationController
  def index
    if params.has_key?(:year)
      generated_id = "OE" + params[:seasonal_adjustment_code]
      print(params[:seasonal_adjustment_code])
      generated_id = generated_id + params[:area_type_code]
      generated_id = generated_id + params[:area_code]
      generated_id = generated_id + params[:industry_code]
      generated_id = generated_id + params[:occupation_code]
      generated_id = generated_id + params[:data_type_code]
      @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
      parsed_json = JSON(@manager.apiCall(generated_id, 2010, 2020))
      @reply = parsed_json
      session[:seasonal_adjustment_code] = params[:seasonal_adjustment_code]
      session[:occupation_code] = params[:occupation_code]
      session[:industry_code] = params[:industry_code]
      session[:area_code] = params[:area_code]
      session[:area_type_code] = params[:area_type_code]
      session[:data_type_code] = params[:data_type_code]
    end

    @seasonal_adjustment_codes = CSV.read('csv_files/oes/seasonal_adjustment_titles.csv')[1..]
    @occupation_codes = CSV.read('csv_files/oes/occupation_titles.csv')[1..]
    @industry_codes = CSV.read('csv_files/oes/industry_titles.csv')[1..]
    @area_codes = CSV.read('csv_files/oes/area_titles.csv')[1..]
    @area_type_codes = CSV.read('csv_files/oes/area_type_titles.csv')[1..]
    @data_type_codes = CSV.read('csv_files/oes/data_type_titles.csv')[1..]
    
    for seasonal_adjustment_code in @seasonal_adjustment_codes do
      tmp = seasonal_adjustment_code[0]
      seasonal_adjustment_code[0] = seasonal_adjustment_code[1]
      seasonal_adjustment_code[1] = tmp
    end

    for area_type_code in @area_type_codes do
      tmp = area_type_code[0]
      area_type_code[0] = area_type_code[1]
      area_type_code[1] = tmp
    end

    for area_code in @area_codes do
      tmp = area_code[0]
      area_code[0] = area_code[1]
      area_code[1] = tmp
    end

    for industry_code in @industry_codes do
      tmp = industry_code[0]
      industry_code[0] = industry_code[1]
      industry_code[1] = tmp
    end

    for occupation_code in @occupation_codes do
      tmp = occupation_code[0]
      occupation_code[0] = occupation_code[1]
      occupation_code[1] = tmp
    end

    for data_type_code in @data_type_codes do
      tmp = data_type_code[0]
      data_type_code[0] = data_type_code[1]
      data_type_code[1] = tmp
    end
  end
  def download_csv
    @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
    generated_id = "OE" + session[:seasonal_adjustment_code] + session[:area_type_code] + session[:area_code] + session[:industry_code] + session[:occupation_code] + session[:data_type_code]
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

