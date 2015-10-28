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
	# Hash for mapping tgs departments to shopify types
	DEPARTMENTS = {

		"1" => "Clothing",
		"2" => "Stationery",
		"3" => "Gift Baskets",
		"4" => "Charms",
		"6" => "Gift Wrap",
		"7" => "Custom Chapter Merchandise",
		"9" => "make-a-wish",
		"11" => "Herff Jones",
		"12" => "Vintage Collection",
	}

	CATEGORIES = {

		"1" => "Sweatshirts",
		"2" => "Short Sleeves",
		"3" => "Cardigans/Zip-Up Jackets",
		"4" => "Shorts & Skirts",
		"5" => "Pants",
		"6" => "Totes",
		"7" => "Aprons",
		"8" => "Headwear",
		"9" => "Long Sleeves",
		"10" => "Youth Clothing",
		"12" => "Scarves/eyewear",
		"14" => "Footwear",
		"16" => "Mittens",
		"17" => "Belts",
	}
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

	def build_type(row_number, input_row, output_row)
		cat = input_row[6]
		dep = input_row[5]
		type = "unknown"
		if missing?(cat)
			# uses a category if no department
			type = DEPARTMENTS[dep]
		else
			type = CATEGORIES[cat]
		end
		if type == nil
			puts "row #{row_number} has a missing or invalid category"
			return
		end
		output_row[4] = type
	end
	def build_handle(row_number, input_row, output_row)
		handle = input_row[1]
		if missing?(handle)
			puts "row #{row_number} is missing an item description"
			return
		end
		if  !missing?input_row[2]
		 	handle += "-#{input_row[2]}"
		end
		if  !missing?input_row[3]
			handle += "-#{input_row[3]}"
		end
		if  !missing?input_row[0]
			handle += "-#{input_row[0]}"
		end
		handle = handle.downcase.gsub(" ","-")
		handle = handle.gsub(/[^-\w\d]|---/,"")
		output_row[0] = handle
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
			build_handle(i, row, row_shopify)
            build_sku(i, row, row_shopify)
			# Place transformed row into output
			build_type(i, row, row_shopify)
			# Places transformed departments and categories into type
			row_shopify[1] = row[1]
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
