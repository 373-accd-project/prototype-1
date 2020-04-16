require 'rest_client'
require 'json'
require 'csv'

class OesController < ApplicationController
  before_action :check_login
  
  def index
    get_filters()

    if params.has_key?(:year)
      p params

      # generate all possible series ids
      generated_ids = generate_ids("OE", [params[:seasonal_adjustment_code], params[:area_type_code], params[:area_code], params[:industry_code], params[:occupation_code], params[:data_type_code]])
      p generated_ids
      # make the download file blank
      IO.write("csv_files/temp.csv", "")

      # populate the results of the api calls one by one
      # write them to the download file simultaneously
      @reply = []
      @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
      generated_ids.each do |gid|
        result = JSON(@manager.apiCall(gid, 2010, 2020))
        @reply.push(result)
        formatted_result = csv_format(prefix_columns(gid, result.nil?), result)
        IO.write("csv_files/temp.csv", gid + "\n", mode: 'a')
        IO.write("csv_files/temp.csv", formatted_result, mode: 'a')
        IO.write("csv_files/temp.csv", "\n\n", mode: 'a')
      end

      @generated_ids = generated_ids
      # Store filters in session hash so that any subsequent downlaod requests
      # have access to them
      session[:seasonal_adjustment_code] = params[:seasonal_adjustment_code]
      session[:occupation_code] = params[:occupation_code]
      session[:industry_code] = params[:industry_code]
      session[:area_code] = params[:area_code]
      session[:area_type_code] = params[:area_type_code]
      session[:data_type_code] = params[:data_type_code]
    end
  end

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

  private
  def generate_ids(prefix, arrays)

    # if there is an empty parameter, there are no permutations
    if arrays.select { |e| e.nil? || (e.length == 0) }.length > 0
      return []
    end

    all_combos = []

    # counters for each parameter
    counts = arrays.map { |e| 0 }
    combo = ""
    # while there are combos left to try
    while more_combos(counts, arrays)
      # create the combo from the counters
      combo = prefix + arrays.each_with_index.map {|a, i| a[counts[i]]}.join("")

      # push to result set and increment
      all_combos.push(combo)
      combo = ""
      counts = increment_counts(counts, arrays)
    end
    return all_combos
  end

  def more_combos(counts, arrays)
    return counts[0] < arrays[0].length
  end

  def increment_counts(counts, arrays)
    # start at last count and move down
    i = counts.length - 1
    while (i >= 0)

      # if a count can be incremented, increment and set the following to 0
      if (counts[i] + 1) % arrays[i].length != 0
        counts[i] += 1
        j = i + 1
        while j < counts.length
          counts[j] = 0
          j += 1
        end
        return counts
      end
      i -= 1
    end
    counts[0] += 1
    return counts
  end

  def prefix_columns(gid, nilcheck)
    if nilcheck
      return []
    end

    seasonal = @seasonal_adjustment_hashmap[gid[2]]
    area_type = @area_type_hashmap[gid[3]]
    area = @area_hashmap[gid[4..10]]
    industry = @industry_hashmap[gid[11..16]]
    occupation = @occupation_hashmap[gid[17..22]]
    data = @data_type_hashmap[gid[23..-1]]
    return [seasonal, area_type, area, industry, occupation, data]
  end

  def csv_format(prefix_columns, result)
    if result["Results"]["series"][0]["data"].length == 0
      return ""
    end

    prefix_names = "Seasonal Adjustment,Area Type,Area,Industry,Occupation,Data,"

    headers = result["Results"]["series"][0]["data"][0].keys
    headers.delete("latest")
    headers_string = headers.join(",") + "\n"
    csv_string = ""
    csv_string = CSV.generate do |csv|
      result["Results"]["series"][0]["data"].each do |row|
        row.delete("latest")
        csv << (prefix_columns + row.values)
      end
    end
    return (prefix_names << (headers << csv_string))
  end

end
