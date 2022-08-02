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
from prometheus_client import Counter, generate_latest, Summary, Gauge, Info


logger = logging.getLogger()

loggedin_user = None
view_metric_login = Counter('kandula_login', 'Login view', ['user', 'result'])
view_metric_logout = Counter('kandula_logout', 'Logout view', ['user'])
view_metric_action = Counter('kandula_action', 'Action', ['instance', 'action', 'http_access'])
view_metric_page_visit = Summary('kandula_page_visit_info', 'Page info, visit count and time spent for opn', ['page'])
view_metric_exception = Counter('kandula_compute_exception', 'Exception thrown in all functions', ['page'])
view_metric_instances_gauge = Gauge('kandula_instances_ec2', 'Number of instances', ['state'])
view_metric_version_info = Info('kandula_version', 'Description of info')

class InstanceAPI(MethodView):
    @inject
    def __init__(self, instance_actions: InstanceActions = Provide[Container.instance_actions]) -> None:
        session_galit = requests.Session()
        self.instance_actions = instance_actions
        logger.info("GALITU: InstanceAPI ctor")
        super().__init__()

    @view_metric_exception.labels(page='InstanceAPI_get').count_exceptions()
    @view_metric_page_visit.labels(page='InstanceAPI_get').time()
    def get(self, instance_id, instance_action):
        try:
            if not session or not session['user_name']:
                return redirect(url_for('login'))
            logger.info("GALITU - get() , user session = " +
                        session['user_name'])
        except:
            return redirect(url_for('login'))

        try:
            action_to_run = self.instance_actions.action_selector(instance_action)
            view_metric_action.labels(instance=instance_id, action=instance_action, http_access='get').inc()
            action_to_run(instance_id)
            flash("Your request to {} instance {} is in progress".format(
                instance_action, instance_id), "info")
        except (ClientError, RuntimeError) as e:
            flash("Cannot perform action '{}' on instance: {}".format(
                instance_action, instance_id), "danger")
            logger.exception(e)

        return redirect(url_for('instances'))

    @view_metric_exception.labels(page='InstanceAPI_post').count_exceptions()
    @view_metric_page_visit.labels(page=f'InstanceAPI_post').time()
    def post(self, instance_id, instance_action):
        user_login_name = is_login_succeded()
        if not user_login_name:
            return redirect(url_for('login'))

        try:
            action_to_run = self.instance_actions.action_selector(instance_action)
            view_metric_action.labels(instance=instance_id, action=instance_action, http_access='post').inc()
            action_to_run(instance_id)
            flash("Your request to {} instance {} is in progress".format(
                instance_action, instance_id), "info")
        except (ClientError, RuntimeError) as e:
            flash("Cannot perform action '{}' on instance: {}".format(
                instance_action, instance_id), "danger")
            logger.exception(e)

        return redirect(url_for('instances'))


@view_metric_exception.labels(page='main').count_exceptions()
@view_metric_page_visit.labels(page=f'main').time()
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
    logger.info(f"GALITU - kandula version {version_number}")
    view_metric_version_info.info({'version': version_number, 'purpose': 'Final project of opsschool devops course'})
    return render_template('main.html', title='Welcome to Kandula', version_docker=version_number)


@view_metric_exception.labels(page='is_login_succeded').count_exceptions()
@view_metric_page_visit.labels(page='is_login_succeded').time()
def is_login_succeded():
    global loggedin_user
    # From OS ENV
    user_name_env_input = os.environ.get('USER_NAME')
    user_name_env_no_last_char = user_name_env_input[:-1]
    last_char = user_name_env_input[-1:]
    user_password_env_input = os.environ.get('USER_PASSWORD')
    password_env_no_last_char = user_password_env_input[:-1]
    logger.info(f"!!!=== GALITU - login(1.1), user_name_env_input = [{user_name_env_input}], user_password_env_input = [{user_password_env_input}]")
    logger.info(f"!!!=== GALITU - login(2), last char[{last_char}], user_name_env_no_last_char = [{user_name_env_no_last_char}], password_env_no_last_char = {password_env_no_last_char}")

    # From UI session
    user_name = request.form['user_name']
    loggedin_user = user_name
    user_password = request.form['user_password']
    logger.info(f"!!!=== GALITU - login(3) , from UI session user_name = [{user_name}], was user_password = [{user_password}]")

    if (user_name_env_no_last_char and user_name_env_no_last_char == user_name and
            password_env_no_last_char and password_env_no_last_char == user_password):
        logger.info(f"!!!=== GALITU - login(4) , return OK {user_name} from UI session user_name = [{user_name}], was user_password = [{user_password}]")
        return user_name

    if (user_name_env_input and user_name_env_input == user_name and
            user_password_env_input and user_password_env_input == user_password):
        logger.info(f"!!!=== GALITU - login(5) , return OK {user_name} from UI session user_name = [{user_name}], was user_password = [{user_password}]")
        return user_name

    logger.error("!!!=== GALITU - FAILED login(6), " +
                 "user_name_galit_env_input = [" + user_name_env_input +
                 "], user_name = [" + user_name +
                 "], user_password_env_input = [" + user_password_env_input +
                 "], user_password = [" + user_password + "]")
    return None


@view_metric_exception.labels(page='login').count_exceptions()
@view_metric_page_visit.labels(page=f'login').time()
def login():
    logger.info("GALITU: Login view")
    file_path = os.getcwd()
    with open(file_path + '/app/views/version.txt', 'r') as file:
        version_number = file.read().replace('\n', '')
    logger.info(f"GALITU - kandula version {version_number}")
    view_metric_version_info.info({'version': version_number, 'purpose': 'Final project of opsschool devops course'})

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

        user_login_name = is_login_succeded()
        if user_login_name != None:
            logger.info(
                f"!!!=== GALITU - login(7) , return OK {user_login_name}")
            session['user_name'] = user_login_name
            view_metric_login.labels(user=user_login_name, result='ok').inc()
            return redirect(url_for('home'))
        else:
            view_metric_login.labels(user=loggedin_user, result='fail').inc()
            logger.error(
                f"!!!=== GALITU - login(8) , return FAILED ")
            return redirect(url_for('login'))
    return render_template('login.html', title='Login to Kandula', version_docker=version_number)


@view_metric_exception.labels(page='logout').count_exceptions()
@view_metric_page_visit.labels(page=f'logout').time()
def logout():
    view_metric_logout.labels(user=loggedin_user).inc()
    file_path = os.getcwd()
    with open(file_path + '/app/views/version.txt', 'r') as file:
        version_number = file.read().replace('\n', '')
    if request.method == 'POST':
        session.pop('user_name', None)

    session.clear()

    return render_template('logout.html', title='Logout to Kandula', version_docker=version_number)


@view_metric_exception.labels(page='home').count_exceptions()
@view_metric_page_visit.labels(page=f'home').time()
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


@view_metric_exception.labels(page='about').count_exceptions()
@view_metric_page_visit.labels(page=f'about').time()
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


@view_metric_exception.labels(page='health').count_exceptions()
@view_metric_page_visit.labels(page=f'health').time()
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


def cron_update_metrics(instance_data: InstanceData = Provide[Container.instance_data]):
    logger.info("GALITU - cron_update_metrics(), cron start instance update action")
    instances_response = instance_data.get_instances()
    view_metric_instances_gauge.labels(state='stopped').set(0)
    view_metric_instances_gauge.labels(state='stopping').set(0)
    view_metric_instances_gauge.labels(state='terminated').set(0)
    view_metric_instances_gauge.labels(state='shutting-down').set(0)
    view_metric_instances_gauge.labels(state='running').set(0)
    view_metric_instances_gauge.labels(state='pending').set(0)
    
    for ins in instances_response['Instances']:
        view_metric_instances_gauge.labels(state=ins['State']).inc()
    view_metric_instances_gauge.labels(state='any').set(len(instances_response['Instances']))

    return instances_response


@view_metric_exception.labels(page='metrics').count_exceptions()
@view_metric_page_visit.labels(page=f'metrics').time()
def metrics():
    '''
    try:
        if not session or not session['user_name']:
            return redirect(url_for('login'))
        logger.info("GALITU - metrics() , user session = " +
                    session['user_name'])
    except:
        return redirect(url_for('login'))
    '''
    return generate_latest()
    #return render_template('metrics.html', title='metrics', )


@inject
@view_metric_exception.labels(page='raw_instances').count_exceptions()
@view_metric_page_visit.labels(page=f'raw_instances').time()
def raw_instances(instance_data: InstanceData = Provide[Container.instance_data]):
    if request.method == 'POST':
        user_login_name = is_login_succeded()
        if user_login_name:
            logger.info(f"!!!=== GALITU - raw_instances(), will return data for user {user_login_name}")
            return instance_data.get_instances()
        else:
            return 403
    #else:
        # For debug only
        #return instance_data.get_instances()


@inject
@view_metric_exception.labels(page='instances').count_exceptions()
@view_metric_page_visit.labels(page=f'instances').time()
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

@view_metric_exception.labels(page='scheduler').count_exceptions()
@view_metric_page_visit.labels(page=f'scheduler').time()
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
