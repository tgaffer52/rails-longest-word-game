require "open-uri"
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(2) { [*'A'..'Z'].sample } +
               Array.new(3) { %w[A E I O U].sample } +
               Array.new(4) { %w[A B C D F G H J K L M N P Q R S T V W X Y Z].sample }
    @letters.shuffle!
    @time_start = Time.now.to_f
  end

  def score
    @word = params[:word]
    @letters = params[:letters][1..-2]
    @time_start = params[:time_start].to_f
    @time = (Time.now.to_f - @time_start)
    @last_score = session[:last_score]

    score_and_message

    update

    @high_score = session[:high_score]
  end

  private

  def english_word?
    url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    dictionary_serialized = URI.open(url).read
    dictionary = JSON.parse(dictionary_serialized)
    dictionary["found"]
  end

  def only_grid?
    word_a = @word.upcase.chars
    word_a.all? { |letter| word_a.count(letter) <= @letters.count(letter) }
  end

  def score_and_message
    if english_word? && only_grid?
      @score = (@word.size / @time.to_f).round(2)
      @message = "Well done!"
    elsif !english_word?
      @score = 0
      @message = "Penalty! This doesn't seem to be an English word..."
    else
      @score = 0
      @message = "Penalty! #{@word.upcase} can't be built out of #{@letters.gsub(/\"/, "")}"
    end
  end

  def update
    if session[:total_score]
      session[:total_score] += @score
    else
      session[:total_score] = @score
    end

    session[:high_score] = @score if !session[:high_score] || @score > session[:high_score]

    @total_score = session[:total_score].round(2)
    session[:last_score] = @score
  end
end
