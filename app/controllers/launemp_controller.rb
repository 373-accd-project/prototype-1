require 'rest_client'
require 'json'
require 'csv'

class LaunempController < ApplicationController
  before_action :check_login

  def index
    get_filters()

    if params.has_key?(:start_year)
      # generate all possible series ids
      if params[:series_id].present?
        @generated_ids = params[:series_id].split(',')
      else
        @generated_ids = SeriesIdGenerator.new.generate_ids("LA", [params[:seasonal_adjustment], params[:area], params[:measure]])
      end
      p @generated_ids

      headers = @generated_ids.map{|e| [e] + prefix_columns(e)}

      prefix_names = "Series ID,Seasonal,Area,Measure,"

      # save_csv Defined in ApplicationController
      @reply = save_csv(@generated_ids, prefix_names, headers)
    end

  end

  private

  def get_filters
    # Read the fitlers from the CSV file
    @area_types = CSV.read('csv_files/la_unemployment/la.area_type.txt', {col_sep: "\t"})[1..]
    @areas = CSV.read('csv_files/la_unemployment/la.area.txt', {col_sep: "\t"})[1..]
    @measures = CSV.read('csv_files/la_unemployment/la.measure.txt', {col_sep: "\t"})[1..]
    @seasonal_adjustment_codes = CSV.read('csv_files/la_unemployment/seasonal_adjustment_codes.csv')[1..]

    # Switch the key-value pairs to make sure that the correct one appears
    # in the drop down for each filter
    for area_type in @area_types do
      tmp = area_type[0]
      area_type[0] = area_type[1]
      area_type[1] = tmp
    end
    for area in @areas do
      area.slice!(0)
      area.slice!(2..)

      tmp = area[0]
      area[0] = area[1]
      area[1] = tmp
      p area
    end
    for measure in @measures do
      tmp = measure[0]
      measure[0] = measure[1]
      measure[1] = tmp
    end
    for seasonal_adjustment_code in @seasonal_adjustment_codes do
      tmp = seasonal_adjustment_code[0]
      seasonal_adjustment_code[0] = seasonal_adjustment_code[1]
      seasonal_adjustment_code[1] = tmp
    end

    # Hashmaps to create the accordian filters
    @sa_hashmap = Hash[@seasonal_adjustment_codes.map {|key, value| [value, key]}]
    @area_hashmap = Hash[@areas.map {|key, value| [value, key]}]
    @measures_hashmap = Hash[@measures.map {|key, value| [value, key]}]
  end

  def prefix_columns(gid)
    seasonal = @sa_hashmap[gid[2]]
    area = @area_hashmap[gid[3..17]]
    measure = @measures_hashmap[gid[18..-1]]
    return [seasonal, area, measure]
  end

end
