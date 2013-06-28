require 'spec_helper'

describe Admin::ListCutterHelper do
  describe "#get_rule" do
    it "should retrieve the rule specified by the given symbol" do
      list = build(:list)
      list.add_rule(:action_taken_rule, :page_ids => [1])

      action_taken = helper.get_rule(list, ListCutter::ActionTakenRule)
      action_taken.should be_instance_of ListCutter::ActionTakenRule
      action_taken.page_ids.should == [1]
    end

    it "should return a new rule instance if none found" do
      list = List.new

      helper.get_rule(list, ListCutter::ActionTakenRule).should be_instance_of ListCutter::ActionTakenRule
      helper.get_rule(list, ListCutter::EmailDomainRule).should be_instance_of ListCutter::EmailDomainRule
      helper.get_rule(list, ListCutter::JoinDateRule).should be_instance_of ListCutter::JoinDateRule
    end
  end

  describe "#source_options" do
    it 'should list all sources for the movement' do
      movement = create(:movement)
      create(:external_activity_event, :movement => movement, :source => 'controlshift')
      create(:external_activity_event, :movement => movement, :source => 'controloption')
      create(:external_activity_event, :source => 'controldelete')

      helper.source_options(movement.id, ['controloption']).should ==
        "<option value=\"controloption\" selected=\"selected\">CONTROLOPTION</option>\n"+
        "<option value=\"controlshift\">CONTROLSHIFT</option>"
    end
  end

  describe "#grouped_select_options and custom selects" do
    it "should return nested <opt group> for campaign -> blast with emails as <options> " do
      movement = create(:movement)

      campaign2 = create(:campaign, name:"Campaign2", movement: movement)
      push2 = create(:push, campaign: campaign2)
      blast2 = create(:blast, name: "blast2", push: push2)
      blast8 = create(:blast, name: "blast1", push: push2)
      blast9 = create(:blast, name: "blast1", push: push2)
      email2 = create(:email, name: "email2", blast: blast2)
      email8 = create(:email, name: "email8", blast: blast9)

      # Create a time difference in the created/updated date
      sleep 1

      campaign1 = create(:campaign, name:"Campaign", movement: movement)
      push1 = create(:push, campaign: campaign1)
      blast1 = create(:blast, name: "blast1", push: push1)
      blast3 = create(:blast, name: "blast1", push: push1)
      blast4 = create(:blast, name: "blast1", push: push1)
      email4 = create(:email, name: "email4", blast: blast4)
      email1 = create(:email, name: "email1", blast: blast1)
      email3 = create(:email, name: "email3", blast: blast1)
      helper.grouped_select_options_emails(movement.id, [email1.id]).gsub(/\sid=\"([^\"]*)\"/, '').should == "<optgroup label=\"#{campaign1.name}\" parent-group=\"true\">"+
          "</optgroup><optgroup label=\"#{blast1.name}\"><option value=\"#{email1.id}\" selected=\"selected\">#{email1.name}</option>"+
          "<option value=\"#{email3.id}\">#{email3.name}</option><option value=\"#{email4.id}\">#{email4.name}</option></optgroup>"+
          "<optgroup label=\"#{campaign2.name}\" parent-group=\"true\"></optgroup><optgroup label=\"#{blast9.name}\">"+
          "<option value=\"#{email8.id}\">#{email8.name}</option></optgroup><optgroup label=\"#{blast2.name}\"><option value=\"#{email2.id}\">#{email2.name}</option></optgroup>"

    end

    it "should return nested <opt group> for campaign -> action sequences with action pages as <options> " do
      movement = create(:movement)

      campaign2 = create(:campaign, movement: movement, name: 'campaign2')
      as2 = create(:action_sequence, campaign: campaign2)
      ap2 = create(:action_page, action_sequence: as2)
      cm2 = create(:email_targets_module)
      cm2_link = create(:content_module_link, page: ap2, content_module: cm2)
      as3 = create(:action_sequence, campaign: campaign2, name: "as3")
      ap3 = create(:action_page, action_sequence: as2, name: "ap3")

      # Create a time difference in the created/updated date
      sleep 1

      campaign1 = create(:campaign, movement: movement)
      as1 = create(:action_sequence, campaign: campaign1, name: 'as1')
      ap1 = create(:action_page, action_sequence: as1, name: 'ap1')
      cm1 = create(:petition_module )
      cm1_link = create(:content_module_link, page: ap1, content_module: cm1)


      helper.grouped_select_options_pages(movement.id, [ap1.id]).gsub(/\sid=\"([^\"]*)\"/, '').should == "<optgroup label=\"#{campaign1.name}\" parent-group=\"true\"></optgroup>"+
          "<optgroup label=\"#{as1.name}\"><option value=\"#{ap1.id}\" selected=\"selected\">#{ap1.name}</option></optgroup>"+
          "<optgroup label=\"#{campaign2.name}\" parent-group=\"true\"></optgroup>"+
          "<optgroup label=\"#{as2.name}\"><option value=\"#{ap2.id}\">#{ap2.name}</option></optgroup>"
    end

    it "#grouped_select_options_external_actions should return nested <opt group> for source -> partner with action slugs as <options>,
        and exclude actions that were created but not signed" do
      movement = create(:movement)
      action_taken = ExternalActivityEvent::Activity::ACTION_TAKEN
      action_created = ExternalActivityEvent::Activity::ACTION_CREATED
      event1 = create(:external_activity_event, :movement => movement, :source => 'controlshift',  :partner => 'aclu', :action_slug => 'russia', :activity => action_taken)
      event2 = create(:external_activity_event, :movement => movement, :source => 'controlshift',  :partner => 'aclu', :action_slug => 'cuba',   :activity => action_taken)
      event2 = create(:external_activity_event, :movement => movement, :source => 'controlshift',  :partner => 'aclu', :action_slug => 'france', :activity => action_created)
      event3 = create(:external_activity_event, :movement => movement, :source => 'controlshift',  :partner => nil,    :action_slug => 'ecuador',:activity => action_taken)
      event4 = create(:external_activity_event, :movement => movement, :source => 'controloption', :partner => nil,    :action_slug => 'brazil', :activity => action_taken)
      event5 = create(:external_activity_event, :movement => movement, :source => 'controloption', :partner => 'aclu', :action_slug => 'china',  :activity => action_taken)

      helper.grouped_select_options_external_actions(movement.id, event4.action_slug).gsub(/\sid=\"([^\"]*)\"/, '').should ==
      "<option value=\"brazil\" selected=\"selected\">CONTROLOPTION: brazil</option>"+
      "\n<option value=\"china\">CONTROLOPTION: ACLU - china</option>"+
      "\n<option value=\"ecuador\">CONTROLSHIFT: ecuador</option>"+
      "\n<option value=\"cuba\">CONTROLSHIFT: ACLU - cuba</option>"+
      "\n<option value=\"russia\">CONTROLSHIFT: ACLU - russia</option>"
    end

    it "should return action pages of type petition, email targets, join, donation as <options>" do
      movement = create(:movement)
      campaign1 = create(:campaign, movement: movement)
      as1 = create(:action_sequence, campaign: campaign1, name: 'as1')
      ap1 = create(:action_page, action_sequence: as1, name: 'ap1')
      cm1 = create(:petition_module )
      cm1_link = create(:content_module_link, page: ap1, content_module: cm1)
      campaign2 = create(:campaign, movement: movement, name: 'campaign2')
      as2 = create(:action_sequence, campaign: campaign2)
      ap2 = create(:action_page, action_sequence: as2)
      cm2 = create(:email_targets_module)
      cm2_link = create(:content_module_link, page: ap2, content_module: cm2)

      as3 = create(:action_sequence, campaign: campaign2, name: "as3")
      ap3 = create(:action_page, action_sequence: as2, name: "ap3")

      helper.select_options_action_pages(movement.id, [ap1.id]).should == "<option value=\"#{ap1.id}\" selected=\"selected\">#{ap1.name}</option><option value=\"#{ap2.id}\">#{ap2.name}</option>"
    end
  end
end