#!/bin/bash
set -e

# Function for logging messages
log_info() {
  echo "[INFO] $1"
}

log_warning() {
  echo "[WARNING] $1" >&2
}

log_error() {
  echo "[ERROR] $1" >&2
}

# Function to validate required variables
validate_config() {
  local missing_vars=()
  
  # Check for credential secret - this is critical for encryption
  if [ -z "$NODE_RED_CREDENTIAL_SECRET" ]; then
    missing_vars+=("NODE_RED_CREDENTIAL_SECRET")
  elif [ ${#NODE_RED_CREDENTIAL_SECRET} -lt 8 ]; then
    log_warning "NODE_RED_CREDENTIAL_SECRET is less than 8 characters which is not recommended for security"
  fi
  
  # Check if admin username is provided
  if [ -z "$NODE_RED_ADMIN_USERNAME" ]; then
    log_info "NODE_RED_ADMIN_USERNAME not set, will use default: 'admin'"
  fi
  
  # Admin auth should have either a password or a hashed password
  if [ -z "$NODE_RED_ADMIN_PASSWORD" ] && [ -z "$NODE_RED_ADMIN_HASHED_PASSWORD" ]; then
    log_warning "Neither NODE_RED_ADMIN_PASSWORD nor NODE_RED_ADMIN_HASHED_PASSWORD is set. Authentication will be limited."
  fi
  
  # If any required variables are missing, show error and exit
  if [ ${#missing_vars[@]} -ne 0 ]; then
    log_error "Missing required environment variables: ${missing_vars[*]}"
    log_error "Please set these variables in your environment or docker-compose file."
    exit 1
  fi
}

# Validate configuration before proceeding
log_info "Validating environment configuration..."
validate_config

# Get plain-text passwords from environment variables
ADMIN_PASSWORD=${NODE_RED_ADMIN_PASSWORD:-}
HTTP_PASSWORD=${NODE_RED_HTTP_PASSWORD:-}

# Hash the admin password if provided and not already hashed
if [ -n "$ADMIN_PASSWORD" ]; then
  # Check if it's already a bcrypt hash (starts with $2)
  if [[ "$ADMIN_PASSWORD" == \$2* ]]; then
    log_info "Admin password is already hashed."
    export NODE_RED_ADMIN_HASHED_PASSWORD="$ADMIN_PASSWORD"
  else
    # Validate password strength
    if [ ${#ADMIN_PASSWORD} -lt 8 ]; then
      log_warning "Admin password is less than 8 characters. This is not recommended for security."
    fi
    
    log_info "Generating hashed admin password..."
    export NODE_RED_ADMIN_HASHED_PASSWORD=$(node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" "$ADMIN_PASSWORD" || {
      log_error "Failed to hash admin password. Is bcryptjs installed?";
      exit 1;
    })
  fi
fi

# Hash the HTTP password if provided and not already hashed
if [ -n "$HTTP_PASSWORD" ]; then
  # Check if it's already a bcrypt hash (starts with $2)
  if [[ "$HTTP_PASSWORD" == \$2* ]]; then
    log_info "HTTP password is already hashed."
    export NODE_RED_HTTP_HASHED_PASSWORD="$HTTP_PASSWORD"
  else
    # Validate password strength
    if [ ${#HTTP_PASSWORD} -lt 8 ]; then
      log_warning "HTTP password is less than 8 characters. This is not recommended for security."
    fi
    
    log_info "Generating hashed HTTP password..."
    export NODE_RED_HTTP_HASHED_PASSWORD=$(node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" "$HTTP_PASSWORD" || {
      log_error "Failed to hash HTTP password. Is bcryptjs installed?";
      exit 1;
    })
  fi
fi

# Check for writable directories
for dir in "/data" "/data/node_modules"; do
  if [ -d "$dir" ] && [ ! -w "$dir" ]; then
    log_error "Directory $dir exists but is not writable. Please check permissions."
    exit 1
  fi
done

# Verify Node-RED is installed correctly
if ! command -v node-red &> /dev/null; then
  log_error "Node-RED executable not found. Please check the installation."
  exit 1
fi

# Execute the original command
log_info "All validation checks passed. Starting Node-RED..."
exec "$@"