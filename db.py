import pyexasol
from config import password, dsn, user

conn = pyexasol.connect(
    dsn=dsn,
    user=user,
    password=password,
    encryption=True,
    websocket_sslopt={"cert_reqs": 0}
)

def init_db():
    print("Setting up Schema if not exists...")
    with open("./schema.sql") as f:
        sql = f.read()

    for statement in sql.split(";"):
        if statement.strip():
            conn.execute(statement)