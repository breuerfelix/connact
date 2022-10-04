import os
import sys
import bcrypt
import json
from radicale.auth import BaseAuth
from radicale.log import logger
from pymongo import MongoClient
from bson.json_util import dumps

PLUGIN_CONFIG_SCHEMA = {
    "auth": {},
}

class Auth(BaseAuth):
    client: MongoClient

    def __init__(self, configuration):
        super().__init__(configuration.copy(PLUGIN_CONFIG_SCHEMA))
        mongo_url = os.environ.get("MONGO_URL")
        if not mongo_url:
            logger.error("env MONGO_URL not found")
            sys.exit(1)

        self.client = MongoClient(mongo_url)


    def login(self, login, password):
        try:
            return self._login(login, password)
        except Exception as e:
            logger.error("exception in login flow")
            logger.error(e)

        return ""


    def _login(self, login, password):
        logger.info("Login attempt by %r with password %r", login, password)
        if not login or not password:
            logger.info("username or password is empty")
            return ""

        user = self.client.auth.users.find_one({"username": login.lower()})
        if not user:
            logger.info("user not found")
            return ""

        jsonUser = json.loads(dumps(user))
        if "password" not in jsonUser:
            logger.info("user has not set a password")
            return ""

        if not bcrypt.checkpw(password.encode(), jsonUser["password"].encode()):
            logger.info("wrong password")
            return ""

        return login
