# coding: utf-8

namespace :ninja do
    desc "Parsing openings.ninja!"

    require "nokogiri"
    require "open-uri"
    # require 'json'
    # require 'date'
    # require 'net/http'

    @root_url = "https://openings.ninja"
    @ext_for_year = "/season"

    # Variables for test
    @year_href_test = '/season/2002'
    @anime_href_test = '/Pokemon+Best+Wishes!+Season+2:+Episode+N/op/1'

    # Variables for full
    # @_full = ''

    task :get_all => :environment do
        puts "PARSING STARTED!"

        @years = get_years()

        @years.each do |year|
            puts "YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR YEAR"
            puts "Parsing #{year[:title]} year!"

            @seasons = get_animes_from_year(year[:href])
            @seasons.each do |season|
                puts "SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON SEASON"
                puts "Parsing #{season[:title]}!"

                season[:animes].each do |anime|
                    puts "ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME ANIME"
                    puts "Parsing #{anime[:title]} anime!"

                    @info = get_info_from_anime(anime[:href])

                    @info.each do |info|
                        puts "Parsing #{info[:title]}"

                        info[:movies].each do |movie|
                            puts "Parsing #{movie[:title]}"

                            movie[:links].each do |link|
                                puts "Link source #{link[:source]}"
                                puts "Link url #{link[:url]}"
                            end
                        end
                    end
                end
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

                @seasons.last[:animes].push({
                        'title': @anime_title,
                        'href': @anime_href
                    })
            end
        end

        return @seasons
    end

    def get_info_from_anime(anime)
        @info = []

        @anime_title_href = anime.split('/op')[0]

        html = Nokogiri::HTML(open("#{@root_url}#{anime}"), nil, 'UTF-8')

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

    # def create_()
    #   @ = .new()
    #   if @.save
    #     puts "!"
    #     puts @
    #   else
    #     puts "Error occured while creating .!"
    #     puts @.errors.full_messages
    #   end
    # end
end
