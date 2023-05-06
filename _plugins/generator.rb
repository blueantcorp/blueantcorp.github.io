module AddCustomPagePlugin
    class CustomGenerator < Jekyll::Generator
      def generate(site)
        site.data.topics << CustomPage.new(site: site)
      end
    end
  
    class CustomPage < Jekyll::Page
      def initialize(site:)
        @site = site
  
        # Path to the source directory.
        @base = site.source
  
        # Directory the page will reside in.
        @dir = 'posts'
  
        # All pages have the same filename.
        @basename = 'index'
        @ext = '.html'
        @name = 'index.html'
  
        # Define any custom data you want.
        @data = {
          'layout' => 'page',
          'custom' => 'data',
          # Get data from wherever you need.
          'whatever' => File.read('~/whatever.txt')
        }
      end
    end
end