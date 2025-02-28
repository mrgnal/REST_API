import os

from dotenv import load_dotenv

load_dotenv()

print("DATABASE_NAME:", os.getenv('DB_NAME'))
print("DB_USER:", os.getenv('DB_USERNAME'))
print("DB_PASSWORD:", os.getenv('DB_PASSWORD'))
print("DB_HOST:", os.getenv('DB_HOST'))
print("DB_PORT:", os.getenv('DB_PORT'))
