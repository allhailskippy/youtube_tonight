#
# Must define these ahead of time:
# user_info:    The UserInfoSection object being tested
# current_user: The user that should be displayed
#
# Example Usage:
#  it_should_behave_like "user_info" do
#    let(:user_info) { @page.user_info }
#    let(:current_user) { admin }
#  end
#
shared_examples "user_info" do
  it 'has the user info section' do
    expect(user_info.profile_image['src']).to eq(current_user.profile_image)
    expect(user_info.user_id.text).to eq(current_user.id.to_s)
    expect(user_info.name.text).to eq(current_user.name)
    expect(user_info.email.text).to eq(current_user.email)
  end
end
