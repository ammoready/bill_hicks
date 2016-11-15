module BillHicks
  class Category < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    # Field names:
    #
    #   {
    #     code:        "...",  # ':category_code' in Catalog response.
    #     description: "..."   # ':category_description' in Catalog response.
    #   }
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
