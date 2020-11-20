module AlmaUserStubs
  def stub_alma_facex_user
    stub_request(:get, "#{ENV['ALMA_API_BASE_URL']}/v1/users/testuser?apikey=#{ENV['ALMA_API_KEY']}&expand=none&user_id_type=all_unique&view=brief").
      with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }).to_return(
          status: 200,
          body: '{"user_group": {"value": "FacEXP","desc": "Faculty Express"}}',
          headers: {}
    )
  end
  def stub_alma_non_facex_user
    stub_request(:get, "#{ENV['ALMA_API_BASE_URL']}/v1/users/testuser?apikey=#{ENV['ALMA_API_KEY']}&expand=none&user_id_type=all_unique&view=brief").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }).to_return(
        status: 200,
        body: '{"user_group": {"value": "staff","desc": "Staff"}}',
        headers: {}
    )
  end
end