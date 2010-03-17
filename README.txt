= Titleize

* http://rubygems.org/gems/titleize

== DESCRIPTION:

Adds String#titleize for creating properly capitalized titles.
It can be called as Titleize.titleize or "a string".titleize. It is also
aliased as titlecase.

The list of "small words" which are not capped comes from the New York Times 
Manual of Style, plus 'vs' and 'v'.

If loaded in a Rails environment, it modifies Inflector.titleize.

Based on TitleCase.pl by John Gruber.
http://daringfireball.net/2008/05/title_case

== SYNOPSIS:

  "a lovely and talented title".titleize # => "A Lovely and Talented Title"

== INSTALL:

* gem install titleize

== LICENSE:

(The MIT License)

Copyright (c) 2008 Grant Hollingworth

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
