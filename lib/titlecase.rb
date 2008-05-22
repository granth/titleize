# Adds String#titlecase for creating properly capitalized titles.
# It can be called as Titlecase.titlecase or "a string".titlecase.
#
# If loaded in a Rails environment, it modifies Inflector.titlecase.
module Titlecase
  SMALL_WORDS = %w{a an and as at but by en for if in of on or the to v v. via vs vs.}

  extend self

  # Capitalizes most words to create a nicer looking title string.
  #
  # The list of "small words" which are not capped comes from
  # the New York Times Manual of Style, plus 'vs' and 'v'.
  #
  #   "notes on a scandal" # => "Notes on a Scandal"
  #   "the good german"    # => "The Good German"
  def titlecase(title)
    phrases(title).map do |phrase|
      words = phrase.split
      words.map do |word|
        def word.capitalize
          # like String#capitalize, but it starts with the first letter
          self.sub(/[[:alpha:]].*/) {|subword| subword.capitalize}
        end

        case word
        when /[[:alpha:]]\.[[:alpha:]]/  # words with dots in, like "example.com"
          word
        when /^[[:alpha:]].*[[:upper:]]/ # non-first letter capitalized already
          word
        when words.first, words.last
          word.capitalize
        when *(SMALL_WORDS + SMALL_WORDS.map {|small| small.capitalize })
          word.downcase
        else
          word.capitalize
        end
      end.join(" ")
    end.join(" ")
  end

  # Splits a title into an array based on punctuation.
  #
  #   "simple title"              # => ["simple title"]
  #   "more complicated: titling" # => ["more complicated:", "titling"]
  def phrases(title)
    phrases = title.scan(/.+?(?:[:.;?!] |$)/).map {|phrase| phrase.strip }

    # rejoin phrases that were split on the '.' from a small word
    if phrases.size > 1
      phrases[0..-1].each_with_index do |phrase, index|
        if SMALL_WORDS.include?(phrase.split.last.downcase)
          phrases[index] << " " + phrases.slice!(index + 1)
        end
      end
    end

    phrases
  end
end

class String
  # Capitalizes most words to create a nicer looking title string.
  #
  # The list of "small words" which are not capped comes from
  # the New York Times Manual of Style, plus 'vs' and 'v'.
  #
  # titlecase is also aliased as titleize.
  #
  #   "notes on a scandal" # => "Notes on a Scandal"
  #   "the good german"    # => "The Good German"
  def titlecase
    Titlecase.titlecase(self)
  end
  alias_method :titleize, :titlecase
end

if defined? Inflector
  module Inflector
    extend self

    # Capitalizes most words to create a nicer looking title string.
    #
    # The list of "small words" which are not capped comes from
    # the New York Times Manual of Style, plus 'vs' and 'v'.
    #
    # This replaces the default Rails titlecase. Like the default, it uses
    # Inflector.underscore and Inflector.humanize to convert
    # underscored_names and CamelCaseNames to a more human form.
    #
    # titlecase is also aliased as titleize.
    #
    #   "notes on an active_record" # => "Notes on an Active Record"
    #   "the GoodGerman"            # => "The Good German"
    def titlecase(title)
      Titlecase.titlecase(Inflector.humanize(Inflector.underscore(title)))
    end
    alias_method :titleize, :titlecase
  end
end
