# Node-RED Docker Deployment

This repository contains the necessary configuration files to deploy Node-RED in a Docker environment with secure authentication and persistent storage.

## Features

- Customized Node-RED Docker image based on the official image
- Built-in password hashing functionality with bcryptjs
- Environment variable-based configuration
- Authentication for both admin interface and HTTP nodes
- Comprehensive validation and error handling for configuration
- Support for Kubernetes deployment
- Volume persistence for Node-RED data
- Timezone configuration
- Optimized settings.js handling using Node-RED's --settings parameter

## Getting Started

### Prerequisites

- Docker and Docker Compose installed
- For Kubernetes: kubectl and a running Kubernetes cluster

### Docker Compose Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/nodered-docker.git
   cd nodered-docker
   ```

2. Create an `.env` file based on the `env.example`:
   ```bash
   cp env.example .env
   ```

3. Edit the `.env` file to set your credentials and configuration.

4. Start the Node-RED container:
   ```bash
   docker-compose up -d
   ```

5. Access Node-RED at http://localhost:1880 and log in with your configured credentials.

### Authentication Configuration

This setup provides two authentication methods:

1. **Admin Authentication**: Controls who can access the Node-RED editor and admin pages
2. **HTTP Node Authentication**: Controls who can access HTTP endpoints created by Node-RED flows

Passwords can be provided either in plain text (they will be hashed automatically at startup) or pre-hashed using bcrypt.

### Environment Variables

See the `env.example` file for all available configuration options.

### Configuration Validation

The container performs several validation checks at startup:

- **Required Variables**: Verifies that essential environment variables like `NODE_RED_CREDENTIAL_SECRET` are set
- **Password Strength**: Checks password length and warns if passwords are less than 8 characters
- **File/Directory Permissions**: Validates that required directories are writable
- **Node-RED Installation**: Confirms that Node-RED is correctly installed

If critical validation checks fail, the container will exit with an error message, preventing insecure configurations from running.

## Kubernetes Deployment

For Kubernetes deployment, use the provided `manifest-nodered.yml` file:

1. Create a Kubernetes secret for your credentials:
   ```bash
   kubectl create secret generic nodered-secret \
     --from-literal=credentials=your_random_credential_secret \
     --from-literal=admin-username=admin \
     --from-literal=admin-password=your_admin_password_hash \
     --from-literal=http-username=http \
     --from-literal=http-password=your_http_password_hash
   ```

2. Apply the configuration:
   ```bash
   kubectl apply -f manifest-nodered.yml
   ```

## Building the Docker Image

To build the Docker image locally:

```bash
docker build -t nodered-custom .
```

## File Structure

- `docker-compose.yaml`: Docker Compose configuration for local deployment
- `Dockerfile`: Docker image definition with optimized settings.js handling
- `entrypoint.sh`: Container entrypoint script that handles password hashing
- `settings.js`: Node-RED settings file with authentication configuration stored in a fixed, non-volume location
- `manifest-nodered.yml`: Kubernetes deployment manifest
- `env.example`: Example environment variables file

## Implementation Notes

The settings.js file is stored at `/usr/src/node-red/config/settings.js` and Node-RED is configured to use this file with the `--settings` parameter. This approach eliminates the need for copying settings files during container initialization and avoids issues with volume mounts overwriting configuration files.

## License

This project is open-source and free to use.