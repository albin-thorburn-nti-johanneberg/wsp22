require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

enable :sessions

get('/')do
    p session
    slim(:index)
end

get('/company') do
    slim(:"company/company")
end

get('/company/new') do
    slim(:"company/new")
end

get('/users/new') do
    slim(:"users/new")
end


get('/login') do
    slim(:"/login")
end

post('/company/new') do
    starting_price = 100
    number_of_shares = 10
    name = params[:name]
    db = SQLite3::Database.new("db/database.db")
    result = db.execute("SELECT id FROM company WHERE name =?",name)

    if result.empty?
        db.execute("INSERT INTO company (name, numberOfShares, startingPrice) VALUES (?,?,?)",name, number_of_shares, starting_price)
    end
    redirect('/')
end

post('/users/new') do
    starting_cash = 100
    name = params[:name]
    password = params[:password]
    db = SQLite3::Database.new("db/database.db")
    result = db.execute("SELECT id FROM user WHERE name =?",name)

    if result.empty?
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO user (name, password, cash) VALUES (?,?,?)",name, password_digest, starting_cash)
    end
    redirect('/')
end

post('/users/login') do
    name = params[:name]
    password = params[:password]
    db = SQLite3::Database.new("db/database.db")
    password_compare = db.execute("SELECT password FROM user WHERE name =?",name)
    if BCrypt::Password.new(password_compare.first.first) == password 
        p "lösenorden stämmer"
    else
        p "löseonrden stämmer inte"
    end
end