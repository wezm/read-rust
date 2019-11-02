# Load .env file before any other config or app code
require "dotenv"
Dotenv.load rescue nil

# Require your shards here
require "avram"
require "lucky"
require "carbon"
require "authentic"
require "jwt"
