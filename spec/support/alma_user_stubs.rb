module AlmaUserStubs
  def stub_alma_facex_user(username = 'testuser')
    stub_request(:get, "#{ENV['ALMA_API_BASE_URL']}/v1/users/#{username}?apikey=#{ENV['ALMA_API_KEY']}&user_id_type=all_unique&view=brief&expand=none&format=json")
      .to_return(
        status: 200,
        body: '{"user_group": {"value": "FacEXP", "desc": "Faculty Express"}}',
        headers: {}
      )
  end

  def stub_alma_non_facex_user(username = 'testuser')
    stub_request(:get, "#{ENV['ALMA_API_BASE_URL']}/v1/users/#{username}?apikey=#{ENV['ALMA_API_KEY']}&user_id_type=all_unique&view=brief&expand=none&format=json")
      .to_return(
        status: 200,
        body: '{"user_group": {"value": "staff", "desc": "Staff"}}',
        headers: {}
      )
  end
end
