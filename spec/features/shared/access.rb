shared_examples "guest_access" do
  before do
    loader
    wait_for_angular_requests_to_finish
  end

  it "goes to sign in" do
    expect(page.current_url).to include("/users/sign_in")
  end
end

shared_examples "unauthorized" do
  before do
    loader
    wait_for_angular_requests_to_finish
  end

  it "goes to unauthorized" do
    expect(page.current_url).to end_with("/app#/unauthorized")
  end
end
