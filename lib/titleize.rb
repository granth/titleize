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
  #
  # Pass additional small words in opts[:small_words]
  #
  #   titleize("coffee w cream", small_words: ['w']) # => "Coffee w Cream"
  #
  # For strings in ALL CAPS, specify acronyms to be preserved in opts[:acronyms]
  #
  #   titleize("SMITH TO HEAD SEC", acronyms: ['SEC']) # => "Smith to Head SEC"
  #
  def titleize(title, opts={})
    title = title.dup
    title.downcase! unless title[/[[:lower:]]/]  # assume all-caps need fixing

    small_words = SMALL_WORDS + (opts[:small_words] || [])
    small_words = small_words + small_words.map { |small| small.capitalize }

    acronyms = opts[:acronyms] || []
    acronyms = acronyms + acronyms.map { |acronym| acronym.downcase }

    phrases(title).map do |phrase|
      words = phrase.split
      words.map.with_index do |word, index|
        def word.capitalize
          # like String#capitalize, but it starts with the first letter
          self.sub(/[[:alpha:]].*/) {|subword| subword.capitalize}
        end

        case word
        when /[[:alpha:]]\.[[:alpha:]]/  # words with dots in, like "example.com"
          word
        when /[-‑]/  # hyphenated word (regular and non-breaking)
          word.split(/([-‑])/).map do |part|
            SMALL_WORDS.include?(part) ? part : part.capitalize
          end.join
        when /^[[:alpha:]].*[[:upper:]]/ # non-first letter capitalized already
          word
        when /^[[:digit:]]/  # first character is a number
          word
        when *small_words
          if index == 0 || index == words.size - 1
            word.capitalize
          else
            word.downcase
          end
        when *acronyms
          word.upcase
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
    phrases = [[]]
    title.split.each do |word|
      phrases.last << word
      phrases << [] if ends_with_punctuation?(word) && !small_word?(word)
    end
    phrases.reject(&:empty?).map { |phrase| phrase.join " " }
  end

  private

  def small_word?(word)
    SMALL_WORDS.include? word.downcase
  end

  def ends_with_punctuation?(word)
    word =~ /[:.;?!]$/
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
  #
  # Pass additional small words in opts[:small_words]
  #
  #   titleize("coffee w cream", small_words: ['w']) # => "Coffee w Cream"
  #
  # For strings in ALL CAPS, specify acronyms to be preserved in opts[:acronyms]
  #
  #   titleize("SMITH TO HEAD SEC", acronyms: ['SEC']) # => "Smith to Head SEC"
  #
  def titleize(opts={})
    if defined? ActiveSupport::Inflector
      ActiveSupport::Inflector.titleize(self, opts)
    else
      Titleize.titleize(self, opts)
    end
  end
  alias_method :titlecase, :titleize

  def titleize!(opts={})
    replace(titleize(opts))
  end
  alias_method :titlecase!, :titleize!
end

if defined? ActiveSupport::Inflector
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
    #
    # Pass additional small words in opts[:small_words]
    #
    #   titleize("coffee w cream", small_words: ['w']) # => "Coffee w Cream"
    #
    # For strings in ALL CAPS, acronyms specified in
    # ActiveSupport::Inflector.inflections.acronyms will be properly
    # capitalized. To override the set of acronyms used, pass in
    # opts[:acronyms]
    #
    #   titleize("SMITH TO HEAD SEC", acronyms: ['SEC']) # => "Smith to Head SEC"
    #
    def titleize(title, opts={})
      opts = {:humanize => true, :underscore => true}.merge(opts)
      title = ActiveSupport::Inflector.underscore(title) if opts[:underscore]
      title = ActiveSupport::Inflector.humanize(title) if opts[:humanize]

      # prioritize passed-in acronyms, fall back to those configured
      # for ActiveSupport::Inflector
      opts[:acronyms] ||= ActiveSupport::Inflector.inflections.acronyms.values

      passthru_opts = opts.select { |k, _| [:acronyms, :small_words].include?(k) }

      Titleize.titleize(title, passthru_opts)
    end
    alias_method :titlecase, :titleize
  end
end
