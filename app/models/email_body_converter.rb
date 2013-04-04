module EmailBodyConverter
	private
	def convert_html_to_plain(html_body)
		doc_fragment = Nokogiri::HTML::DocumentFragment.parse(html_body)

    doc_fragment.css("a").each { |a|
      if a.inner_html !~ /(?!<.*?)http(?!.*?>)/i
        a.children = "#{a[:href]}"
      end
    }

    doc_fragment.text
	end
end