require 'rest_client'
require 'json'
require 'csv'

class NationaleheController < ApplicationController
  before_action :check_login
  
  def index
    get_filters()

    if params.has_key?(:start_year)
      # generate all possible series ids
      if params[:series_id].present?
        @generated_ids = params[:series_id].split(',')
      else
        @generated_ids = SeriesIdGenerator.new.generate_ids("CE", [params[:seasonal_adjustment_code], params[:industry], params[:data_type]])
      end
      p @generated_ids

      headers = @generated_ids.map{|e| [e] + prefix_columns(e)}

      prefix_names = "Series ID,Seasonal Adjustment,Industry,Data Type,"
      
      # save_csv Defined in ApplicationController
      @reply = save_csv(@generated_ids, prefix_names, headers)
    end
  end

  private

  def get_filters
    # Read the fitlers from the CSV file
    @seasonal_adjustment_codes = CSV.read('csv_files/nationalehe/seasonal_adjustment_codes.csv')[1..]
    @supersectors = CSV.read('csv_files/nationalehe/supersector_codes.csv')[1..]
    @industries = CSV.read('csv_files/nationalehe/industry_codes.csv')[1..]
    @data_types = CSV.read('csv_files/nationalehe/data_type_codes.csv')[1..]
    @state_initials.to_h

    # Hashmaps to create the accordian filters
    @sa_hashmap = Hash[@seasonal_adjustment_codes.map {|key, value| [key, value]}]
    @ss_hashmap = Hash[@supersectors.map {|key, value| [key, value]}]
    @data_hashmap = Hash[@data_types.map {|key, value| [key, value]}]
    @industries_hashmap = Hash[@industries.map {|key, value| [key, value]}]

    # Switch the key-value pairs to make sure that the correct one appears
    # in the drop down for each filter
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
    for sa in @seasonal_adjustment_codes do
      tmp = sa[0]
      sa[0] = sa[1]
      sa[1] = tmp
    end
  end

  def prefix_columns(gid)
    seasonal = @sa_hashmap[gid[2]]
    data = @data_hashmap[gid[11..-1]]
    industry = @industries_hashmap[gid[3..10]]
    return [seasonal, industry, data]
  end
end
