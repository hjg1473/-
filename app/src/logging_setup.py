import logging

class CustomFormatter(logging.Formatter):
    def format(self, record):
        if not hasattr(record, 'user'):
            record.user = 'anonymous'  # 기본값 설정
        return super().format(record)

class LoggerSetup:

    def __init__(self) -> None:
        self.logger = logging.getLogger('main_logger')
        self.setup_logging()

    def setup_logging(self):
        if self.logger.hasHandlers():
            self.logger.handlers.clear()

        LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s - [user: %(user)s]"
        formatter = CustomFormatter(LOG_FORMAT)

        # Configure console handler
        console = logging.StreamHandler()
        console.setFormatter(formatter)

        # Configure TimeRotatingFileHandler
        log_file = "src/logs/fastapi-efk.log"
        file = logging.handlers.TimedRotatingFileHandler(
            filename=log_file, when="midnight", backupCount=5
        )
        file.setFormatter(formatter)

        # Add handlers
        self.logger.addHandler(console)
        self.logger.addHandler(file)
        self.logger.setLevel(logging.INFO)

    def get_logger(self, user=None):
        return logging.LoggerAdapter(self.logger, {'user': user or 'anonymous'})
