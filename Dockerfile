# Use the official Selenium Python image
FROM selenium/standalone-chrome:latest

# Switch to root to install packages
USER root

# Install Python and pip
RUN apt-get update && apt-get install -y python3 python3-pip

# Set up the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Switch back to the selenium user
USER seluser

# Specify the command to run your application
CMD ["python3", "-m", "gunicorn", "app:app", "--bind", "0.0.0.0:8080"]
