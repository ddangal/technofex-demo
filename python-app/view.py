from flask import Flask, render_template
from flask_mysqldb import MySQL
from flask_cors import CORS

import MySQLdb.cursors
import os
import json

app = Flask(__name__)
CORS(app)


app.config['MYSQL_HOST'] = 'database-1.cm5pyamwkmzx.us-east-1.rds.amazonaws.com'
app.config['MYSQL_USER'] = 'admin'
app.config['MYSQL_PASSWORD'] = 'Genese#321'
app.config['MYSQL_DB'] = 'demo'
mysql = MySQL(app)
@app.route('/')
def home():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("select * from user_data")
    data=cursor.fetchall()
    response = json.dumps(data)
    return json.dumps(data)


if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)