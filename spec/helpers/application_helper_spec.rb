require "spec_helper"

describe ApplicationHelper do
  describe "#sum_list" do
    it "should sum up all the transactions in the list" do
      donation = FactoryGirl.create(:donation)

      transactions = [Transaction.create!(donation: donation, successful: true, amount_in_cents: 113 ),
                      Transaction.create!(donation: donation, successful: true, amount_in_cents: 117 ),
                      Transaction.create!(donation: donation, successful: true, amount_in_cents: 103)]

      helper.sum_list(transactions, :amount_in_dollars).should eql 3.33
    end
  end

  describe "navbar_item" do
    before do
      controller.stub(:active_nav?).and_return false
    end

    context "tab is not active," do
      it "should render an HTML anchor within a List Item" do
        html = helper.navbar_item :movements, "Movements", path: "/movements"
        html.should have_tag "li a", with: { href: "/movements" }, text: "Movements"
      end

      it "should default path to # when not provided" do
        html = helper.navbar_item :movements, "Movements"
        html.should have_tag "li a", with: { href: "#" }, text: "Movements" 
      end

      it "should not have a class attribute in the LI" do
        html = helper.navbar_item :movements, "Movements"
        html.should have_tag "li:not(.active)" do
          with_tag "a", text: "Movements"
        end
      end
    end

    context "tab is active" do
      before do
        controller.stub(:active_nav?).and_return true
      end
      
      it "should add an 'active' class to the LI" do
        html = helper.navbar_item :movements, "Movements"
        html.should have_tag "li", with: { class: "active" } do
          with_tag "a", text: "Movements"
        end
      end
    end
  end

  describe "minimum_blast_schedule_time" do
    it "should return the time in UTC format" do
      now = Time.new(2012, 9, 21, 12, 7, 50)
      Time.stub_chain(:now, :utc).and_return(now)
      AppConstants.stub(:blast_job_delay).and_return(300)

      helper.minimum_blast_schedule_time.should == "2012/09/21 12:12:50"
    end
  end

end
