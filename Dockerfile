FROM python:3.12

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ .

EXPOSE 80

CMD ["python", "manage.py", "runserver", "0.0.0.0:80"]

