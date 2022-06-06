"""Views module."""

from flask import Flask
from flask import render_template, flash, url_for, request, redirect, g, session

from dependency_injector.wiring import inject, Provide
from werkzeug.utils import redirect

from app.src.services import app_health, instance_shutdown_scheduling
from app.src.services.instance_actions import InstanceActions
from app.src.services.instance_data import InstanceData
from app.containers import Container
import os
import requests

from botocore.exceptions import ClientError

from flask.views import MethodView

import logging

logger = logging.getLogger()


class InstanceAPI(MethodView):
    @inject
    def __init__(self, instance_actions: InstanceActions = Provide[Container.instance_actions]) -> None:
        session_galit = requests.Session()
        self.instance_actions = instance_actions
        logger.info("GALITU: InstanceAPI ctor")
        super().__init__()

    def get(self, instance_id, instance_action):
        try:
            if not session or not session['user_name']:
                return redirect(url_for('login'))
            logger.info("GALITU - get() , user session = " +
                        session['user_name'])
        except:
            return redirect(url_for('login'))

        try:
            action_to_run = self.instance_actions.action_selector(
                instance_action)
            action_to_run(instance_id)
            flash("Your request to {} instance {} is in progress".format(
                instance_action, instance_id), "info")
        except (ClientError, RuntimeError) as e:
            flash("Cannot perform action '{}' on instance: {}".format(
                instance_action, instance_id), "danger")
            logger.exception(e)

        return redirect(url_for('instances'))

    def post(self, instance_id, instance_action):
        try:
            if not session or not session['user_name']:
                return redirect(url_for('login'))
            logger.info("GALITU - post() , user session = " +
                        session['user_name'])
        except:
            return redirect(url_for('login'))

        try:
            action_to_run = self.instance_actions.action_selector(
                instance_action)
            action_to_run(instance_id)
            flash("Your request to {} instance {} is in progress".format(
                instance_action, instance_id), "info")
        except (ClientError, RuntimeError) as e:
            flash("Cannot perform action '{}' on instance: {}".format(
                instance_action, instance_id), "danger")
            logger.exception(e)

        return redirect(url_for('instances'))


def main():
    logger.info("GALITU: Main view")
    try:
        if session and session['user_name']:
            return redirect(url_for('home'))
        logger.info("GALITU - login() , user session = " +
                    session['user_name'])
    except:
        return redirect(url_for('login'))
    file_path = os.getcwd()
    with open(file_path + '/app/views/version.txt', 'r') as file:
        version_number = file.read().replace('\n', '')
    return render_template('main.html', title='Welcome to Kandula', version_docker=version_number)


def login():
    logger.info("GALITU: Login view")
    try:
        if session and session['user_name']:
            return redirect(url_for('home'))
        logger.info("GALITU - login() , user session = " +
                    session['user_name'])
    except:
        pass

    file_path = os.getcwd()
    with open(file_path + '/app/views/version.txt', 'r') as file:
        version_number = file.read().replace('\n', '')
    if request.method == 'POST':
        session.pop('user_name', None)

        # From OS ENV
        user_name_env_input = os.environ.get('USER_NAME')
        user_name_env_no_last_char = user_name_env_input[:-1]
        last_char = user_name_env_input[-1:]
        user_password_env_input = os.environ.get('USER_PASSWORD')
        password_env_no_last_char = user_password_env_input[:-1]
        logger.info(
            "!!!=== GALITU - login(1.1), user_name_env_input = [{}], user_password_env_input = [{}]".format(user_name_env_input, user_password_env_input))
        logger.info(
            "!!!=== GALITU - login(2), last char[{}], user_name_env_no_last_char = [{}], password_env_no_last_char = {}".format(last_char, user_name_env_no_last_char, password_env_no_last_char))

        # From UI session
        user_name = request.form['user_name']
        user_password = request.form['user_password']
        logger.info("!!!=== GALITU - login(3) , from UI session user_name = [{}], was user_password = [{}]".format(
            user_name, user_password))

        if (user_name_env_no_last_char and user_name_env_no_last_char == user_name and
            password_env_no_last_char and password_env_no_last_char == user_password):
            session['user_name'] = user_name
            logger.info("!!!=== GALITU - login(4) - SUCCEDED")
            return redirect(url_for('home'))

        if (user_name_env_input and user_name_env_input == user_name and
            user_password_env_input and user_password_env_input == user_password):
            session['user_name'] = user_name
            logger.info("!!!=== GALITU - login(5) - SUCCEDED")
            return redirect(url_for('home'))

        logger.info("!!!=== GALITU - FAILED login(6), " +
                    "user_name_galit_env_input = [" + user_name_env_input +
                    "], user_name = [" + user_name +
                    "], user_password_env_input = [" + user_password_env_input +
                    "], user_password = [" + user_password + "]")
        return redirect(url_for('login'))

    return render_template('login.html', title='Login to Kandula', version_docker=version_number)


def logout():
    file_path = os.getcwd()
    with open(file_path + '/app/views/version.txt', 'r') as file:
        version_number = file.read().replace('\n', '')
    if request.method == 'POST':
        session.pop('user_name', None)

    session.clear()

    return render_template('logout.html', title='Logout to Kandula', version_docker=version_number)


def home():
    try:
        if not session or not session['user_name']:
            return redirect(url_for('login'))
        logger.info("GALITU - home() , user session = " + session['user_name'])
    except:
        return redirect(url_for('login'))

    file_path = os.getcwd()
    with open(file_path + '/app/views/version.txt', 'r') as file:
        version_number = file.read().replace('\n', '')
    return render_template('home.html', title='Welcome to Kandula', version_docker=version_number)


def about():
    try:
        if not session or not session['user_name']:
            return redirect(url_for('login'))
        logger.info("GALITU - about() , user session = " +
                    session['user_name'])
    except:
        return redirect(url_for('login'))

    file_path = os.getcwd()
    with open(file_path + '/app/views/version.txt', 'r') as file:
        version_number = file.read().replace('\n', '')
    return render_template('about.html', title='About', version_docker=version_number)


def health():
    try:
        if not session or not session['user_name']:
            return redirect(url_for('login'))
        logger.info("GALITU - health() , user session = " +
                    session['user_name'])
    except:
        return redirect(url_for('login'))

    health_metrics, is_app_healthy = app_health.get_app_health()

    return render_template('health.html', title='Application Health',
                           healthchecks=health_metrics), 200 if is_app_healthy else 500


def metrics():
    try:
        if not session or not session['user_name']:
            return redirect(url_for('login'))
        logger.info("GALITU - metrics() , user session = " +
                    session['user_name'])
    except:
        return redirect(url_for('login'))
    return render_template('metrics.html', title='metrics', )


@inject
def instances(instance_data: InstanceData = Provide[Container.instance_data]):
    try:
        if not session or not session['user_name']:
            return redirect(url_for('login'))
        logger.info("GALITU - instances() , user session = " +
                    session['user_name'])
    except:
        return redirect(url_for('login'))

    instances_response = instance_data.get_instances()
    return render_template('instances.html', title='Instances',
                           instances=instances_response['Instances'])


def scheduler():
    try:
        if not session or not session['user_name']:
            return redirect(url_for('login'))
        logger.info("GALITU - scheduler() , user session = " +
                    session['user_name'])
    except:
        return redirect(url_for('login'))
    if request.method == 'POST':
        instance_shutdown_scheduling.handle_instance(request.form)

    scheduled_instances = instance_shutdown_scheduling.get_scheduled_instances()
    return render_template('scheduler.html', title='Scheduling',
                           scheduled_instances=scheduled_instances["Instances"])
