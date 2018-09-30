class Api::V1::RequestsController < ApplicationController

    def shuffle
        @shuffle = [[], [], [], [], []]

        @top50 = Anime.order(views: :desc).limit(50)
        @top50.sample(5).each do |sample|
            @shuffle[0] << sample[:id]
            @shuffle[4] << sample[:id]
        end

        @shuffle_demo = [*1..Anime.count].shuffle
        @shuffle_demo -= @shuffle[0]
        @shuffle[0] += @shuffle_demo
        @shuffle[4] += @shuffle_demo

        @answers_list = [*1..Anime.count].shuffle

        for i in (0..Anime.count)
            if @answers_list.count < 4
                @shuffle[0] = @shuffle[0][0..i-1]
                @shuffle[1] = @shuffle[1][0..i-1]
                @shuffle[2] = @shuffle[2][0..i-1]
                @shuffle[3] = @shuffle[3][0..i-1]
                @shuffle[4] = @shuffle[4][0..i-1]

                break
            end

            @answers_list.delete(@shuffle[0][i])

            @answers = @answers_list.shuffle.sample(3)
            @shuffle[1][i] = @answers[0]
            @shuffle[2][i] = @answers[1]
            @shuffle[3][i] = @answers[2]
        end

        @shuffle[0].map! { |id| Anime.find(id)[:title_ru] }
        @shuffle[1].map! { |id| Anime.find(id)[:title_ru] }
        @shuffle[2].map! { |id| Anime.find(id)[:title_ru] }
        @shuffle[3].map! { |id| Anime.find(id)[:title_ru] }
        @shuffle[4].map! { |id|
            @anime = Anime.find(id)

            @movie = @anime.movies.shuffle.find { |m| m[:theme] == "Openings" }

            if !@movie
               @movie = @anime.movies.shuffle.find { |m| m[:theme] == "Endings" }
            end

            @movie[:link]
        }

        render json: @shuffle
    end
end
