from os import environ
from app.application import create_app
from flask import g, session

app = create_app()


def before_request():
    """pull user info from the database based on session id"""
    g.user = None
    if 'user_name' in session:
        try:
            try:
                g.user = session['user_name']
            except TypeError:  # session probably expired
                pass
        except KeyError:
            pass


MANDATORY_ENV_VARIABLES = ["FLASK_ENV", "FLASK_APP", "SECRET_KEY",
                           "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "USER_NAME", "USER_PASSWORD", "TERMINATION_DRY_RUN"]


def validate_mandatory_env_variables():
    for variable in MANDATORY_ENV_VARIABLES:
        if environ.get(variable) is None:
            raise SystemExit(
                "ERROR: Kandula app must have a valid environment variable of {}. Exiting...".format(variable))


if __name__ == "__main__":
    validate_mandatory_env_variables()
    app.run(host='0.0.0.0', use_evalex=False)
