import os

from cs50 import SQL
from flask import Flask, flash, redirect, render_template, request, session
from flask_session import Session
from werkzeug.security import check_password_hash, generate_password_hash

from helpers import apology, login_required, lookup, usd

# Configure application
app = Flask(__name__)

# Custom filter
app.jinja_env.filters["usd"] = usd

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///finance.db")


@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/")
@login_required
def index():
    """Show portfolio of stocks"""
    portifolio = db.execute(
        "SELECT *, sum(num_shares) as sum_shares FROM transactions WHERE user_id = ? GROUP BY symbol ORDER BY symbol", session["user_id"])
    user_info = db.execute("SELECT * FROM users WHERE id = ?", session["user_id"])
    ticker_list = []
    ticker_list_total = []
    for i in range(len(portifolio)):
        ticker_updated = float(lookup(portifolio[i]["symbol"])["price"])
        ticker_list.append(ticker_updated)
        ticker_list_total.append(ticker_updated*portifolio[i]["sum_shares"])
    cash = float(user_info[0]["cash"])
    portifolio_total = sum(ticker_list_total)
    return render_template("index.html", portifolio=portifolio, ticker_list=ticker_list, ticker_list_total=ticker_list_total, cash=cash, total=portifolio_total)


@app.route("/buy", methods=["GET", "POST"])
@login_required
def buy():
    """Buy shares of stock"""
    if request.method == "GET":
        return render_template("buy.html")

    elif request.method == "POST":
        ticker = lookup(request.form.get("symbol"))
        shares_input = request.form.get("shares")
        if not shares_input.isdigit():
            return apology("INVALID SHARE NUMBER", 400)

        num_shares = int(request.form.get("shares"))
        user_cash = db.execute("SELECT cash FROM users WHERE id = ?", session["user_id"])

        if ticker is None:
            return apology("INVALID SYMBOL", 400)
        elif num_shares < 1 or num_shares%1 != 0:
            return apology("INVALID SHARE NUMBER", 400)
        elif ticker["price"]*num_shares > user_cash[0]['cash']:
            return apology("Not enough resource for this transaction", 400)
        balance = user_cash[0]['cash'] - ticker["price"]*num_shares
        db.execute("INSERT INTO transactions (user_id, symbol, num_shares, current_price) VALUES (?, ?, ?, ?)",
                   session["user_id"], ticker["symbol"], num_shares, ticker["price"])
        db.execute("UPDATE users SET cash = ? WHERE id = ?", balance, session["user_id"])
        return redirect("/")
    return apology("an error occured", 400)


@app.route("/history")
@login_required
def history():
    """Show history of transactions"""
    historic = db.execute("SELECT * FROM transactions WHERE user_id = ?", session["user_id"])
    return render_template("history.html", historic=historic)


@app.route("/login", methods=["GET", "POST"])
def login():
    """Log user in"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":
        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)

        # Query database for username
        rows = db.execute(
            "SELECT * FROM users WHERE username = ?", request.form.get("username")
        )

        # Ensure username exists and password is correct
        if len(rows) != 1 or not check_password_hash(
            rows[0]["hash"], request.form.get("password")
        ):
            return apology("invalid username and/or password", 403)

        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("login.html")


@app.route("/logout")
def logout():
    """Log user out"""

    # Forget any user_id
    session.clear()

    # Redirect user to login form
    return redirect("/")


@app.route("/quote", methods=["GET", "POST"])
@login_required
def quote():
    """Get stock quote."""
    if request.method == "GET":
        return render_template("quote.html")

    elif request.method == "POST":
        symbol = request.form.get("symbol")
        quote = lookup(symbol)

        if quote is not None:
            return render_template("quote.html", quote=quote)

        return apology("error", 400)


@app.route("/register", methods=["GET", "POST"])
def register():
    """Register user"""
    if request.method == "GET":
        return render_template("register.html")

    elif request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        confirmation = request.form.get("confirmation")
        rows = db.execute("SELECT * FROM users WHERE username = ?", username)

        if username == "":
            return apology("username not valid", 400)

        elif len(rows) != 0:
            return apology("username already exists", 400)

        elif (password == "" or confirmation == "") or password != confirmation:
            return apology("password input error", 400)

    db.execute("INSERT INTO users (username, hash) VALUES (?,  ?)", username, generate_password_hash(password))
    new_user = db.execute("SELECT id FROM users WHERE username = ?", username)
    session["user_id"] = new_user[0]["id"]
    return redirect("/")


@app.route("/sell", methods=["GET", "POST"])
@login_required
def sell():
    """Sell shares of stock"""
    portifolio = db.execute(
        "SELECT * FROM users LEFT JOIN transactions ON users.id = transactions.user_id WHERE users.id = ? AND num_shares > 0 GROUP BY symbol ORDER BY symbol", session["user_id"])

    if request.method == "GET":
        return render_template("sell.html", portifolio=portifolio)

    elif request.method == "POST":
        ticker = request.form.get("symbol")
        ticker_amount = db.execute(
            "SELECT sum(num_shares) as sum FROM transactions WHERE user_id = ? AND symbol = ?", session["user_id"], ticker)
        shares_sell = int(request.form.get("shares"))
        current_price = lookup(ticker)
        if shares_sell > int(ticker_amount[0]["sum"]):
            return apology("Too many shares")

        db.execute("INSERT INTO transactions (user_id, symbol, num_shares, current_price) VALUES ( ?, ?, ?, ?)",
                   session["user_id"], ticker, -shares_sell, current_price["price"])
        return redirect("/")

    return apology("error")


@app.route("/change_password", methods=["GET", "POST"])
def change_password():
    """Change user password"""
    if request.method == "GET":
        return render_template("change-password.html")

    elif request.method == "POST":
        username = request.form.get("username")
        actual_password = request.form.get("actual_password")
        new_password = request.form.get("new_password")
        confirmation = request.form.get("confirmation")
        rows = db.execute("SELECT * FROM users WHERE username = ?", username)

        if rows[0]["id"] != session["user_id"]:
            return apology("invalid username", 403)

        elif actual_password == "" or not check_password_hash(rows[0]["hash"], request.form.get("actual_password")):
            return apology("invalid password", 403)

        elif (new_password == "" or confirmation == "") or new_password != confirmation:
            return apology("invalid new password", 403)

    db.execute("UPDATE users SET hash = ? WHERE id = ?", generate_password_hash(new_password), session["user_id"])
    new_user = db.execute("SELECT id FROM users WHERE username = ?", username)
    session["user_id"] = new_user[0]["id"]
    return redirect("/")
