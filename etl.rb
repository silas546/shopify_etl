#! /usr/bin/env ruby

require 'csv'

#method to check for nil or undefined column values
def missing?(column)
	if column == nil || column == "" || column == "!Undefined"
		true
	else
		false
	end
end


class CocEtl
	# Init
	def initialize
		# Get input and output files from command line arguments
		@infile = ARGV[0]
		@outfile = ARGV[1]
		raise "Syntax: etl.rb <infile> <outfile>" if @infile == nil || @outfile == nil
		# Initialize our output rows
		@output_rows = []
		# Input rows
		@input_rows = []

	end

	def build_sku(row_number, input_row, output_row)
		## puts "#{row_number} - #{input_row[0]}"
	end



	def initial_error_checks
		duplicate_item_numbers = 0
		undefined_categories = 0
		item_numbers = {}
		@input_rows.each_with_index do |row, i|
			item_number = row[0]
			# check for nil item numbers
			raise "ERROR: value nil in row #{i}" if missing?(item_number)
			# check for duplicate item numbers
			if item_numbers[item_number] != nil
			    puts "Found duplicate item number #{item_number} in row #{i}"
			    duplicate_item_numbers+=1
			end
			item_numbers[item_number] = true 
			# check that every product has a category
			if missing?(row[6])
				puts "Found an undefined category in row #{i}"
				undefined_categories+=1
			end	
			# check for suspicious pricing
			 
		end
		puts "#{duplicate_item_numbers} duplicate item_numbers were found"
		puts "#{undefined_categories} undefined categories were found"
	end






	# Run our transforms
	def run
		# Read our csv into @input_rows_
		@input_rows = CSV.read(@infile)

		# Run checks
		initial_error_checks

		# Process each input row
		@input_rows.each_with_index do |row, i|
			row_shopify=[]
			# Do transforms
            build_sku(i, row, row_shopify)
			# Place transformed row into output
			@output_rows << row_shopify
		end
		# Write output_rows into our output csv file
		CSV.open(@outfile, "wb") do |csv|
			@output_rows.each do |row|
				csv << row
			end
		end
    end
end

# Create an instance of our class and run it
CocEtl.new.run
