require "spec_helper"

describe InlineTokenReplacement do
  include InlineTokenReplacement

  it "does not replace tokens if values are not specified" do
    text = "{This} will not be {Replaced}."
    text = replace_tokens(text, "Animal" => "Cat")
    text.should == "{This} will not be {Replaced}."
  end

  it "replaces tokens with defaults if values are not specified" do
    text = "{This} {maybe|will} be {Replaced}."
    text = replace_tokens(text, "Animal" => "Cat")
    text.should == "{This} will be {Replaced}."
  end

  it "replaces all occurences of a token within a block of text" do
    text = "{Animal}s are called {Animal} because they are a {Animal}"
    text = replace_tokens(text, "Animal" => "Cat")
    text.should == "Cats are called Cat because they are a Cat"
  end

  it "replaces all occurences of a token with different defaults" do
    text = "{Animal}s are called {Animal|Dog} because they are a {Animal|Stupid}"
    text = replace_tokens(text, "Animal" => "Cat")
    text.should == "Cats are called Cat because they are a Cat"
  end

  it "allows defaults to be specified for when no value is available" do
    text = "{Animal|Dog}s go {NOISE|Woof Woof}"
    text = replace_tokens(text, "Animal" => "Cat", "NOISE" => "")
    text.should == "Cats go Woof Woof"
  end

  it "allows prefix text to be rendered with the token when conditional evaluates to true" do
    text = "{(A )Animal|Dog} goes Woof Woof"
    text = replace_tokens(text, "Animal" => "Cat")
    text.should == "A Cat goes Woof Woof"
  end

  it "does not render the prefix text if token does not have a replacement but has a default value" do
    text = "{(A )Animal|The Dog} goes Woof Woof"
    text = replace_tokens(text, "Animal" => "")
    text.should == "The Dog goes Woof Woof"
  end

  it "does not render anything if token does not have a replacement neither has a default value" do
    text = "Yay!{(A )Animal|} goes Woof Woof"
    text = replace_tokens(text, "Animal" => "")
    text.should == "Yay! goes Woof Woof"
  end

  it "can take a lambda in place of a value to allow HTML to be inserted" do
    text = "All {Animal} deserve to be emphasised"
    text = replace_tokens(text, "Animal" => lambda { |default| "<em>KITTENS</em>"} )
    text.should == "All <em>KITTENS</em> deserve to be emphasised"
  end

  it "passes the default value to a lambda if one is provided" do
    text = "{Animal|Walruses} should be in italics"
    text = replace_tokens(text, "Animal" => lambda { |default| "<i>#{default.upcase}</i>"} )
    text.should == "<i>WALRUSES</i> should be in italics"
  end
end
