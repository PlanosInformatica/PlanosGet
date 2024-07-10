from os import path,listdir
import signal
import logging
from datetime import datetime
import hashlib
from logging.handlers import RotatingFileHandler
import json
PACKAGE_ARCH=['amd64','i386','noarch']
PACKAGE_OS=['windows', 'linux','android']

REPO_ROOT='/home/siteplanos/repo'
INDEX_FILE='packageindex.csv'
META_FILE = '/home/siteplanos/indexgen/packagemeta.json'
logger = logging.getLogger()
handler = RotatingFileHandler('/home/siteplanos/indexgen/logs/indexgen.log', maxBytes=1024000,backupCount=5)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)


class DaemonSignalHandler:
    terminate = False
    def __init__(self):
        signal.signal(signal.SIGINT, self.exit_sigint)
        signal.signal(signal.SIGTERM, self.exit_sigterm)
    def exit_sigint(self, *args):
        logging.error(f'indexgen received SIGINT and is now terminating')
        self.terminate = True
    def exit_sigterm(self, *args):
        logging.info(f'indexgen received SIGTERM and is now terminating')
        self.terminate = True


def main():
    sighandler = DaemonSignalHandler()
    logger.info(f'Starting updating the index at {datetime.now()}')
    package_meta = json.load(open(META_FILE))
    with open(path.join(REPO_ROOT,INDEX_FILE),"w") as index:
        for arch in PACKAGE_ARCH:
            for so in PACKAGE_OS:
                file_list = listdir(path.join(REPO_ROOT,arch,so))
                for file in file_list:
                    filename = path.splitext(file)[0]
                    package_name = filename.split('-')[0]
                    package_version = filename.split('-')[1]
                    package_hash = hashlib.md5(open(path.join(REPO_ROOT,arch,so,file),"rb").read()).hexdigest()
                    package_desc = package_meta[package_name]['desc']
                    package_deps = package_meta[package_name]['deps']
                    index.write(f'{package_name};{arch};{so};{package_version};{package_hash};{package_desc};{package_deps}\n')
    logger.info(f'Finished updating the index at {datetime.now()}')


if __name__ == '__main__':
    main()