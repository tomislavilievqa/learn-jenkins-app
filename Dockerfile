# Start from the Microsoft Playwright base image version 1.39.0 on Ubuntu Jammy (22.04)
FROM mcr.microsoft.com/playwright:v1.39.0-jammy

# Install global npm packages for:
# 1. Netlify CLI (netlify-cli) - used for deploying and managing sites on Netlify.
# 2. jq (node-jq) - a lightweight command-line JSON processor, helpful for parsing JSON data.
RUN npm install -g netlify-cli node-jq