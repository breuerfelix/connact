import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();
const JWT_SECRET = config.requireSecret("jwtSecret")
const MONGO_URL = config.requireSecret("mongoURL")
const DB_USER = config.requireSecret("dbUser")
const DB_PASS = config.requireSecret("dbPass")
const DB_NAMESPACE = config.requireSecret("dbNamespace")
const DB_DATABASE = config.requireSecret("dbDatabase")

export {
    JWT_SECRET,
    DB_USER,
    DB_PASS,
    DB_NAMESPACE,
    DB_DATABASE,
    MONGO_URL,
}
