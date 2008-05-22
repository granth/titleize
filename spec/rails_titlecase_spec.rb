describe String, "in Rails" do
  before(:all) do
    module Rails
      # stub
    end
    require File.join(File.dirname(__FILE__), "..", "lib/titlecase.rb")
  end

  describe "#titlecase" do
    it "should call rails_titlecase" do
      title = "active_record and ActiveResource"
      Titlecase.should_receive(:rails_titlecase).with(title)
      title.titlecase
    end
  end
end
