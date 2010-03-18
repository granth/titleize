module Inflector
  #stub
end

require File.dirname(__FILE__) + "/spec_helper.rb"

SMALL_WORDS = %w{a an and as at but by en for if in of on or the to v v. via vs vs.}

describe Titleize do
  include Titleize

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

    it "should handle punctuation combined with a small word as the last word" do
      phrases("this. that of").should == ["this.", "that of"]
    end
  end

  describe "titleize" do
    it "should return a string" do
      titleize("this").should be_an_instance_of(String)
    end

    it "should capitalize the first letter of regular words" do
      titleize("cat beats monkey").should == "Cat Beats Monkey"
    end

    it "should not capitalize small words" do
      SMALL_WORDS.each do |word|
        titleize("first #{word} last").should == "First #{word} Last"
      end
    end

    it "should downcase a small word if it is capitalized" do
      SMALL_WORDS.each do |word|
        titleize("first #{word.capitalize} last").should == "First #{word} Last"
      end
    end

    it "should capitalize a small word if it is the first word" do
      SMALL_WORDS.each do |word|
        titleize("#{word} is small").should == "#{word.capitalize} Is Small"
        titleize("after: #{word} ok").should == "After: #{word.capitalize} Ok"
        titleize("after; #{word} ok").should == "After; #{word.capitalize} Ok"
        titleize("after. #{word} ok").should == "After. #{word.capitalize} Ok"
        titleize("after? #{word} ok").should == "After? #{word.capitalize} Ok"
        titleize("after! #{word} ok").should == "After! #{word.capitalize} Ok"
      end
    end

    it "should capitalize a small word if it is the last word" do
      SMALL_WORDS.each do |word|
        titleize("small #{word}").should == "Small #{word.capitalize}"
      end
    end

    it "should not screw up acronyms" do
      titleize("the SEC's decision").should == "The SEC's Decision"
    end

    it "should not capitalize words with dots" do 
      titleize("del.icio.us web site").should == "del.icio.us Web Site"
    end

    it "should not think a quotation mark makes a dot word" do
      titleize("'quoted.' yes.").should == "'Quoted.' Yes."
      titleize("ends with 'quotation.'").should == "Ends With 'Quotation.'"
    end

    it "should not capitalize words that have a lowercase first letter" do 
      titleize("iTunes").should == "iTunes"
    end

    it "should not capitalize words that start with a number" do
      titleize("2lmc").should == "2lmc"
    end

    describe "with hyphens" do
      it "should handle hyphenated words" do
        titleize("iPhone la-la land").should == "iPhone La-La Land"
      end

      it "should handle non-breaking hyphens" do
        titleize("non‑breaking hyphen").should == "Non‑Breaking Hyphen"
      end

      it "should not capitalize small words within a hyphenated word" do
        titleize("step-by-step directions").should == "Step-by-Step Directions"
      end
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
        titleize(before).should == after
      end
    end
  end

  it "should have titleize as a singleton method" do
    Titleize.singleton_methods.should include("titleize")
  end
end

describe Inflector do
  include Inflector

  describe "titleize" do
    before(:each) do
      @title = "active_record and ActiveResource"
    end

    it "should call humanize and underscore like the default in Rails" do
      underscored_title = "active_record and active_resource"
      humanized_title = "Active record and active resource"
      Inflector.should_receive(:underscore).with(@title).and_return(underscored_title)
      Inflector.should_receive(:humanize).with(underscored_title).and_return(humanized_title)
      titleize(@title).should == "Active Record and Active Resource"
    end

    it "should replace Inflector.titleize" do
      Titleize.should_receive(:titleize).with(@title)
      Inflector.stub!(:underscore).and_return(@title)
      Inflector.stub!(:humanize).and_return(@title)
      Inflector.titleize(@title)
    end

    it "should be aliased as titlecase" do
      Inflector.singleton_methods.should include("titlecase")
      Inflector.stub!(:titlecase).and_return("title")
      Inflector.stub!(:titleize).and_return("title")
      Inflector.titlecase("this").should == Inflector.titleize("this")
    end
  end
end

describe String do
  it "should have a titleize method" do
    String.instance_methods.should include("titleize")
  end

  it "should work" do
    "this is a test".titleize.should == "This Is a Test"
  end

  it "should be aliased as #titlecase" do
    String.instance_methods.should include("titlecase")
    title = "this is a pile of testing text"
    title.titlecase.should == title.titleize
  end
end
