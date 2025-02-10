FROM nodered/node-red:latest-debian

# Copy package.json to the WORKDIR so npm builds all
# of your added nodes modules for Node-RED
WORKDIR /data
# COPY package.json /data
# RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production
RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production node-red-contrib-postgresql
RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production bcryptjs

WORKDIR /usr/src/node-red
RUN mkdir -p /usr/src/node-red/config
COPY settings.js /usr/src/node-red/config/settings.js
# Copy _your_ Node-RED project files into place
# NOTE: This will only work if you DO NOT later mount /data as an external volume.
#       If you need to use an external volume for persistence then
#       copy your settings and flows files to that volume instead.
# COPY flows_cred.json /data/flows_cred.json
# COPY flows.json /data/flows.json

COPY docker-entrypoint.sh /usr/src/node-red/docker-entrypoint.sh
RUN chmod +x /usr/src/node-red/docker-entrypoint.sh

EXPOSE 1880

ENTRYPOINT ["/usr/src/node-red/docker-entrypoint.sh"]
CMD ["npm", "start", "--", "--userDir", "/data"]
