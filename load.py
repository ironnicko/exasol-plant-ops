import pandas as pd
from db import conn, init_db
import os

DATASET_DIR = "./plant_ops_dataset/csv"

def load_data_to_db():
    print("Loading Data to DB...")
    for file in os.listdir(DATASET_DIR):
        file_name, ext = file.split(".")
        if ext != "csv": continue
        df = pd.read_csv(os.path.join(DATASET_DIR, file))
        conn.import_from_pandas(df, ("PLANT_OPS", file_name.upper()))  

init_db()
load_data_to_db()
print("Successfully loaded data!")