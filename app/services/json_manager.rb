require 'json'
require 'rest_client' 
class JsonManager
  attr_accessor :response
  def initialize(url, apikey)
    @url = url
    @response = ''
    @apikey = apikey
  end
  def apiCall(seriesid, start_year, end_year)
    p @url
    p start_year
    p end_year
    # 7c60490a53d74af280a1e90b529c36cd
    # "37b0d1df14db4d78be9f853d2ad7db40"
    @response = RestClient::Request.execute(
      method: :post, 
      url: @url,
      payload: {
        seriesid: seriesid,
        startyear: start_year,
        endyear: end_year,
        registrationKey: @apikey
      }, 
      open_timeout: 240
    )
    # RestClient.post(@url, :open_timeout => 30,
    #                         {'seriesid' => seriesid,
    #                           'startyear' => '2010',
    #                           'endyear' => '2020',
    #                           'registrationKey' => "8d6999649c42476c914b6d535d678ef5"
    #                         }.to_json,
    #                         :content_type => 'application/json')
    @response
  end
end