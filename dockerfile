# Use official Python 3.9 image
FROM python:3.9-slim

# Prevent Python from buffering stdout/stderr
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (better caching)
COPY requirements.txt /app/

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the whole project
COPY . /app/

# Collect static files (ensure settings allow this)
RUN python manage.py collectstatic --noinput

# Expose port (Waitress will listen here)
EXPOSE 8000

# Start Django using Waitress
# Replace "yourprojectname" with your Django project folder (where wsgi.py is)
CMD ["waitress-serve", "--port=8000", "fyp.wsgi:application"]
