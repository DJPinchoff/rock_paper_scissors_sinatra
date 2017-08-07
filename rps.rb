require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, "secret"
end

helpers do
  def human_wins
    session[:human]
  end

  def computer_wins
    session[:computer]
  end

  def match_won?
    session[:human].to_i == 3 || session[:computer].to_i == 3
  end
end

def computer_choice
  ["rock", "paper", "scissors"].sample
end

def detect_winner(user, comp)
  case user
  when "rock"
    rock_result(comp)
  when "paper"
    paper_result(comp)
  when "scissors"
    scissors_result(comp)
  end
end

def rock_result(comp)
  if comp == "rock"
    :tie
  elsif comp == "scissors"
    :human
  else
    :computer
  end
end

def paper_result(comp)
  if comp == "paper"
    :tie
  elsif comp == "rock"
    :human
  else
    :computer
  end
end

def scissors_result(comp)
  if comp == "scissors"
    :tie
  elsif comp == "paper"
    :human
  else
    :computer
  end
end

def increment_winner(winner)
  session[:human] = session[:human] || "0"
  session[:computer] = session[:computer] || "0"
  return if winner == :tie
  session[winner] = (session[winner].to_i + 1).to_s
end

def winning_message(winner, user, comp)
  phrases = ["rock crushes scissors!", "scissors cuts paper!",
             "paper covers rock!"]
  if winner == :tie
    "It's a tie!"
  elsif phrases[0].include?(user) && phrases[0].include?(comp)
    phrases[0].capitalize
  elsif phrases[1].include?(user) && phrases[1].include?(comp)
    phrases[1].capitalize
  else
    phrases[2].capitalize
  end
end

def match_won_message(winner)
  return if winner == :tie
  if winner == :human
    "You win the match. CONGRATULATIONS!!"
  else
    "Computer wins the match. GAME OVER!!"
  end
end

def reset
  session[:human] = "0"
  session[:computer] = "0"
  session[:message] = "Scores have been reset."
end

get "/" do
  redirect "/user_choice"
end

get "/user_choice" do
  erb :user_choice, layout: :layout
end

get "/:user_choice" do
  reset if match_won?
  @user_choice = params[:user_choice]
  @comp_choice = computer_choice
  @winner = detect_winner(@user_choice, @comp_choice)
  increment_winner(@winner)
  session[:message] = if match_won?
                        winning_message(@winner, @user_choice, @comp_choice) +
                          ' ' + match_won_message(@winner)
                      else
                        winning_message(@winner, @user_choice, @comp_choice)
                      end
  erb :result
end

post "/reset" do
  reset
  redirect "/user_choice"
end
