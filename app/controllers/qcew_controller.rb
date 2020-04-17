require 'rest_client'
require 'json'
require 'csv'

class QcewController < ApplicationController
  before_action :check_login

  def index
    get_filters()

    if params.has_key?(:start_year)
      # generate all possible series ids
      if params[:series_id].present?
        @generated_ids = params[:series_id].split(',')
      else
        @generated_ids = SeriesIdGenerator.new.generate_ids("ENU", [params[:area_code], params[:datatype], params[:size], params[:ownership], params[:industry]])
      end
      p @generated_ids

      headers = @generated_ids.map{|e| [e] + prefix_columns(e)}

      prefix_names = "Series ID,Area,Datatype,Industry,Ownership,Size,"

      # save_csv Defined in ApplicationController
      @reply = save_csv(@generated_ids, prefix_names, headers)
    end
  end

  private

  def prefix_columns(series_id)
    area = @area_hashmap[series_id[3..7]]
    data = @data_hashmap[series_id[8]]
    industry = @industries_hashmap[series_id[11..-1]]
    owner = @ownership_hashmap[series_id[10]]
    size = @sizes_hashmap[series_id[9]]
    return [area, data, industry, owner, size]
  end

  def get_filters
    # Read the fitlers from the CSV file
    @area_codes = CSV.read('csv_files/qcew/area_titles.csv')[1..]
    @data_types = CSV.read('csv_files/qcew/datatype_titles.csv')[1..]
    @industries = CSV.read('csv_files/qcew/industry_titles.csv')[1..]
    @ownership = CSV.read('csv_files/qcew/ownership_titles.csv')[1..]
    @sizes = CSV.read('csv_files/qcew/size_titles.csv')[1..]

    # Hashmaps to create the accordian filters
    @area_hashmap = Hash[@area_codes.map {|key, value| [key, value]}]
    @data_hashmap = Hash[@data_types.map {|key, value| [key, value]}]
    @industries_hashmap = Hash[@industries.map {|key, value| [key, value]}]
    @ownership_hashmap = Hash[@ownership.map {|key, value| [key, value]}]
    @sizes_hashmap = Hash[@sizes.map {|key, value| [key, value]}]

    # <%= @area_codes[] %>
    # Differentiating between Supersectors + NAICS
    @naics_industries = []
    @super_industries = []

    for industry in @industries do
      type = industry[1].split(" ")[0]
      if type[0..4] == "NAICS" then
        @naics_industries.append(industry)
      else
        @super_industries.append(industry)
      end
    end

    # Switch the key-value pairs to make sure that the correct one appears
    # in the drop down for each filter
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
end
