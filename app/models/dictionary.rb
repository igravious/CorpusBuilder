class Dictionary < ActiveRecord::Base

	def domain
		self.URI.split('/')[2]
	end
end
