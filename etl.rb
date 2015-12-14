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

def badprice(column)
	if column.to_i == nil || column.to_i >= 10000
		true
	else
		false
	end
end



class CocEtl
	# Hash for mapping tgs departments to shopify types
	DEPARTMENTS = {

		"1" => "01 Clothing",
		"2" => "02 Stationary",
		"3" => "03 Gifts",
		"4" => "04 Jewelry",
		"6" => "06 Gift Wrap",
		"7" => "07 Customs",
		"9" => "09 Make-a-Wish/Philanthropy",
		"11" => "11 Herff Jones",
		"12" => "12 Vintage Collection",
	}
	#Hash for mapping tgs categories to shopify types
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
	#Hash for mapping tgs vendor numbers to shopify vendor names
	VENDORS = {

		"1" => "BIC/Norwood",
		"10" => "4 imprint",
		"101" => "Express-A-Button",
		"102" => "Whitney Howard Designs",
		"105" => "John Gray Awards/Terryberry",
		"106" => "MaxPack",
		"11" => "Ben Kaufman Sales Co. Inc.",
		"111" => "Apollo Distributing",
		"118" => "Herff Jones",
		"122" => "Two's Company",
		"123" => "Documart",
		"133" => "Legacy",
		"137" => "Tn Secretary Of State",
		"139" => "Imprints Unlimited",
		"14" => "Charles River",
		"142" => "Shayne McCarter",
		"146" => "Aurora World, Inc.",
		"151" => "Midwest -CBK",
		"154" => "Rhea & Ivy",
		"160" => "Zebra Marketing",
		"161" => "Chichlow Data Sciences",
		"168" => "Oriental Trading Co.",
		"169" => "Christopher Radko",
		"173" => "Champion Awards",
		"175" => "Bags And Bows",
		"178" => "McCartney, Inc",
		"179" => "E K Success",
		"181" => "Universal Export Ltd",
		"186" => "Reed & Barton",
		"191" => "Fraternity Row",
		"192" => "Heartstrings",
		"197" => "The Graphic Cow",
		"2" => "Mud Pie",
		"20" => "CK Enterprises",
		"204" => "Rock Creek Metal Craft",
		"212" => "Zutano, Inc.",
		"214" => "Tervis",
		"218" => "Universal Imports",
		"220" => "Gift Mart, Inc.",
		"227" => "Ganz",
		"234" => "BrandAdvantage",
		"237" => "First & Main, Inc.",
		"238" => "HIP Innovative Products, LLC",
		"24" => "Scotty Gear",
		"240" => "Miller Ribbons",
		"247" => "Random House, Inc.",
		"250" => "Brown's Graduation Supplies",
		"252" => "Urban Bird Designs",
		"26" => "Holiday Container",
		"260" => "Ares",
		"262" => "Wild Card Studios",
		"263" => "Crown Manufacturing Inc.",
		"264" => "Joy To The World Collectibles",
		"267" => "LCD Embroidery",
		"268" => "Carved Designs",
		"269" => "C & J Trophy",
		"270" => "Frazzled and Bedazzled",
		"278" => "Old World Christmas",
		"279" => "Inge Glas of Germany",
		"281" => "Bunnies and Bows",
		"282" => "Affiliated",
		"283" => "Kitty Keller Designs, LLC",
		"285" => "Graphic Systems, Inc",
		"287" => "MSC/Mainstreet Collection",
		"291" => "Gary W. Vaughn",
		"292" => "Enviro-Totes",
		"293" => "Wild Eye Designs",
		"296" => "3 Marthas",
		"297" => "Nola Coutoure",
		"298" => "Dynamex",
		"299" => "Finial Showcase",
		"3" => "Mariposa",
		"300" => "What's In Store on Main, LLC",
		"305" => "CBK",
		"307" => "AM PM Kids!",
		"308" => "Rubadub-dub",
		"309" => "Vineyard Vines",
		"310" => "Get Some Greek",
		"312" => "Boxercraft, Inc.",
		"313" => "Safeguard",
		"314" => "Shawn Paul Jewelry",
		"318" => "Conrad Creative",
		"321" => "Maude Asbury",
		"322" => "Mayfair Lane",
		"323" => "Pouch Depot",
		"324" => "Natural Life",
		"325" => "Kaeser & Blair Incorporated",
		"326" => "The Gift Wrap Company",
		"327" => "Re-Hy Bottle",
		"328" => "Regal Art and Gift Inc.",
		"330" => "Gone Greek.com",
		"333" => "B & B Solutions",
		"337" => "Mary Meyer",
		"338" => "Tag",
		"339" => "B Amici",
		"34" => "Potter Mfg. Inc.",
		"341" => "Embroidery Design Group, LLC",
		"346" => "Maison Chic",
		"347" => "Bosuk",
		"348" => "Padibbles",
		"349" => "Cody Foster & Company",
		"350" => "One Hundred 80 Degrees",
		"351" => "Hinge Designs",
		"352" => "Designing Ducks",
		"353" => "New Humor Mfg., Inc.",
		"354" => "Ring Ching Ching",
		"355" => "Coynes & Co.",
		"356" => "It's A Wrap",
		"357" => "Wellspring",
		"358" => "Artrageous T's",
		"359" => "Casey Braun Creative",
		"360" => "Night Owl Paper Goods, Inc.",
		"361" => "Winsome Creations",
		"363" => "Lilly Pulitzer",
		"369" => "Karen Wilson",
		"370" => "Peking Handicraft, Inc.",
		"371" => "Golden Stella",
		"372" => "Up With Paper",
		"374" => "Dolma, Inc.",
		"375" => "Nu Sport",
		"376" => "Sterling Cut Glass",
		"378" => "Canvas Bag Station",
		"379" => "Froggie's",
		"381" => "Coton Colors Express, LLC",
		"382" => "Espe",
		"384" => "UPPERCASES, LLC",
		"385" => "Lifeguard Press",
		"387" => "Dormtique",
		"388" => "Greenhouse Fabrics",
		"390" => "Designs by Beverly, Inc",
		"391" => "Three Designing Women",
		"392" => "Jenniifer Thames Originals",
		"393" => "Sorority Girl Store",
		"394" => "Slant Products",
		"395" => "Demdaco",
		"396" => "Occasionally Made",
		"397" => "College Glasses",
		"398" => "DII Design Imports",
		"399" => "Abbott",
		"4" => "Alexandra's And Co.",
		"40" => "Timber Range Designs",
		"401" => "Star Home",
		"402" => "Confidence Beads",
		"403" => "Rochard",
		"405" => "Lucky Lou Designs, LLC",
		"406" => "Thomas Dale Company",
		"407" => "Silverhooks",
		"408" => "Sloane Ranger",
		"409" => "Boutique Greek",
		"410" => "Boardman Silversmiths, Inc.",
		"411" => "Blue Wave Printing & Display",
		"412" => "Design Imports",
		"413" => "Oh Yeaus",
		"414" => "Signature Tumblers",
		"415" => "Bearington Collection",
		"416" => "The Royal Standard",
		"417" => "Woodstock Chimes",
		"418" => "Kate Spade",
		"419" => "Ann Page",
		"420" => "Donovan Designs",
		"421" => "Sosie Designs",
		"422" => "A-List Greek Designs",
		"423" => "Azarhia, LLC",
		"424" => "Metal Boutique",
		"425" => "Sweaty Bands",
		"426" => "The Collegiate Standard",
		"427" => "Art of Handmade Gifts",
		"428" => "ALEX AND ANI",
		"429" => "Smathers & Branson",
		"432" => "Nava New York",
		"46" => "Angelus Pacific Co.",
		"47" => "Fast Signs",
		"5" => "The Baroness Collection, Inc.",
		"55" => "Metropolis Graphics",
		"56" => "For Bare Feet",
		"57" => "Fox Run USA, LLC",
		"59" => "Faux Designs",
		"6" => "Kitchen Collectibles",
		"60" => "Alpha Stationary",
		"79" => "Craftique",
		"80" => "Geneologie",
		"81" => "Campus I. D.",
		"82" => "Nashville Wraps",
		"83" => "Design Group Inc",
		"84" => "Fine Awards.com",
		"88" => "Specialty Apparel",
		"90" => "Chi Omega Fraternity",
		"91" => "Chi Omega Foundation",
		"92" => "Tennessee Dept Of Revenue",

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

	def build_vendor(row_number, input_row, output_row)
		vendor_number = input_row[8]
		vendor = "unknown"
		if !missing?(vendor_number)
			vendor = VENDORS[vendor_number]
		else
			puts "row #{row_number} is missing a vendor"
		end
		output_row[3] = vendor
	end

	def build_sku(row_number, input_row, output_row)
		## puts "#{row_number} - #{input_row[0]}"
	end

	def build_type(row_number, input_row, output_row)
		dep = input_row[5]
		type = "unknown"
		if !missing?(dep)
			type = DEPARTMENTS[dep]
		end
		if type == nil
			type = "unknown"
		end
		output_row[4] = type
	end

	def build_tags(row_number, input_row, output_row)
		cat = input_row[6]
		tags = nil
		if !missing?(cat)
			tags = CATEGORIES[cat]
		end
		output_row[5] = tags
	end

	def build_handle(row_number, input_row, output_row)
		handle = input_row[1]
		if missing?(handle)
			puts "row #{row_number} is missing an item description"
			return
		end
		#if  !missing?input_row[2]
		 	#handle += "-#{input_row[2]}"
		#end
		#if  !missing?input_row[3]
			#handle += "-#{input_row[3]}"
		#end
		if  !missing?input_row[0]
			handle += "-#{input_row[0]}"
		end
		handle = handle.downcase.gsub(" ","-")
		handle = handle.gsub(/[^-\w\d]|---/,"")
		output_row[0] = handle
	end

	def build_variant_sku(row_number, input_row, output_row)
		variant_sku = input_row[0]
		if missing?(variant_sku)
			puts "row #{row_number} is missing an item number"
			return
		end
		if !missing?input_row[2]
			variant_sku += "-#{input_row[2]}"
		end
		if !missing?input_row[3]
			variant_sku += "-#{input_row[3]}"
		end
		output_row[13] = variant_sku
	end 


	def initial_error_checks
		duplicate_item_numbers = 0
		undefined_categories = 0
		suspicious_price = 0
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
			if missing?(row[6,5])
				puts "Found an undefined category AND undefined department in row #{i}"
				undefined_categories+=1
			end	
			# check for suspicious pricing
			if badprice(row[16])
				puts "Found a suspicious price in row #{i}"
			 suspicious_price+=1
			end
		end
		puts "#{duplicate_item_numbers} DUPLICATE ITEM NUMBERS WERE FOUND"
		puts "#{undefined_categories} UNDEFINED DEPARTMENTS/CATEGORIES WERE FOUND"
		puts "#{suspicious_price} ITEMS WITH SUSPICIOUS PRICING WERE FOUND"
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
			build_tags(i, row, row_shopify)
			# Places transformed departments and categories into type
			build_variant_sku(i, row, row_shopify)
			build_vendor(i, row, row_shopify)
			row_shopify[1] = row[1]
			row_shopify[19] = row[16]
			row_shopify[6] = 'TRUE'
			unless missing?(row[2])
			 row_shopify[7] = 'Size'
			 row_shopify[8] = row[2]
			end
			unless missing?(row[3])
			 row_shopify[9] = 'Color'
			 row_shopify[10] = row[3]
			end
			row_shopify[15] = 'shopify'
			row_shopify[17] = 'deny'
			row_shopify[18] = 'manual'
			row_shopify[21] = 'TRUE'
			row_shopify[22] = 'FALSE'
			row_shopify[26] = 'FALSE'
			row_shopify[43] = row[22]

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
