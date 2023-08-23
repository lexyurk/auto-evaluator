FROM node:14

WORKDIR /usr/src/app

# Copy package.json and yarn.lock files to the container
COPY nextjs ./

# Install the app dependencies
RUN yarn install

# Expose port 3000 (default port for Next.js) for the app to be accessible
EXPOSE 3000

# Command to run the application
CMD ["yarn", "dev"]
