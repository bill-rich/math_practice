#!/usr/bin/env ruby

require 'sinatra'
require 'erb'
require 'time'
require 'yaml'

set :bind, '0.0.0.0'

$max=10
$operations = ["+", "-"]
def create_problem()
	@a = (rand*$max).to_i
	@b = (rand*$max).to_i
	@operation = $operations[(rand*$operations.count).to_i]
	while @b > @a and @operation == "-"
		@b = (rand*$max).to_i
	end
	return @a, @b, @operation
end

def check_problem(a, b, operation, answer)
	if eval("#{a}#{operation}#{b}") == answer.to_i
		@result = "correct"
		$score = $score +1
	else
		@result = "incorrect"
	end
	return @result
end

get '/' do
	if $start_time == nil or $start_time + 60 < Time.now
		$start_time = Time.now
	end
	$time_left = (60 - (Time.now - $start_time)).to_i
	$score = 0
	$a, $b, $operation = create_problem()
	ERB.new(File.new("index.erb").read).result
end

post "/" do
	puts Time.now
	puts $start_time + 60
	$result = check_problem(params[:a], params[:b], params[:operation], params[:answer])
	if $start_time + 60 < Time.now
		redirect "/finished"
	end
	$time_left = (60 - (Time.now - $start_time)).to_i
	$a, $b, $operation = create_problem()
	ERB.new(File.new("index.erb").read).result
end

get "/finished" do
	$data = YAML.load(File.open("math.yaml"))
	$record = false
	if $score > $data[:score]
		$data[:score] = $score.to_i
		$data[:time] = Time.now()
		$record = true
	end
	File.open("math.yaml", "w"){|f| f.write $data.to_yaml}
	ERB.new(File.new("finish.erb").read).result
end
