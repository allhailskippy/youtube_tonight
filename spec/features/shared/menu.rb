shared_examples 'admin menu' do
  it 'has the right menu options' do
    expect(menu.active.text).to eq(active)
    expect(menu.home.text).to eq('YouTube Tonight')
    expect(menu.home['href']).to end_with('/#/shows')
    expect(menu.users.text).to eq('Users')
    expect(menu.users['href']).to end_with('/#/users')
    expect(menu.shows.text).to eq('Shows')
    expect(menu.shows['href']).to end_with('/#/shows')
    expect(menu.playlists.text).to eq('Playlists')
    expect(menu.playlists['href']).to end_with('/#/playlists')
    expect(menu.logout.text).to eq('Sign Out')
    expect(menu.logout['href']).to end_with('/users/sign_out')
    expect(menu.logout['data-method']).to end_with('delete')
  end

  it 'goes to the right places' do
    menu.home.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to end_with("/#/shows")

    menu.users.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to end_with("/#/users")

    menu.shows.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to end_with('/#/shows')
    
    menu.playlists.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to end_with('/#/playlists')

    menu.logout.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to end_with('/users/sign_in')
  end
end

shared_examples 'host menu' do
  it 'has the right menu options' do
    expect(menu.active.text).to eq(active) if defined?(active)
    expect(menu.home.text).to eq('YouTube Tonight')
    expect(menu.home['href']).to end_with('/#/shows')
    expect(menu.shows.text).to eq('Shows')
    expect(menu.shows['href']).to end_with('/#/shows')
    expect(menu.playlists.text).to eq('Playlists')
    expect(menu.playlists['href']).to end_with('/#/playlists')
    expect(menu.logout.text).to eq('Sign Out')
    expect(menu.logout['href']).to end_with('/users/sign_out')
    expect(menu.logout['data-method']).to end_with('delete')
    using_wait_time(0) do
      expect{menu.users}.to raise_error(Capybara::ElementNotFound)
    end
  end

  it 'goes to the right places' do
    menu.home.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to end_with("/#/shows")

    menu.shows.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to end_with('/#/shows')
    
    menu.playlists.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to end_with('/#/playlists')

    menu.logout.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to end_with('/users/sign_in')
  end
end

shared_examples 'guest menu' do
  it 'has the right menu options' do
    expect(menu.home.text).to eq('YouTube Tonight')
    expect(menu.home['href']).to end_with('/users/sign_in')
    expect(menu.login.text).to eq('Sign In')
    expect(menu.login['href']).to end_with('/users/sign_in')

    using_wait_time(0) do
      expect{menu.active}.to raise_error(Capybara::ElementNotFound)
      expect{menu.users}.to raise_error(Capybara::ElementNotFound)
      expect{menu.shows}.to raise_error(Capybara::ElementNotFound)
      expect{menu.playlists}.to raise_error(Capybara::ElementNotFound)
    end
  end

  it 'goes to the right places' do
    menu.home.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to include('users/sign_in')

    menu.login.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to include('/users/sign_in')
  end
end
