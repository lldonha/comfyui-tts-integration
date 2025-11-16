FROM python:3.12-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY api_wrapper.py .

# Expose port
EXPOSE 8001

# Run the application
CMD ["python", "api_wrapper.py"]
