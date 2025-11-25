from gen import app as app_gen
from syst import app as app_systemctl
from typer import Typer


app = Typer()
app.add_typer(app_gen, name="gen")
app.add_typer(app_systemctl, name="sys")


if __name__ == "__main__":
    app()
