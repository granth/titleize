# -*- coding: utf-8 -*-
# Adds String#titleize for creating properly capitalized titles.
# It can be called as Titleize.titleize or "a string".titleize.
#
# titlecase is included as an alias for titleize.
#
# If loaded in a Rails environment, it modifies Inflector.titleize.
module Titleize
  SMALL_WORDS = %w{a an and as at but by en for if in of on or the to v v. via vs vs.}

  extend self

  # Capitalizes most words to create a nicer looking title string.
  #
  # The list of "small words" which are not capped comes from
  # the New York Times Manual of Style, plus 'vs' and 'v'.
  #
  #   "notes on a scandal" # => "Notes on a Scandal"
  #   "the good german"    # => "The Good German"
  def titleize(title, add_small_words = [])
    all_small_words = SMALL_WORDS.dup.concat(add_small_words)

    title = title.dup
    title.downcase! unless title[/[[:lower:]]/]  # assume all-caps need fixing

    phrases(title, add_small_words).map do |phrase|
      words = phrase.split
      words.map do |word|
        def word.capitalize
          # like String#capitalize, but it starts with the first letter
          self.sub(/[[:alpha:]].*/) {|subword| subword.capitalize}
        end

        case word
        when /[[:alpha:]]\.([[:alpha:]]\.)+/ # words with dots ending with dots, like "ph.d."
          word.split(/\./).map(&:capitalize).concat([""]).join(".")
        when /[[:alpha:]]\.[[:alpha:]]/  # words with dots in, like "example.com"
          word
        when /[-‑]/  # hyphenated word (regular and non-breaking)
          word.split(/([-‑])/).map do |part|
            all_small_words.include?(part) ? part : part.capitalize
          end.join
        when /^[[:alpha:]].*[[:upper:]]/ # non-first letter capitalized already
          word
        when /^[[:digit:]]/  # first character is a number
          word
        when words.first, words.last
          word.capitalize
        when *(all_small_words + all_small_words.map {|small| small.capitalize })
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
  def phrases(title, add_small_words = [])
    all_small_words = SMALL_WORDS.dup.concat(add_small_words)
    adjusted = false

    phrases = title.scan(/.+?(?:[:.;?!] |$)/).map {|phrase| phrase.strip }

    # rejoin phrases that were split on the '.' from a small word
    if phrases.size > 1 
      loop do
        adjusted = false
        phrases[0..-2].each_with_index do |phrase, index|
          if (all_small_words.include?(phrase.split.last.downcase) || phrase.split.last.downcase.match(/(.+\.)+.+\./)) && phrases.size > index + 1
            phrases[index] << " " + phrases.slice!(index + 1).to_s
            adjusted = true
          end
        end
        break if !adjusted
      end
    end
    phrases.map(&:strip)
  end
end

class String
  # Capitalizes most words to create a nicer looking title string.
  #
  # The list of "small words" which are not capped comes from
  # the New York Times Manual of Style, plus 'vs' and 'v'.
  #
  # titleize is also aliased as titlecase.
  #
  #   "notes on a scandal" # => "Notes on a Scandal"
  #   "the good german"    # => "The Good German"
  def titleize(opts={})
    if defined? ActiveSupport
      ActiveSupport::Inflector.titleize(self, opts)
    else
      Titleize.titleize(self)
    end
  end
  alias_method :titlecase, :titleize

  def titleize!
    replace(titleize)
  end
  alias_method :titlecase!, :titleize!
end

if defined? ActiveSupport
  module ActiveSupport::Inflector
    extend self

    # Capitalizes most words to create a nicer looking title string.
    #
    # The list of "small words" which are not capped comes from
    # the New York Times Manual of Style, plus 'vs' and 'v'.
    #
    # This replaces the default Rails titleize. Like the default, it uses
    # Inflector.underscore and Inflector.humanize to convert
    # underscored_names and CamelCaseNames to a more human form. However, you can change
    # this behavior by passing :humanize => false or :underscore => false as options. 
    # This can be useful when dealing with words like "iPod" and "GPS".
    #
    # titleize is also aliased as titlecase.
    #
    #   "notes on an active_record" # => "Notes on an Active Record"
    #   "the GoodGerman"            # => "The Good German"
    def titleize(title, opts={})
      opts = {:humanize => true, :underscore => true}.merge(opts)
      title = ActiveSupport::Inflector.underscore(title) if opts[:underscore]
      title = ActiveSupport::Inflector.humanize(title) if opts[:humanize]

      Titleize.titleize(title)
    end
    alias_method :titlecase, :titleize
  end
end
