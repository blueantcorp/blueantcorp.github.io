module Jekyll
    class DataPage < Page
      def initialize(site, base, dir, name)
        @site = site
        @base = base
        @dir = dir
        @name = name
        self.process(@name)
        self.data ||= {}
      end
    end
  
    class CategoryPageGenerator < Generator
      def generate(site)
        data = site.config['navigation']
        if data
            data.each do |data|
                name = 'index.html'
                title = data['title']
                category = data['category']
                permalink = data['permalink']
                published = data['published'] || false
                if title && category && permalink && published
                    page = Jekyll::DataPage.new(site, site.source, permalink, name)
                    page.data['layout'] = data['layout'] || 'page_index'
                    page.data['title'] = title
                    page.data['description'] = data['description'] || ''
                    page.data['category'] = category
                    page.data['permalink'] = permalink
                    page.data['published'] = published
                    site.pages << page
                end
            end
        end
      end
    end
end