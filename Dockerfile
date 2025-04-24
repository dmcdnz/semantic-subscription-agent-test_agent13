FROM python:3.9-slim

WORKDIR /app

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy agent code and assets
COPY agent.py .
COPY agent_base.py .
COPY agent_container.py .
COPY interest_model.py .
COPY config.yaml .

# Create an empty examples file that will be overwritten if one exists
RUN touch /app/examples.jsonl

# Try to copy examples file (will override the empty one)
COPY examples.jsonl /app/

# Create directory for models and copy any existing fine-tuned model files
RUN mkdir -p ./fine_tuned_model/

# Copy fine-tuned model files if they exist
# Create directory for fine-tuned model (will be populated during build)
RUN mkdir -p ./fine_tuned_model/

# Add a README in the fine_tuned_model directory with instructions
RUN echo "# Fine-tuned Model Directory\n\nPlace your fine-tuned sentence transformer model files here to improve agent interest detection.\nThe agent will automatically use this model when present." > ./fine_tuned_model/README.md

# Environment variables
ENV AGENT_ID="${AGENT_ID}"
ENV AGENT_NAME="${AGENT_NAME}"

# Set Core API URL - use host.docker.internal for Windows/Mac, host network for Linux
# For Linux compatibility, this will be overridden at runtime
ENV CORE_API_URL="http://host.docker.internal:8888"

# Run the agent
CMD ["python", "agent_container.py"]
