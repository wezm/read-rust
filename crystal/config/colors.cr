# This enables the color output when in development or test
# Check out the Colorize docs for more information
# https://crystal-lang.org/api/Colorize.html
Colorize.enabled = LuckyEnv.development? || LuckyEnv.test?
