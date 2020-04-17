require 'rest_client'
require 'json'
require 'csv'

class OesController < ApplicationController
  before_action :check_login
  
  def index
    get_filters()

    if params.has_key?(:start_year)
      # generate all possible series ids
      if params[:series_id].present?
        @generated_ids = params[:series_id].split(',')
      else
        @generated_ids = SeriesIdGenerator.new.generate_ids("OE", [params[:seasonal_adjustment_code], params[:area_type_code], params[:area_code], params[:industry_code], params[:occupation_code], params[:data_type_code]])
      end
      p @generated_ids

      headers = @generated_ids.map{|e| [e] + prefix_columns(e)}

      prefix_names = "Series ID,Seasonal Adjustment,Area Type,Area,Industry,Occupation,Data,"
      
      # save_csv Defined in ApplicationController
      @reply = save_csv(@generated_ids, prefix_names, headers)
    end
  end

  private

  def get_filters
    # Read the fitlers from the CSV file
    @seasonal_adjustment_codes = CSV.read('csv_files/oes/seasonal_adjustment_titles.csv')[1..]
    @occupation_codes = CSV.read('csv_files/oes/occupation_titles.csv')[1..]
    @industry_codes = CSV.read('csv_files/oes/industry_titles.csv')[1..]
    @area_codes = CSV.read('csv_files/oes/area_titles.csv')[1..]
    @area_type_codes = CSV.read('csv_files/oes/area_type_titles.csv')[1..]
    @data_type_codes = CSV.read('csv_files/oes/data_type_titles.csv')[1..]

    # Hashmaps to create the accordian filters
    @seasonal_adjustment_hashmap = Hash[@seasonal_adjustment_codes.map {|key, value| [key, value]}]
    @occupation_hashmap = Hash[@occupation_codes.map {|key, value| [key, value]}]
    @industry_hashmap = Hash[@industry_codes.map {|key, value| [key, value]}]
    @area_hashmap = Hash[@area_codes.map {|key, value| [key, value]}]
    @area_type_hashmap = Hash[@area_type_codes.map {|key, value| [key, value]}]
    @data_type_hashmap = Hash[@data_type_codes.map {|key, value| [key, value]}]


    # Switch the key-value pairs to make sure that the correct one appears
    # in the drop down for each filter
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

  def prefix_columns(gid)
    seasonal = @seasonal_adjustment_hashmap[gid[2]]
    area_type = @area_type_hashmap[gid[3]]
    area = @area_hashmap[gid[4..10]]
    industry = @industry_hashmap[gid[11..16]]
    occupation = @occupation_hashmap[gid[17..22]]
    data = @data_type_hashmap[gid[23..-1]]
    return [seasonal, area_type, area, industry, occupation, data]
  end
end
