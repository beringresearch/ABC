import sys
import time
import threading

class Spinner:
    """A pretty spinner to indicate progress, because why not :) ."""

    busy = False
    delay = 0.1

    @staticmethod
    def spinning_cursor():
        """Spinning cursror running in a separate thread."""
        while 1:
            for cursor in '|/-\\':
                yield cursor

    def __init__(self, delay=None):
        self.spinner_generator = self.spinning_cursor()
        if delay and float(delay):
            self.delay = delay

    def spinner_task(self):
        while self.busy:
            sys.stdout.write(next(self.spinner_generator))
            sys.stdout.flush()
            time.sleep(self.delay)
            sys.stdout.write('\b')
            sys.stdout.flush()

    def start(self):
        self.busy = True
        threading.Thread(target=self.spinner_task).start()
    
    def stop(self):
        self.busy = False
        time.sleep(self.delay)
