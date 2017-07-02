import click
from cefpython3 import cefpython as cef
import platform
import webbrowser
import sys

URL="http://localhost:3838/apps/"

@click.group()
def cli():
    pass

@click.command()
def start():
    webbrowser.open_new(URL)

@click.command()
def cef():
    check_versions()
    sys.excepthook = cef.ExceptHook
    cef.Initialize()
    cef.CreateBrowserSync(urli=URL,
            window_title="DeepVis")
    cef.MessageLoop()
    cef.Shutdown()

def check_versions():
    print("[deepvis.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[deepvis.py] Python {ver} {arch}".format(
        ver=platform.python_version(), arch=platform.architecture()[0]))
    assert cef.__version__ >= "55.3", "CEF Python v55.3+ required to run this"


cli.add_command(start)
cli.add_command(cef)
