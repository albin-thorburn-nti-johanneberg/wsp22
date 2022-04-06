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

get('/company/view') do
    db = SQLite3::Database.new("db/database.db")
    id = session[:user_id]
    name = db.execute("SELECT name FROM user WHERE id =?",id)
    cash = db.execute("SELECT cash FROM user WHERE id =?",id)

    companies = db.execute("SELECT")

    slim(:"company/view", locals:{name:name, cash:cash, companies:})

end

get('/users/new') do
    slim(:"users/new")
end

get('/login') do
    slim(:"/login")
end

get('/delete') do
    db = SQLite3::Database.new("db/database.db")
    name = ""
    db.execute("DELETE FROM user WHERE name =?",name)
    db.execute("DELETE FROM company WHERE name =?",name)

end

post('/company/new') do
    starting_price = 100
    number_of_shares = 10
    name = params[:name]
    db = SQLite3::Database.new("db/database.db")
    result = db.execute("SELECT id FROM company WHERE name =?",name)

    admin_id = 19
    status = "ask"

    if result.empty?
        db.execute("INSERT INTO company (name, numberOfShares, startingPrice) VALUES (?,?,?)",name, number_of_shares, starting_price)

        company_id = db.execute("SELECT id FROM company WHERE name =?",name)

        number_of_shares.times do
            db.execute("INSERT INTO stock (ownerId, companyId, price, status) VALUES (?,?,?,?)",admin_id, company_id, starting_price, status)
        end
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
        name = params[:name]
        id = db.execute("SELECT id FROM user WHERE name =?",name)
        session[:user_id] = id
        redirect('/company/view') 
    else
        p "löseonrden stämmer inte"
    end
end