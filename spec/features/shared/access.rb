shared_examples "guest_access" do
  it "goes to sign in" do
    expect(page.current_url).to include("/users/sign_in")
  end
end

shared_examples "unauthorized" do
  it "goes to unauthorized" do
    expect(page.current_url).to end_with("/#/unauthorized")
  end
end

shared_examples "requires_auth" do
  it "goes to requires_auth" do
    expect(page.current_url).to end_with("/users/#{current_user.id}/requires_auth")
  end
end
