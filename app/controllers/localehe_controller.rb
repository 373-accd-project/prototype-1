require 'rest_client'
require 'json'
require 'csv'

class LocaleheController < ApplicationController
  before_action :check_login
  
  def index
    get_filters()

    if params.has_key?(:start_year)
      # generate all possible series ids
      if params[:series_id].present?
        @generated_ids = params[:series_id].split(',')
      else
        @generated_ids = SeriesIdGenerator.new.generate_ids("SM", [params[:seasonal_adjustment_code], params[:state_code], params[:area_code], params[:industry], params[:data_type]])
      end
      
      p @generated_ids

      headers = @generated_ids.map{|e| [e] + prefix_columns(e)}

      prefix_names = "Series ID,Seasonal Adjustment,State,Area,Industry,Data Type,"

      # save_csv Defined in ApplicationController
      @reply = save_csv(@generated_ids, prefix_names, headers)
    end
  end

  private

  def get_filters
    # Read the fitlers from the CSV file
    @seasonal_adjustment_codes = CSV.read('csv_files/localehe/seasonal_adjustment_codes.csv')[1..]
    @state_codes = CSV.read('csv_files/localehe/state_codes.csv')[1..]
    @area_codes = CSV.read('csv_files/localehe/area_codes.csv')[1..]
    @supersectors = CSV.read('csv_files/localehe/supersector_codes.csv')[1..]
    @industries = CSV.read('csv_files/localehe/industry_codes.csv')[1..]
    @data_types = CSV.read('csv_files/localehe/data_type_codes.csv')[1..]
    @state_initials = CSV.read('csv_files/localehe/state_initials.csv')[1..]
    @state_initials.to_h

    # Hashmaps to create the accordian filters
    @sa_hashmap = Hash[@seasonal_adjustment_codes]
    @state_hashmap = Hash[@state_codes]
    @area_hashmap = Hash[@area_codes]
    @data_hashmap = Hash[@data_types]
    @industries_hashmap = Hash[@industries]

    for seasonal_adjustment_code in @seasonal_adjustment_codes do
      tmp = seasonal_adjustment_code[0]
      seasonal_adjustment_code[0] = seasonal_adjustment_code[1]
      seasonal_adjustment_code[1] = tmp
    end
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

  def prefix_columns(gid)
    seasonal = @sa_hashmap[gid[2]]
    state = @state_hashmap[gid[3..4]]
    area = @area_hashmap[gid[5..9]]
    data = @data_hashmap[gid[18..-1]]
    industry = @industries_hashmap[gid[10..17]]
    return [seasonal, state, area, industry, data]
  end
end
