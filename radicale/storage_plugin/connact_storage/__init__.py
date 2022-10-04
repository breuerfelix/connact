from radicale.storage import BaseCollection, BaseStorage
from radicale.log import logger

PLUGIN_CONFIG_SCHEMA = {
    "storage": {},
}

class Storage(BaseStorage):
    def __init__(self, configuration):
        super().__init__(configuration.copy(PLUGIN_CONFIG_SCHEMA))
        logger.info("creating Storage")


class Collection(BaseCollection):
    pass
