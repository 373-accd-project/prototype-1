require 'json'
require 'rest_client' 
class JsonManager
  attr_accessor :response
  def initialize(url)
    @url = url
    @response = ''
  end
  def apiCall(seriesid, startyear, endyear)
    p @url
    @response = RestClient::Request.execute(method: :post, url: @url,
                          payload: {seriesid: seriesid,
                            startyear: '2010',
                            endyear: '2020',
                            registrationKey: "8d6999649c42476c914b6d535d678ef5"}, 
                          open_timeout: 240)
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