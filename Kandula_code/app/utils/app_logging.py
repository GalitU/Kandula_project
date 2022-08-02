import logging
import sys

import json_logging


def init_logging():
    json_logging.init_flask(enable_json=True)

    logger = logging.getLogger()
    FORMAT_FILE = "[%(asctime)s %(filename)-13s->%(funcName)-s():%(lineno)-4s]-[%(levelname)-7s]: %(message)s   [%(threadName)s]"
    FORMAT_SCREEN = "[%(asctime)s %(filename)-5s->%(funcName)-6s():%(lineno)-4s]-[%(levelname)-7s]: %(message)s   [%(threadName)s]"
    logging.basicConfig(format=FORMAT_SCREEN, level='INFO')
    logger.setLevel('INFO')
    file_handler = logging.handlers.RotatingFileHandler(filename='kandula.log', maxBytes=5000000, backupCount=10)
    file_handler.setFormatter(logging.Formatter(FORMAT_FILE))
    logger.addHandler(file_handler)
    logger.debug(f"Log level will be set to {'DEBUG'}")
