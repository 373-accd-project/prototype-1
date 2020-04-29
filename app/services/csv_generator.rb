class CsvGenerator
  def initialize(prefix_names)
    @prefix_names = prefix_names
  end

  def save(manager, generated_ids, start_year, end_year, filename, headerValues)
    reply = []
    headerAdded = false
    # populate the results of the api calls one by one
    # write them to the download file simultaneously
    generated_ids.each_with_index do |gid, i|
      result = JSON(manager.apiCall(gid, start_year, end_year))
      # only tries to parse successful requests
      if result["status"] == "REQUEST_SUCCEEDED"

        # eview each index individually
        result["Results"]["series"].each_with_index do |series, j|
          if !headerAdded && (!series["data"].nil?) && series["data"].length != 0
            # Add the headers
            headers = series["data"][0].keys
            headers.delete("latest")
            headers_string = headers.join(",") + "\n"
            IO.write("csv_files/temp.csv", @prefix_names + headers_string)
            headerAdded = true
          end

          # get series result headers by taking jth result in ith result set 
          formatted_result = csv_format(headerValues[i][j], series)
          # IO.write("csv_files/temp.csv", gid + "\n", mode: 'a')
          IO.write("csv_files/temp.csv", formatted_result, mode: 'a')
        end
      end
      reply += flatten_for_views(result)
    end
    reply
  end

  private

  def csv_format(prefix_columns, series)
    # weed out empty series
    if series.nil? || series["data"].length == 0
      return ""
    end

    # generate csv by taking all the values
    csv_string = CSV.generate do |csv|
      series["data"].each do |row|
        row.delete("latest")
        csv << (prefix_columns + row.values)
      end
    end

    # return all values
    csv_string
  end

# function to flatten the grouped requests into individual that the views can handle
  def flatten_for_views(result)
    # only worry about successful requests since thats all views need to worry about
    if result["status"] != "REQUEST_SUCCEEDED"
      return result
    end

    flattened = []
    # put the status and the corresponding message and then the series data
    # adheres to format used in the views for each dataset
    result["Results"]["series"].each_with_index do |series, j|
      flattened.push({"status"=>result["status"],
                      "message"=>[result["message"][j]],
                      # test this message line to make sure it can the BLS putting multiple messages on one series (i think they only make one message per series but im not sure)
                      "Results"=>
                        {"series"=>[series]}})
    end
    flattened
  end

end
