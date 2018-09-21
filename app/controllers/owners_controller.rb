class OwnersController < ApplicationController
	def index
		# render :index
		@owners = Owner.all
	end

	def exampleaction
		render :whatevertheshit
	end
end