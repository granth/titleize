require File.join(File.dirname(__FILE__), "..", "lib/titlecase.rb")

# SMALL_WORDS = %w{
#   a an and as at but by en for if in of on or the to v v. via vs vs.
# }

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

  it "should downcase a small word if it is capitilized" do
    SMALL_WORDS.each do |word|
      titlecase("first #{word.capitalize} last").should == "First #{word} Last"
    end
  end

  it "should capitalize a small word if it is the first word" do
    SMALL_WORDS.each do |word|
      titlecase("#{word} is small").should == "#{word.capitalize} Is Small"
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

  it "should not capitilize words with dots" do 
    titlecase("del.icio.us web site").should == "del.icio.us Web Site"
  end

  it "should not think a quotation mark makes a dot word" do
    titlecase("'quoted.' yes.").should == "'Quoted.' Yes."
    titlecase("ends with 'quotation.'").should == "Ends With 'Quotation.'"
  end

  it "should not capitilize words that have a lowercase first letter" do 
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
    }.each do |before, after|
      titlecase(before).should == after
    end
  end
end