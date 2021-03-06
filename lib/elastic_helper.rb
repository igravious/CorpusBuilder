
	require 'elasticsearch'

	def elastic(log_switch)
		begin
			name = caller[0]
			# STDOUT.puts "called from #{name}"
			ec = Elasticsearch::Client.new log: log_switch
			Rails.logger.error ec.inspect
		rescue Exception => msg
			Rails.logger.error "  Possible Elastic Search issue? #{msg}"
			ec = nil
			# STDERR.puts juju
		end
		yield ec
	end

	def count_snaps
		query = Elasticsearch::Client.new log: false
		Rails.logger.error query.inspect
		begin
			res = query.get(index: 'corpus', type: 'snapshots', id: 0) {}
			counter = res['_source']['counter']
			return counter.to_i
		rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
			return 0
		end
	end

	def latest_snap
		# TODO if 0 blah
		'snapshot'+(count_snaps.to_s)
	end

