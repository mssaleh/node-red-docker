module.exports = {
  credentialSecret: process.env.NODE_RED_CREDENTIAL_SECRET,

  adminAuth: {
    type: "credentials",
    users: [
        {
            username: process.env.NODE_RED_ADMIN_USERNAME || "admin",
            password: process.env.NODE_RED_ADMIN_HASHED_PASSWORD || "",
            permissions: "*"
        }
    ]
  },

  httpNodeAuth: {
    user: process.env.NODE_RED_HTTP_USERNAME || "http",
    pass: process.env.NODE_RED_HTTP_HASHED_PASSWORD || "",
  },
}