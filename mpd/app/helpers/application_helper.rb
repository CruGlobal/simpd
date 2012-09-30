module ApplicationHelper

	def print_flashes
		render :partial => 'shared/flash'
	end

	def page_header(title)
		render :partial => 'shared/page_header', :locals => {:title => title}
	end
end
