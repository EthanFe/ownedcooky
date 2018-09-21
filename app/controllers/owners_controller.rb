class OwnersController < ApplicationController
	def index
		# render :index
		redirect_to "http://www.rubyonrails.org"
	end

	def exampleaction
		render :whatevertheshit
	end
end