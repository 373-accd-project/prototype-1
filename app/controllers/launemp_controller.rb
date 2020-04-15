require 'rest_client'
require 'json'
require 'csv'

class LaunempController < ApplicationController
  def index
    get_filters()

    if params.has_key?(:year)

      # generate all possible series ids
      generated_ids = generate_ids("LA", [params[:seasonal_adjustment], params[:area], params[:measure]])

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
      session[:seasonal_adjustment] = params[:seasonal_adjustment]
      session[:area_type] = params[:area_type]
      session[:area] = params[:area]
      session[:measure] = params[:measure]
    end

  end

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

    seasonal = @sa_hashmap[gid[2]]
    area = @area_hashmap[gid[3..17]]
    measure = @measures_hashmap[gid[18..-1]]
    return [seasonal, area, measure]
  end

  def csv_format(prefix_columns, result)
    # weed out empty series
    if result["Results"]["series"][0]["data"].length == 0
      return ""
    end

    # get the column headers
    prefix_names = "Seasonal,Area,Measure,"

    headers = result["Results"]["series"][0]["data"][0].keys
    headers.delete("latest")
    headers_string = headers.join(",") + "\n"

    # generate csv by taking all the values
    csv_string = CSV.generate do |csv|
      result["Results"]["series"][0]["data"].each do |row|
        row.delete("latest")
        csv << (prefix_columns + row.values)
      end
    end

    # return headers concatenated with all values
    return (prefix_names << (headers_string << csv_string))
  end

end
