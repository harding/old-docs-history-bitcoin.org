#mdhtml.rb replaces HTML comments like <!--#md#(content)#md#-->
#in all pages by the content of each comment.

#This is used as a workaround for GitHub not displaying
#markdown correctly when wrapped in HTML block elements.

module Jekyll
  class MarkdownHTML < Generator
    def generate(site)
      site.pages.each do |page|
        page.content = page.content.gsub('<!--#md#','').gsub('#md#-->','')
      end
    end
  end
end
