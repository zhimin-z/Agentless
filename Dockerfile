FROM ubuntu:latest

# Install Python 3.12 and other dependencies including git
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    build-essential \
    git \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Install Python 3.12
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y python3.12 python3.12-venv python3.12-dev python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip within the virtual environment
RUN pip install --upgrade pip

# Create a working directory
WORKDIR /app

# Copy requirements.txt (if you have one)
COPY requirements.txt* /app/

# Install Python requirements if requirements.txt exists
RUN if [ -f "requirements.txt" ]; then pip install -r requirements.txt; fi

# Copy your bash script into the container
COPY run.sh /app/
RUN chmod +x /app/run.sh

# Set the working directory to the mounted data directory
WORKDIR /data

# Set the script as the entrypoint
ENTRYPOINT ["/app/run.sh"]