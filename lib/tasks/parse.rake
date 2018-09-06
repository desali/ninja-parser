# coding: utf-8

namespace :anime do
    desc "Parsing openings.ninja with shikimori!"

    require "nokogiri"
    require "open-uri"
    require "json"


    @root_url = "https://openings.ninja"
    @ext_for_year = "/season"
    @ext_url_for_shikimori = "https://shikimori.org/animes?search="

    # Variables for test
    @year_href_test = '/season/2016'
    @anime_href_test = '/Pokemon+Best+Wishes!+Season+2:+Episode+N/op/1'

    # Variables for full
    # @_full = ''

    task :check => :environment do
        @shikimori_anime_html = Nokogiri::HTML(open(URI.escape("https://shikimori.org/animes/36286-re-zero-kara-hajimeru-isekai-seikatsu-memory-snow"), 'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36'), nil, 'UTF-8')

        if (@shikimori_anime_html.css('.scores')[0])
            @scores_html = @shikimori_anime_html.css('.scores')[0]
            @scores_html.css('meta').each do |meta|
                if meta['itemprop'] == 'bestRating'
                    @rating_full = meta['content']
                elsif meta['itemprop'] == 'ratingValue'
                    @rating_value = meta['content']
                elsif meta['itemprop'] == 'ratingCount'
                    @rating_count = meta['content']
                end
            end
        else
            @rating_full = 0
            @rating_value = 0
            @rating_count = 0
        end
    end

    task :get_all => :environment do
        puts "PARSING STARTED!"
        start_time = Time.now

        @years = get_years()

        @years.each do |year|
            # For heroku (2018 and 2017 parsed already)

            if year[:title] == '2018' || year[:title] == '2017' || year[:title] == '2016'
                puts "Skipping 2018 or 2017 or 2016"
                next
            end

            # puts "YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR"
            puts "Parsing #{year[:title]} year!"

            @year = Year.find_by(title: year[:title]) || create_year(year[:title])

            if @year
                @seasons = get_animes_from_year(year[:href])
                @seasons.each do |season|
                    # puts "SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON"
                    puts "Parsing #{season[:title]}!"
                    @season = Season.find_by(title: season[:title]) || create_season(season[:title])

                    if @season
                        season[:animes].each do |anime|
                            # puts "ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME"
                            puts "Parsing #{anime[:title]} anime!"
                            puts "Link to anime #{anime[:href]}"

                            @anime = create_anime(anime[:title], anime[:title_ru], @season[:id], @year[:id], anime[:rating_value], anime[:views_count])

                            if @anime
                                @info = get_info_from_anime(anime[:href])

                                @info.each do |info|
                                    puts "Parsing #{info[:title]}"

                                    info[:movies].each do |movie|
                                        puts "Parsing #{movie[:title]}"

                                        movie[:links].each do |link|
                                            puts "Link source #{link[:source]}"
                                            puts "Link url #{link[:url]}"

                                            @movie = create_movie(movie[:title], @anime[:id], info[:title], link[:source], link[:url])
                                        end
                                    end
                                end
                            else
                                # If anime doesnt created
                            end
                        end

                    else
                        # If there is no season or doesnt created
                    end
                end
            else
                # If year doesnt created
            end
        end
    end

    task :get_years => :environment do
        # get_years()
        @years = get_years()

        puts @years
    end

    task :get_animes_from_year => :environment do
        # get_animes_from_year(@year_href_test)
        @seasons = get_animes_from_year(@year_href_test)

        puts @seasons
    end

    task :get_info_from_anime => :environment do
        # get_info_from_anime(@anime_href_test)
        @info = get_info_from_anime(@anime_href_test)

        puts @info
    end


    def get_years()
        @years = []

        html = Nokogiri::HTML(open("#{@root_url}#{@ext_for_year}"), nil, 'UTF-8')

        @years_html = html.css(".modal-body")[0]
        @years_html.css('a').each do |year|
            @year_title = year.text
            @year_href = year['href']

            @years.push({
                    'title': @year_title,
                    'href': @year_href
                })
        end

      return @years
    end

    def get_animes_from_year(year)
        @seasons = []

        html = Nokogiri::HTML(open("#{@root_url}#{year}"), nil, 'UTF-8')

        @animes_html = html.css(".modal-body")[0]

        @animes_html.css('.modal-title').each do |season|
            @season_title = season.text

            @seasons.push({
                    'title': @season_title,
                    'animes': []
                })

            @start_index = @animes_html.to_s.index(@season_title)
            @end_index = @animes_html.to_s.index("modal-title", @start_index) || -1

            Nokogiri::HTML(@animes_html.to_s[@start_index..@end_index]).css('a').each do |anime|
                @anime_title = anime.text
                @anime_href = anime['href']

                # sleep(2)
                @shikimori_html = Nokogiri::HTML(open(URI.escape("#{@ext_url_for_shikimori}#{@anime_title}"), 'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36'), nil, 'UTF-8')

                if @shikimori_html.css('.cover')[0]
                    if @shikimori_html.css('.cover')[0].css('.name-ru')[0]
                        @anime_title_ru = @shikimori_html.css('.cover')[0].css('.name-ru')[0]['data-text']
                    else
                        @anime_title_ru = @anime_title
                    end

                    @anime_shikimori_href = @shikimori_html.css('.cover')[0]['data-href'] || @shikimori_html.css('.cover')[0]['href']

                    # sleep(2)
                    @shikimori_anime_html = Nokogiri::HTML(open(URI.escape("#{@anime_shikimori_href}"), 'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36'), nil, 'UTF-8')
                    puts "#{@anime_shikimori_href}"

                    if (@shikimori_anime_html.css('.scores')[0])
                        @scores_html = @shikimori_anime_html.css('.scores')[0]
                        @scores_html.css('meta').each do |meta|
                            if meta['itemprop'] == 'bestRating'
                                @rating_full = meta['content']
                            elsif meta['itemprop'] == 'ratingValue'
                                @rating_value = meta['content']
                            elsif meta['itemprop'] == 'ratingCount'
                                @rating_count = meta['content']
                            end
                        end
                    else
                        @rating_full = 0
                        @rating_value = 0
                        @rating_count = 0
                    end

                    @views_json = JSON.parse(@shikimori_anime_html.css('#rates_statuses_stats')[0]['data-stats'].to_s)

                    @views_json.each do |stat|
                        if stat['name'] == 'Просмотрено'
                            @watched_count = stat['value']
                        elsif stat['name'] == 'Смотрю'
                            @watching_count = stat['value']
                        end
                    end

                    @views_count = (@watched_count + (@watching_count * 0.8)).to_i

                    @seasons.last[:animes].push({
                            'title': @anime_title,
                            'title_ru': @anime_title_ru,
                            'href': @anime_href,
                            'rating_value': @rating_value,
                            'rating_full': @rating_full,
                            'rating_count': @rating_count,
                            'watched_count': @watched_count,
                            'views_count': @views_count
                        })
                else
                    @shikimori_anime_html = @shikimori_html

                    @scores_html = @shikimori_anime_html.css('.scores')[0]
                    @scores_html.css('meta').each do |meta|
                        if meta['itemprop'] == 'bestRating'
                            @rating_full = meta['content']
                        elsif meta['itemprop'] == 'ratingValue'
                            @rating_value = meta['content']
                        elsif meta['itemprop'] == 'ratingCount'
                            @rating_count = meta['content']
                        end
                    end

                    @views_json = JSON.parse(@shikimori_anime_html.css('#rates_statuses_stats')[0]['data-stats'].to_s)

                    @views_json.each do |stat|
                        if stat['name'] == 'Просмотрено'
                            @watched_count = stat['value']
                        elsif stat['name'] == 'Смотрю'
                            @watching_count = stat['value']
                        end
                    end

                    @views_count = (@watched_count + (@watching_count * 0.8)).to_i

                    @seasons.last[:animes].push({
                            'title': @anime_title,
                            'title_ru': @anime_title_ru,
                            'href': @anime_href,
                            'rating_value': @rating_value,
                            'rating_full': @rating_full,
                            'rating_count': @rating_count,
                            'watched_count': @watched_count,
                            'views_count': @views_count
                        })
                end
            end
        end

        return @seasons
    end

    def get_info_from_anime(anime)
        @info = []

        @anime_title_href = anime.split('/op')[0]
        puts @anime_title_href
        puts "#{@root_url}#{anime}"

        html = Nokogiri::HTML(open(URI.escape("#{@root_url}#{@anime_title_href}/")), nil, 'UTF-8')

        @info_html = html.css('#themes')[0]

        @info_html.css('.dropdown-header').each do |info|
            @info_title = info.text

            @info.push({
                    'title': @info_title,
                    'movies': []
                })

            @start_index = @info_html.to_s.index(@info_title)
            @end_index = @info_html.to_s.index('<li class="dropdown-header">', @start_index) || -1

            Nokogiri::HTML(@info_html.to_s[@start_index..@end_index]).css('li').each do |movie|
                @movie_theme = movie['data-theme']
                @movie_type = movie['data-theme'].split('-')[0]
                @movie_index = movie['data-theme'].split('-')[1]
                @movie_title = movie.css('a')[0].text[3..-1]

                @info.last[:movies].push({
                        'title': @movie_title,
                        'type': @movie_type,
                        'index': @movie_index,
                        'links': []
                    })

                @movie_html = html.css('#mirror')[0]

                @movie_html.css('li').each do |link|
                    if link['data-theme'] == @movie_theme
                        if link['data-url'] != 'https://youtube.com/?op'
                            @movie_link_source = link.css('a')[0].text
                            @movie_link_url = link['data-url']

                            @info.last[:movies].last[:links].push({
                                    'source': @movie_link_source,
                                    'url': @movie_link_url
                                })
                        end
                    end
                end
            end
        end

        return @info
    end


    def create_year(title)
      @year = Year.new(title: title)
      if @year.save
        puts "Year created!"
        puts @year

        return @year
      else
        puts "Error occured while creating year!"
        puts @year.errors.full_messages

        return false
      end
    end

    def create_season(title)
      @season = Season.new(title: title)
      if @season.save
        puts "Season created!"
        puts @season

        return @season
      else
        puts "Error occured while creating season!"
        puts @season.errors.full_messages

        return false
      end
    end

    def create_anime(title, title_ru, season_id, year_id, rating, views)
      @anime = Anime.new(title: title, title_ru: title_ru, season_id: season_id, year_id: year_id, rating: rating, views: views)
      if @anime.save
        puts "Anime created!"
        puts @anime

        return @anime
      else
        puts "Error occured while creating anime!"
        puts @anime.errors.full_messages

        return false
      end
    end

    def create_movie(title, anime_id, theme, source, link)
      @movie = Movie.new(title: title, anime_id: anime_id, theme: theme, source: source, link: link)
      if @movie.save
        puts "Movie created!"
        puts @movie

        return @movie
      else
        puts "Error occured while creating movie!"
        puts @movie.errors.full_messages

        return false
      end
    end
end
