module Jekyll

require 'yaml'

  class AutoCrossRefBlock < Liquid::Block

    def initialize(tag_name, text, tokens)
      super
    end

    def render(context)
      output = super

      ## Load terms from file
      terms = YAML.load_file("_autocrossref.yaml")

      ## Sort terms by reverse length, so longest matches get linked
      ## first (e.g. "block chain" before "block"). Otherwise short
      ## terms would get linked first and there'd be nothing for long
      ## terms to link to.
      terms.sort_by { |k, v| -k.length }.each { |term|
        term[0] = Regexp.escape(term[0])

        ## Replace literal space with \s to match across newlines. This
        ## can do weird things if you don't end sentences with a period,
        ## such as linking together "standard" and "transactions" in
        ## something like this:
        ### * RFC1234 is a standard
        ###
        ### Transactions are cool
        term[0].gsub!('\ ', '\s+')

        output.gsub!(/
            (?<!\w)  ## Don't match inside words
            #{term[0]}  ## Find our key
            (?![^\[]*\])  ## No subst if key inside [brackets]
            (?![^\{]*\})  ## No subst if key inside {braces}
            (?![^\(]*(\.svg|\.png))  ## No subst if key inside an image name. This 
		     ## simple regex has the side effect that we can't
		     ## use .svg or .png in non-image base text; if that
		     ## becomes an issue, we can devise a more complex
		     ## regex
            (?!\w)  ## Don't match inside words
          /xmi, "[\\&][#{term[1]}]")
      }

      output
    end # terms.sort_by
  end # render(content)
end # AutoCrossRefBlock class 

Liquid::Template.register_tag('autocrossref', Jekyll::AutoCrossRefBlock)
