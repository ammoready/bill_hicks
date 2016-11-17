module BillHicks
  # Category item response structure:
  #
  #   {
  #     code:        "...",  # ':category_code' in Catalog response.
  #     description: "..."   # ':category_description' in Catalog response.
  #   }
  class Category < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    # Returns an array of hashes with category details.
    def all
      categories = []

      # Categories are listed in catalog csv, so fetch that.
      catalog = Catalog.all(@options)
      catalog.each do |item|
        categories << {
          code: item[:category_code],
          description: item[:category_description]
        }
      end

      categories.uniq! { |c| c[:description] }
      categories.sort_by! { |c| c[:description] }

      categories
    end

  end
end
