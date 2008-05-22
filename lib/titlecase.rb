module Titlecase
  SMALL_WORDS = %w{a an and as at but by en for if in of on or the to v v. via vs vs.}

  extend self

  def titlecase(title)
    phrases(title).map do |phrase|
      unless phrase[/[[:alpha:]]/]
        phrase
      else
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
      end
    end.join(" ")
  end

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
  def titlecase
    Titlecase.titlecase(self)
  end
  alias_method :titleize, :titlecase
end

if defined? Inflector
  module Inflector
    extend self

    def titlecase(title)
      Titlecase.titlecase(Inflector.humanize(Inflector.underscore(title)))
    end
    alias_method :titleize, :titlecase
  end
end
