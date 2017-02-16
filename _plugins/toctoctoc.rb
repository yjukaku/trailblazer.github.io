require "nokogiri"

module Jekyll
  # module TOC
  #   def toctoctoc(html)
  #     doc = Nokogiri::HTML(html)

  #     # h2[:id] comes from kramdown/auto_ids.
  #     headers = doc.css("h2").collect do |h2|

  #       # FIXME: we don't apply that change, yet, as we only render the menu.
  #       h2["data-magellan-target"] = h2[:id]
  #       # h2.after(%{<a name="#{h2[:id]}"></a>})

  #       [h2[:id], h2.text]
  #     end

  #     content = headers.collect do |id, text|
  #       %{<li><a href="##{id}">#{text}</a></li>}
  #     end

  #     %{
  #       <ul class="vertical menu" data-magellan id="page-toc">
  #         #{content.join("\n")}
  #       </ul>
  #     }
  #   end # toctoctoc
  # end

  class TOCGenerator# < Converter

    def call(page)
      html = page.output
      doc  = Nokogiri::HTML(html)

# sidebar
      path = page.path.sub("/index.md", "")
      path = path.sub(".md", ".html")
      path = "/#{path}"
      current_a = doc.css(".side-nav li a[href='#{path}']").first
      if current_a
        # Set active class for this <a>, and also its corresponding '.link-group' parent
        current_a[:class] += " is-active"
        current_li = current_a.parent
        nested_ul = current_li.parent
        if nested_ul[:class] =~ "nested"
          nested_ul[:class] += " is-active"
        end
      end


# add magellan target
      # h2[:id] comes from kramdown/auto_ids.
      headers = doc.css("h2").collect do |h2|
        h2["data-magellan-target"] = h2[:id]
        # h2.after(%{<a name="#{h2[:id]}"></a>})

        [h2[:id], h2.text]
      end

      content = headers.collect do |id, text|
        %{<li><a href="##{id}">#{text}</a></li>}
      end

      magellan = %{
        <ul class="vertical menu" data-magellan id="page-toc">
          <li class="page-toc-heading">ON THIS PAGE:</li>
          #{content.join("\n")}
        </ul>
      }

      magellan_node = doc.css("magellan-placeholder").first and magellan_node.replace(magellan)
      doc.to_s
    end
  end
end

# Liquid::Template.register_filter(Jekyll::TOC)

Jekyll::Hooks.register :pages, :post_render do |page, payload|
  page.output = Jekyll::TOCGenerator.new.(page)
  # code to call after Jekyll renders a post
end
