module Inflector
  #stub
end

require File.join(File.dirname(__FILE__), "..", "lib/titlecase.rb")

SMALL_WORDS = %w{a an and as at but by en for if in of on or the to v v. via vs vs.}

describe Titlecase do
  describe "phrases" do
    it "should return an array" do
      phrases("a little sentence").should be_an_instance_of(Array)
    end

    it "should split on colons" do
      phrases("this: a subphrase").should == ["this:", "a subphrase"]
    end

    it "should split on semi-colons" do
      phrases("this; that").should == ["this;", "that"]
    end

    it "should split on question marks" do
      phrases("this? that").should == ["this?", "that"]
    end

    it "should split on periods" do
      phrases("this. that.").should == ["this.", "that."]
    end

    it "should split on exclamation marks" do
      phrases("headache! yes").should == ["headache!", "yes"]
    end

    it "should rejoin into the original string" do
      title = "happy: not sad; pushing! laughing? ok."
      phrases(title).join(" ").should == title
    end

    it "should not get confused by small words with punctuation" do
      phrases("this vs. that").should == ["this vs. that"]
      phrases("this vs. that. no").should == ["this vs. that.", "no"]
      phrases("this: that vs. him. no. why?").should ==
        ["this:", "that vs. him.", "no.", "why?"]
    end
  end

  describe "titlecase" do
    it "should return a string" do
      titlecase("this").should be_an_instance_of(String)
    end

    it "should capitalize the first letter of regular words" do
      titlecase("cat beats monkey").should == "Cat Beats Monkey"
    end

    it "should not capitalize small words" do
      SMALL_WORDS.each do |word|
        titlecase("first #{word} last").should == "First #{word} Last"
      end
    end

    it "should downcase a small word if it is capitalized" do
      SMALL_WORDS.each do |word|
        titlecase("first #{word.capitalize} last").should == "First #{word} Last"
      end
    end

    it "should capitalize a small word if it is the first word" do
      SMALL_WORDS.each do |word|
        titlecase("#{word} is small").should == "#{word.capitalize} Is Small"
        titlecase("after: #{word} ok").should == "After: #{word.capitalize} Ok"
        titlecase("after; #{word} ok").should == "After; #{word.capitalize} Ok"
        titlecase("after. #{word} ok").should == "After. #{word.capitalize} Ok"
        titlecase("after? #{word} ok").should == "After? #{word.capitalize} Ok"
        titlecase("after! #{word} ok").should == "After! #{word.capitalize} Ok"
      end
    end

    it "should capitalize a small word if it is the last word" do
      SMALL_WORDS.each do |word|
        titlecase("small #{word}").should == "Small #{word.capitalize}"
      end
    end

    it "should not screw up acronyms" do
      titlecase("the SEC's decision").should == "The SEC's Decision"
    end

    it "should not capitalize words with dots" do 
      titlecase("del.icio.us web site").should == "del.icio.us Web Site"
    end

    it "should not think a quotation mark makes a dot word" do
      titlecase("'quoted.' yes.").should == "'Quoted.' Yes."
      titlecase("ends with 'quotation.'").should == "Ends With 'Quotation.'"
    end

    it "should not capitalize words that have a lowercase first letter" do 
      titlecase("iTunes").should == "iTunes"
    end

    # http://daringfireball.net/projects/titlecase/examples-edge-cases
    it "should handle edge cases" do
      {
        %{Q&A With Steve Jobs: 'That's What Happens In Technology'} =>
          %{Q&A With Steve Jobs: 'That's What Happens in Technology'},

        %{What Is AT&T's Problem?} => %{What Is AT&T's Problem?},

        %{Apple Deal With AT&T Falls Through} =>
        %{Apple Deal With AT&T Falls Through},

        %{this v that}   => %{This v That},
        %{this vs that}  => %{This vs That},
        %{this v. that}  => %{This v. That},
        %{this vs. that} => %{This vs. That},

        %{The SEC's Apple Probe: What You Need to Know} =>
          %{The SEC's Apple Probe: What You Need to Know},

        %{'by the Way, small word at the start but within quotes.'} =>
          %{'By the Way, Small Word at the Start but Within Quotes.'},

        %{Small word at end is nothing to be afraid of} =>
          %{Small Word at End Is Nothing to Be Afraid Of},

        %{Starting Sub-Phrase With a Small Word: a Trick, Perhaps?} =>
        %{Starting Sub-Phrase With a Small Word: A Trick, Perhaps?},

        %{Sub-Phrase With a Small Word in Quotes: 'a Trick, Perhaps?'} =>
        %{Sub-Phrase With a Small Word in Quotes: 'A Trick, Perhaps?'},

        %{Sub-Phrase With a Small Word in Quotes: "a Trick, Perhaps?"} =>
        %{Sub-Phrase With a Small Word in Quotes: "A Trick, Perhaps?"},

        %{"Nothing to Be Afraid of?"} => %{"Nothing to Be Afraid Of?"},
        %{"Nothing to Be Afraid Of?"} => %{"Nothing to Be Afraid Of?"},
        %{a thing} => %{A Thing},

        %{'Gruber on OmniFocus and Vapo(u)rware'} =>
        %{'Gruber on OmniFocus and Vapo(u)rware'},
      }.each do |before, after|
        titlecase(before).should == after
      end
    end
  end

  it "should have titlecase as a singleton method" do
    Titlecase.singleton_methods.should include("titlecase")
  end
end

describe Inflector do
  describe "titlecase" do
    before(:each) do
      @title = "active_record and ActiveResource"
    end

    it "should call humanize and underscore like the default in Rails" do
      underscored_title = "active_record and active_resource"
      humanized_title = "Active record and active resource"
      Inflector.should_receive(:underscore).with(@title).and_return(underscored_title)
      Inflector.should_receive(:humanize).with(underscored_title).and_return(humanized_title)
      titlecase(@title).should == "Active Record and Active Resource"
    end

    it "should replace Inflector.titlecase" do
      Titlecase.should_receive(:titlecase).with(@title)
      Inflector.stub!(:underscore).and_return(@title)
      Inflector.stub!(:humanize).and_return(@title)
      Inflector.titlecase(@title)
    end

    it "should be aliased as titleize" do
      Inflector.singleton_methods.should include("titleize")
      Inflector.stub!(:titlecase).and_return("title")
      Inflector.stub!(:titleize).and_return("title")
      Inflector.titleize("this").should == Inflector.titlecase("this")
    end
  end
end

describe String do
  it "should have a titlecase method" do
    String.instance_methods.should include("titlecase")
  end

  it "should work" do
    "this is a test".titlecase.should == "This Is a Test"
  end

  it "should be aliased as #titleize" do
    String.instance_methods.should include("titleize")
    title = "this is a pile of testing text"
    title.titleize.should == title.titlecase
  end
end
